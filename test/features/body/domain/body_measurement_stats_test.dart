import 'package:app_muscu/features/body/domain/body_measurement_stats.dart';
import 'package:flutter_test/flutter_test.dart';

MeasurementPoint _point(int day, double value) =>
    (date: DateTime(2026, 9, day), value: value);

void main() {
  group('smoothedWeight (RG-20)', () {
    test('moyenne des pesées des 7 derniers jours, celle-ci comprise', () {
      // Une pesée par jour du 1 au 10 : au 10e jour, la moyenne porte sur
      // les jours 4 à 10 (7 valeurs).
      final points = [
        for (var day = 1; day <= 10; day++) _point(day, day.toDouble()),
      ];

      final smoothed = smoothedWeight(points);

      // Jour 1 : une seule pesée dans la fenêtre → moyenne = 1.
      expect(smoothed[0].value, 1);
      // Jour 10 : moyenne de 4..10 = 7.
      expect(smoothed[9].value, 7);
    });

    test('des pesées espacées ne comptent que celles vraiment dans la '
        'fenêtre', () {
      final points = [_point(1, 80), _point(20, 90)];

      final smoothed = smoothedWeight(points);

      // Chacune est seule dans sa propre fenêtre de 7 jours.
      expect(smoothed[0].value, 80);
      expect(smoothed[1].value, 90);
    });
  });

  group('measurementDelta (RG-21)', () {
    test('une seule mesure : pas d\'écart', () {
      expect(
        measurementDelta([_point(1, 80)], useThirtyDayReference: true),
        isNull,
      );
    });

    test('poids : référence = dernière mesure d\'il y a au moins 30 jours', () {
      final points = [
        _point(1, 80), // il y a 40 jours
        _point(11, 82), // il y a 30 jours (référence : la plus proche)
        _point(41, 78), // aujourd'hui
      ];

      final delta = measurementDelta(points, useThirtyDayReference: true);

      expect(delta!.value, closeTo(-4, 0.001)); // 78 - 82
      expect(delta.trend, MeasurementTrend.down);
      expect(delta.referenceDate, DateTime(2026, 9, 11));
      expect(delta.referenceIsThirtyDaysAgo, isTrue);
    });

    test('poids : sans mesure d\'il y a 30 jours, la référence est la '
        'première', () {
      final points = [_point(1, 80), _point(5, 81)];

      final delta = measurementDelta(points, useThirtyDayReference: true);

      expect(delta!.value, closeTo(1, 0.001));
      expect(delta.trend, MeasurementTrend.up);
      expect(delta.referenceDate, DateTime(2026, 9, 1));
      expect(delta.referenceIsThirtyDaysAgo, isFalse);
    });

    test('tour : toujours la première mesure, même récente', () {
      final points = [_point(1, 38), _point(2, 38), _point(3, 39)];

      final delta = measurementDelta(points, useThirtyDayReference: false);

      expect(delta!.value, closeTo(1, 0.001));
      expect(delta.referenceDate, DateTime(2026, 9, 1));
      expect(delta.referenceIsThirtyDaysAgo, isFalse);
    });

    test('valeur égale : =', () {
      final delta = measurementDelta([
        _point(1, 80),
        _point(2, 80),
      ], useThirtyDayReference: false);
      expect(delta!.trend, MeasurementTrend.equal);
    });
  });
}
