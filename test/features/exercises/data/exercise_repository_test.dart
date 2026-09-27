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
          bodyPart: bodyPart,
          equipment: equipment,
        )
        .first;
    return exercises.map((e) => e.name).toList();
  }

  group('liste (EX-02, EX-03)', () {
    test('trie les exercices par ordre alphabétique', () async {
      final list = await names();

      expect(list, hasLength(83));
      expect(list.first, 'Ab Wheel Rollout');
      expect(list.last, 'Wrist Curl (Dumbbell)');
    });

    test('recherche sans tenir compte des accents ni de la casse', () async {
      expect(await names(search: 'PRESS'), [
        'Arnold Press',
        'Bench Press (Barbell)',
        'Bench Press (Dumbbell)',
        'Close-Grip Bench Press',
        'Incline Bench Press (Barbell)',
        'Incline Bench Press (Dumbbell)',
        'Leg Press',
        'Leg Press Calf Raise',
        'Overhead Press (Barbell)',
        'Overhead Press (Dumbbell)',
        'Shoulder Press (Machine)',
      ]);
      expect(await names(search: 'leg press'), [
        'Leg Press',
        'Leg Press Calf Raise',
      ]);
    });

    test('filtre par groupe musculaire et par équipement', () async {
      expect(await names(bodyPart: BodyPart.lats), [
        'Barbell Row',
        'Chest-Supported Row (Machine)',
        'Dumbbell Pullover',
        'Lat Pulldown (Cable)',
        'One-Arm Dumbbell Row',
        'Pull-Up',
        'Seated Cable Row',
        'T-Bar Row',
      ]);
      expect(
        await names(bodyPart: BodyPart.lats, equipment: Equipment.barbell),
        ['Barbell Row', 'T-Bar Row'],
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
