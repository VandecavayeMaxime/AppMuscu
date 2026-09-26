import '../../../core/database/app_database.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../data/workout_repository.dart';
import 'set_type.dart';

/// Volume d'une série en kg (RG-01) : kg × reps si elle est validée, de type
/// poids + reps, et pas un échauffement ; 0 sinon.
double setVolumeKg(WorkoutSet set, TrackingType trackingType) {
  if (set.completedAt == null ||
      trackingType != TrackingType.weightReps ||
      set.setType == SetType.warmup) {
    return 0;
  }
  return (set.weightKg ?? 0) * (set.reps ?? 0);
}

/// Chiffres du résumé de fin de séance (WO-18).
class WorkoutSummary {
  WorkoutSummary._({
    required this.duration,
    required this.exerciseCount,
    required this.setCount,
    required this.volumeKg,
  });

  /// Calculé sur les séries validées uniquement.
  factory WorkoutSummary.of(WorkoutDetails details) {
    final workout = details.workout;
    var setCount = 0;
    var volume = 0.0;
    for (final item in details.exercises) {
      for (final set in item.sets) {
        if (set.completedAt == null) continue;
        setCount++;
        volume += setVolumeKg(set, item.exercise.trackingType);
      }
    }
    return WorkoutSummary._(
      duration: (workout.endedAt ?? workout.startedAt).difference(
        workout.startedAt,
      ),
      exerciseCount: details.exercises
          .where((item) => item.sets.any((s) => s.completedAt != null))
          .length,
      setCount: setCount,
      volumeKg: volume,
    );
  }

  final Duration duration;
  final int exerciseCount;
  final int setCount;
  final double volumeKg;
}
