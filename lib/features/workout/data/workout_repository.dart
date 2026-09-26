import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Accès aux séances (docs/SPEC.md §5.2). Complété au jalon M3.
class WorkoutRepository {
  WorkoutRepository(this._db);

  final AppDatabase _db;

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
