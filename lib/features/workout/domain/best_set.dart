import '../../../core/database/app_database.dart';
import '../../exercises/domain/exercise_enums.dart';
import 'set_type.dart';

/// 1RM estimé (formule d'Epley) : la charge qu'on pourrait soulever une fois.
/// Permet de comparer « 100 kg × 5 » et « 90 kg × 10 ».
double estimatedOneRepMax(double kg, int reps) {
  if (reps <= 0) return 0;
  if (reps == 1) return kg;
  return kg * (1 + reps / 30);
}

/// Position de la meilleure série d'une liste (RG-13), `null` s'il n'y en a
/// aucune. Les échauffements ne comptent pas ; en cas d'égalité, la première
/// l'emporte.
int? bestSetIndex(List<WorkoutSet> sets, TrackingType trackingType) {
  int? bestIndex;
  var bestScore = 0.0;
  for (final (index, set) in sets.indexed) {
    if (set.setType == SetType.warmup) continue;
    final score = switch (trackingType) {
      TrackingType.weightReps => estimatedOneRepMax(
        set.weightKg ?? 0,
        set.reps ?? 0,
      ),
      TrackingType.reps => (set.reps ?? 0).toDouble(),
      TrackingType.duration => (set.durationSeconds ?? 0).toDouble(),
    };
    if (score > bestScore) {
      bestIndex = index;
      bestScore = score;
    }
  }
  return bestIndex;
}
