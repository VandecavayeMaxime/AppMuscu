import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/data/exercise_repository.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/rest_timer/presentation/rest_line.dart';
import 'package:app_muscu/features/workout/presentation/set_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  /// Chaque test dispose d'un modèle vide, « Séance libre » (WO-01).
  void testWorkout(
    String description,
    Future<void> Function(WidgetTester tester) body, {
    Future<void> Function(AppDatabase db)? setUp,
  }) => testApp(
    description,
    body,
    setUp: (db) async {
      await addEmptyTemplate(db);
      await setUp?.call(db);
    },
  );

  Future<void> startWorkoutWith(WidgetTester tester, String exercise) async {
    await tester.tap(find.text('Séance libre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer la séance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();
    await checkExercise(tester, exercise);
    await tester.tap(find.textContaining('Ajouter ('));
    await tester.pumpAndSettle();
  }

  Future<void> addSet(WidgetTester tester) async {
    await tester.tap(find.text('Ajouter une série'));
    await tester.pumpAndSettle();
  }

  /// Remplit la série [index] (poids + reps) et la valide.
  Future<void> fillAndValidate(WidgetTester tester, int index) async {
    await tester.enterText(find.byType(TextField).at(index * 2), '100');
    await tester.enterText(find.byType(TextField).at(index * 2 + 1), '5');
    await tester.tap(find.byTooltip('Valider la série').first);
    await tester.pumpAndSettle();
  }

  Future<void> chooseRest(
    WidgetTester tester,
    String choice, {
    bool allSets = false,
  }) async {
    await tester.tap(find.text('2:00').first);
    await tester.pumpAndSettle();
    if (allSets) {
      await tester.tap(
        find.text("Appliquer à toutes les séries de l'exercice"),
      );
      await tester.pump();
    }
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  Finder runningBar() => find.byType(LinearProgressIndicator);

  testWorkout('une ligne de repos sous chaque série, avec le temps prévu '
      '(RT-03)', (tester) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await addSet(tester);

    expect(find.text('2:00'), findsNWidgets(2));
  });

  testWorkout('repos terminé : ligne surlignée comme la série validée', (
    tester,
  ) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await addSet(tester);
    // Valider la 2e série arrête le repos de la 1re : il est terminé.
    await fillAndValidate(tester, 0);
    await fillAndValidate(tester, 1);

    final highlight = completedSetColor(
      Theme.of(tester.element(find.byType(RestLine).first)).colorScheme,
    );
    bool isHighlighted(Finder restLine) => tester
        .widgetList<Ink>(
          find.descendant(of: restLine, matching: find.byType(Ink)),
        )
        .any(
          (ink) =>
              ink.decoration is BoxDecoration &&
              (ink.decoration! as BoxDecoration).color == highlight,
        );

    expect(isHighlighted(find.byType(RestLine).first), isTrue); // terminé
    expect(isHighlighted(find.byType(RestLine).last), isFalse); // en cours
  });

  testWorkout('valider une série lance le repos et programme la notification '
      '(RT-02, RT-05)', (tester) async {
    await startWorkoutWith(tester, 'Squat (barre)');

    await fillAndValidate(tester, 0);

    expect(runningBar(), findsOneWidget);
    final scheduled = notificationsOf(tester).scheduled;
    expect(scheduled.single.nextExercise, 'Squat (barre)');
  });

  testWorkout('dévalider la série arrête le repos', (tester) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await fillAndValidate(tester, 0);

    await tester.tap(find.byTooltip('Annuler la validation'));
    await tester.pumpAndSettle();

    expect(runningBar(), findsNothing);
    expect(find.text('2:00'), findsOneWidget);
    expect(notificationsOf(tester).cancellations, 1);
  });

  testWorkout('valider la série suivante déplace le repos sous celle-ci', (
    tester,
  ) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await addSet(tester);

    await fillAndValidate(tester, 0);
    await fillAndValidate(tester, 1);

    expect(runningBar(), findsOneWidget);
    expect(notificationsOf(tester).scheduled, hasLength(2));
  });

  testWorkout('toucher une ligne change le repos de cette série (RT-07)', (
    tester,
  ) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await addSet(tester);

    await chooseRest(tester, '1:30');

    expect(find.text('1:30'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
  });

  testWorkout('… ou de toutes les séries de l’exercice', (tester) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await addSet(tester);

    await chooseRest(tester, '1:30', allSets: true);

    expect(find.text('1:30'), findsNWidgets(2));
  });

  testWorkout('« Sans repos » : valider ne lance pas de minuteur (RT-01)', (
    tester,
  ) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await chooseRest(tester, 'Sans repos');
    expect(find.text('Sans repos'), findsOneWidget);

    await fillAndValidate(tester, 0);

    expect(runningBar(), findsNothing);
    expect(notificationsOf(tester).scheduled, isEmpty);
  });

  testWorkout(
    'le repos par défaut de l’exercice s’applique (RG-09)',
    setUp: (db) => ExerciseRepository(db).updatePreferences(
      benchPressId,
      weightUnit: WeightUnit.kg,
      defaultRestSeconds: 60,
    ),
    (tester) async {
      await startWorkoutWith(tester, 'Développé couché (barre)');

      expect(find.text('1:00'), findsOneWidget);
    },
  );

  testWorkout('terminer la séance arrête le repos (RT-04)', (tester) async {
    await startWorkoutWith(tester, 'Squat (barre)');
    await fillAndValidate(tester, 0);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Terminer'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Séance terminée'), findsOneWidget);
    expect(notificationsOf(tester).cancellations, greaterThanOrEqualTo(1));
  });
}
