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

  Future<Exercise> createHipThrust({String name = 'Hip thrust'}) {
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

      expect(list, hasLength(10));
      expect(list.first, 'Curl biceps (haltères)');
      expect(list.last, 'Tractions');
    });

    test('recherche sans tenir compte des accents ni de la casse', () async {
      expect(await names(search: 'DEVELOPPE'), [
        'Développé couché (barre)',
        'Développé militaire (barre)',
      ]);
      expect(await names(search: 'presse à'), ['Presse à cuisses']);
    });

    test('filtre par groupe musculaire et par équipement', () async {
      expect(await names(bodyPart: BodyPart.back), [
        'Rowing (barre)',
        'Soulevé de terre (barre)',
        'Tractions',
      ]);
      expect(
        await names(bodyPart: BodyPart.back, equipment: Equipment.barbell),
        ['Rowing (barre)', 'Soulevé de terre (barre)'],
      );
    });

    test('se met à jour toute seule quand la table change', () async {
      final updates = StreamIterator(repository.watchExercises(search: 'hip'));

      expect(await updates.moveNext(), isTrue);
      expect(updates.current, isEmpty);

      await createHipThrust();

      expect(await updates.moveNext(), isTrue);
      expect(updates.current.single.name, 'Hip thrust');
      await updates.cancel();
    });
  });

  group('exercices perso (EX-04 à EX-06)', () {
    test('crée un exercice perso en nettoyant le nom', () async {
      final created = await createHipThrust(name: '  Hip    thrust ');

      expect(created.name, 'Hip thrust');
      expect(created.isCustom, isTrue);
      expect(await names(), contains('Hip thrust'));
    });

    test('refuse un nom déjà pris, même écrit autrement', () async {
      await expectLater(
        createHipThrust(name: 'developpe COUCHE (barre)'),
        throwsA(isA<DuplicateExerciseNameException>()),
      );
    });

    test('refuse un nom vide', () async {
      await expectLater(createHipThrust(name: '   '), throwsArgumentError);
    });

    test('modifie un exercice perso', () async {
      final created = await createHipThrust();

      await repository.updateCustom(
        created.id,
        name: 'Hip thrust (machine)',
        equipment: Equipment.machine,
        bodyPart: BodyPart.glutes,
        trackingType: TrackingType.weightReps,
        instructions: 'Dos contre le banc.',
      );

      final updated = await repository.findById(created.id);
      expect(updated!.name, 'Hip thrust (machine)');
      expect(updated.equipment, Equipment.machine);
      expect(updated.instructions, 'Dos contre le banc.');
    });

    test(
      'garder son propre nom en modifiant ne compte pas comme un doublon',
      () async {
        final created = await createHipThrust();

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
        'Développé couché (barre)',
      );
    });

    test("archive un exercice : il disparaît de la liste mais reste en base, "
        'et son nom redevient disponible', () async {
      final created = await createHipThrust();

      await repository.archiveCustom(created.id);

      expect(await names(), isNot(contains('Hip thrust')));
      expect((await repository.findById(created.id))!.deletedAt, isNotNull);
      await createHipThrust(); // ne lève pas d'exception
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
