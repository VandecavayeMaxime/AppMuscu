import 'package:app_muscu/features/activity/domain/activity_summary.dart';
import 'package:flutter_test/flutter_test.dart';

ActivitySample _sample(
  DateTime from,
  DateTime to,
  ActivityMetric metric,
  double value,
) => (from: from, to: to, metric: metric, value: value);

void main() {
  group('aggregateByDay (D36)', () {
    test('additionne plusieurs échantillons du même jour et de la même '
        'mesure', () {
      final summaries = aggregateByDay([
        _sample(
          DateTime(2026, 9, 1, 8),
          DateTime(2026, 9, 1, 9),
          ActivityMetric.steps,
          3000,
        ),
        _sample(
          DateTime(2026, 9, 1, 18),
          DateTime(2026, 9, 1, 19),
          ActivityMetric.steps,
          4000,
        ),
      ]);

      expect(summaries, hasLength(1));
      expect(summaries.single.date, DateTime(2026, 9, 1));
      expect(summaries.single.steps, 7000);
    });

    test('des mesures différentes le même jour restent séparées', () {
      final summaries = aggregateByDay([
        _sample(
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 1, 1),
          ActivityMetric.steps,
          5000,
        ),
        _sample(
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 1, 1),
          ActivityMetric.distance,
          3200,
        ),
        _sample(
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 1, 1),
          ActivityMetric.calories,
          210,
        ),
      ]);

      final summary = summaries.single;
      expect(summary.steps, 5000);
      expect(summary.distanceMeters, 3200);
      expect(summary.activeCalories, 210);
      expect(summary.sleepMinutes, isNull);
    });

    test('un échantillon à cheval sur deux jours compte pour le jour de son '
        'début (une nuit de sommeil)', () {
      final summaries = aggregateByDay([
        _sample(
          DateTime(2026, 9, 1, 23),
          DateTime(2026, 9, 2, 7),
          ActivityMetric.sleep,
          480,
        ),
      ]);

      expect(summaries.single.date, DateTime(2026, 9, 1));
      expect(summaries.single.sleepMinutes, 480);
    });

    test('des jours différents restent des lignes séparées, triées du plus '
        'ancien au plus récent', () {
      final summaries = aggregateByDay([
        _sample(
          DateTime(2026, 9, 3),
          DateTime(2026, 9, 3, 1),
          ActivityMetric.steps,
          1000,
        ),
        _sample(
          DateTime(2026, 9, 1),
          DateTime(2026, 9, 1, 1),
          ActivityMetric.steps,
          2000,
        ),
      ]);

      expect(summaries.map((s) => s.date), [
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 3),
      ]);
    });

    test('aucun échantillon : aucune ligne', () {
      expect(aggregateByDay([]), isEmpty);
    });
  });

  group('ActivityMetric.valueOf', () {
    test('lit le bon champ, ou null si absent', () {
      final ActivitySummary summary = (
        date: DateTime(2026, 9, 1),
        steps: 8000,
        distanceMeters: null,
        activeCalories: 320.0,
        sleepMinutes: null,
      );
      expect(ActivityMetric.steps.valueOf(summary), 8000);
      expect(ActivityMetric.distance.valueOf(summary), isNull);
      expect(ActivityMetric.calories.valueOf(summary), 320.0);
      expect(ActivityMetric.sleep.valueOf(summary), isNull);
    });
  });
}
