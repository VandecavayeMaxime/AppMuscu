import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../domain/weekly_sessions.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(appDatabaseProvider)),
);

/// Ce qu'il faut savoir d'une série validée pour la carte des muscles
/// (SA-04) : la date de sa séance (pour filtrer par période) et les muscles
/// travaillés par son exercice (RG-17).
typedef MuscleUsage = ({
  DateTime workoutStartedAt,
  BodyPart main,
  List<BodyPart> secondary,
});

/// Lectures de l'onglet Stats (docs/SPEC.md §5.6). Rien n'y est modifié.
class StatsRepository {
  StatsRepository(this._db);

  final AppDatabase _db;

  /// Séances terminées et non supprimées, de la plus ancienne à la plus
  /// récente (SA-02).
  Stream<List<SessionEntry>> watchFinishedSessions() {
    final query = _db.select(_db.workouts)
      ..where((w) => w.endedAt.isNotNull() & w.deletedAt.isNull())
      ..orderBy([(w) => OrderingTerm.asc(w.startedAt)]);
    return query.watch().map(
      (workouts) => [
        for (final workout in workouts)
          SessionEntry(
            id: workout.id,
            name: workout.name,
            templateId: workout.templateId,
            startedAt: workout.startedAt,
            endedAt: workout.endedAt!,
          ),
      ],
    );
  }

  /// Tous les modèles, supprimés compris, dans l'ordre qui fixe leur couleur
  /// (RG-16) : les actifs dans l'ordre de l'onglet Séance, puis les
  /// supprimés.
  Stream<List<Template>> watchTemplatesByColor() {
    final query = _db.select(_db.templates)
      ..orderBy([
        // `deleted_at IS NULL` vaut 1 pour un modèle actif : en ordre
        // décroissant, les actifs passent devant.
        (t) => OrderingTerm.desc(t.deletedAt.isNull()),
        (t) => OrderingTerm.asc(t.position),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Une entrée par série validée d'une séance terminée (SA-04, RG-17), sur
  /// tout l'historique : la période se filtre côté écran, pour changer sans
  /// relire la base.
  Stream<List<MuscleUsage>> watchMuscleUsage() {
    final set = _db.workoutSets;
    final entry = _db.workoutExercises;
    final workout = _db.workouts;
    final exercise = _db.exercises;

    final query =
        _db.select(set).join([
          innerJoin(entry, entry.id.equalsExp(set.workoutExerciseId)),
          innerJoin(workout, workout.id.equalsExp(entry.workoutId)),
          innerJoin(exercise, exercise.id.equalsExp(entry.exerciseId)),
        ])..where(
          set.completedAt.isNotNull() &
              workout.endedAt.isNotNull() &
              workout.deletedAt.isNull(),
        );

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            workoutStartedAt: row.readTable(workout).startedAt,
            main: row.readTable(exercise).bodyPart,
            secondary: row.readTable(exercise).secondaryMuscles,
          ),
      ],
    );
  }
}
