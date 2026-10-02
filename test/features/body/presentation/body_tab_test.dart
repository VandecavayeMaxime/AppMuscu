import 'package:app_muscu/core/database/app_database.dart';
import 'package:drift/drift.dart';
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

  testApp('sans mesure : le corps et ses 9 tours quand même, un message et un '
      'bouton pour en ajouter (D33)', (tester) async {
    await openBody(tester);
    expect(find.text('Cou'), findsOneWidget);
    expect(find.text('Avant-bras'), findsOneWidget);
    expect(find.text('Mollet'), findsOneWidget);
    expect(
      find.text('Ajoute ton poids ou tes tours pour suivre leur évolution.'),
      findsOneWidget,
    );
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

    // La valeur apparaît deux fois : dans la ligne dédiée sous la
    // silhouette (D43) et dans le graphique, affiché par défaut.
    expect(find.text('Poids'), findsOneWidget); // titre du graphique
    expect(find.text('82,5 kg'), findsWidgets);
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

  testApp('ajoute un tour, le voit étiqueté sur la silhouette et dans le '
      'graphique, qui ne s\'ouvre pas en le touchant (SA-07, D31, D40)', (
    tester,
  ) async {
    await openBody(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Mesure'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Taille (cm)'), '82');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    // L'étiquette sur la silhouette ("Taille 82") et le titre du
    // graphique ("Taille"), seule mesure saisie donc déjà affichée.
    expect(find.textContaining('Taille'), findsWidgets);
    expect(find.text('82 cm'), findsOneWidget);

    // Toucher le graphique ne navigue plus vers une autre page (D40) :
    // toujours sur l'onglet Corps, pas de bouton retour.
    await tester.tap(find.text('82 cm'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Mesure'), findsOneWidget);
  });

  testApp(
    'touche une autre zone de la silhouette : le graphique change (D31)',
    setUp: (db) async {
      await db
          .into(db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              measuredAt: DateTime(2026, 8, 1),
              waistCm: const Value(82),
              neckCm: const Value(40),
            ),
          );
    },
    (tester) async {
      await openBody(tester);

      // Le cou (premier tour de la liste, BodyMeasurementField.circumferences)
      // est affiché par défaut.
      expect(find.text('40 cm'), findsOneWidget);
      expect(find.text('82 cm'), findsNothing);

      await tester.tap(find.textContaining('Taille'));
      await tester.pumpAndSettle();

      expect(find.text('82 cm'), findsOneWidget);
      expect(find.text('40 cm'), findsNothing);
    },
  );

  testApp(
    'touche la masse grasse : sélectionne le champ pour le graphique '
    'commun, pas de page séparée (D45)',
    setUp: (db) async {
      // Un poids, pour que le graphique par défaut soit « Poids » plutôt
      // que « Masse grasse » : sinon la même valeur s'afficherait deux fois
      // (une fois dans le graphique, une fois dans la ligne).
      await addMeasurement(db, day: DateTime(2026, 7, 1), weightKg: 80);
      await addMeasurement(db, day: DateTime(2026, 9, 1), bodyFatPercent: 16);
    },
    (tester) async {
      await openBody(tester);

      expect(find.text('Poids'), findsOneWidget); // titre du graphique
      expect(find.widgetWithText(ListTile, 'Masse grasse'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Masse grasse'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsNothing);
      expect(find.text('Masse grasse'), findsWidgets); // titre du graphique
      expect(find.text('16 %'), findsWidgets);
    },
  );

  testApp(
    'poids : juste le chiffre sous la silhouette, qui sélectionne le poids '
    'pour le graphique plutôt que d\'ouvrir une page (D43, D44)',
    setUp: (db) async {
      await addMeasurement(db, day: DateTime(2026, 8, 1), weightKg: 80);
      await db
          .into(db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              measuredAt: DateTime(2026, 8, 2),
              waistCm: const Value(82),
            ),
          );
    },
    (tester) async {
      await openBody(tester);

      // Pas de nom « Poids » ni d'écart à côté du chiffre sous la
      // silhouette : juste la valeur, centrée (D43).
      expect(find.widgetWithText(ListTile, 'Poids'), findsNothing);

      // Sélectionne un tour : le graphique change (D31).
      await tester.tap(find.textContaining('Taille'));
      await tester.pumpAndSettle();
      expect(find.text('82 cm'), findsOneWidget);

      // Toucher le chiffre du poids ramène le graphique sur le poids,
      // sans ouvrir une autre page (D44).
      await tester.tap(find.text('80 kg').first);
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsNothing);
      expect(find.text('82 cm'), findsNothing);
      expect(find.text('Poids'), findsOneWidget); // titre du graphique
    },
  );

  testApp(
    'poids : choix entre courbe lissée et brute, absent pour les autres '
    'champs (D41)',
    setUp: (db) async {
      await addMeasurement(db, day: DateTime(2026, 9, 1), weightKg: 80);
      await addMeasurement(db, day: DateTime(2026, 9, 6), weightKg: 76);
      await db
          .into(db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              measuredAt: DateTime(2026, 9, 7),
              waistCm: const Value(82),
            ),
          );
    },
    (tester) async {
      await openBody(tester);

      final segmented = find.byType(SegmentedButton<bool>);
      expect(segmented, findsOneWidget);
      // Lissé par défaut (D41).
      expect(tester.widget<SegmentedButton<bool>>(segmented).selected, {true});

      await tester.tap(find.text('Brut'));
      await tester.pumpAndSettle();
      expect(tester.widget<SegmentedButton<bool>>(segmented).selected, {false});

      // Pas de choix lissé/brut pour un tour : seul le poids est jamais
      // lissé (RG-20).
      await tester.tap(find.textContaining('Taille'));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<bool>), findsNothing);
    },
  );
}
