import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  Future<void> openBody(WidgetTester tester) async {
    await tester.tap(tab('Stats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corps'));
    await tester.pumpAndSettle();
  }

  testApp('sans mesure : un message et un bouton pour en ajouter', (
    tester,
  ) async {
    await openBody(tester);
    expect(find.text('Pas encore de mesure'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Mesure'), findsOneWidget);
  });

  testApp('ajoute une mesure de poids, la voit dans la liste (SA-06, SA-07)', (
    tester,
  ) async {
    await openBody(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Mesure'));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle mesure'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Poids (kg)'),
      '82,5',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Poids'), findsOneWidget);
    expect(find.text('82,5 kg'), findsOneWidget);
  });

  testApp(
    'refuse d\'enregistrer sans aucune valeur, ni une valeur hors bornes',
    (tester) async {
      await openBody(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Mesure'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.text('Saisis au moins une valeur.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Poids (kg)'),
        '900',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.textContaining('entre'), findsOneWidget);
    },
  );

  testApp(
    'ajoute un tour, le voit étiqueté sur la silhouette, et l\'ouvre (SA-07, '
    'SA-08)',
    (tester) async {
      await openBody(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Mesure'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Taille (cm)'),
        '82',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Tours'), findsOneWidget);
      expect(find.textContaining('Taille'), findsOneWidget);

      await tester.tap(find.textContaining('Taille'));
      await tester.pumpAndSettle();
      expect(find.text('Taille'), findsWidgets); // titre de la page
      expect(find.text('82 cm'), findsOneWidget);
    },
  );

  testApp(
    'touche le poids : sa page, avec l\'historique ; modifier et supprimer '
    'une valeur (SA-08)',
    setUp: (db) async {
      await addMeasurement(db, day: DateTime(2026, 8, 1), weightKg: 80);
      await addMeasurement(db, day: DateTime(2026, 9, 1), weightKg: 82);
    },
    (tester) async {
      await openBody(tester);

      await tester.tap(find.text('Poids'));
      await tester.pumpAndSettle();
      expect(find.text('82 kg'), findsOneWidget);
      expect(find.text('80 kg'), findsOneWidget);

      // Modifier la plus récente.
      await tester.tap(find.text('82 kg'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '83');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('83 kg'), findsOneWidget);

      // Supprimer l'autre en la balayant.
      await tester.drag(find.text('80 kg'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('80 kg'), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('83 kg'), findsOneWidget);
    },
  );
}
