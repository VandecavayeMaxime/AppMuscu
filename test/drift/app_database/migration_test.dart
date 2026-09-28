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
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;
import 'generated/schema_v10.dart' as v10;
import 'generated/schema_v11.dart' as v11;
import 'generated/schema_v12.dart' as v12;

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
        name: 'Bench Press (Barbell)',
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
        name: 'Bench Press (Barbell)',
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

  test('v2 → v3 : les séries existantes sont conservées, sans valeurs '
      'prévues', () async {
    const exercise = v2.ExercisesData(
      id: 'squat',
      createdAt: 0,
      updatedAt: 0,
      name: 'Squat',
      nameNormalized: 'squat',
      equipment: 'barbell',
      bodyPart: 'legs',
      trackingType: 'weightReps',
      weightUnit: 'kg',
      isCustom: 0,
    );
    const workout = v2.WorkoutsData(
      id: 'w1',
      createdAt: 0,
      updatedAt: 0,
      name: 'Séance du soir',
      startedAt: 0,
      endedAt: 3600,
    );
    const entry = v2.WorkoutExercisesData(
      id: 'we1',
      workoutId: 'w1',
      exerciseId: 'squat',
      position: 0,
    );
    const oldSet = v2.WorkoutSetsData(
      id: 's1',
      workoutExerciseId: 'we1',
      position: 0,
      setType: 'normal',
      weightKg: 100,
      reps: 5,
      restSeconds: 180,
      completedAt: 600,
    );
    const expectedSet = v3.WorkoutSetsData(
      id: 's1',
      workoutExerciseId: 'we1',
      position: 0,
      setType: 'normal',
      weightKg: 100,
      reps: 5,
      restSeconds: 180,
      completedAt: 600,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insert(oldDb.exercises, exercise)
          ..insert(oldDb.workouts, workout)
          ..insert(oldDb.workoutExercises, entry)
          ..insert(oldDb.workoutSets, oldSet);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.workoutSets).get(), [expectedSet]);
      },
    );
  });

  test(
    'v3 → v4 : chaque exercice reprend sa dernière note de séance',
    () async {
      v3.ExercisesData exercise(String id) => v3.ExercisesData(
        id: id,
        createdAt: 0,
        updatedAt: 0,
        name: id,
        nameNormalized: id,
        equipment: 'barbell',
        bodyPart: 'legs',
        trackingType: 'weightReps',
        weightUnit: 'kg',
        isCustom: 0,
      );
      v3.WorkoutsData workout(String id, int startedAt) => v3.WorkoutsData(
        id: id,
        createdAt: 0,
        updatedAt: 0,
        name: id,
        startedAt: startedAt,
        endedAt: startedAt + 3600,
      );
      v3.WorkoutExercisesData entry(String workoutId, String? notes) =>
          v3.WorkoutExercisesData(
            id: 'we-$workoutId',
            workoutId: workoutId,
            exerciseId: 'squat',
            position: 0,
            notes: notes,
          );

      await verifier.testWithDataIntegrity(
        oldVersion: 3,
        newVersion: 4,
        createOld: v3.DatabaseAtV3.new,
        createNew: v4.DatabaseAtV4.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch
            ..insertAll(oldDb.exercises, [exercise('squat'), exercise('bench')])
            ..insertAll(oldDb.workouts, [
              workout('lundi', 1000),
              workout('mercredi', 2000),
              workout('vendredi', 3000),
            ])
            ..insertAll(oldDb.workoutExercises, [
              entry('lundi', 'Ancienne note'),
              entry('mercredi', 'Siège cran 4'),
              entry('vendredi', null), // pas de note cette fois-là
            ]);
        },
        validateItems: (newDb) async {
          final notes = {
            for (final row in await newDb.select(newDb.exercises).get())
              row.id: row.note,
          };
          expect(notes, {'squat': 'Siège cran 4', 'bench': null});
        },
      );
    },
  );

  test(
    'v4 → v5 : les exercices intégrés reçoivent leurs muscles secondaires',
    () async {
      v4.ExercisesData exercise(String id, {String bodyPart = 'quads'}) =>
          v4.ExercisesData(
            id: id,
            createdAt: 0,
            updatedAt: 0,
            name: id,
            nameNormalized: id,
            equipment: 'barbell',
            bodyPart: bodyPart,
            trackingType: 'weightReps',
            weightUnit: 'kg',
            isCustom: 0,
          );
      // Développé couché (intégré, avec des muscles secondaires) et un
      // exercice perso (jamais touché par la migration).
      const benchPressId = '509d3ccf-bf4e-411b-a5db-2d2e491f586c';
      const customId = 'custom-hip-thrust';

      await verifier.testWithDataIntegrity(
        oldVersion: 4,
        newVersion: 5,
        createOld: v4.DatabaseAtV4.new,
        createNew: v5.DatabaseAtV5.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.exercises, [
            exercise(benchPressId, bodyPart: 'chest'),
            exercise(customId, bodyPart: 'glutes'),
          ]);
        },
        validateItems: (newDb) async {
          // `newDb` est le schéma brut de la version 5 (pas `AppDatabase`) :
          // pas de convertisseur, `secondaryMuscles` reste une chaîne.
          final muscles = {
            for (final row in await newDb.select(newDb.exercises).get())
              row.id: row.secondaryMuscles,
          };
          expect(muscles, {
            benchPressId: 'triceps,shoulders',
            customId: '', // exercice perso : pas de muscle secondaire ajouté
          });
        },
      );
    },
  );

  test('v5 → v6 : « Dos » devient dorsaux, lombaires… (D20)', () async {
    v5.ExercisesData exercise(
      String id, {
      required String bodyPart,
      String secondaryMuscles = '',
    }) => v5.ExercisesData(
      id: id,
      createdAt: 0,
      updatedAt: 0,
      name: id,
      nameNormalized: id,
      equipment: 'barbell',
      bodyPart: bodyPart,
      trackingType: 'weightReps',
      weightUnit: 'kg',
      secondaryMuscles: secondaryMuscles,
      isCustom: 0,
    );
    const rowingId = '8087a454-a438-4c79-be98-f6670785da3e';
    const deadliftId = '7c098dc4-7640-4b19-9dda-14dd6f4cb30a';
    const pullUpId = 'd160b037-2046-44ac-ba37-97784a8cade2';
    const customBackId = 'custom-back-exercise';
    const customChestId = 'custom-chest-exercise';

    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.exercises, [
          exercise(rowingId, bodyPart: 'back'),
          exercise(deadliftId, bodyPart: 'back'),
          exercise(pullUpId, bodyPart: 'back'),
          // Exercice perso « Dos » : bascule par défaut vers « dorsaux ».
          exercise(
            customBackId,
            bodyPart: 'back',
            secondaryMuscles: 'back,triceps',
          ),
          // Sans rapport avec « Dos » : ni le groupe ni les muscles
          // secondaires (déjà « lombaires ») ne doivent bouger.
          exercise(
            customChestId,
            bodyPart: 'chest',
            secondaryMuscles: 'lowerBack,triceps',
          ),
        ]);
      },
      validateItems: (newDb) async {
        final rows = {
          for (final row in await newDb.select(newDb.exercises).get())
            row.id: row,
        };
        expect(rows[rowingId]!.bodyPart, 'lats');
        expect(rows[deadliftId]!.bodyPart, 'lowerBack');
        expect(rows[pullUpId]!.bodyPart, 'lats');
        expect(rows[customBackId]!.bodyPart, 'lats');
        expect(rows[customBackId]!.secondaryMuscles, 'lats,triceps');
        // Ni le groupe ni les muscles secondaires ne bougent quand ils ne
        // valent pas « back ».
        expect(rows[customChestId]!.bodyPart, 'chest');
        expect(rows[customChestId]!.secondaryMuscles, 'lowerBack,triceps');
      },
    );
  });

  test('v6 → v7 : la bibliothèque reçoit 73 exercices de plus (D21), sans '
      'toucher aux exercices déjà en base', () async {
    v6.ExercisesData custom() => v6.ExercisesData(
      id: 'custom-hip-thrust',
      createdAt: 0,
      updatedAt: 0,
      name: 'Hip thrust perso',
      nameNormalized: 'hip thrust perso',
      equipment: 'barbell',
      bodyPart: 'glutes',
      trackingType: 'weightReps',
      weightUnit: 'kg',
      secondaryMuscles: 'hamstrings',
      isCustom: 1,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: 7,
      createOld: v6.DatabaseAtV6.new,
      createNew: v7.DatabaseAtV7.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.exercises, [custom()]);
      },
      validateItems: (newDb) async {
        final all = await newDb.select(newDb.exercises).get();
        // L'exercice perso déjà en base + les 73 nouveaux (la base de test
        // part vide : les 10 du MVP ne sont insérés qu'à la création d'une
        // vraie base, via `onCreate`).
        expect(all, hasLength(1 + 73));
        expect(
          all.where((e) => e.id == 'custom-hip-thrust').single.name,
          'Hip thrust perso',
        );
        // Un nouvel exercice de chaque groupe musculaire ajouté, présent.
        final names = all.map((e) => e.name).toSet();
        expect(names, contains('Shrug (Barbell)'));
        expect(names, contains('Standing Calf Raise'));
      },
    );
  });

  test('v7 → v8 : les exercices intégrés reprennent leur nom d’usage, en '
      'anglais (D22)', () async {
    v7.ExercisesData exercise(
      String id, {
      required String name,
      bool custom = false,
    }) => v7.ExercisesData(
      id: id,
      createdAt: 0,
      updatedAt: 0,
      name: name,
      nameNormalized: name.toLowerCase(),
      equipment: 'barbell',
      bodyPart: 'chest',
      trackingType: 'weightReps',
      weightUnit: 'kg',
      secondaryMuscles: '',
      isCustom: custom ? 1 : 0,
    );
    const benchPressId = '509d3ccf-bf4e-411b-a5db-2d2e491f586c';
    const customId = 'custom-perso';

    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: 8,
      createOld: v7.DatabaseAtV7.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.exercises, [
          exercise(benchPressId, name: 'Développé couché (barre)'),
          exercise(customId, name: 'Mon exercice perso', custom: true),
        ]);
      },
      validateItems: (newDb) async {
        final rows = {
          for (final row in await newDb.select(newDb.exercises).get())
            row.id: row,
        };
        expect(rows[benchPressId]!.name, 'Bench Press (Barbell)');
        expect(rows[benchPressId]!.nameNormalized, 'bench press (barbell)');
        // Un exercice perso ne fait pas partie de la bibliothèque : son nom
        // ne bouge pas.
        expect(rows[customId]!.name, 'Mon exercice perso');
      },
    );
  });

  test(
    'v10 → v11 : Chest Dip et Tricep Dip passent en poids + reps (D28)',
    () async {
      v10.ExercisesData exercise(
        String id, {
        required String name,
        String trackingType = 'reps',
      }) => v10.ExercisesData(
        id: id,
        createdAt: 0,
        updatedAt: 0,
        name: name,
        nameNormalized: name.toLowerCase(),
        equipment: 'bodyweight',
        bodyPart: 'chest',
        trackingType: trackingType,
        weightUnit: 'kg',
        secondaryMuscles: '',
        isCustom: 0,
      );
      const chestDipId = '5190e591-346d-4944-85aa-1204579521d0';
      const tricepDipId = '5871b2cb-cb62-4433-af1d-69da2e1d3c4d';
      const otherId = 'other-exercise';

      await verifier.testWithDataIntegrity(
        oldVersion: 10,
        newVersion: 11,
        createOld: v10.DatabaseAtV10.new,
        createNew: v11.DatabaseAtV11.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.exercises, [
            exercise(chestDipId, name: 'Chest Dip'),
            exercise(tricepDipId, name: 'Tricep Dip'),
            // Un exercice « reps » qui n'est pas concerné ne bouge pas.
            exercise(otherId, name: 'Push-Up'),
          ]);
        },
        validateItems: (newDb) async {
          final rows = {
            for (final row in await newDb.select(newDb.exercises).get())
              row.id: row,
          };
          expect(rows[chestDipId]!.trackingType, 'weightReps');
          expect(rows[tricepDipId]!.trackingType, 'weightReps');
          expect(rows[otherId]!.trackingType, 'reps');
        },
      );
    },
  );

  test('v11 → v12 : Trapèzes scindé en haut et milieu/bas (D29)', () async {
    v11.ExercisesData exercise(
      String id, {
      required String name,
      String bodyPart = 'chest',
      String secondaryMuscles = '',
    }) => v11.ExercisesData(
      id: id,
      createdAt: 0,
      updatedAt: 0,
      name: name,
      nameNormalized: name.toLowerCase(),
      equipment: 'bodyweight',
      bodyPart: bodyPart,
      trackingType: 'weightReps',
      weightUnit: 'kg',
      secondaryMuscles: secondaryMuscles,
      isCustom: 0,
    );
    const shrugId = 'f60801a4-8ec9-47bb-83ff-bbf9666388b7';
    const facePullId = '75458925-1deb-4d8f-9e4d-acc867a239c3';
    const rearDeltFlyId = 'b9a7bb05-91e6-4d93-a091-8ed7f960ef2b';
    const customId = 'custom-exercise';

    await verifier.testWithDataIntegrity(
      oldVersion: 11,
      newVersion: 12,
      createOld: v11.DatabaseAtV11.new,
      createNew: v12.DatabaseAtV12.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.exercises, [
          exercise(shrugId, name: 'Shrug (Dumbbell)', bodyPart: 'trapezius'),
          exercise(
            facePullId,
            name: 'Face Pull (Cable)',
            bodyPart: 'trapezius',
          ),
          exercise(
            rearDeltFlyId,
            name: 'Rear Delt Fly (Dumbbell)',
            bodyPart: 'shoulders',
            secondaryMuscles: 'trapezius',
          ),
          // Exercice perso : bascule par défaut vers le haut.
          exercise(
            customId,
            name: 'Mon exercice perso',
            bodyPart: 'trapezius',
            secondaryMuscles: 'shoulders,trapezius',
          ),
        ]);
      },
      validateItems: (newDb) async {
        final rows = {
          for (final row in await newDb.select(newDb.exercises).get())
            row.id: row,
        };
        expect(rows[shrugId]!.bodyPart, 'trapeziusUpper');
        expect(rows[facePullId]!.bodyPart, 'trapeziusLower');
        expect(rows[rearDeltFlyId]!.secondaryMuscles, 'trapeziusLower');
        expect(rows[customId]!.bodyPart, 'trapeziusUpper');
        expect(rows[customId]!.secondaryMuscles, 'shoulders,trapeziusUpper');
      },
    );
  });
}
