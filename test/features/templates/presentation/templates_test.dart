import 'package:app_muscu/features/exercises/data/exercise_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  Finder field(int index) => find.byType(TextField).at(index);
  String text(WidgetTester tester, int index) =>
      tester.widget<TextField>(field(index)).controller!.text;
  String? hint(WidgetTester tester, int index) =>
      tester.widget<TextField>(field(index)).decoration?.hintText;
  final nameField = find.widgetWithText(TextField, 'Nom du modèle');

  Finder inDialog(String text) =>
      find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> addExercises(WidgetTester tester, List<String> names) async {
    await tapAndSettle(tester, find.text('Ajouter des exercices'));
    for (final name in names) {
      await checkExercise(tester, name);
    }
    await tapAndSettle(tester, find.textContaining('Ajouter ('));
  }

  /// Touche la carte du modèle, puis « Démarrer la séance » dans l'aperçu.
  Future<void> startFromTemplate(
    WidgetTester tester, [
    String name = 'Push',
  ]) async {
    await tapAndSettle(tester, find.text(name));
    await tapAndSettle(tester, find.text('Démarrer la séance'));
  }

  Future<void> finishWorkout(WidgetTester tester) async {
    await tapAndSettle(tester, find.text('Terminer'));
    await tapAndSettle(tester, inDialog('Terminer'));
  }

  Future<void> openMenu(WidgetTester tester, String action) async {
    await tapAndSettle(tester, find.byTooltip('Options du modèle').first);
    await tapAndSettle(tester, find.text(action));
  }

  group('éditeur de modèle (TP-01, TP-03)', () {
    testApp('crée un modèle : nom, exercice, séries prévues', (tester) async {
      expect(find.text('Aucun modèle'), findsOneWidget);

      await tapAndSettle(tester, find.text('Nouveau'));
      expect(find.text('Nouveau modèle'), findsOneWidget);
      await tester.enterText(nameField, 'Push');
      await addExercises(tester, ['Développé couché (barre)']);
      await tester.enterText(field(1), '80');
      await tester.enterText(field(2), '8');
      await tapAndSettle(tester, find.text('Ajouter une série'));

      // La nouvelle série copie celle du dessus (RG-15).
      expect(text(tester, 3), '80');
      expect(text(tester, 4), '8');

      await tapAndSettle(tester, find.text('Enregistrer'));

      expect(find.text('Push'), findsOneWidget);
      expect(find.text('2 × Développé couché (barre)'), findsOneWidget);
      expect(find.text('Jamais utilisé'), findsOneWidget);
    });

    testApp('enregistrer demande un nom et au moins un exercice', (
      tester,
    ) async {
      await tapAndSettle(tester, find.text('Nouveau'));

      await tapAndSettle(tester, find.text('Enregistrer'));
      expect(find.text('Donne un nom au modèle'), findsOneWidget);

      await tester.enterText(nameField, 'Push');
      await tapAndSettle(tester, find.text('Enregistrer'));
      expect(find.text('Ajoute au moins un exercice'), findsOneWidget);
      expect(find.text('Nouveau modèle'), findsOneWidget);
    });

    testApp('quitter sans enregistrer demande confirmation', (tester) async {
      // Sans modification, on sort sans question.
      await tapAndSettle(tester, find.text('Nouveau'));
      await tapAndSettle(tester, find.byType(BackButton));
      expect(find.text('Aucun modèle'), findsOneWidget);

      await tapAndSettle(tester, find.text('Nouveau'));
      await tester.enterText(nameField, 'Push');
      await tester.pump(); // l'écran se redessine : retour désormais bloqué
      await tapAndSettle(tester, find.byType(BackButton));
      expect(find.text('Abandonner les modifications ?'), findsOneWidget);

      await tapAndSettle(tester, find.text('Continuer'));
      expect(find.text('Nouveau modèle'), findsOneWidget);

      await tapAndSettle(tester, find.byType(BackButton));
      await tapAndSettle(tester, find.text('Abandonner'));
      expect(find.text('Aucun modèle'), findsOneWidget);
    });

    testApp(
      'modifier un modèle depuis son menu',
      setUp: (db) => addTemplate(db),
      (tester) async {
        await openMenu(tester, 'Modifier');

        expect(find.text('Modifier le modèle'), findsOneWidget);
        expect(text(tester, 0), 'Push');
        expect(text(tester, 1), '80');

        await tester.enterText(field(0), 'Push lourd');
        await tester.enterText(field(1), '90');
        await tapAndSettle(tester, find.text('Enregistrer'));
        expect(find.text('Push lourd'), findsOneWidget);

        await openMenu(tester, 'Modifier');
        expect(text(tester, 1), '90');
      },
    );

    testApp(
      'réordonner et retirer des exercices',
      setUp: (db) => addTemplate(db),
      (tester) async {
        await openMenu(tester, 'Modifier');
        await addExercises(tester, ['Squat (barre)', 'Tractions']);

        // Appui long sur un nom : exercices réduits, à faire glisser.
        await tester.longPress(find.text('Squat (barre)'));
        await tester.pumpAndSettle();
        await dragUp(tester, 'Squat (barre)');
        await tapAndSettle(tester, find.text('OK'));

        await tapAndSettle(
          tester,
          find.byTooltip("Options de l'exercice").last,
        );
        await tapAndSettle(tester, find.text('Retirer du modèle'));
        await tapAndSettle(tester, find.text('Enregistrer'));

        // Carte : un exercice par ligne, dans le nouvel ordre.
        final squat = find.text('1 × Squat (barre)');
        final bench = find.text('1 × Développé couché (barre)');
        expect(squat, findsOneWidget);
        expect(bench, findsOneWidget);
        expect(find.text('1 × Tractions'), findsNothing);
        expect(
          tester.getTopLeft(squat).dy,
          lessThan(tester.getTopLeft(bench).dy),
        );
      },
    );
  });

  testApp(
    'la note de l’exercice se voit et se modifie dans l’éditeur, '
    'enregistrée tout de suite (EX-11)',
    setUp: (db) async {
      await addTemplate(db);
      await ExerciseRepository(db).updateNote(benchPressId, 'Siège cran 4');
    },
    (tester) async {
      await openMenu(tester, 'Modifier');
      expect(find.text('Siège cran 4'), findsOneWidget);

      await tapAndSettle(tester, find.byTooltip("Options de l'exercice"));
      await tapAndSettle(tester, find.text('Modifier la note'));
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Siège cran 5',
      );
      await tapAndSettle(tester, inDialog('Enregistrer'));
      expect(find.text('Siège cran 5'), findsOneWidget);

      // Le modèle n'a pas changé : on sort sans question, et la note reste.
      await tapAndSettle(tester, find.byType(BackButton));
      await tapAndSettle(tester, tab('Exercices'));
      await tapAndSettle(tester, find.text('Développé couché (barre)'));
      expect(find.text('Siège cran 5'), findsOneWidget);
    },
  );

  testApp(
    'dupliquer puis supprimer un modèle (TP-04, TP-03)',
    setUp: (db) => addTemplate(db),
    (tester) async {
      await openMenu(tester, 'Dupliquer');
      expect(find.text('Push (copie)'), findsOneWidget);

      await openMenu(tester, 'Supprimer');
      expect(find.text('Supprimer « Push » ?'), findsOneWidget);
      await tapAndSettle(tester, inDialog('Supprimer'));

      expect(find.text('Push'), findsNothing);
      expect(find.text('Push (copie)'), findsOneWidget);
    },
  );

  group('démarrer depuis un modèle (TP-05)', () {
    testApp(
      'la séance reprend le modèle ; ses valeurs passent avant '
      '« Précédent » (RG-11)',
      setUp: (db) async {
        await addWorkout(
          db,
          day: DateTime(2026, 9, 21, 18),
          sets: [const TestSet(70, 10), const TestSet(70, 9)],
        );
        await addTemplate(db, sets: [(80, 8), (80, null)]);
      },
      (tester) async {
        await startFromTemplate(tester);

        expect(find.text('Terminer'), findsOneWidget);
        expect(find.text('Push'), findsOneWidget); // nom de la séance
        expect(find.text('70 × 10'), findsOneWidget); // Précédent
        expect(hint(tester, 0), '80'); // modèle
        expect(hint(tester, 1), '8');
        expect(hint(tester, 2), '80'); // modèle
        expect(hint(tester, 3), '9'); // pas prévu → Précédent

        await tapAndSettle(tester, find.byTooltip('Valider la série').first);
        expect(text(tester, 0), '80');
        expect(text(tester, 1), '8');
      },
    );

    testApp(
      'une séance est déjà en cours : la reprendre (WO-02)',
      setUp: (db) async {
        await addTemplate(db);
        await addWorkout(
          db,
          day: DateTime(2026, 9, 26, 7),
          name: 'Séance du matin',
          sets: [const TestSet(80, 8)],
          finished: false,
        );
      },
      (tester) async {
        await startFromTemplate(tester);
        expect(find.text('Une séance est déjà en cours'), findsOneWidget);

        await tapAndSettle(tester, find.text('Reprendre la séance en cours'));
        expect(find.text('Séance du matin'), findsOneWidget);
        expect(find.text('Terminer'), findsOneWidget);
      },
    );

    testApp(
      'une séance est déjà en cours : l’abandonner (WO-02)',
      setUp: (db) async {
        await addTemplate(db);
        await addWorkout(
          db,
          day: DateTime(2026, 9, 26, 7),
          name: 'Séance du matin',
          sets: [const TestSet(80, 8)],
          finished: false,
        );
      },
      (tester) async {
        await startFromTemplate(tester);
        await tapAndSettle(tester, find.text("L'abandonner et démarrer"));

        expect(find.text('Push'), findsOneWidget);
        expect(find.text('Terminer'), findsOneWidget);
        await tapAndSettle(tester, find.byTooltip('Réduire'));
        expect(find.text('Séance du matin'), findsNothing);
      },
    );
  });

  group('fin de séance', () {
    testApp(
      'séance différente du modèle : le mettre à jour (TP-07)',
      setUp: (db) => addTemplate(db, sets: [(80, 8)]),
      (tester) async {
        await startFromTemplate(tester);
        await tester.enterText(field(0), '85');
        await tapAndSettle(tester, find.byTooltip('Valider la série'));
        await finishWorkout(tester);

        expect(
          find.text('La séance diffère du modèle « Push ».'),
          findsOneWidget,
        );
        await tapAndSettle(tester, find.text('Mettre à jour le modèle'));
        expect(find.text('Modèle « Push » mis à jour'), findsOneWidget);
        expect(
          find.text('La séance diffère du modèle « Push ».'),
          findsNothing,
        );

        await tapAndSettle(tester, find.text('OK'));
        expect(
          find.text("Aujourd'hui"),
          findsOneWidget,
        ); // dernière utilisation
        await openMenu(tester, 'Modifier');
        expect(text(tester, 1), '85');
      },
    );

    testApp(
      'séance conforme au modèle : rien à proposer',
      setUp: (db) => addTemplate(db, sets: [(80, 8)]),
      (tester) async {
        await startFromTemplate(tester);
        await tapAndSettle(tester, find.byTooltip('Valider la série'));
        await finishWorkout(tester);

        expect(find.text('Séance terminée'), findsOneWidget);
        expect(find.textContaining('diffère du modèle'), findsNothing);
      },
    );
  });
}
