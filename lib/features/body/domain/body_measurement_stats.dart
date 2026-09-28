// Moyenne lissée et écart d'un champ de mesure (SA-07, SA-08).

import '../../../core/database/app_database.dart';
import '../../stats/domain/chart_point.dart';
import 'body_measurement_field.dart';

/// Une valeur d'un champ à une date (déjà filtrée : jamais nulle).
typedef MeasurementPoint = ({DateTime date, double value});

/// Les valeurs de [field] parmi [rows] (une par mesure qui le renseigne),
/// dans l'ordre chronologique de [rows].
List<MeasurementPoint> pointsOf(
  List<BodyMeasurement> rows,
  BodyMeasurementField field,
) => [
  for (final row in rows)
    if (field.valueOf(row) case final value?)
      (date: row.measuredAt, value: value),
];

/// Sens d'un écart (RG-21).
enum MeasurementTrend { up, down, equal }

/// Écart d'un champ (RG-21) : dernière valeur − valeur de référence, avec
/// sa date (pour le libellé « en 30 jours » ou « depuis le 12 sept. »).
typedef MeasurementDelta = ({
  double value,
  MeasurementTrend trend,
  DateTime referenceDate,

  /// `true` si la référence est « la dernière mesure d'il y a au moins 30
  /// jours », `false` si c'est la toute première mesure (faute de mieux, ou
  /// parce que le champ est un tour : RG-21).
  bool referenceIsThirtyDaysAgo,
});

/// Moyenne lissée du poids (RG-20) : pour chaque pesée de [points] (triés du
/// plus ancien au plus récent), la moyenne des pesées des 7 derniers jours,
/// celle-ci comprise.
List<ChartPoint> smoothedWeight(List<MeasurementPoint> points) => [
  for (final point in points)
    ChartPoint(point.date, _trailingAverage(points, point.date)),
];

double _trailingAverage(List<MeasurementPoint> points, DateTime date) {
  final windowStart = DateTime(date.year, date.month, date.day - 6);
  final inWindow = [
    for (final p in points)
      if (!p.date.isBefore(windowStart) && !p.date.isAfter(date)) p.value,
  ];
  return inWindow.reduce((a, b) => a + b) / inWindow.length;
}

/// Écart de la dernière valeur de [points] (RG-21). `null` s'il n'y a
/// qu'une seule mesure. Pour le poids, la masse grasse et la masse
/// musculaire ([useThirtyDayReference] = `true`), la référence est la
/// dernière mesure datée d'il y a au moins 30 jours, sinon la première
/// mesure ; pour les tours, toujours la première.
MeasurementDelta? measurementDelta(
  List<MeasurementPoint> points, {
  required bool useThirtyDayReference,
}) {
  if (points.length < 2) return null;
  final last = points.last;

  var referenceIsThirtyDaysAgo = false;
  var reference = points.first;
  if (useThirtyDayReference) {
    final cutoff = DateTime(
      last.date.year,
      last.date.month,
      last.date.day - 30,
    );
    final qualifying = points.where((p) => !p.date.isAfter(cutoff));
    if (qualifying.isNotEmpty) {
      reference = qualifying.last;
      referenceIsThirtyDaysAgo = true;
    }
  }

  final delta = last.value - reference.value;
  final trend = delta > 0
      ? MeasurementTrend.up
      : delta < 0
      ? MeasurementTrend.down
      : MeasurementTrend.equal;
  return (
    value: delta,
    trend: trend,
    referenceDate: reference.date,
    referenceIsThirtyDaysAgo: referenceIsThirtyDaysAgo,
  );
}
