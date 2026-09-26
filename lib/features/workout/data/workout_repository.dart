import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/workout_naming.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(appDatabaseProvider)),
);

/// Une séance où un exercice a été fait (onglet Historique de la fiche, EX-07).
class ExerciseSession {
  ExerciseSession({required this.workoutName, required this.date});

  final String workoutName;
  final DateTime date;

  /// Séries validées de l'exercice dans cette séance, dans l'ordre.
  final List<WorkoutSet> sets = [];
}

/// Une séance avec tout son contenu, pour l'écran « Séance en cours ».
class WorkoutDetails {
  WorkoutDetails(this.workout);

  final Workout workout;

  /// Exercices de la séance, dans l'ordre.
  final List<WorkoutExerciseDetails> exercises = [];
}

/// Un exercice dans une séance, avec ses séries.
class WorkoutExerciseDetails {
  WorkoutExerciseDetails({required this.entry, required this.exercise});

  /// La ligne de la table workout_exercises (position, notes…).
  final WorkoutExercise entry;

  /// L'exercice de la bibliothèque (nom, type de suivi, unité…).
  final Exercise exercise;

  /// Séries, dans l'ordre.
  final List<WorkoutSet> sets = [];
}

/// Terminer une séance sans aucune série validée est interdit (RG-08).
class NoCompletedSetException implements Exception {
  @override
  String toString() => 'Aucune série validée dans la séance.';
}

/// Accès aux séances (docs/SPEC.md §5.2).
///
/// Chaque modification est écrite immédiatement (WO-21) et met à jour
/// `updated_at` de la séance, pour la future sync.
class WorkoutRepository {
  WorkoutRepository(this._db);

  final AppDatabase _db;

  // ─── Lecture ───────────────────────────────────────────────────────────────

  /// La séance en cours, ou `null` s'il n'y en a pas (WO-02 : au plus une).
  Stream<Workout?> watchActiveWorkout() {
    return (_db.select(_db.workouts)
          ..where((w) => w.endedAt.isNull() & w.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  /// Une séance avec ses exercices et ses séries, mis à jour en direct.
  Stream<WorkoutDetails?> watchWorkoutDetails(String workoutId) {
    final workout = _db.workouts;
    final entry = _db.workoutExercises;
    final exercise = _db.exercises;
    final set = _db.workoutSets;

    // Jointures « externes » : la séance est renvoyée même sans exercice,
    // et un exercice même sans série.
    final query =
        _db.select(workout).join([
            leftOuterJoin(entry, entry.workoutId.equalsExp(workout.id)),
            leftOuterJoin(exercise, exercise.id.equalsExp(entry.exerciseId)),
            leftOuterJoin(set, set.workoutExerciseId.equalsExp(entry.id)),
          ])
          ..where(workout.id.equals(workoutId))
          ..orderBy([
            OrderingTerm.asc(entry.position),
            OrderingTerm.asc(set.position),
          ]);

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final details = WorkoutDetails(rows.first.readTable(workout));
      final byEntry = <String, WorkoutExerciseDetails>{};
      for (final row in rows) {
        final currentEntry = row.readTableOrNull(entry);
        if (currentEntry == null) continue;
        final item = byEntry.putIfAbsent(
          currentEntry.id,
          () => WorkoutExerciseDetails(
            entry: currentEntry,
            exercise: row.readTable(exercise),
          ),
        );
        final currentSet = row.readTableOrNull(set);
        if (currentSet != null) item.sets.add(currentSet);
      }
      details.exercises.addAll(byEntry.values);
      return details;
    });
  }

  /// Historique d'un exercice (EX-10) : un élément par séance terminée où il
  /// a au moins une série validée, de la plus récente à la plus ancienne.
  Stream<List<ExerciseSession>> watchExerciseHistory(String exerciseId) {
    final exercise = _db.workoutExercises;
    final workout = _db.workouts;
    final set = _db.workoutSets;

    final query =
        _db.select(set).join([
            innerJoin(exercise, exercise.id.equalsExp(set.workoutExerciseId)),
            innerJoin(workout, workout.id.equalsExp(exercise.workoutId)),
          ])
          ..where(
            exercise.exerciseId.equals(exerciseId) &
                set.completedAt.isNotNull() &
                workout.endedAt.isNotNull() &
                workout.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.desc(workout.startedAt),
            OrderingTerm.asc(exercise.position),
            OrderingTerm.asc(set.position),
          ]);

    // Une ligne SQL par série : on les regroupe par séance, dans l'ordre.
    return query.watch().map((rows) {
      final sessions = <String, ExerciseSession>{};
      for (final row in rows) {
        final occurrence = row.readTable(exercise);
        final parent = row.readTable(workout);
        sessions
            .putIfAbsent(
              occurrence.id,
              () => ExerciseSession(
                workoutName: parent.name,
                date: parent.startedAt,
              ),
            )
            .sets
            .add(row.readTable(set));
      }
      return sessions.values.toList();
    });
  }

