import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/templates/data/template_repository.dart';
import 'package:app_muscu/features/workout/data/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late TemplateRepository templates;
  late WorkoutRepository workouts;
  late Exercise bench;
  late Exercise squat;

  setUp(() async {
    db = createTestDatabase();
    templates = TemplateRepository(db);
    workouts = WorkoutRepository(db);
    Future<Exercise> find(String id) =>
        (db.select(db.exercises)..where((e) => e.id.equals(id))).getSingle();
    bench = await find(benchPressId);
    squat = await find(squatId);
  });
  tearDown(() => db.close());

  /// « Push » : 2 × développé couché (80 × 8, repos 1:30), 1 × squat vide.
  TemplateDraft push() => TemplateDraft(
    name: ' Push ',
    exercises: [
      DraftExercise(bench, [
        DraftSet(weightKg: 80, reps: 8, restSeconds: 90),
        DraftSet(weightKg: 80, reps: 8, restSeconds: 90),
      ]),
      DraftExercise(squat),
    ],
  );

  /// Contenu lisible d'un modèle : ['Bench Press (Barbell) 80.0×8 90', …].
  List<String> describe(TemplateDetails details) => [
    for (final item in details.exercises)
      for (final set in item.sets)
        '${item.exercise.name} ${set.weightKg}×${set.reps} ${set.restSeconds}',
  ];

  group('enregistrer (TP-01, TP-03)', () {
    test(
      'crée un modèle avec ses exercices et ses séries, dans l’ordre',
      () async {
        final id = await templates.saveTemplate(push());

        final details = (await templates.getTemplate(id))!;
        expect(details.template.name, 'Push');
        expect(details.lastUsedAt, isNull);
        expect(describe(details), [
          'Bench Press (Barbell) 80.0×8 90',
          'Bench Press (Barbell) 80.0×8 90',
          'Squat (Barbell) null×null null',
        ]);
      },
    );

    test('les nouveaux modèles s’ajoutent en fin de liste', () async {
      await templates.saveTemplate(push()..name = 'A');
      await templates.saveTemplate(push()..name = 'B');

      final list = await templates.watchTemplates().first;
      expect(list.map((t) => t.template.name), ['A', 'B']);
    });

    test('réordonner les modèles (TP-08)', () async {
      final a = await templates.saveTemplate(push()..name = 'A');
      final b = await templates.saveTemplate(push()..name = 'B');
      final c = await templates.saveTemplate(push()..name = 'C');

      await templates.reorderTemplates([c, a, b]);

      final list = await templates.watchTemplates().first;
      expect(list.map((t) => t.template.name), ['C', 'A', 'B']);
    });

    test('modifier remplace le nom et tout le contenu', () async {
      final id = await templates.saveTemplate(push());

      final draft = TemplateDraft.fromDetails(
        (await templates.getTemplate(id))!,
      )..name = 'Push lourd';
      draft.exercises.removeAt(0);
      draft.exercises.single.sets.single.weightKg = 120;
      await templates.saveTemplate(draft, templateId: id);

      final details = (await templates.getTemplate(id))!;
      expect(details.template.name, 'Push lourd');
      expect(describe(details), ['Squat (Barbell) 120.0×null null']);
      // Les anciennes séries ont bien été effacées (suppression en cascade).
      expect(await db.select(db.templateSets).get(), hasLength(1));
    });
  });

  test('dupliquer (TP-04)', () async {
    final id = await templates.saveTemplate(push());

    final copyId = await templates.duplicateTemplate(id);

    final copy = (await templates.getTemplate(copyId!))!;
    expect(copy.template.name, 'Push (copie)');
    expect(describe(copy), describe((await templates.getTemplate(id))!));
  });

  test(
    'supprimer : le modèle disparaît, ses séances restent (TP-03)',
    () async {
      final id = await templates.saveTemplate(push());
      final workout = await workouts.startWorkout(id);

      await templates.deleteTemplate(id);

      expect(await templates.watchTemplates().first, isEmpty);
      expect(await templates.getTemplate(id), isNull);
      expect(await workouts.getWorkoutDetails(workout.id), isNotNull);
    },
  );

  group('démarrer une séance depuis un modèle (TP-05)', () {
    test('reprend le nom, les exercices, les séries, les repos et les '
        'valeurs prévues', () async {
      final id = await templates.saveTemplate(push());

      final workout = await workouts.startWorkout(id);

      final details = (await workouts.getWorkoutDetails(workout.id))!;
      expect(details.workout.name, 'Push');
      expect(details.workout.templateId, id);
      expect(details.exercises.map((e) => e.exercise.id), [
        benchPressId,
        squatId,
      ]);
      final first = details.exercises.first.sets.first;
      expect(first.plannedWeightKg, 80);
      expect(first.plannedReps, 8);
      expect(first.restSeconds, 90);
      // Rien n'est encore saisi ni validé.
      expect(first.weightKg, isNull);
      expect(first.completedAt, isNull);
      expect(details.exercises.first.sets, hasLength(2));
      expect(details.exercises.last.sets, hasLength(1));
    });

    test('dernière utilisation : mise à jour quand la séance se termine '
        '(TP-02)', () async {
      final id = await templates.saveTemplate(push());
      final lastUsed = templates.watchTemplates().map(
        (list) => list.single.lastUsedAt,
      );
      final expectation = expectLater(
        lastUsed,
        emitsInOrder([isNull, emitsThrough(isNotNull)]),
      );

      final workout = await workouts.startWorkout(id);
      final details = (await workouts.getWorkoutDetails(workout.id))!;
      await workouts.completeSet(
        details.exercises.first.sets.first.id,
        weightKg: 80,
        reps: 8,
      );
      await workouts.finishWorkout(workout.id);

      await expectation;
      expect((await templates.getTemplate(id))!.lastUsedAt, workout.startedAt);
    });
  });

  group('depuis une séance terminée', () {
    /// Séance « Push » terminée : 1 × développé couché 85 × 6 (repos 2:00).
    Future<WorkoutDetails> finishedPush(String templateId) async {
      final workout = await workouts.startWorkout(templateId);
      var details = (await workouts.getWorkoutDetails(workout.id))!;
      final benchSets = details.exercises.first.sets;
      await workouts.setSetRest(benchSets.first.id, 120);
      await workouts.completeSet(benchSets.first.id, weightKg: 85, reps: 6);
      await workouts.finishWorkout(workout.id);
      details = (await workouts.getWorkoutDetails(workout.id))!;
      return details;
    }

    test(
      'mettre à jour le modèle (TP-07) : séries validées, même nom',
      () async {
        final id = await templates.saveTemplate(push());
        final workout = await finishedPush(id);

        await templates.updateFromWorkout(id, workout);

        final details = (await templates.getTemplate(id))!;
        expect(details.template.name, 'Push');
        expect(describe(details), ['Bench Press (Barbell) 85.0×6 120']);
      },
    );
  });
}
