import '../../../core/database/app_database.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../exercises/domain/exercise_enums.dart';

/// Valeur d'une série telle qu'affichée : « 82,5 kg × 8 », « 12 reps », « 1:30 ».
String formatSetValue(
  WorkoutSet set,
  TrackingType trackingType,
  WeightUnit unit,
) {
  return switch (trackingType) {
    TrackingType.weightReps =>
      '${formatWeight(set.weightKg ?? 0, unit)} ${unit.label} × ${set.reps ?? 0}',
    TrackingType.reps => '${set.reps ?? 0} reps',
    TrackingType.duration => formatDuration(set.durationSeconds ?? 0),
  };
}
