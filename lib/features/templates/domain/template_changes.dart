import '../../exercises/domain/exercise_enums.dart';
import '../../workout/domain/workout_details.dart';
import 'template_details.dart';

/// La séance terminée diffère-t-elle du modèle dont elle est issue (TP-07) ?
///
/// On compare les séries validées de la séance aux séries prévues : ordre
/// des exercices, nombre de séries, valeurs (selon le type de suivi) et
/// temps de repos. Une valeur prévue vide compte comme différente d'une
/// valeur réalisée.
bool workoutDiffersFromTemplate(
  WorkoutDetails workout,
  TemplateDetails template,
) {
  final done = [
    for (final item in workout.exercises)
      (
        item: item,
        sets: [
          for (final set in item.sets)
            if (set.completedAt != null) set,
        ],
      ),
  ].where((entry) => entry.sets.isNotEmpty).toList();

  if (done.length != template.exercises.length) return true;

  for (final (index, entry) in done.indexed) {
    final planned = template.exercises[index];
    if (entry.item.exercise.id != planned.exercise.id) return true;
    if (entry.sets.length != planned.sets.length) return true;

    final type = entry.item.exercise.trackingType;
    for (final (setIndex, set) in entry.sets.indexed) {
      final plannedSet = planned.sets[setIndex];
      final sameValues = switch (type) {
        TrackingType.weightReps =>
          _sameWeight(set.weightKg, plannedSet.weightKg) &&
              set.reps == plannedSet.reps,
        TrackingType.reps => set.reps == plannedSet.reps,
        TrackingType.duration =>
          set.durationSeconds == plannedSet.durationSeconds,
      };
      if (!sameValues || set.restSeconds != plannedSet.restSeconds) {
        return true;
      }
    }
  }
  return false;
}

/// Les poids sont des nombres à virgule : on tolère une infime différence
/// (conversion lb → kg).
bool _sameWeight(double? a, double? b) {
  if (a == null || b == null) return a == b;
  return (a - b).abs() < 1e-6;
}
