import '../../../core/database/app_database.dart';
import '../../exercises/domain/exercise_enums.dart';
import 'best_set.dart';
import 'workout_summary.dart';

/// Évolution d'une valeur par rapport à la dernière fois.
enum Trend { up, down, same }

Trend trendOf(double current, double previous) {
  const tolerance = 0.001; // évite les faux écarts dus aux arrondis
  if (current > previous + tolerance) return Trend.up;
  if (current < previous - tolerance) return Trend.down;
  return Trend.same;
}

/// Total d'un exercice sur une séance, séries validées uniquement : volume en
/// kg (poids + reps, RG-01), nombre de reps (reps seules) ou durée en
/// secondes (durée).
double exerciseTotal(List<WorkoutSet> sets, TrackingType trackingType) {
  var total = 0.0;
  for (final set in sets) {
    if (set.completedAt == null) continue;
    total += switch (trackingType) {
      TrackingType.weightReps => setVolumeKg(set, trackingType),
      TrackingType.reps => (set.reps ?? 0).toDouble(),
      TrackingType.duration => (set.durationSeconds ?? 0).toDouble(),
    };
  }
  return total;
}

/// Un exercice de la séance comparé à sa séance précédente (WO-18).
class ExerciseComparison {
  ExerciseComparison({
    required this.trackingType,
    required this.total,
    required this.previousTotal,
    required this.best,
    required this.previousBest,
  });

  final TrackingType trackingType;
  final double total;
  final double previousTotal;
  final WorkoutSet best;
  final WorkoutSet previousBest;

  double get totalDelta => total - previousTotal;
  Trend get totalTrend => trendOf(total, previousTotal);
  Trend get bestTrend => trendOf(
    setScore(best, trackingType),
    setScore(previousBest, trackingType),
  );
}

/// Compare les séries d'un exercice à celles de la dernière fois ; `null` si
/// l'exercice n'avait jamais été fait (ou s'il manque des séries).
ExerciseComparison? compareWithPrevious(
  List<WorkoutSet> current,
  List<WorkoutSet> previous,
  TrackingType trackingType,
) {
  final best = bestSetIndex(current, trackingType);
  final previousBest = bestSetIndex(previous, trackingType);
  if (best == null || previousBest == null) return null;
  return ExerciseComparison(
    trackingType: trackingType,
    total: exerciseTotal(current, trackingType),
    previousTotal: exerciseTotal(previous, trackingType),
    best: current[best],
    previousBest: previous[previousBest],
  );
}
