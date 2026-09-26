import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/workout/data/workout_repository.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repository;

  /// Modèle vide, « Séance libre » : toute séance part d'un modèle (WO-01).
  late String templateId;

  setUp(() async {
    db = createTestDatabase();
    repository = WorkoutRepository(db);
    templateId = await addEmptyTemplate(db);
  });
  tearDown(() => db.close());

  String describe(WorkoutSet set) => '${set.weightKg}×${set.reps}';

  final monday = DateTime(2026, 9, 21, 18);
  final wednesday = DateTime(2026, 9, 23, 18);

  group('previousSets (RG-03, RG-04)', () {
    /// « Précédent » sous forme lisible : ['80.0×8', …].
    Future<List<String>> previous(String exerciseId) async =>
        (await repository.previousSets(exerciseId)).map(describe).toList();

    test('renvoie une liste vide pour un exercice jamais fait', () async {
      expect(await previous(benchPressId), isEmpty);
    });

    test('renvoie les séries validées de la séance la plus récente, '
        'dans l’ordre', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(80, 8), const TestSet(80, 7)],
      );

      expect(await previous(benchPressId), ['80.0×8', '80.0×7']);
    });

    test('ignore la séance en cours', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(90, 5)],
        finished: false,
      );

      expect(await previous(benchPressId), ['70.0×10']);
    });

    test('ignore les séances supprimées', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(90, 5)],
        deleted: true,
      );

      expect(await previous(benchPressId), ['70.0×10']);
    });

    test(
      'ignore les séries non validées, et les séances sans série validée',
      () async {
        await addWorkout(
          db,
          day: monday,
          sets: [const TestSet(70, 10), const TestSet(70, 9, done: false)],
        );
        await addWorkout(
          db,
          day: wednesday,
          sets: [const TestSet(90, 5, done: false)],
        );

        expect(await previous(benchPressId), ['70.0×10']);
      },
    );

    test('avec startedBefore : ignore les séances commencées à partir de '
        'cette date (comparaison du résumé)', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(db, day: wednesday, sets: [const TestSet(80, 8)]);

      final sets = await repository.previousSets(
        benchPressId,
        startedBefore: wednesday,
      );

      expect(sets.map(describe), ['70.0×10']);
    });

    test('ne mélange pas les exercices', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        exerciseId: squatId,
        sets: [const TestSet(100, 5)],
      );

      expect(await previous(benchPressId), ['70.0×10']);
      expect(await previous(squatId), ['100.0×5']);
    });
  });

  group('watchExerciseHistory (EX-07)', () {
    Future<List<ExerciseSession>> history(String exerciseId) =>
        repository.watchExerciseHistory(exerciseId).first;

    test('renvoie une liste vide pour un exercice jamais fait', () async {
      expect(await history(benchPressId), isEmpty);
    });

    test('une séance par bloc, de la plus récente à la plus ancienne, '
        'avec ses séries validées dans l’ordre', () async {
      await addWorkout(
        db,
        name: 'Séance du soir',
        day: monday,
        sets: [const TestSet(75, 8)],
      );
      await addWorkout(
        db,
        name: 'Push',
        day: wednesday,
        sets: [
          const TestSet(40, 10, type: SetType.warmup),
          const TestSet(80, 8),
          const TestSet(80, 7, done: false),
        ],
      );

      final sessions = await history(benchPressId);

      expect(sessions.map((s) => s.workoutName), ['Push', 'Séance du soir']);
      expect(sessions.first.date, wednesday);
      expect(sessions.first.sets.map(describe), ['40.0×10', '80.0×8']);
      expect(sessions.first.sets.first.setType, SetType.warmup);
    });

    test('ignore les séances en cours, supprimées ou sans série validée, '
        'et les autres exercices', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(90, 5)],
        finished: false,
      );
      await addWorkout(
        db,
        day: DateTime(2026, 9, 22),
        sets: [const TestSet(85, 5)],
        deleted: true,
      );
      await addWorkout(
        db,
        day: DateTime(2026, 9, 20),
        sets: [const TestSet(60, 5, done: false)],
      );
      await addWorkout(
        db,
        day: DateTime(2026, 9, 19),
        exerciseId: squatId,
        sets: [const TestSet(100, 5)],
      );

      final sessions = await history(benchPressId);

      expect(sessions, hasLength(1));
      expect(sessions.single.sets.map(describe), ['70.0×10']);
    });
  });

  group('séance en cours', () {
    Future<WorkoutDetails> details(String workoutId) async =>
        (await repository.watchWorkoutDetails(workoutId).first)!;

    test('démarre une séance depuis un modèle, qui lui donne son nom '
        '(WO-01)', () async {
      final workout = await repository.startWorkout(templateId);

      expect(workout.name, 'Séance libre');
      expect(workout.templateId, templateId);
      expect(workout.endedAt, isNull);
      expect((await repository.watchActiveWorkout().first)?.id, workout.id);
    });

    test('refuse une deuxième séance en cours (WO-02)', () async {
      await repository.startWorkout(templateId);

      await expectLater(
        repository.startWorkout(templateId),
        throwsA(isA<Exception>()),
      );
    });

    test('ajoute des exercices à la suite, chacun avec une série vide '
        '(WO-04)', () async {
      final workout = await repository.startWorkout(templateId);

      await repository.addExercises(workout.id, [benchPressId]);
      await repository.addExercises(workout.id, [squatId, pullUpId]);

      final exercises = (await details(workout.id)).exercises;
      expect(exercises.map((e) => e.exercise.name), [
        'Développé couché (barre)',
        'Squat (barre)',
        'Tractions',
      ]);
      expect(exercises.map((e) => e.entry.position), [0, 1, 2]);
      for (final exercise in exercises) {
        expect(exercise.sets, hasLength(1));
        expect(exercise.sets.single.completedAt, isNull);
      }
    });

    test('réordonne les exercices (WO-15)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [
        benchPressId,
        squatId,
        pullUpId,
      ]);
      final ids = [
        for (final item in (await details(workout.id)).exercises) item.entry.id,
      ];

      await repository.reorderExercises(workout.id, [ids[2], ids[0], ids[1]]);

      final exercises = (await details(workout.id)).exercises;
      expect(exercises.map((e) => e.exercise.id), [
        pullUpId,
        benchPressId,
        squatId,
      ]);
    });

    test('une nouvelle série reprend le repos de la précédente (WO-10, '
        'RG-12)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId]);
      final entry = (await details(workout.id)).exercises.single;
      await (db.update(db.workoutSets)
            ..where((s) => s.id.equals(entry.sets.single.id)))
          .write(const WorkoutSetsCompanion(restSeconds: Value(90)));

      await repository.addSet(entry.entry.id);

      final sets = (await details(workout.id)).exercises.single.sets;
      expect(sets.map((s) => s.position), [0, 1]);
      expect(sets.map((s) => s.restSeconds), [90, 90]);
    });

    test('saisit, valide puis dévalide une série (WO-07 à WO-09)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId]);
      Future<WorkoutSet> theSet() async =>
          (await details(workout.id)).exercises.single.sets.single;
      final setId = (await theSet()).id;

      await repository.updateSet(
        setId,
        weightKg: const Value(80),
        reps: const Value(8),
      );
      expect(describe(await theSet()), '80.0×8');
      expect((await theSet()).completedAt, isNull);

      await repository.completeSet(setId, weightKg: 82.5, reps: 6);
      expect(describe(await theSet()), '82.5×6');
      expect((await theSet()).completedAt, isNotNull);

      await repository.uncompleteSet(setId);
      expect((await theSet()).completedAt, isNull);
      expect(describe(await theSet()), '82.5×6');
    });

    test('terminer supprime les séries non validées et les exercices vides, '
        'puis alimente « Précédent »', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId, squatId]);
      final bench = (await details(workout.id)).exercises.first;
      await repository.completeSet(bench.sets.single.id, weightKg: 80, reps: 8);
      await repository.addSet(bench.entry.id); // restera vide

      await repository.finishWorkout(workout.id);

      final finished = await details(workout.id);
      expect(finished.workout.endedAt, isNotNull);
      expect(finished.exercises.map((e) => e.exercise.name), [
        'Développé couché (barre)',
      ]);
      expect(finished.exercises.single.sets.map(describe), ['80.0×8']);
      expect(await repository.watchActiveWorkout().first, isNull);
      expect((await repository.previousSets(benchPressId)).map(describe), [
        '80.0×8',
      ]);
    });

    test('refuse de terminer sans série validée (RG-08)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId]);

      await expectLater(
        repository.finishWorkout(workout.id),
        throwsA(isA<NoCompletedSetException>()),
      );
      expect(await repository.watchActiveWorkout().first, isNotNull);
    });

    test('« Tout valider » valide les séries complètes et supprime les '
        'séries partielles ou vides (WO-17)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId]);
      final entry = (await details(workout.id)).exercises.single;
      final first = entry.sets.single.id;
      await repository.updateSet(
        first,
        weightKg: const Value(80),
        reps: const Value(8),
      );
      await repository.addSet(entry.entry.id);
      await repository.addSet(entry.entry.id);
      final sets = (await details(workout.id)).exercises.single.sets;
      await repository.updateSet(sets[1].id, weightKg: const Value(80));

      await repository.finishWorkout(workout.id, validateReadySets: true);

      final finished = (await details(workout.id)).exercises.single.sets;
      expect(finished.map(describe), ['80.0×8']);
      expect(finished.single.completedAt, isNotNull);
    });

    test('renomme la séance (WO-01)', () async {
      final workout = await repository.startWorkout(templateId);

      await repository.renameWorkout(workout.id, '  Push  ');

      expect((await details(workout.id)).workout.name, 'Push');
    });

    test(
      'suppression de série, note et retrait d’exercice (WO-11, WO-13)',
      () async {
        final workout = await repository.startWorkout(templateId);
        await repository.addExercises(workout.id, [benchPressId, squatId]);
        final bench = (await details(workout.id)).exercises.first;
        await repository.addSet(bench.entry.id);
        final benchSets = (await details(workout.id)).exercises.first.sets;

        await repository.deleteSet(benchSets.last.id);
        await repository.updateExerciseNote(bench.entry.id, ' Siège cran 4 ');
        await repository.removeExercise(
          (await details(workout.id)).exercises.last.entry.id,
        );

        final result = await details(workout.id);
        expect(result.exercises, hasLength(1));
        expect(result.exercises.single.entry.notes, 'Siège cran 4');
        expect(result.exercises.single.sets.map((s) => s.id), [
          benchSets.first.id,
        ]);

        await repository.updateExerciseNote(bench.entry.id, '');
        expect(
          (await details(workout.id)).exercises.single.entry.notes,
          isNull,
        );
      },
    );

    test('temps de repos d’une série, ou de toutes celles d’un exercice '
        '(RT-07)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId]);
      final entry = (await details(workout.id)).exercises.single;
      await repository.addSet(entry.entry.id);
      Future<List<int?>> currentRests() async => [
        for (final s in (await details(workout.id)).exercises.single.sets)
          s.restSeconds,
      ];

      final first = (await details(workout.id)).exercises.single.sets.first;
      await repository.setSetRest(first.id, 90);
      expect(await currentRests(), [90, null]);

      await repository.setExerciseRest(entry.entry.id, 150);
      expect(await currentRests(), [150, 150]);

      await repository.setExerciseRest(entry.entry.id, null);
      expect(await currentRests(), [null, null]);
    });

    test('abandonner efface la séance et tout son contenu (WO-19)', () async {
      final workout = await repository.startWorkout(templateId);
      await repository.addExercises(workout.id, [benchPressId]);

      await repository.discardWorkout(workout.id);

      expect(await repository.watchWorkoutDetails(workout.id).first, isNull);
      expect(await db.select(db.workoutExercises).get(), isEmpty);
      expect(await db.select(db.workoutSets).get(), isEmpty);
    });
  });
}
