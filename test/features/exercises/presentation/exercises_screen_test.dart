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
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.widgetWithText(TextFormField, 'Nom');

  group('liste (EX-02, EX-03)', () {
    testApp('affiche les 10 exercices de base par ordre alphabétique', (
      tester,
    ) async {
      await openExercisesTab(tester);

      expect(find.byType(ListTile), findsNWidgets(10));
      expect(
        tester.getTopLeft(find.text('Curl biceps (haltères)')).dy,
        lessThan(tester.getTopLeft(find.text('Tractions')).dy),
      );
      expect(find.text('Pectoraux · Barre'), findsOneWidget);
    });

    testApp('recherche sans tenir compte des accents', (tester) async {
      await openExercisesTab(tester);

      await tester.enterText(find.byType(SearchBar), 'developpe');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Développé couché (barre)'), findsOneWidget);
      expect(find.text('Développé militaire (barre)'), findsOneWidget);
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
      await tester.tap(find.text('Dos'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('Tractions'), findsOneWidget);

      await tester.tap(find.byTooltip('Retirer le filtre'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(10));
    });
  });

  group('exercices perso (EX-04 à EX-06)', () {
    testApp('crée un exercice perso', (tester) async {
      await openNewExerciseForm(tester);

      await tester.enterText(nameField(), 'Hip thrust');
      await choose(tester, 'Groupe musculaire', 'Fessiers');
      await choose(tester, 'Catégorie', 'Barre');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);
      expect(find.text('Hip thrust'), findsOneWidget);
      expect(find.text('Fessiers · Barre'), findsOneWidget);
    });

    testApp('exige les champs obligatoires', (tester) async {
      await openNewExerciseForm(tester);

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Le nom est obligatoire'), findsOneWidget);
      expect(find.text('Choisis un groupe musculaire'), findsOneWidget);
      expect(find.text('Choisis une catégorie'), findsOneWidget);
    });

    testApp('refuse un nom déjà pris', (tester) async {
      await openNewExerciseForm(tester);

      await tester.enterText(nameField(), 'squat (BARRE)');
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
        name: 'Hip thrust',
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
        await tester.tap(find.text('Hip thrust'));
        await tester.pumpAndSettle();

        // Fiche → Modifier → formulaire → retour à la fiche.
        await openMenu('Modifier');
        expect(find.text("Modifier l'exercice"), findsOneWidget);
        await tester.enterText(nameField(), 'Hip thrust (machine)');
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(AppBar, 'Hip thrust (machine)'),
          findsOneWidget,
        );

        // Fiche → Supprimer → confirmation → retour à la liste.
        await openMenu('Supprimer');
        await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);
        expect(find.text('Hip thrust (machine)'), findsNothing);
        expect(find.byType(ListTile), findsNWidgets(10));
      },
    );

    testApp('un exercice intégré ouvre sa fiche, sans menu Modifier', (
      tester,
    ) async {
      await openExercisesTab(tester);

      await tester.tap(find.text('Squat (barre)'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Squat (barre)'), findsOneWidget);
      expect(find.byTooltip("Plus d'options"), findsNothing);
    });
  });
}