  /// Séries validées de l'exercice lors de sa séance de référence, dans
  /// l'ordre : la k-ième alimente la colonne « Précédent » de la ligne k
  /// (RG-03, WO-06). Liste vide si l'exercice n'a jamais été fait.
  ///
  /// Séance de référence (RG-04) : la plus récente, terminée, non supprimée,
  /// avec au moins une série validée de cet exercice.
  Future<List<WorkoutSet>> previousSets(String exerciseId) async {
    final exercise = _db.workoutExercises;
    final workout = _db.workouts;
    final set = _db.workoutSets;

    final hasCompletedSet = existsQuery(
      _db.select(set)..where(
        (s) =>
            s.workoutExerciseId.equalsExp(exercise.id) &
            s.completedAt.isNotNull(),
      ),
    );

    final reference =
        await (_db.select(exercise).join([
                innerJoin(workout, workout.id.equalsExp(exercise.workoutId)),
              ])
              ..where(
                exercise.exerciseId.equals(exerciseId) &
                    workout.endedAt.isNotNull() &
                    workout.deletedAt.isNull() &
                    hasCompletedSet,
              )
              ..orderBy([
                OrderingTerm.desc(workout.startedAt),
                OrderingTerm.asc(exercise.position),
              ])
              ..limit(1))
            .map((row) => row.readTable(exercise))
            .getSingleOrNull();

    if (reference == null) return [];

    return (_db.select(set)
          ..where(
            (s) =>
                s.workoutExerciseId.equals(reference.id) &
                s.completedAt.isNotNull(),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.position)]))
        .get();
  }

  // ─── Séance ────────────────────────────────────────────────────────────────

  /// Démarre une séance vide (WO-01), nommée selon l'heure (RG-05).
  /// Échoue si une séance est déjà en cours (WO-02, garanti par la base).
  Future<Workout> startWorkout() {
    return _db
        .into(_db.workouts)
        .insertReturning(
          WorkoutsCompanion.insert(name: defaultWorkoutName(clock.now())),
        );
  }

  /// Termine la séance : supprime les séries non validées, puis les
  /// exercices restés vides, et enregistre l'heure de fin.
  ///
  /// Lève [NoCompletedSetException] s'il n'y a aucune série validée (RG-08).
  /// (Version simple ; le choix « Tout valider / Supprimer » arrive au M3b, WO-17.)
  Future<void> finishWorkout(String workoutId) {
    return _db.transaction(() async {
      final entryIds = _db.selectOnly(_db.workoutExercises)
        ..addColumns([_db.workoutExercises.id])
        ..where(_db.workoutExercises.workoutId.equals(workoutId));

      final completed = countAll();
      final completedCount =
          await (_db.selectOnly(_db.workoutSets)
                ..addColumns([completed])
                ..where(
                  _db.workoutSets.workoutExerciseId.isInQuery(entryIds) &
                      _db.workoutSets.completedAt.isNotNull(),
                ))
              .map((row) => row.read(completed)!)
              .getSingle();
      if (completedCount == 0) throw NoCompletedSetException();

      await (_db.delete(_db.workoutSets)..where(
            (s) =>
                s.workoutExerciseId.isInQuery(entryIds) &
                s.completedAt.isNull(),
          ))
          .go();
      await (_db.delete(_db.workoutExercises)..where(
            (e) =>
                e.workoutId.equals(workoutId) &
                notExistsQuery(
                  _db.select(_db.workoutSets)
                    ..where((s) => s.workoutExerciseId.equalsExp(e.id)),
                ),
          ))
          .go();

      final now = clock.now();
      await (_db.update(_db.workouts)..where((w) => w.id.equals(workoutId)))
          .write(WorkoutsCompanion(endedAt: Value(now), updatedAt: Value(now)));
    });
  }

  /// Abandonne la séance (WO-19) : elle est effacée pour de bon, avec ses
  /// exercices et ses séries (RG-10).
  Future<void> discardWorkout(String workoutId) {
    return (_db.delete(
      _db.workouts,
    )..where((w) => w.id.equals(workoutId))).go();
  }

  // ─── Exercices et séries ───────────────────────────────────────────────────

  /// Ajoute des exercices à la fin de la séance, chacun avec une série vide
  /// (WO-04).
  Future<void> addExercises(String workoutId, List<String> exerciseIds) {
    return _db.transaction(() async {
      final maxPosition = _db.workoutExercises.position.max();
      final lastPosition =
          await (_db.selectOnly(_db.workoutExercises)
                ..addColumns([maxPosition])
                ..where(_db.workoutExercises.workoutId.equals(workoutId)))
              .map((row) => row.read(maxPosition))
              .getSingle();

      var position = (lastPosition ?? -1) + 1;
      for (final exerciseId in exerciseIds) {
        final entry = await _db
            .into(_db.workoutExercises)
            .insertReturning(
              WorkoutExercisesCompanion.insert(
                workoutId: workoutId,
                exerciseId: exerciseId,
                position: position++,
              ),
            );
        await _db
            .into(_db.workoutSets)
            .insert(
              WorkoutSetsCompanion.insert(
                workoutExerciseId: entry.id,
                position: 0,
              ),
            );
      }
      await _touchWorkout(workoutId);
    });
  }

  /// Ajoute une série vide à la fin de l'exercice (WO-10), avec le temps de
  /// repos propre de la série au-dessus (RG-12).
  Future<void> addSet(String workoutExerciseId) async {
    final last =
        await (_db.select(_db.workoutSets)
              ..where((s) => s.workoutExerciseId.equals(workoutExerciseId))
              ..orderBy([(s) => OrderingTerm.desc(s.position)])
              ..limit(1))
            .getSingleOrNull();
    await _db
        .into(_db.workoutSets)
        .insert(
          WorkoutSetsCompanion.insert(
            workoutExerciseId: workoutExerciseId,
            position: (last?.position ?? -1) + 1,
            restSeconds: Value(last?.restSeconds),
          ),
        );
    await _touchWorkoutOfEntry(workoutExerciseId);
  }

  /// Modifie une série. Seuls les champs passés sont modifiés : `Value(x)`
  /// enregistre x (`Value(null)` vide le champ), un champ omis reste tel quel.
  Future<void> updateSet(
    String setId, {
    Value<double?> weightKg = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) async {
    await (_db.update(_db.workoutSets)..where((s) => s.id.equals(setId))).write(
      WorkoutSetsCompanion(
        weightKg: weightKg,
        reps: reps,
        durationSeconds: durationSeconds,
        completedAt: completedAt,
      ),
    );
    await _touchWorkoutOfSet(setId);
  }

  /// Valide une série avec ses valeurs définitives (WO-08).
  Future<void> completeSet(
    String setId, {
    double? weightKg,
    int? reps,
    int? durationSeconds,
  }) {
    return updateSet(
      setId,
      weightKg: Value(weightKg),
      reps: Value(reps),
      durationSeconds: Value(durationSeconds),
      completedAt: Value(clock.now()),
    );
  }

  /// Dévalide une série (WO-09).
  Future<void> uncompleteSet(String setId) =>
      updateSet(setId, completedAt: const Value(null));

  // ─── Horodatage de la séance (sync future) ─────────────────────────────────

  Future<void> _touchWorkout(String workoutId) {
    return (_db.update(_db.workouts)..where((w) => w.id.equals(workoutId)))
        .write(WorkoutsCompanion(updatedAt: Value(clock.now())));
  }

  Future<void> _touchWorkoutOfEntry(String workoutExerciseId) {
    return _db.customUpdate(
      'UPDATE workouts SET updated_at = ? WHERE id = '
      '(SELECT workout_id FROM workout_exercises WHERE id = ?)',
      variables: [Variable(clock.now()), Variable(workoutExerciseId)],
      updates: {_db.workouts},
    );
  }

  Future<void> _touchWorkoutOfSet(String setId) {
    return _db.customUpdate(
      'UPDATE workouts SET updated_at = ? WHERE id = '
      '(SELECT e.workout_id FROM workout_exercises e '
      'JOIN workout_sets s ON s.workout_exercise_id = e.id WHERE s.id = ?)',
      variables: [Variable(clock.now()), Variable(setId)],
      updates: {_db.workouts},
    );
  }
}
