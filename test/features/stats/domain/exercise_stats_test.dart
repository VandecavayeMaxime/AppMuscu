import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/stats/domain/exercise_stats.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:app_muscu/features/workout/domain/workout_details.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSet _set({
  double? kg,
  int? reps,
  int? seconds,
  SetType type = SetType.normal,
}) => WorkoutSet(
  id: 'id',
  workoutExerciseId: 'we',
  position: 0,
  setType: type,
  weightKg: kg,
  reps: reps,
  durationSeconds: seconds,
);

/// Une séance de l'historique, le [day] septembre 2026.
ExerciseSession _session(int day, List<WorkoutSet> sets) =>
    ExerciseSession(workoutName: 'Push', date: DateTime(2026, 9, day))
      ..sets.addAll(sets);

/// Historique d'un exercice poids + reps, du plus récent au plus ancien
/// (comme l'onglet « Historique »).
final _history = [
  _session(20, [_set(kg: 90, reps: 5), _set(kg: 85, reps: 8)]),
  _session(10, [_set(kg: 100, reps: 1), _set(kg: 80, reps: 8)]),
  _session(1, [_set(kg: 80, reps: 8), _set(kg: 95, reps: 3)]),
];

void main() {
  group('courbe d’évolution (EX-12)', () {
    test('un point par séance, dans l’ordre chronologique', () {
      final points = metricHistory(_history, ExerciseMetric.maxWeight);
      expect(points.map((p) => p.date.day), [1, 10, 20]);
      expect(points.map((p) => p.value), [95, 100, 90]);
    });

    test('1RM estimé de la meilleure série et volume de la séance', () {
      final oneRepMax = metricHistory(_history, ExerciseMetric.oneRepMax);
      expect(oneRepMax.last.value, closeTo(85 * (1 + 8 / 30), 1e-9));
      final volume = metricHistory(_history, ExerciseMetric.volume);
      expect(volume.last.value, 90 * 5 + 85 * 8);
    });

    test('valeurs proposées selon le type de suivi', () {
      expect(ExerciseMetric.of(TrackingType.weightReps), [
        ExerciseMetric.oneRepMax,
        ExerciseMetric.maxWeight,
        ExerciseMetric.volume,
        ExerciseMetric.maxReps,
        ExerciseMetric.totalReps,
      ]);
      expect(
        ExerciseMetric.of(TrackingType.duration).first,
        ExerciseMetric.maxDuration,
      );
    });

    test('les séries d’échauffement et les séances à zéro sont ignorées', () {
      final points = metricHistory([
        _session(5, [_set(kg: 0, reps: 10)]),
        _session(3, [
          _set(kg: 120, reps: 5, type: SetType.warmup),
          _set(kg: 60, reps: 5),
        ]),
      ], ExerciseMetric.maxWeight);
      expect(points.map((p) => p.value), [60]);
    });
  });

  group('records (EX-13)', () {
    test('poids + reps : 1RM estimé, poids max, meilleure série, volume', () {
      final records = {
        for (final r in exerciseRecords(_history, TrackingType.weightReps))
          r.kind: r,
      };
      expect(records.keys, [
        RecordKind.oneRepMax,
        RecordKind.maxWeight,
        RecordKind.bestSetVolume,
        RecordKind.sessionVolume,
      ]);
      // 85 × 8 → 107,7 ; 90 × 5 → 105 ; 100 × 1 → 100.
      expect(records[RecordKind.oneRepMax]!.set!.weightKg, 85);
      expect(records[RecordKind.maxWeight]!.value, 100);
      expect(records[RecordKind.maxWeight]!.date, DateTime(2026, 9, 10));
      expect(records[RecordKind.bestSetVolume]!.value, 85 * 8);
      expect(records[RecordKind.sessionVolume]!.value, 90 * 5 + 85 * 8);
    });

    test('en cas d’égalité, la première fois compte', () {
      final records = exerciseRecords([
        _session(9, [_set(kg: 80, reps: 8)]),
        _session(2, [_set(kg: 80, reps: 8)]),
      ], TrackingType.weightReps);
      expect(records.every((r) => r.date == DateTime(2026, 9, 2)), isTrue);
    });

    test('reps seules et durée', () {
      final reps = exerciseRecords([
        _session(4, [_set(reps: 12), _set(reps: 10)]),
        _session(2, [_set(reps: 15), _set(reps: 3)]),
      ], TrackingType.reps);
      expect(reps.map((r) => (r.kind, r.value)), [
        (RecordKind.maxReps, 15),
        (RecordKind.sessionReps, 22),
      ]);

      final duration = exerciseRecords([
        _session(4, [_set(seconds: 60), _set(seconds: 45)]),
      ], TrackingType.duration);
      expect(duration.map((r) => (r.kind, r.value)), [
        (RecordKind.maxDuration, 60),
        (RecordKind.sessionDuration, 105),
      ]);
    });
  });

  group('records par nombre de reps (RG-18)', () {
    test('seulement les vrais records, du plus petit nombre de reps au plus '
        'grand', () {
      final records = repRecords(_history);
      // Chaque ligne est plus lourde que celles à plus de reps : toutes
      // restent. À 8 reps, 85 kg bat 80 kg.
      expect(records.map((r) => (r.reps, r.weightKg)), [
        (1, 100),
        (3, 95),
        (5, 90),
        (8, 85),
      ]);
    });

    test(
      'une ligne battue par plus de reps à un poids plus lourd disparaît',
      () {
        final records = repRecords([
          _session(3, [_set(kg: 100, reps: 5)]),
          _session(2, [_set(kg: 95, reps: 3)]),
          _session(1, [_set(kg: 100, reps: 2)]),
        ]);
        expect(records.map((r) => (r.reps, r.weightKg)), [(5, 100)]);
      },
    );

    test('date = la première fois que le record a été atteint', () {
      final records = repRecords([
        _session(8, [_set(kg: 90, reps: 5)]),
        _session(4, [_set(kg: 90, reps: 5)]),
      ]);
      expect(records.single.date, DateTime(2026, 9, 4));
    });
  });

  group('fréquence (EX-15, RG-19)', () {
    test('séances, moyenne par semaine depuis la première, dernière fois', () {
      final frequency = exerciseFrequency(_history, DateTime(2026, 9, 29))!;
      expect(frequency.sessions, 3);
      // 3 séances en 4 semaines (du 1er au 29 septembre).
      expect(frequency.perWeek, 0.8);
      expect(frequency.last, DateTime(2026, 9, 20));
    });

    test('au moins une semaine, pour ne pas gonfler la moyenne', () {
      final frequency = exerciseFrequency([
        _session(20, [_set(kg: 80, reps: 8)]),
        _session(18, [_set(kg: 80, reps: 8)]),
      ], DateTime(2026, 9, 21))!;
      expect(frequency.perWeek, 2);
    });

    test('aucune séance → null', () {
      expect(exerciseFrequency([], DateTime(2026, 9, 21)), isNull);
    });
  });
}
