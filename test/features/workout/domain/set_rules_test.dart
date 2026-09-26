import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/workout/domain/set_rules.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSet _set({
  double? kg,
  int? reps,
  int? seconds,
  double? plannedKg,
  int? plannedReps,
  int? plannedSeconds,
}) => WorkoutSet(
  id: 'id',
  workoutExerciseId: 'we',
  position: 0,
  setType: SetType.normal,
  weightKg: kg,
  reps: reps,
  durationSeconds: seconds,
  plannedWeightKg: plannedKg,
  plannedReps: plannedReps,
  plannedDurationSeconds: plannedSeconds,
);

void main() {
  group('placeholdersOf (RG-11)', () {
    final previous = _set(kg: 80, reps: 8, seconds: 45);

    test('valeur prévue par le modèle, sinon « Précédent »', () {
      final set = _set(plannedKg: 85, plannedSeconds: 60);

      final placeholders = placeholdersOf(set, previous);

      expect(placeholders.weightKg, 85); // modèle
      expect(placeholders.reps, 8); // pas prévu → Précédent
      expect(placeholders.durationSeconds, 60);
    });

    test('ni modèle ni « Précédent » : pas de placeholder', () {
      final placeholders = placeholdersOf(_set(), null);
      expect(placeholders.weightKg, isNull);
      expect(placeholders.reps, isNull);
      expect(placeholders.durationSeconds, isNull);
    });
  });
}
