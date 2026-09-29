import 'package:app_muscu/features/stats/presentation/line_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> openActivity(WidgetTester tester) async {
    await tester.tap(tab('Stats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activité'));
    await tester.pumpAndSettle();
  }

  testApp(
    "sans autorisation : un écran d'explication, pas de graphique (D36)",
    (tester) async {
      await openActivity(tester);

      expect(find.text('Accès à tes données de santé'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      expect(healthDataOf(tester).permissionRequests, 0);
    },
  );

  testApp("toucher « Autoriser l'accès » la demande, puis affiche le contenu "
      '(D36)', (tester) async {
    await openActivity(tester);

    await tester.tap(find.text("Autoriser l'accès"));
    await tester.pumpAndSettle();

    expect(healthDataOf(tester).permissionRequests, 1);
    expect(find.text('Accès à tes données de santé'), findsNothing);
    // Pas encore de mesure (l'historique de la fausse implémentation est
    // vide par défaut).
    expect(find.text('Aucune donnée sur cette période.'), findsOneWidget);
  });

  testApp(
    'une fois autorisé : les 4 mesures, une courbe, et on peut changer de '
    'mesure et de période (D36)',
    (tester) async {
      healthDataOf(tester).permission = true;
      healthDataOf(tester).summaries = [
        (
          date: DateTime(2026, 9, 1),
          steps: 8000,
          distanceMeters: 6200.0,
          activeCalories: 310.0,
          sleepMinutes: 420,
        ),
        (
          date: DateTime(2026, 9, 2),
          steps: 10500,
          distanceMeters: 8100.0,
          activeCalories: 380.0,
          sleepMinutes: 450,
        ),
      ];

      await openActivity(tester);

      // Pas (mesure par défaut) : la dernière valeur.
      expect(find.text('10500 pas'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);

      // Distance.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Distance'));
      await tester.pumpAndSettle();
      expect(find.text('8,1 km'), findsOneWidget);

      // Calories.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Calories'));
      await tester.pumpAndSettle();
      expect(find.text('380 kcal'), findsOneWidget);

      // Sommeil.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sommeil'));
      await tester.pumpAndSettle();
      expect(find.text('7 h 30'), findsOneWidget);
    },
  );
}
