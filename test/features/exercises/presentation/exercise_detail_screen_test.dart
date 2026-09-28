import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  Future<void> openExercise(WidgetTester tester, String name) async {
    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
    await tapExercise(tester, name);
  }

  Future<void> openHistory(WidgetTester tester) async {
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
  }

  group('onglet À propos', () {
    testApp('affiche groupe, catégorie, instructions et préférences', (
      tester,
    ) async {
      await openExercise(tester, 'Bench Press (Barbell)');

      expect(
        find.widgetWithText(AppBar, 'Bench Press (Barbell)'),
        findsOneWidget,
      );
      expect(find.text('Pectoraux'), findsOneWidget);
      expect(find.text('Barre'), findsOneWidget);
      expect(find.textContaining('Allonge-toi sur le banc'), findsOneWidget);
      expect(find.text('Unité'), findsOneWidget);
      expect(find.text('Réglage global'), findsOneWidget);
    });

    testApp('note personnelle, même pour un exercice intégré (EX-11)', (
      tester,
    ) async {
      await openExercise(tester, 'Bench Press (Barbell)');
      expect(find.text('Aucune note'), findsOneWidget);

      await tester.tap(find.text('Aucune note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Siège cran 4',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Enregistrer'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Siège cran 4'), findsOneWidget);
      expect(find.text('Aucune note'), findsNothing);
    });

    testApp('change l’unité et le minuteur de repos', (tester) async {
      await openExercise(tester, 'Bench Press (Barbell)');

      await tester.tap(find.text('lb'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Réglage global'));
      await tester.tap(find.text('Réglage global'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2:30'));
      await tester.pumpAndSettle();

      final unitButton = tester.widget<SegmentedButton<WeightUnit>>(
        find.byType(SegmentedButton<WeightUnit>),
      );
      expect(unitButton.selected, {WeightUnit.lb});
      expect(find.text('2:30'), findsOneWidget);
    });

    testApp('pas de préférence d’unité pour un exercice sans poids', (
      tester,
    ) async {
      await openExercise(tester, 'Pull-Up');

      expect(find.text('Unité'), findsNothing);
      expect(find.text('Minuteur de repos'), findsOneWidget);
    });
  });

  group('onglet Historique', () {
    testApp('message quand l’exercice n’a jamais été fait', (tester) async {
      await openExercise(tester, 'Bench Press (Barbell)');
      await openHistory(tester);

      expect(find.text("Pas encore d'historique"), findsOneWidget);
    });

    testApp(
      'un bloc par séance : nom, date, séries, meilleure série',
      setUp: (db) async {
        await addWorkout(
          db,
          name: 'Push',
          day: DateTime(2026, 9, 23, 18),
          sets: [
            const TestSet(40, 10, type: SetType.warmup),
            const TestSet(80, 8),
            const TestSet(82.5, 6),
          ],
        );
        await addWorkout(
          db,
          name: 'Séance du soir',
          day: DateTime(2026, 9, 21, 18),
          sets: [const TestSet(77.5, 8)],
        );
      },
      (tester) async {
        await openExercise(tester, 'Bench Press (Barbell)');
        await openHistory(tester);

        expect(find.text('Push'), findsOneWidget);
        expect(find.text('mercredi 23 septembre 2026'), findsOneWidget);
        expect(find.text('W'), findsOneWidget);
        expect(find.text('40 kg × 10'), findsOneWidget);
        expect(find.text('82,5 kg × 6'), findsOneWidget);
        expect(find.text('Séance du soir'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Push')).dy,
          lessThan(tester.getTopLeft(find.text('Séance du soir')).dy),
        );

        // 80 × 8 (1RM ≈ 101) bat 82,5 × 6 (1RM = 99) : l'étoile est sur 80 × 8.
        Finder starOnRowOf(String text) => find.descendant(
          of: find.ancestor(of: find.text(text), matching: find.byType(Row)),
          matching: find.byIcon(Icons.star),
        );
        expect(starOnRowOf('80 kg × 8'), findsOneWidget);
        expect(starOnRowOf('82,5 kg × 6'), findsNothing);
      },
    );

    testApp(
      'affiche les poids dans l’unité de l’exercice',
      setUp: (db) async {
        await addWorkout(
          db,
          day: DateTime(2026, 9, 23, 18),
          sets: [TestSet(WeightUnit.lb.toKg(135), 5)],
        );
      },
      (tester) async {
        await openExercise(tester, 'Bench Press (Barbell)');
        await tester.tap(find.text('lb'));
        await tester.pumpAndSettle();
        await openHistory(tester);

        expect(find.text('135 lb × 5'), findsOneWidget);
      },
    );
  });
}
