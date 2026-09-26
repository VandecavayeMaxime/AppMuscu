import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/workout/domain/exercise_comparison.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSet _set({double? kg, int? reps, int? seconds, bool done = true}) {
  return WorkoutSet(
    id: 'id',
    workoutExerciseId: 'we',
    position: 0,
    setType: SetType.normal,
    weightKg: kg,
    reps: reps,
    durationSeconds: seconds,
    completedAt: done ? DateTime(2026) : null,
  );
}

void main() {
  test('trendOf', () {
    expect(trendOf(10, 5), Trend.up);
    expect(trendOf(5, 10), Trend.down);
    expect(trendOf(5, 5), Trend.same);
    expect(trendOf(5.0000001, 5), Trend.same);
  });

  test('exerciseTotal : volume, reps ou durée selon le type, séries validées '
      'uniquement', () {
    final sets = [_set(kg: 100, reps: 5), _set(kg: 100, reps: 4, done: false)];
    expect(exerciseTotal(sets, TrackingType.weightReps), 500);
    expect(
      exerciseTotal([_set(reps: 10), _set(reps: 8)], TrackingType.reps),
      18,
    );
    expect(
      exerciseTotal([
        _set(seconds: 60),
        _set(seconds: 45),
      ], TrackingType.duration),
      105,
    );
  });

  group('compareWithPrevious', () {
    test('compare le total et la meilleure série', () {
      final comparison = compareWithPrevious(
        [_set(kg: 100, reps: 5), _set(kg: 100, reps: 4)],
        [_set(kg: 95, reps: 5), _set(kg: 95, reps: 5)],
        TrackingType.weightReps,
      )!;

      expect(comparison.total, 900);
      expect(comparison.previousTotal, 950);
      expect(comparison.totalDelta, -50);
      expect(comparison.totalTrend, Trend.down);
      expect(comparison.best.weightKg, 100);
      expect(comparison.previousBest.weightKg, 95);
      expect(comparison.bestTrend, Trend.up);
    });

    test('première fois : pas de comparaison', () {
      expect(
        compareWithPrevious([_set(reps: 10)], [], TrackingType.reps),
        isNull,
      );
    });
  });
}
