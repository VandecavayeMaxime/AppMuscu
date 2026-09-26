import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/workout/domain/best_set.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSet _set({
  double? kg,
  int? reps,
  int? seconds,
  SetType type = SetType.normal,
}) {
  return WorkoutSet(
    id: 'id',
    workoutExerciseId: 'we',
    position: 0,
    setType: type,
    weightKg: kg,
    reps: reps,
    durationSeconds: seconds,
  );
}

void main() {
  group('estimatedOneRepMax (Epley)', () {
    test('1 rep = la charge elle-même', () {
      expect(estimatedOneRepMax(100, 1), 100);
    });

    test('plusieurs reps : charge × (1 + reps / 30)', () {
      expect(estimatedOneRepMax(90, 10), closeTo(120, 0.001));
    });

    test('0 rep = 0', () {
      expect(estimatedOneRepMax(100, 0), 0);
    });
  });

  group('bestSetIndex (RG-13)', () {
    test('poids + reps : la série au 1RM estimé le plus élevé', () {
      final sets = [_set(kg: 100, reps: 5), _set(kg: 90, reps: 10)];

      // 100 × 5 → 116,7 ; 90 × 10 → 120
      expect(bestSetIndex(sets, TrackingType.weightReps), 1);
    });

    test('ignore les échauffements', () {
      final sets = [
        _set(kg: 200, reps: 5, type: SetType.warmup),
        _set(kg: 80, reps: 8),
      ];

      expect(bestSetIndex(sets, TrackingType.weightReps), 1);
    });

    test('reps seules : le plus de reps', () {
      final sets = [_set(reps: 8), _set(reps: 12), _set(reps: 10)];

      expect(bestSetIndex(sets, TrackingType.reps), 1);
    });

    test('durée : la plus longue', () {
      final sets = [_set(seconds: 60), _set(seconds: 45)];

      expect(bestSetIndex(sets, TrackingType.duration), 0);
    });

    test('en cas d’égalité, la première l’emporte', () {
      final sets = [_set(kg: 80, reps: 8), _set(kg: 80, reps: 8)];

      expect(bestSetIndex(sets, TrackingType.weightReps), 0);
    });

    test('aucune série comptable → null', () {
      expect(bestSetIndex([], TrackingType.weightReps), isNull);
      expect(
        bestSetIndex([
          _set(kg: 40, reps: 10, type: SetType.warmup),
        ], TrackingType.weightReps),
        isNull,
      );
    });
  });
}
