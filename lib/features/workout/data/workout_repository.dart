import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/set_rules.dart';
import '../domain/workout_details.dart';

// Les écrans qui utilisent le repository ont aussi besoin de ces modèles.
export '../domain/workout_details.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(appDatabaseProvider)),
);

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

  /// Comme [watchActiveWorkout], en une seule lecture.
  Future<Workout?> getActiveWorkout() {
    return (_db.select(_db.workouts)
          ..where((w) => w.endedAt.isNull() & w.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Une séance avec ses exercices et ses séries, mis à jour en direct.
  Stream<WorkoutDetails?> watchWorkoutDetails(String workoutId) =>
      _detailsQuery(workoutId).watch().map(_toDetails);

  /// Comme [watchWorkoutDetails], en une seule lecture.
  Future<WorkoutDetails?> getWorkoutDetails(String workoutId) async =>
      _toDetails(await _detailsQuery(workoutId).get());

  // Jointures « externes » : la séance est renvoyée même sans exercice, et un
  // exercice même sans série. Une ligne SQL par série.
  JoinedSelectStatement<HasResultSet, dynamic> _detailsQuery(String workoutId) {
    final workout = _db.workouts;
    final entry = _db.workoutExercises;
    final set = _db.workoutSets;
    return _db.select(workout).join([
        leftOuterJoin(entry, entry.workoutId.equalsExp(workout.id)),
        leftOuterJoin(
          _db.exercises,
          _db.exercises.id.equalsExp(entry.exerciseId),
        ),
        leftOuterJoin(set, set.workoutExerciseId.equalsExp(entry.id)),
      ])
      ..where(workout.id.equals(workoutId))
      ..orderBy([
        OrderingTerm.asc(entry.position),
        OrderingTerm.asc(set.position),
      ]);
  }

  WorkoutDetails? _toDetails(List<TypedResult> rows) {
    if (rows.isEmpty) return null;
    final details = WorkoutDetails(rows.first.readTable(_db.workouts));
    final byEntry = <String, WorkoutExerciseDetails>{};
    for (final row in rows) {
      final entry = row.readTableOrNull(_db.workoutExercises);
      if (entry == null) continue;
      final item = byEntry.putIfAbsent(
        entry.id,
        () => WorkoutExerciseDetails(
          entry: entry,
          exercise: row.readTable(_db.exercises),
        ),
      );
      final set = row.readTableOrNull(_db.workoutSets);
      if (set != null) item.sets.add(set);
    }
    details.exercises.addAll(byEntry.values);
    return details;
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
  /// avec au moins une série validée de cet exercice. Avec [startedBefore],
  /// seules les séances commencées avant cette date comptent : c'est ce qui
  /// permet au résumé de comparer une séance à la précédente (WO-18).
  Future<List<WorkoutSet>> previousSets(
    String exerciseId, {
    DateTime? startedBefore,
  }) async {
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
                    (startedBefore == null
                        ? const Constant(true)
                        : workout.startedAt.isSmallerThanValue(startedBefore)) &
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

  /// Démarre une séance depuis un modèle (WO-01, TP-05) : elle prend son nom
  /// et reçoit ses exercices et ses séries, avec leur temps de repos et leurs
  /// valeurs prévues (placeholders, RG-11).
  ///
  /// Échoue si une séance est déjà en cours (WO-02, garanti par la base).
  Future<Workout> startWorkout(String templateId) {
    return _db.transaction(() async {
      final template = await (_db.select(
        _db.templates,
      )..where((t) => t.id.equals(templateId))).getSingle();
      final workout = await _db
          .into(_db.workouts)
          .insertReturning(
            WorkoutsCompanion.insert(
              name: template.name,
              templateId: Value(templateId),
            ),
          );

      final entries =
          await (_db.select(_db.templateExercises)
                ..where((e) => e.templateId.equals(templateId))
                ..orderBy([(e) => OrderingTerm.asc(e.position)]))
              .get();
      for (final (position, templateEntry) in entries.indexed) {
        final entry = await _db
            .into(_db.workoutExercises)
            .insertReturning(
              WorkoutExercisesCompanion.insert(
                workoutId: workout.id,
                exerciseId: templateEntry.exerciseId,
                position: position,
              ),
            );
        final sets =
            await (_db.select(_db.templateSets)
                  ..where((s) => s.templateExerciseId.equals(templateEntry.id))
                  ..orderBy([(s) => OrderingTerm.asc(s.position)]))
                .get();
        for (final (setPosition, set) in sets.indexed) {
          await _db
              .into(_db.workoutSets)
              .insert(
                WorkoutSetsCompanion.insert(
                  workoutExerciseId: entry.id,
                  position: setPosition,
                  restSeconds: Value(set.restSeconds),
                  plannedWeightKg: Value(set.weightKg),
                  plannedReps: Value(set.reps),
                  plannedDurationSeconds: Value(set.durationSeconds),
                ),
              );
        }
      }
      return workout;
    });
  }

  /// Renomme la séance (WO-01).
  Future<void> renameWorkout(String workoutId, String name) {
    return (_db.update(
      _db.workouts,
    )..where((w) => w.id.equals(workoutId))).write(
      WorkoutsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(clock.now()),
      ),
    );
  }

  /// Termine la séance (WO-17) : avec [validateReadySets], valide d'abord les
  /// séries non validées dont toutes les valeurs sont saisies (« Tout
  /// valider »). Supprime ensuite les séries non validées restantes, puis les
  /// exercices restés vides, et enregistre l'heure de fin.
  ///
  /// Lève [NoCompletedSetException] s'il n'y a aucune série validée (RG-08).
  Future<void> finishWorkout(
    String workoutId, {
    bool validateReadySets = false,
  }) {
    return _db.transaction(() async {
      if (validateReadySets) {
        final details = await getWorkoutDetails(workoutId);
        final now = clock.now();
        for (final item in details?.exercises ?? <WorkoutExerciseDetails>[]) {
          for (final set in item.sets) {
            if (set.completedAt == null &&
                isSetReady(set, item.exercise.trackingType)) {
              await (_db.update(_db.workoutSets)
                    ..where((s) => s.id.equals(set.id)))
                  .write(WorkoutSetsCompanion(completedAt: Value(now)));
            }
          }
        }
      }

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

  /// Supprime une séance terminée (WO-23). Suppression douce (RG-10) : elle
  /// reste en base, mais toutes les lectures l'ignorent (stats, historique,
  /// « Précédent », dernière utilisation du modèle).
  Future<void> deleteWorkout(String workoutId) {
    final now = clock.now();
    return (_db.update(_db.workouts)..where((w) => w.id.equals(workoutId)))
        .write(WorkoutsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  /// Annule [deleteWorkout] : la séance réapparaît partout.
  Future<void> restoreWorkout(String workoutId) {
    return (_db.update(
      _db.workouts,
    )..where((w) => w.id.equals(workoutId))).write(
      WorkoutsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(clock.now()),
      ),
    );
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

  /// Temps de repos propre à une série (RT-07) ; `null` = valeur par défaut
  /// (RG-09), 0 = pas de minuteur.
  Future<void> setSetRest(String setId, int? seconds) async {
    await (_db.update(_db.workoutSets)..where((s) => s.id.equals(setId))).write(
      WorkoutSetsCompanion(restSeconds: Value(seconds)),
    );
    await _touchWorkoutOfSet(setId);
  }

  /// Même temps de repos pour toutes les séries d'un exercice (RT-07).
  Future<void> setExerciseRest(String workoutExerciseId, int? seconds) async {
    await (_db.update(_db.workoutSets)
          ..where((s) => s.workoutExerciseId.equals(workoutExerciseId)))
        .write(WorkoutSetsCompanion(restSeconds: Value(seconds)));
    await _touchWorkoutOfEntry(workoutExerciseId);
  }

  /// Supprime une série (WO-11). Les numéros des suivantes se décalent tout
  /// seuls, car ils sont calculés à l'affichage (RG-02).
  Future<void> deleteSet(String setId) async {
    // Horodatage avant la suppression : ensuite, la série n'existe plus.
    await _touchWorkoutOfSet(setId);
    await (_db.delete(_db.workoutSets)..where((s) => s.id.equals(setId))).go();
  }

  /// Réordonne les exercices de la séance (WO-15) : [entryIds] donne les
  /// lignes de workout_exercises dans le nouvel ordre.
  Future<void> reorderExercises(String workoutId, List<String> entryIds) {
    return _db.transaction(() async {
      for (final (position, id) in entryIds.indexed) {
        await (_db.update(_db.workoutExercises)..where((e) => e.id.equals(id)))
            .write(WorkoutExercisesCompanion(position: Value(position)));
      }
      await _touchWorkout(workoutId);
    });
  }

  /// Retire un exercice de la séance, avec ses séries (WO-13).
  Future<void> removeExercise(String workoutExerciseId) async {
    await _touchWorkoutOfEntry(workoutExerciseId);
    await (_db.delete(
      _db.workoutExercises,
    )..where((e) => e.id.equals(workoutExerciseId))).go();
  }

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
