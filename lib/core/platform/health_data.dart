import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import '../../features/activity/domain/activity_summary.dart';

/// Pas, distance, calories actives et sommeil du téléphone (D36) : Health
/// Connect sur Android, Apple Santé sur iOS, via le paquet `health`. Les
/// tests la remplacent par une fausse implémentation.
final healthDataProvider = Provider<HealthData>((ref) => PlatformHealthData());

abstract interface class HealthData {
  /// `null` = jamais demandée. Sinon accordée ou refusée.
  Future<bool?> hasPermission();

  /// Demande l'autorisation de lire pas, distance, calories et sommeil.
  Future<bool> requestPermission();

  /// Un point par jour ayant au moins une valeur, du plus ancien au plus
  /// récent, entre [start] (inclus) et [end] (exclu).
  Future<List<ActivitySummary>> history(DateTime start, DateTime end);
}

/// Implémentation réelle, par le paquet `health` (Health Connect / Apple
/// Santé). L'agrégation par jour est une fonction pure séparée
/// (`aggregateByDay`, domain/activity_summary.dart) : elle ne connaît que le
/// format commun `ActivitySample`, jamais les types du paquet, pour rester
/// testable sans lui.
class PlatformHealthData implements HealthData {
  PlatformHealthData() : _health = Health();

  final Health _health;
  bool _configured = false;

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
  ];

  static const _metricOf = {
    HealthDataType.STEPS: ActivityMetric.steps,
    HealthDataType.DISTANCE_DELTA: ActivityMetric.distance,
    HealthDataType.ACTIVE_ENERGY_BURNED: ActivityMetric.calories,
    HealthDataType.SLEEP_ASLEEP: ActivityMetric.sleep,
  };

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool?> hasPermission() async {
    try {
      await _ensureConfigured();
      return await _health.hasPermissions(_types);
    } on Exception catch (error) {
      debugPrint('Vérification des autorisations de santé impossible : $error');
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _ensureConfigured();
      return await _health.requestAuthorization(_types);
    } on Exception catch (error) {
      debugPrint("Demande d'autorisation de santé impossible : $error");
      return false;
    }
  }

  @override
  Future<List<ActivitySummary>> history(DateTime start, DateTime end) async {
    try {
      await _ensureConfigured();
      final points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: end,
      );
      final samples = [
        for (final point in points)
          if (point.value case final NumericHealthValue value)
            (
              from: point.dateFrom,
              to: point.dateTo,
              metric: _metricOf[point.type]!,
              value: value.numericValue.toDouble(),
            ),
      ];
      return aggregateByDay(samples);
    } on Exception catch (error) {
      debugPrint('Lecture des données de santé impossible : $error');
      return [];
    }
  }
}
