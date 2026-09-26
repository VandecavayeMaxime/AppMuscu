// Tests des migrations de la base (NF-08).
// Base générée par `dart run drift_dev make-migrations`, complétée à la main.
import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/core/database/seed/built_in_exercises.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Pour chaque paire de versions : la base migrée doit avoir exactement la
  // même structure qu'une base créée directement dans la nouvelle version.
  group('structure après migration', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(i + 1)) {
        test('v$fromVersion → v$toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, toVersion);
          await db.close();
        });
      }
    }
  });

  test('v1 → v2 : notes → instructions, unité kg, consignes des exercices '
      'intégrés', () async {
    const benchPressId = '509d3ccf-bf4e-411b-a5db-2d2e491f586c';
    const customId = 'custom-hip-thrust';
    const oldExercises = [
      v1.ExercisesData(
        id: benchPressId,
        createdAt: 0,
        updatedAt: 0,
        name: 'Développé couché (barre)',
        nameNormalized: 'developpe couche (barre)',
        equipment: 'barbell',
        bodyPart: 'chest',
        trackingType: 'weightReps',
        isCustom: 0,
      ),
      v1.ExercisesData(
        id: customId,
        createdAt: 0,
        updatedAt: 0,
        name: 'Hip thrust',
        nameNormalized: 'hip thrust',
        equipment: 'barbell',
        bodyPart: 'glutes',
        trackingType: 'weightReps',
        defaultRestSeconds: 90,
        notes: 'Menton rentré',
        isCustom: 1,
      ),
    ];
    final expectedExercises = [
      v2.ExercisesData(
        id: benchPressId,
        createdAt: 0,
        updatedAt: 0,
        name: 'Développé couché (barre)',
        nameNormalized: 'developpe couche (barre)',
        equipment: 'barbell',
        bodyPart: 'chest',
        trackingType: 'weightReps',
        weightUnit: 'kg',
        instructions: builtInInstructions[benchPressId],
        isCustom: 0,
      ),
      const v2.ExercisesData(
        id: customId,
        createdAt: 0,
        updatedAt: 0,
        name: 'Hip thrust',
        nameNormalized: 'hip thrust',
        equipment: 'barbell',
        bodyPart: 'glutes',
        trackingType: 'weightReps',
        defaultRestSeconds: 90,
        weightUnit: 'kg',
        instructions: 'Menton rentré',
        isCustom: 1,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) =>
          batch.insertAll(oldDb.exercises, oldExercises),
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.exercises).get(), expectedExercises);
      },
    );
  });
}
