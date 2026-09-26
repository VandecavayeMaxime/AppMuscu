import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/templates/domain/template_changes.dart';
import 'package:app_muscu/features/templates/domain/template_draft.dart';
import 'package:app_muscu/features/templates/domain/template_preview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'template_test_data.dart';

void main() {
  final bench = exercise('Développé couché');
  final squat = exercise('Squat');
  final plank = exercise('Gainage', TrackingType.duration);

  group('workoutDiffersFromTemplate (TP-07)', () {
    final push = template({
      bench: [planned(80, 8, rest: 120), planned(80, 8, rest: 120)],
      squat: [planned(100, 5)],
    });

    test('séance conforme au modèle : pas de différence', () {
      final session = workout({
        bench: [done(80, 8, rest: 120), done(80, 8, rest: 120)],
        squat: [done(100, 5)],
      });
      expect(workoutDiffersFromTemplate(session, push), isFalse);
    });

    test('les séries non validées sont ignorées', () {
      final session = workout({
        bench: [
          done(80, 8, rest: 120),
          done(80, 8, rest: 120),
          done(null, null, completed: false),
        ],
        squat: [done(100, 5)],
      });
      expect(workoutDiffersFromTemplate(session, push), isFalse);
    });

    test('valeur, nombre de séries, repos ou exercices différents', () {
      final changes = {
        'poids': workout({
          bench: [done(82.5, 8, rest: 120), done(80, 8, rest: 120)],
          squat: [done(100, 5)],
        }),
        'série en plus': workout({
          bench: [done(80, 8, rest: 120), done(80, 8, rest: 120)],
          squat: [done(100, 5), done(100, 5)],
        }),
        'repos': workout({
          bench: [done(80, 8, rest: 90), done(80, 8, rest: 120)],
          squat: [done(100, 5)],
        }),
        'exercice retiré': workout({
          bench: [done(80, 8, rest: 120), done(80, 8, rest: 120)],
        }),
        'ordre': workout({
          squat: [done(100, 5)],
          bench: [done(80, 8, rest: 120), done(80, 8, rest: 120)],
        }),
      };
      for (final MapEntry(key: change, value: session) in changes.entries) {
        expect(
          workoutDiffersFromTemplate(session, push),
          isTrue,
          reason: change,
        );
      }
    });

    test('une valeur prévue vide diffère de la valeur réalisée', () {
      final empty = template({
        bench: [planned(null, null)],
      });
      final session = workout({
        bench: [done(80, 8)],
      });
      expect(workoutDiffersFromTemplate(session, empty), isTrue);
    });

    test('seules comptent les valeurs du type de suivi', () {
      final gainage = template({
        plank: [planned(null, null, seconds: 60)],
      });
      expect(
        workoutDiffersFromTemplate(
          workout({
            plank: [done(null, null, seconds: 60)],
          }),
          gainage,
        ),
        isFalse,
      );
      expect(
        workoutDiffersFromTemplate(
          workout({
            plank: [done(null, null, seconds: 75)],
          }),
          gainage,
        ),
        isTrue,
      );
    });
  });

  group('TemplateDraft', () {
    test('une série ajoutée copie celle du dessus (RG-15)', () {
      final item = DraftExercise(bench, [
        DraftSet(weightKg: 80, reps: 8, restSeconds: 90),
      ]);

      item.addSet();

      expect(item.sets, hasLength(2));
      expect(item.sets[1].weightKg, 80);
      expect(item.sets[1].reps, 8);
      expect(item.sets[1].restSeconds, 90);
      expect(item.sets[1], isNot(same(item.sets[0])));
    });

    test('un exercice ajouté a une série vide', () {
      final item = DraftExercise(bench);
      expect(item.sets, hasLength(1));
      expect(item.sets.single.weightKg, isNull);
    });

    test('déplacer un exercice (glisser-déposer)', () {
      final draft = TemplateDraft(
        exercises: [
          DraftExercise(bench),
          DraftExercise(squat),
          DraftExercise(plank),
        ],
      );

      draft.moveExercise(2, 0);
      expect(draft.exercises.map((e) => e.exercise.name), [
        'Gainage',
        'Développé couché',
        'Squat',
      ]);

      draft.moveExercise(0, 2);
      expect(draft.exercises.last.exercise, plank);
    });

    test('depuis une séance : séries validées seulement (TP-07)', () {
      final draft = TemplateDraft.fromWorkout(
        workout({
          bench: [done(80, 8, rest: 90), done(80, 6, completed: false)],
          squat: [done(null, null, completed: false)],
        }),
      );

      expect(draft.name, 'Push');
      expect(draft.exercises, hasLength(1)); // squat sans série validée
      final set = draft.exercises.single.sets.single;
      expect((set.weightKg, set.reps, set.restSeconds), (80, 8, 90));
    });

    test('depuis un modèle enregistré', () {
      final draft = TemplateDraft.fromDetails(
        template({
          bench: [planned(80, 8, rest: 120)],
        }),
      );
      expect(draft.name, 'Push');
      final set = draft.exercises.single.sets.single;
      expect((set.weightKg, set.reps, set.restSeconds), (80, 8, 120));
    });
  });

  test('aperçu d’un modèle, une ligne par exercice (TP-02)', () {
    final preview = templatePreview(
      template({
        bench: [planned(80, 8), planned(80, 8), planned(80, 8)],
        squat: [planned(100, 5)],
      }),
    );
    expect(preview, ['3 × Développé couché', '1 × Squat']);
  });
}
