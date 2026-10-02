import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/body_measurement_field.dart';

final bodyRepositoryProvider = Provider<BodyRepository>(
  (ref) => BodyRepository(ref.watch(appDatabaseProvider)),
);

/// Lecture et écriture des mesures (SA-06 à SA-08).
class BodyRepository {
  BodyRepository(this._db);

  final AppDatabase _db;

  /// Toutes les mesures, de la plus ancienne à la plus récente.
  Stream<List<BodyMeasurement>> watchAll() {
    final query = _db.select(_db.bodyMeasurements)
      ..orderBy([(m) => OrderingTerm.asc(m.measuredAt)]);
    return query.watch();
  }

  /// Ajoute une mesure datée de [date] à partir d'une valeur par champ
  /// (SA-06) : un seul endroit sait faire correspondre un [BodyMeasurementField]
  /// à sa colonne ([_withField]), pour ne pas risquer d'en oublier un si la
  /// liste des champs change.
  Future<void> addMeasurementValues(
    DateTime date,
    Map<BodyMeasurementField, double> values,
  ) {
    var fields = const BodyMeasurementsCompanion();
    for (final MapEntry(key: field, value: value) in values.entries) {
      fields = _withField(fields, field, Value(value));
    }
    return addMeasurement(date, fields);
  }

  /// Ajoute une mesure datée de [date] (RG-22) : si une mesure existe déjà
  /// ce jour-là, seuls les champs fournis dans [fields] la complètent (les
  /// autres restent tels quels) ; sinon une nouvelle mesure est créée.
  Future<void> addMeasurement(
    DateTime date,
    BodyMeasurementsCompanion fields,
  ) async {
    final day = DateTime(date.year, date.month, date.day);
    final existing = await (_db.select(
      _db.bodyMeasurements,
    )..where((m) => m.measuredAt.equals(day))).getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.bodyMeasurements)
          .insert(fields.copyWith(measuredAt: Value(day)));
    } else {
      await (_db.update(
        _db.bodyMeasurements,
      )..where((m) => m.id.equals(existing.id))).write(fields);
    }
  }

  /// La dernière valeur de chaque champ, toutes mesures confondues : sert de
  /// repère grisé dans le formulaire (SA-06), pas enregistré tant qu'on n'y
  /// touche pas.
  Future<Map<BodyMeasurementField, double>> latestValues() async {
    final query = _db.select(_db.bodyMeasurements)
      ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)]);
    final rows = await query.get();

    final latest = <BodyMeasurementField, double>{};
    for (final field in BodyMeasurementField.values) {
      for (final row in rows) {
        final value = field.valueOf(row);
        if (value != null) {
          latest[field] = value;
          break;
        }
      }
    }
    return latest;
  }

  /// Pose la valeur de [field] sur [companion] (`copyWith`, qui garde les
  /// autres champs déjà posés) : seul endroit qui sait faire correspondre un
  /// [BodyMeasurementField] à sa colonne, pour ne pas risquer d'en oublier un
  /// (`addMeasurementValues`).
  BodyMeasurementsCompanion _withField(
    BodyMeasurementsCompanion companion,
    BodyMeasurementField field,
    Value<double?> value,
  ) => switch (field) {
    BodyMeasurementField.weight => companion.copyWith(weightKg: value),
    BodyMeasurementField.bodyFat => companion.copyWith(bodyFatPercent: value),
    BodyMeasurementField.muscleMass => companion.copyWith(muscleMassKg: value),
    BodyMeasurementField.neck => companion.copyWith(neckCm: value),
    BodyMeasurementField.chest => companion.copyWith(chestCm: value),
    BodyMeasurementField.arm => companion.copyWith(armCm: value),
    BodyMeasurementField.forearm => companion.copyWith(forearmCm: value),
    BodyMeasurementField.waist => companion.copyWith(waistCm: value),
    BodyMeasurementField.hips => companion.copyWith(hipsCm: value),
    BodyMeasurementField.glutes => companion.copyWith(glutesCm: value),
    BodyMeasurementField.thigh => companion.copyWith(thighCm: value),
    BodyMeasurementField.calf => companion.copyWith(calfCm: value),
  };
}
