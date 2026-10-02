import 'dart:async';

import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/data/exercise_repository.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = ExerciseRepository(db);
  });
  tearDown(() => db.close());

  Future<Exercise> createTestExercise({String name = 'Exercice test'}) {
    return repository.createCustom(
      name: name,
      equipment: Equipment.barbell,
      bodyPart: BodyPart.glutes,
      trackingType: TrackingType.weightReps,
    );
  }

  Future<List<String>> names({
    String search = '',
    BodyPart? bodyPart,
    Equipment? equipment,
  }) async {
    final exercises = await repository
        .watchExercises(
          search: search,
          bodyParts: bodyPart == null ? const {} : {bodyPart},
          equipment: equipment == null ? const {} : {equipment},
        )
        .first;
    return exercises.map((e) => e.name).toList();
  }

  group('liste (EX-02, EX-03)', () {
    test('trie les exercices par ordre alphabétique', () async {
      final list = await names();

      expect(list, hasLength(528));
      expect(list.first, 'Ab Wheel Rollout');
      expect(list.last, 'Zottman Curl');
    });

    test('recherche sans tenir compte des accents ni de la casse', () async {
      expect(await names(search: 'PRESS'), [
        'Arnold Press',
        'Behind the Neck Press',
        'Bench Press (Barbell)',
        'Bench Press (Dumbbell)',
        'Bodyweight Overhead Press',
        'Cable Chest Press',
        'Cable Pallof Press',
        'Close-Grip Bench Press',
        'Close-Grip Dumbbell Bench Press',
        'Close-Grip EZ-Bar Bench Press',
        'Close-Grip Incline Bench Press',
        'Close-Stance Leg Press',
        'Decline Barbell Bench Press',
        'Decline Bench Press',
        'Decline EZ-Bar Bench Press',
        'Double Kettlebell Clean and Press',
        'Double Kettlebell Overhead Press',
        'Double Kettlebell Push Press',
        'Dumbbell Floor Press',
        'Dumbbell Push Press',
        'Dumbbell Svend Press',
        'EZ-Bar Bench Press',
        'Floor EZ-Bar Press',
        'Floor Press',
        'High-Foot Leg Press',
        'Horizontal Leg Press',
        'Incline Bench Press (Barbell)',
        'Incline Bench Press (Dumbbell)',
        'Incline Dumbbell Press',
        'Incline EZ-Bar Bench Press',
        'Kettlebell Close-Grip Floor Press',
        'Kettlebell Floor Press',
        'Kettlebell Lunge Press',
        'Kettlebell Offset Reverse Lunge and Press',
        'Kettlebell Svend Press',
        'Landmine Press',
        'Leg Press',
        'Leg Press Calf Raise',
        'Machine Chest Press',
        'One Arm Kettlebell Floor Glute Bridge Press',
        'One Arm Kettlebell Floor Press',
        'One Arm Kettlebell Push Press',
        'One Arm Kettlebell Shoulder Press',
        'One-Arm Dumbbell Push Press',
        'One-Arm Kettlebell Bottoms-Up Press',
        'One-Arm Landmine Press',
        'Overhead Press (Barbell)',
        'Overhead Press (Dumbbell)',
        'Paused Bench Press',
        'Paused Incline Bench Press',
        'Paused Overhead Press',
        'Push Press',
        'Seated Barbell Overhead Press',
        'Seated Dumbbell Shoulder Press',
        'Seated Smith Machine Shoulder Press',
        'Shoulder Press (Machine)',
        'Single Dumbbell Svend Press',
        'Single Leg Press',
        'Single-Arm Machine Shoulder Press',
        'Smith Machine Bench Press',
        'Smith Machine Decline Bench Press',
        'Smith Machine Incline Bench Press',
        'Smith Machine Shoulder Press',
        'Spoto Press',
        'Svend Press',
        'TRX Chest Press',
        'Wide-Grip Bench Press',
        'Wide-Stance Leg Press',
      ]);
      expect(await names(search: 'leg press'), [
        'Close-Stance Leg Press',
        'High-Foot Leg Press',
        'Horizontal Leg Press',
        'Leg Press',
        'Leg Press Calf Raise',
        'Single Leg Press',
        'Wide-Stance Leg Press',
      ]);
    });

    test('filtre par groupe musculaire et par équipement', () async {
      expect(await names(bodyPart: BodyPart.lats), [
        'Archer Pull Ups',
        'Assisted Pull Ups',
        'Band Assisted Pull Ups',
        'Barbell Pullover',
        'Barbell Row',
        'Behind-the-Neck Lat Pulldown',
        'Behind-the-Neck Pull-Up',
        'Bench Pull',
        'Bent Arm Barbell Pullover',
        'Bent-Arm EZ-Bar Pullover',
        'Bent-Over Dumbbell Row',
        'Bent-Over EZ-Bar Row',
        'Cable Bent-Over Row',
        'Chest-Supported Dumbbell Row',
        'Chest-Supported Kettlebell Row',
        'Chest-Supported Row (Machine)',
        'Close Grip Lat Pulldown',
        'Double Kettlebell Row',
        'Dumbbell Bench Pull',
        'Dumbbell Pullover',
        'EZ Bar Pullover',
        'Floor Kettlebell Pullover',
        'Front Lever',
        'Human Flag',
        'Inverted Row',
        'Kettlebell Pullover',
        'Kneeling Cable Row',
        'Lat Pulldown (Cable)',
        'Muscle Ups',
        'Negative Pull Ups',
        'Neutral Grip Pull Ups',
        'One Arm Kettlebell Row',
        'One-Arm Dumbbell Row',
        'One-Arm Lat Pulldown',
        'Pause Pull-Up',
        'Pendlay Row',
        'Plate Pullover',
        'Pull-Up',
        'Reverse Grip Bent Over Row',
        'Ring Muscle-Up',
        'Ring Row',
        'Rings Inverted Row',
        'Rope Climb',
        'Scapular Pull Ups',
        'Seated Cable Row',
        'Single-Arm Chest-Supported Dumbbell Row',
        'Sled Row',
        'Smith Machine Bent Over Row',
        'Straight-Arm Pulldown',
        'T-Bar Row',
        'TRX Row',
        'V-Bar Lat Pulldown',
        'Weighted Pull-Up',
        'Wide Grip Pull Ups',
        'Wide Grip Seated Cable Row',
      ]);
      expect(
        await names(bodyPart: BodyPart.lats, equipment: Equipment.barbell),
        [
          'Barbell Pullover',
          'Barbell Row',
          'Bench Pull',
          'Bent Arm Barbell Pullover',
          'Bent-Arm EZ-Bar Pullover',
          'Bent-Over EZ-Bar Row',
          'EZ Bar Pullover',
          'Inverted Row',
          'Pendlay Row',
          'Reverse Grip Bent Over Row',
          'T-Bar Row',
        ],
      );
    });

    test('se met à jour toute seule quand la table change', () async {
      final updates = StreamIterator(
        repository.watchExercises(search: 'exercice test'),
      );

      expect(await updates.moveNext(), isTrue);
      expect(updates.current, isEmpty);

      await createTestExercise();

      expect(await updates.moveNext(), isTrue);
      expect(updates.current.single.name, 'Exercice test');
      await updates.cancel();
    });
  });

  group('exercices perso (EX-04 à EX-06)', () {
    test('crée un exercice perso en nettoyant le nom', () async {
      final created = await createTestExercise(name: '  Exercice    test ');

      expect(created.name, 'Exercice test');
      expect(created.isCustom, isTrue);
      expect(await names(), contains('Exercice test'));
    });

    test('refuse un nom déjà pris, même écrit autrement', () async {
      await expectLater(
        createTestExercise(name: 'bench PRESS (barbell)'),
        throwsA(isA<DuplicateExerciseNameException>()),
      );
    });

    test('refuse un nom vide', () async {
      await expectLater(createTestExercise(name: '   '), throwsArgumentError);
    });

    test('modifie un exercice perso', () async {
      final created = await createTestExercise();

      await repository.updateCustom(
        created.id,
        name: 'Exercice test (machine)',
        equipment: Equipment.machine,
        bodyPart: BodyPart.glutes,
        trackingType: TrackingType.weightReps,
        instructions: 'Dos contre le banc.',
      );

      final updated = await repository.findById(created.id);
      expect(updated!.name, 'Exercice test (machine)');
      expect(updated.equipment, Equipment.machine);
      expect(updated.instructions, 'Dos contre le banc.');
    });

    test(
      'garder son propre nom en modifiant ne compte pas comme un doublon',
      () async {
        final created = await createTestExercise();

        await repository.updateCustom(
          created.id,
          name: 'HIP THRUST',
          equipment: Equipment.barbell,
          bodyPart: BodyPart.glutes,
          trackingType: TrackingType.weightReps,
        );

        expect((await repository.findById(created.id))!.name, 'HIP THRUST');
      },
    );

    test('ne modifie pas un exercice intégré', () async {
      await repository.updateCustom(
        benchPressId,
        name: 'Autre nom',
        equipment: Equipment.machine,
        bodyPart: BodyPart.chest,
        trackingType: TrackingType.weightReps,
      );

      expect(
        (await repository.findById(benchPressId))!.name,
        'Bench Press (Barbell)',
      );
    });

    test("archive un exercice : il disparaît de la liste mais reste en base, "
        'et son nom redevient disponible', () async {
      final created = await createTestExercise();

      await repository.archiveCustom(created.id);

      expect(await names(), isNot(contains('Exercice test')));
      expect((await repository.findById(created.id))!.deletedAt, isNotNull);
      await createTestExercise(); // ne lève pas d'exception
    });

    test('muscles secondaires : créés, modifiés, vides par défaut '
        '(EX-04, EX-09)', () async {
      final created = await repository.createCustom(
        name: 'Exercice test',
        equipment: Equipment.barbell,
        bodyPart: BodyPart.glutes,
        secondaryMuscles: [BodyPart.hamstrings, BodyPart.quads],
        trackingType: TrackingType.weightReps,
      );
      expect(created.secondaryMuscles, [BodyPart.hamstrings, BodyPart.quads]);

      await repository.updateCustom(
        created.id,
        name: created.name,
        equipment: created.equipment,
        bodyPart: created.bodyPart,
        secondaryMuscles: const [],
        trackingType: created.trackingType,
      );
      expect(
        (await repository.findById(created.id))!.secondaryMuscles,
        isEmpty,
      );

      final withoutMuscles = await createTestExercise(
        name: 'Autre exercice test',
      );
      expect(withoutMuscles.secondaryMuscles, isEmpty);
    });
  });

  group('fiche (EX-07 à EX-09)', () {
    test('les exercices intégrés ont des instructions', () async {
      final bench = await repository.findById(benchPressId);

      expect(bench!.instructions, startsWith('1. '));
      expect(bench.weightUnit, WeightUnit.kg);
    });

    test('modifie les préférences, même d’un exercice intégré', () async {
      await repository.updatePreferences(
        benchPressId,
        weightUnit: WeightUnit.lb,
        defaultRestSeconds: 150,
      );

      final bench = await repository.findById(benchPressId);
      expect(bench!.weightUnit, WeightUnit.lb);
      expect(bench.defaultRestSeconds, 150);
    });

    test('note personnelle, même d’un exercice intégré (EX-11)', () async {
      await repository.updateNote(benchPressId, '  Siège cran 4 ');
      expect((await repository.findById(benchPressId))!.note, 'Siège cran 4');

      await repository.updateNote(benchPressId, '   ');
      expect((await repository.findById(benchPressId))!.note, isNull);
    });

    test('la fiche se met à jour toute seule', () async {
      final updates = StreamIterator(repository.watchExercise(benchPressId));

      expect(await updates.moveNext(), isTrue);
      expect(updates.current!.defaultRestSeconds, isNull);

      await repository.updatePreferences(
        benchPressId,
        weightUnit: WeightUnit.kg,
        defaultRestSeconds: 90,
      );

      expect(await updates.moveNext(), isTrue);
      expect(updates.current!.defaultRestSeconds, 90);
      await updates.cancel();
    });
  });
}
