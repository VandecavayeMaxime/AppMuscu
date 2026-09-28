import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

void main() {
  Future<void> openSettings(WidgetTester tester) async {
    // Pas un onglet du bas (D32) : une icône en haut de chacun des 3 autres.
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  Future<void> backToWorkoutTab(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  /// Démarre le modèle vide « Séance libre » et y ajoute un squat.
  Future<void> startSquatWorkout(WidgetTester tester) async {
    await tester.tap(find.text('Séance libre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer la séance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter des exercices'));
    await tester.pumpAndSettle();
    await checkExercise(tester, 'Squat (Barbell)');
    await tester.tap(find.textContaining('Ajouter ('));
    await tester.pumpAndSettle();
  }

  testApp(
    'temps de repos par défaut, appliqué aux séries (ST-01)',
    setUp: (db) => addEmptyTemplate(db),
    (tester) async {
      await openSettings(tester);
      expect(find.text('2:00'), findsOneWidget);

      await tester.tap(find.text('Temps de repos par défaut'));
      await tester.pumpAndSettle();
      expect(
        find.text('Par défaut (2:00)'),
        findsNothing,
      ); // pas pour le global
      await tester.tap(find.text('1:30'));
      await tester.pumpAndSettle();
      expect(find.text('1:30'), findsOneWidget);

      await backToWorkoutTab(tester);
      await startSquatWorkout(tester);
      expect(find.text('1:30'), findsOneWidget); // ligne de repos
    },
  );

  testApp(
    'son coupé : la notification de fin de repos est sans son (ST-02)',
    setUp: (db) => addEmptyTemplate(db),
    (tester) async {
      await openSettings(tester);
      await tester.tap(find.text('Son'));
      await tester.pumpAndSettle();

      await backToWorkoutTab(tester);
      await startSquatWorkout(tester);
      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(1), '5');
      await tester.tap(find.byTooltip('Valider la série'));
      await tester.pumpAndSettle();

      final notification = notificationsOf(tester).scheduled.single;
      expect(notification.sound, isFalse);
      expect(notification.vibration, isTrue);
    },
  );

  testApp('thème sombre (ST-03)', (tester) async {
    ThemeMode? themeMode() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;
    expect(themeMode(), ThemeMode.system);

    await openSettings(tester);
    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();

    expect(themeMode(), ThemeMode.dark);
  });

  testApp(
    'écran allumé tant qu’une séance est en cours (ST-04)',
    setUp: (db) => addEmptyTemplate(db),
    (tester) async {
      await openSettings(tester);
      await tester.tap(find.text("Garder l'écran allumé"));
      await tester.pumpAndSettle();
      expect(screenAwakeOf(tester).keptOn, isFalse); // pas de séance

      await backToWorkoutTab(tester);
      await startSquatWorkout(tester);
      expect(screenAwakeOf(tester).keptOn, isTrue);

      await tester.tap(find.text('Annuler la séance'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Supprimer'),
        ),
      );
      await tester.pumpAndSettle();
      expect(screenAwakeOf(tester).keptOn, isFalse);
    },
  );
}
