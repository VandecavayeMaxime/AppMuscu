import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/body/data/body_repository.dart';
import 'package:app_muscu/features/body/domain/body_measurement_field.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late BodyRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = BodyRepository(db);
  });
  tearDown(() => db.close());

  test('addMeasurementValues enregistre chaque champ (aucun oublié dans le '
      'passage de BodyMeasurementField à sa colonne)', () async {
    // Une valeur distincte par champ, pour repérer un champ qui écrirait
    // dans la mauvaise colonne.
    final values = {
      for (final (index, field) in BodyMeasurementField.values.indexed)
        field: 10.0 + index,
    };

    await repository.addMeasurementValues(DateTime(2026, 9, 27), values);

    final rows = await repository.watchAll().first;
    final row = rows.single;
    for (final MapEntry(key: field, value: expected) in values.entries) {
      expect(
        field.valueOf(row),
        expected,
        reason: '${field.name} ne correspond pas à sa colonne',
      );
    }
  });

  test('en saisir une autre le même jour ne remplace que les champs fournis '
      '(RG-22)', () async {
    await repository.addMeasurementValues(DateTime(2026, 9, 27), {
      BodyMeasurementField.weight: 80,
      BodyMeasurementField.glutes: 95,
    });
    await repository.addMeasurementValues(DateTime(2026, 9, 27), {
      BodyMeasurementField.weight: 81,
    });

    final row = (await repository.watchAll().first).single;
    expect(BodyMeasurementField.weight.valueOf(row), 81);
    expect(BodyMeasurementField.glutes.valueOf(row), 95);
  });
}
