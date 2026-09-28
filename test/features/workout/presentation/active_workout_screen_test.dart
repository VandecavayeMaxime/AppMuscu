import 'package:app_muscu/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:app_muscu/features/workout/presentation/active_workout_bar.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  /// Toute séance part d'un modèle (WO-01) : chaque test dispose d'un modèle
  /// vide, « Séance libre », en plus de ce que prépare [setUp].
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

  /// Démarre une séance vide depuis le modèle « Séance libre ».
  Future<void> startWorkout(WidgetTester tester) async {
    await tester.tap(find.text('Séance libre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer la séance'));
    await tester.pumpAndSettle();
  }

  Future<void> addExercises(WidgetTester tester, List<String> names) async {
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();
    for (final name in names) {
      await checkExercise(tester, name);
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

  testWorkout('démarre une séance vide et y ajoute des exercices', (
    tester,
  ) async {
    await startWorkout(tester);

    expect(find.text('Terminer'), findsOneWidget);
    expect(find.text('Séance libre'), findsOneWidget); // nom du modèle

    await addExercises(tester, ['Squat (Barbell)', 'Pull-Up']);

    expect(find.text('Squat (Barbell)'), findsOneWidget);
    expect(find.text('Pull-Up'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget); // colonnes du squat
    expect(find.text('Reps'), findsNWidgets(2)); // squat + tractions
    expect(find.byTooltip('Valider la série'), findsNWidgets(2));
  });

  testWorkout('saisit et valide une série, puis ajoute une série', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (Barbell)']);

    await tester.enterText(field(0), '100');
    await tester.enterText(field(1), '5');
    await validateSet(tester);

    expect(find.byTooltip('Annuler la validation'), findsOneWidget);

    await tester.tap(find.text('Ajouter une série'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget); // numéro de la 2e série
    expect(find.byTooltip('Valider la série'), findsOneWidget);
  });

  testWorkout('refuse de valider une série vide sans valeur précédente', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (Barbell)']);

    await validateSet(tester);

    expect(find.text('Saisis le poids et les reps'), findsOneWidget);
    expect(find.byTooltip('Valider la série'), findsOneWidget);
  });

  testWorkout(
    'affiche « Précédent » et valide une série vide avec ces valeurs',
    setUp: (db) => addWorkout(
      db,
      day: DateTime(2026, 9, 21, 18),
      sets: [const TestSet(80, 8), const TestSet(80, 7)],
    ),
    (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Bench Press (Barbell)']);

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

  testWorkout(
    'taper sur « Précédent » recopie les valeurs',
    setUp: (db) => addWorkout(
      db,
      day: DateTime(2026, 9, 21, 18),
      sets: [const TestSet(77.5, 6)],
    ),
    (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Bench Press (Barbell)']);

      await tester.tap(find.text('77,5 × 6'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field(0)).controller!.text, '77,5');
      expect(tester.widget<TextField>(field(1)).controller!.text, '6');
    },
  );

  testWorkout('terminer : la séance apparaît dans l’historique de l’exercice', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (Barbell)']);
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
    expect(find.text('Modèles'), findsOneWidget);

    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
    await tapExercise(tester, 'Squat (Barbell)');
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
      await addExercises(tester, ['Squat (Barbell)']);
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

    testWorkout('sans série validée : propose d’abandonner la séance', (
      tester,
    ) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (Barbell)']);

      await tapFinish(tester);
      expect(find.text('Aucune série validée'), findsOneWidget);

      await tester.tap(inDialog('Continuer la séance'));
      await tester.pumpAndSettle();
      expect(find.text('Terminer'), findsOneWidget);

      await tapFinish(tester);
      await tester.tap(inDialog('Abandonner'));
      await tester.pumpAndSettle();
      expect(find.text('Modèles'), findsOneWidget);
    });

    testWorkout('séries inachevées : « Compléter »', (tester) async {
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

    testWorkout('séries inachevées : « Jeter »', (tester) async {
      await oneValidatedOneReady(tester);

      await tapFinish(tester);
      await tester.tap(inDialog('Jeter'));
      await tester.pumpAndSettle();

      expect(find.text('Séance terminée'), findsOneWidget);
      expect(stat('Séries', '1'), findsOneWidget);
    });

    testWorkout(
      'sans série validée mais avec des séries remplies : « Abandonner » '
      'plutôt que « Jeter »',
      (tester) async {
        await startWorkout(tester);
        await addExercises(tester, ['Squat (Barbell)']);
        await tester.enterText(field(0), '100');
        await tester.enterText(field(1), '5');
        await tester.pump();

        await tapFinish(tester);

        expect(inDialog('Jeter'), findsNothing);
        expect(inDialog('Compléter'), findsOneWidget);

        await tester.tap(inDialog('Abandonner'));
        await tester.pumpAndSettle();
        expect(find.text('Modèles'), findsOneWidget);
      },
    );

    testWorkout('le résumé affiche les chiffres de la séance', (tester) async {
      await oneValidatedOneReady(tester);
      await tapFinish(tester);
      await tester.tap(inDialog('Compléter'));
      await tester.pumpAndSettle();

      expect(stat('Exercices', '1'), findsOneWidget);
      expect(stat('Séries', '2'), findsOneWidget);
      // Volume : 100 × 5 + 100 × 4 = 900 kg
      expect(stat('Volume', '900 kg'), findsOneWidget);
      expect(find.text('Squat (Barbell)'), findsOneWidget);
      expect(find.text('100 kg × 5'), findsOneWidget);
      expect(find.text('100 kg × 4'), findsOneWidget);
      expect(find.textContaining(' → '), findsOneWidget); // horaires
      expect(find.text('Première fois avec cet exercice'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Modèles'), findsOneWidget);
    });

    testWorkout(
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
      await addExercises(tester, ['Squat (Barbell)']);
      await tester.tap(find.text('Ajouter une série'));
      await tester.pumpAndSettle();
    }

    testWorkout('balayer une série vers la gauche la supprime', (tester) async {
      await squatWithTwoSets(tester);

      // Geste parti de la colonne « Précédent » (« — ») : sur un champ de
      // saisie, le glissement servirait à sélectionner du texte.
      await tester.drag(find.text('—').first, const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWorkout('ajoute une note à un exercice, puis le retire', (
      tester,
    ) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (Barbell)', 'Pull-Up']);

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

      // La note est attachée à l'exercice : on la retrouve dans sa fiche,
      // ouverte depuis la séance comme depuis l'onglet Exercices (EX-11).
      await tester.tap(find.text('Squat (Barbell)'));
      await tester.pumpAndSettle();
      expect(find.text('Pieds un peu plus écartés'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip("Options de l'exercice").first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer de la séance'));
      await tester.pumpAndSettle();
      await tester.tap(inDialog('Retirer'));
      await tester.pumpAndSettle();

      expect(find.text('Squat (Barbell)'), findsNothing);
      expect(find.text('Pull-Up'), findsOneWidget);
    });

    testWorkout('toucher le nom de la séance permet de la renommer', (
      tester,
    ) async {
      await startWorkout(tester);

      await tester.tap(find.text('Séance libre'));
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

  testWorkout('annuler la séance la supprime', (tester) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (Barbell)']);

    await tester.tap(find.text('Annuler la séance'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Modèles'), findsOneWidget);
    expect(find.byTooltip('Reprendre la séance'), findsNothing);
  });

  group('séance réduite (WO-20, RT-08)', () {
    testWorkout('une barre au-dessus des onglets, dans chaque onglet, '
        'rouvre la séance', (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (Barbell)']);

      await tester.tap(find.byTooltip('Réduire'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Reprendre la séance'), findsOneWidget);

      await tester.tap(tab('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Reprendre la séance'), findsOneWidget);

      await tester.tap(find.byTooltip('Reprendre la séance'));
      await tester.pumpAndSettle();
      expect(find.text('Terminer'), findsOneWidget);
      expect(find.text('Squat (Barbell)'), findsOneWidget);
    });

    testWorkout('pendant un repos, la barre affiche le compteur', (
      tester,
    ) async {
      await startWorkout(tester);
      await addExercises(tester, ['Squat (Barbell)']);
      await tester.enterText(field(0), '100');
      await tester.enterText(field(1), '5');
      await validateSet(tester);

      await tester.tap(find.byTooltip('Réduire'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ActiveWorkoutBar),
          matching: find.byTooltip('Repos en cours'),
        ),
        findsOneWidget,
      );
    });

    testWorkout('ligne de repos hors de l’écran : compteur dans l’en-tête, '
        'qui y ramène', (tester) async {
      await startWorkout(tester);
      await addExercises(tester, [
        'Squat (Barbell)',
        'Bench Press (Barbell)',
        'Pull-Up',
      ]);
      // Écran plus petit (360 × 500 dp) : la séance ne tient plus en entier.
      tester.view.physicalSize = const Size(1080, 1500);
      await tester.pumpAndSettle();
      await tester.enterText(field(0), '100');
      await tester.enterText(field(1), '5');
      await validateSet(tester);
      final headerCountdown = find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip('Repos en cours'),
      );
      expect(headerCountdown, findsNothing); // la ligne est visible

      // Glisser depuis la colonne « Série », hors des champs de saisie.
      await tester.dragFrom(const Offset(20, 350), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(headerCountdown, findsOneWidget);

      await tester.tap(headerCountdown);
      await tester.pumpAndSettle();
      expect(headerCountdown, findsNothing);
    });
  });

  testWorkout(
    'toucher le nom d’un exercice ouvre sa fiche, puis revient à la séance',
    setUp: (db) => addWorkout(
      db,
      name: 'Push',
      day: DateTime(2026, 9, 21, 18),
      sets: [const TestSet(80, 8)],
    ),
    (tester) async {
      await startWorkout(tester);
      await addExercises(tester, ['Bench Press (Barbell)']);

      await tester.tap(find.text('Bench Press (Barbell)'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppBar, 'Bench Press (Barbell)'),
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

  testWorkout('dans le sélecteur, le nom ouvre la fiche et la sélection est '
      'conservée au retour', (tester) async {
    await startWorkout(tester);
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();
    await checkExercise(tester, 'Pull-Up');

    await tapExercise(tester, 'Squat (Barbell)');
    expect(find.widgetWithText(AppBar, 'Squat (Barbell)'), findsOneWidget);
    expect(find.text('À propos'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Ajouter (1)'), findsOneWidget);

    await tester.tap(find.text('Ajouter (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Pull-Up'), findsOneWidget);
    expect(find.text('Squat (Barbell)'), findsNothing);
  });

  testWorkout('le sélecteur est l’onglet Exercices : mêmes filtres, et un '
      'exercice créé est coché d’office', (tester) async {
    Future<void> choose(String label, String choice) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(choice).last);
      await tester.pumpAndSettle();
    }

    await startWorkout(tester);
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();

    await choose('Groupe musculaire', 'Dorsaux');
    expect(find.text('Squat (Barbell)'), findsNothing);
    expect(find.text('Pull-Up'), findsOneWidget);

    await tester.tap(find.byTooltip('Nouvel exercice'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom'),
      'Exercice test',
    );
    await choose('Groupe musculaire', 'Fessiers');
    await choose('Catégorie', 'Barre');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter (1)'), findsOneWidget);
    await tester.tap(find.text('Ajouter (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Exercice test'), findsOneWidget);
  });

  testWorkout('exercice « reps seules » : une seule colonne de saisie', (
    tester,
  ) async {
    await startWorkout(tester);
    await addExercises(tester, ['Push-Up']);

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(field(0), '12');
    await validateSet(tester);

    expect(find.byTooltip('Annuler la validation'), findsOneWidget);
  });

  testWorkout('appui long sur un exercice : le faire glisser pour changer '
      'l’ordre (WO-15)', (tester) async {
    await startWorkout(tester);
    await addExercises(tester, ['Squat (Barbell)', 'Pull-Up']);

    await tester.longPress(find.text('Pull-Up'));
    await tester.pumpAndSettle();
    expect(
      find.text('Glisse les exercices pour changer leur ordre'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing); // séries masquées

    await dragUp(tester, 'Pull-Up');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Pull-Up')).dy,
      lessThan(tester.getTopLeft(find.text('Squat (Barbell)')).dy),
    );
    expect(find.byType(TextField), findsNWidgets(3)); // séries revenues
  });

  group('toucher la notification de fin de repos (RT-10)', () {
    testWorkout('ouvre la séance en cours', (tester) async {
      await startWorkout(tester);
      await tester.tap(find.byTooltip('Réduire'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Exercices'));
      await tester.pumpAndSettle();

      notificationsOf(tester).tap();
      await tester.pumpAndSettle();
      expect(find.text('Terminer'), findsOneWidget);

      // Déjà sur la séance : rien ne change (pas de seconde séance empilée).
      notificationsOf(tester).tap();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Réduire'));
      await tester.pumpAndSettle();
      expect(find.text('Terminer'), findsNothing);
    });

    testWorkout('sans séance en cours, ne fait rien', (tester) async {
      notificationsOf(tester).tap();
      await tester.pumpAndSettle();
      expect(find.text('Modèles'), findsOneWidget);
      expect(find.text('Aucune séance en cours'), findsNothing);
    });
  });
}
