import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  Future<void> startWorkout(WidgetTester tester) async {
    await tester.tap(find.text('Démarrer une séance vide'));
    await tester.pumpAndSettle();
  }

  /// Case à cocher d'un exercice dans le sélecteur.
  Finder checkboxOf(String name) => find.descendant(
    of: find.widgetWithText(ListTile, name),
    matching: find.byType(Checkbox),
  );

  Future<void> addExercises(WidgetTester tester, List<String> names) async {
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();
    for (final name in names) {
      await tester.tap(checkboxOf(name));
      await tester.pump();
    }
    await tester.tap(find.textContaining('Ajouter ('));
    await tester.pumpAndSettle();
  }

  Future<void> validateSet(WidgetTester tester, {int index = 0}) async {
    await tester.tap(find.byTooltip('Valider la série').at(index));
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextField).at(index);

  Finder inDialog(String text) =>
      find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

  testApp('démarre une séance vide et y ajoute des exercices', (tester) async {
    await startWorkout(tester);

    expect(find.text('Terminer'), findsOneWidget);
    expect(find.textContaining('Séance d'), findsOneWidget);

    await addExercises(tester, ['Squat (barre)', 'Tractions']);

    expect(find.text('Squat (barre)'), findsOneWidget);
    expect(find.text('Tractions'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget); // colonnes du squat
    expect(find.text('Reps'), findsNWidgets(2)); // squat + tractions
    expect(find.byTooltip('Valider la série'), findsNWidgets(2));
  });

  testApp('saisit et valide une série, puis ajoute une série', (tester) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (barre)']);

    await tester.enterText(field(0), '100');
    await tester.enterText(field(1), '5');
    await validateSet(tester);

    expect(find.byTooltip('Annuler la validation'), findsOneWidget);

    await tester.tap(find.text('Ajouter une série'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget); // numéro de la 2e série
    expect(find.byTooltip('Valider la série'), findsOneWidget);
  });

  testApp('refuse de valider une série vide sans valeur précédente', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (barre)']);

    await validateSet(tester);

    expect(find.text('Saisis le poids et les reps'), findsOneWidget);
    expect(find.byTooltip('Valider la série'), findsOneWidget);
  });

  testApp(
    'affiche « Précédent » et valide une série vide avec ces valeurs',
    setUp: (db) => addWorkout(
      db,
      day: DateTime(2026, 9, 21, 18),
      sets: [const TestSet(80, 8), const TestSet(80, 7)],
    ),
    (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Développé couché (barre)']);

      expect(find.text('80 × 8'), findsOneWidget);

      await validateSet(tester);
      expect(find.byTooltip('Annuler la validation'), findsOneWidget);
      expect(
        tester.widget<TextField>(field(0)).controller!.text,
        '80',
      ); // placeholder repris

      await tester.tap(find.text('Ajouter une série'));
      await tester.pumpAndSettle();
      expect(find.text('80 × 7'), findsOneWidget);
    },
  );

  testApp(
    'taper sur « Précédent » recopie les valeurs',
    setUp: (db) => addWorkout(
      db,
      day: DateTime(2026, 9, 21, 18),
      sets: [const TestSet(77.5, 6)],
    ),
    (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Développé couché (barre)']);

      await tester.tap(find.text('77,5 × 6'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field(0)).controller!.text, '77,5');
      expect(tester.widget<TextField>(field(1)).controller!.text, '6');
    },
  );

  testApp('terminer : la séance apparaît dans l’historique de l’exercice', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (barre)']);
    await tester.enterText(field(0), '100');
    await tester.enterText(field(1), '5');
    await validateSet(tester);
    await tester.tap(find.text('Ajouter une série')); // restera vide
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Terminer'));
    await tester.pumpAndSettle();

    expect(find.text('Séance terminée'), findsOneWidget); // résumé
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Démarrer une séance vide'), findsOneWidget);

    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat (barre)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();

    expect(find.text('100 kg × 5'), findsOneWidget);
    expect(
      find.textContaining(' kg × '),
      findsOneWidget,
    ); // série vide supprimée
  });

  group('terminer (WO-17, WO-18)', () {
    Future<void> tapFinish(WidgetTester tester) async {
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();
    }

    /// Squat : 1re série 100 × 5 validée, 2e série 100 × 4 remplie mais pas
    /// validée.
    Future<void> oneValidatedOneReady(WidgetTester tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (barre)']);
      await tester.enterText(field(0), '100');
      await tester.enterText(field(1), '5');
      await validateSet(tester);
      await tester.tap(find.text('Ajouter une série'));
      await tester.pumpAndSettle();
      await tester.enterText(field(2), '100');
      await tester.enterText(field(3), '4');
      await tester.pump();
    }

    /// La case du résumé intitulée [label] affiche [value].
    Finder stat(String label, String value) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Card)),
      matching: find.text(value),
    );

    testApp('sans série validée : propose d’abandonner la séance', (
      tester,
    ) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (barre)']);

      await tapFinish(tester);
      expect(find.text('Aucune série validée'), findsOneWidget);

      await tester.tap(inDialog('Continuer la séance'));
      await tester.pumpAndSettle();
      expect(find.text('Terminer'), findsOneWidget);

      await tapFinish(tester);
      await tester.tap(inDialog('Abandonner'));
      await tester.pumpAndSettle();
      expect(find.text('Démarrer une séance vide'), findsOneWidget);
    });

    testApp('séries inachevées : « Compléter »', (tester) async {
      await oneValidatedOneReady(tester);

      await tapFinish(tester);
      expect(
        find.text('1 série est remplie mais pas validée.'),
        findsOneWidget,
      );
      await tester.tap(inDialog('Compléter'));
      await tester.pumpAndSettle();

      expect(find.text('Séance terminée'), findsOneWidget);
      expect(stat('Séries', '2'), findsOneWidget);
    });

    testApp('séries inachevées : « Jeter »', (tester) async {
      await oneValidatedOneReady(tester);

      await tapFinish(tester);
      await tester.tap(inDialog('Jeter'));
      await tester.pumpAndSettle();

      expect(find.text('Séance terminée'), findsOneWidget);
      expect(stat('Séries', '1'), findsOneWidget);
    });

    testApp('sans série validée mais avec des séries remplies : pas de '
        '« Jeter »', (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (barre)']);
      await tester.enterText(field(0), '100');
      await tester.enterText(field(1), '5');
      await tester.pump();

      await tapFinish(tester);

      expect(inDialog('Jeter'), findsNothing);
      expect(inDialog('Compléter'), findsOneWidget);
    });

    testApp('le résumé affiche les chiffres de la séance', (tester) async {
      await oneValidatedOneReady(tester);
      await tapFinish(tester);
      await tester.tap(inDialog('Compléter'));
      await tester.pumpAndSettle();

      expect(stat('Exercices', '1'), findsOneWidget);
      expect(stat('Séries', '2'), findsOneWidget);
      // Volume : 100 × 5 + 100 × 4 = 900 kg
      expect(stat('Volume', '900 kg'), findsOneWidget);
      expect(find.text('Squat (barre)'), findsOneWidget);
      expect(find.text('100 kg × 5'), findsOneWidget);
      expect(find.text('100 kg × 4'), findsOneWidget);
      expect(find.textContaining(' → '), findsOneWidget); // horaires
      expect(find.text('Première fois avec cet exercice'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Démarrer une séance vide'), findsOneWidget);
    });

    testApp(
      'le résumé compare chaque exercice à la dernière fois',
      setUp: (db) => addWorkout(
        db,
        exerciseId: squatId,
        day: DateTime(2026, 9, 21, 18),
        sets: [const TestSet(95, 5), const TestSet(95, 5)],
      ),
      (tester) async {
        await oneValidatedOneReady(tester);
        await tapFinish(tester);
        await tester.tap(inDialog('Compléter'));
        await tester.pumpAndSettle();

        // Volume : 900 kg contre 950 kg la dernière fois → en baisse.
        expect(find.text('−50 kg'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
        // Meilleure série : 100 × 5 bat 95 × 5 → en hausse.
        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
        expect(find.text('Dernière fois : 95 kg × 5'), findsOneWidget);
      },
    );
  });

  group('séries et exercices (WO-11 à WO-13, WO-01)', () {
    Future<void> squatWithTwoSets(WidgetTester tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (barre)']);
      await tester.tap(find.text('Ajouter une série'));
      await tester.pumpAndSettle();
    }

    testApp('balayer une série vers la gauche la supprime', (tester) async {
      await squatWithTwoSets(tester);

      // Geste parti de la colonne « Précédent » (« — ») : sur un champ de
      // saisie, le glissement servirait à sélectionner du texte.
      await tester.drag(find.text('—').first, const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testApp('ajoute une note à un exercice, puis le retire', (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (barre)', 'Tractions']);

      await tester.tap(find.byTooltip("Options de l'exercice").first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter une note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Pieds un peu plus écartés',
      );
      await tester.tap(inDialog('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Pieds un peu plus écartés'), findsOneWidget);

      await tester.tap(find.byTooltip("Options de l'exercice").first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer de la séance'));
      await tester.pumpAndSettle();
      await tester.tap(inDialog('Retirer'));
      await tester.pumpAndSettle();

      expect(find.text('Squat (barre)'), findsNothing);
      expect(find.text('Tractions'), findsOneWidget);
    });

    testApp('toucher le nom de la séance permet de la renommer', (
      tester,
    ) async {
      await startWorkout(tester);

      await tester.tap(find.textContaining('Séance d'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Push',
      );
      await tester.tap(inDialog('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Push'), findsOneWidget);
    });
  });

  testApp('annuler la séance la supprime', (tester) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (barre)']);

    await tester.tap(find.text('Annuler la séance'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Démarrer une séance vide'), findsOneWidget);
    expect(find.text('Reprendre'), findsNothing);
  });

  testApp('réduire la séance puis la reprendre depuis l’onglet Séance', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (barre)']);

    await tester.tap(find.byTooltip('Réduire'));
    await tester.pumpAndSettle();

    expect(find.text('Séance en cours'), findsOneWidget);
    expect(find.text('Démarrer une séance vide'), findsNothing);

    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();

    expect(find.text('Squat (barre)'), findsOneWidget);
  });

  testApp(
    'toucher le nom d’un exercice ouvre sa fiche, puis revient à la séance',
    setUp: (db) => addWorkout(
      db,
      name: 'Push',
      day: DateTime(2026, 9, 21, 18),
      sets: [const TestSet(80, 8)],
    ),
    (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Développé couché (barre)']);

      await tester.tap(find.text('Développé couché (barre)'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppBar, 'Développé couché (barre)'),
        findsOneWidget,
      );
      expect(find.byTooltip("Plus d'options"), findsNothing);
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.text('Push'), findsOneWidget);

      // (tester.pageBack() cherche le bouton de flutter/material, pas celui
      // de material_ui : on tape directement sur notre BackButton.)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Terminer'), findsOneWidget);
    },
  );

  testApp('dans le sélecteur, le nom ouvre la fiche et la sélection est '
      'conservée au retour', (tester) async {
    await startWorkout(tester);
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();
    await tester.tap(checkboxOf('Tractions'));
    await tester.pump();

    await tester.tap(find.text('Squat (barre)'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Squat (barre)'), findsOneWidget);
    expect(find.text('À propos'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Ajouter (1)'), findsOneWidget);

    await tester.tap(find.text('Ajouter (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Tractions'), findsOneWidget);
    expect(find.text('Squat (barre)'), findsNothing);
  });

  testApp('exercice « reps seules » : une seule colonne de saisie', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Tractions']);

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(field(0), '12');
    await validateSet(tester);

    expect(find.byTooltip('Annuler la validation'), findsOneWidget);
  });
}
