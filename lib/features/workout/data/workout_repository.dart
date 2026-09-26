import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

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

/// Accès aux séances (docs/SPEC.md §5.2). Complété au jalon M3.
class WorkoutRepository {
  WorkoutRepository(this._db);

  final AppDatabase _db;

  /// Historique d'un exercice (EX-07) : un élément par séance terminée où il
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
}
