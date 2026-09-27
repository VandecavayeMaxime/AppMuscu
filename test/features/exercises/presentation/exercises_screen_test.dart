import 'package:app_muscu/features/exercises/data/exercise_repository.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> openExercisesTab(WidgetTester tester) async {
    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
  }

  Future<void> openNewExerciseForm(WidgetTester tester) async {
    await openExercisesTab(tester);
    await tester.tap(find.byTooltip('Nouvel exercice'));
    await tester.pumpAndSettle();
  }

  /// Ouvre la liste déroulante [label] et choisit [choice].
  Future<void> choose(WidgetTester tester, String label, String choice) async {
    // `warnIfMissed: false` : une fois une valeur choisie, le libellé se
    // réduit en petit label flottant, en dehors de sa zone tactile réelle
    // (le `InputDecorator` autour reste bien touché, lui).
    await tester.tap(find.text(label), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.widgetWithText(TextFormField, 'Nom');

  group('liste (EX-02, EX-03)', () {
    testApp('affiche les 83 exercices de base par ordre alphabétique', (
      tester,
    ) async {
      await openExercisesTab(tester);

      // La bibliothèque est grande : seul le début de la liste est construit
      // (liste paresseuse), d'où des vérifications sur les tout premiers.
      expect(
        tester.getTopLeft(find.text('Ab Wheel Rollout')).dy,
        lessThan(tester.getTopLeft(find.text('Arnold Press')).dy),
      );
      // Seul « Ab Wheel Rollout » est abdos + autre.
      expect(find.text('Abdos · Autre'), findsOneWidget);
      // Barre verticale toujours visible, pour voir où on en est.
      expect(
        tester.widget<Scrollbar>(find.byType(Scrollbar)).thumbVisibility,
        isTrue,
      );
    });

    testApp('recherche sans tenir compte des accents', (tester) async {
      await openExercisesTab(tester);

      await tester.enterText(find.byType(SearchBar), 'press');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(11));
      expect(find.text('Bench Press (Barbell)'), findsOneWidget);
      expect(find.text('Overhead Press (Barbell)'), findsOneWidget);
    });

    testApp('affiche un message quand rien ne correspond', (tester) async {
      await openExercisesTab(tester);

      await tester.enterText(find.byType(SearchBar), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Aucun exercice trouvé'), findsOneWidget);
    });

    testApp('filtre par groupe musculaire, puis retire le filtre', (
      tester,
    ) async {
      await openExercisesTab(tester);

      await tester.tap(find.text('Groupe musculaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dorsaux'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(8));
      expect(find.text('Pull-Up'), findsOneWidget);
      // Retiré par le filtre : pas un exercice de dos.
      expect(find.text('Ab Wheel Rollout'), findsNothing);

      await tester.tap(find.byTooltip('Retirer le filtre'));
      await tester.pumpAndSettle();

      // Premier de la liste complète, revenu en tête.
      expect(find.text('Ab Wheel Rollout'), findsOneWidget);
    });
  });

  group('exercices perso (EX-04 à EX-06)', () {
    testApp('crée un exercice perso', (tester) async {
      await openNewExerciseForm(tester);

      await tester.enterText(nameField(), 'Exercice test');
      await choose(tester, 'Groupe musculaire', 'Fessiers');
      await choose(tester, 'Catégorie', 'Barre');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);
      final tile = await findExerciseTile(tester, 'Exercice test');
      expect(tile, findsOneWidget);
      expect(
        find.descendant(of: tile, matching: find.text('Fessiers · Barre')),
        findsOneWidget,
      );
    });

    testApp('exige les champs obligatoires', (tester) async {
      await openNewExerciseForm(tester);

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Le nom est obligatoire'), findsOneWidget);
      expect(find.text('Choisis un groupe musculaire'), findsOneWidget);
      expect(find.text('Choisis une catégorie'), findsOneWidget);
    });

    testApp('muscles secondaires : le groupe principal est exclu, retiré s’il '
        'redevient le principal (EX-04)', (tester) async {
      await openNewExerciseForm(tester);

      await tester.enterText(nameField(), 'Exercice test');
      await choose(tester, 'Groupe musculaire', 'Fessiers');
      // Le groupe principal ne se propose pas comme muscle secondaire.
      expect(find.widgetWithText(FilterChip, 'Fessiers'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'Quadriceps'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Ischios'));
      await tester.pumpAndSettle();

      // Changer le groupe principal retire le muscle devenu principal.
      await choose(tester, 'Groupe musculaire', 'Quadriceps');
      expect(find.widgetWithText(FilterChip, 'Quadriceps'), findsNothing);
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Ischios'))
            .selected,
        isTrue,
      );

      await choose(tester, 'Catégorie', 'Barre');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      await tapExercise(tester, 'Exercice test');
      expect(
        find.widgetWithText(ListTile, 'Muscles secondaires'),
        findsOneWidget,
      );
      expect(find.text('Ischios'), findsOneWidget);
    });

    testApp('refuse un nom déjà pris', (tester) async {
      await openNewExerciseForm(tester);

      await tester.enterText(nameField(), 'squat (BARBELL)');
      await choose(tester, 'Groupe musculaire', 'Quadriceps');
      await choose(tester, 'Catégorie', 'Barre');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Un exercice porte déjà ce nom'), findsOneWidget);
      // On reste sur le formulaire.
      expect(find.text('Nouvel exercice'), findsOneWidget);
    });

    testApp(
      'modifie puis supprime un exercice perso',
      setUp: (db) => ExerciseRepository(db).createCustom(
        name: 'Exercice test',
        equipment: Equipment.barbell,
        bodyPart: BodyPart.glutes,
        trackingType: TrackingType.weightReps,
      ),
      (tester) async {
        Future<void> openMenu(String item) async {
          await tester.tap(find.byTooltip("Plus d'options"));
          await tester.pumpAndSettle();
          await tester.tap(find.text(item));
          await tester.pumpAndSettle();
        }

        await openExercisesTab(tester);
        await tapExercise(tester, 'Exercice test');

        // Fiche → Modifier → formulaire → retour à la fiche.
        await openMenu('Modifier');
        expect(find.text("Modifier l'exercice"), findsOneWidget);
        await tester.enterText(nameField(), 'Exercice test (machine)');
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(AppBar, 'Exercice test (machine)'),
          findsOneWidget,
        );

        // Fiche → Supprimer → confirmation → retour à la liste.
        await openMenu('Supprimer');
        await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);
        expect(find.text('Exercice test (machine)'), findsNothing);
        expect(
          await findExerciseTile(tester, 'Ab Wheel Rollout'),
          findsOneWidget,
        );
      },
    );

    testApp('un exercice intégré ouvre sa fiche, sans menu Modifier', (
      tester,
    ) async {
      await openExercisesTab(tester);

      await tapExercise(tester, 'Squat (Barbell)');

      expect(find.widgetWithText(AppBar, 'Squat (Barbell)'), findsOneWidget);
      expect(find.byTooltip("Plus d'options"), findsNothing);
    });
  });
}
