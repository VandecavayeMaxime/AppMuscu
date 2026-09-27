import 'package:app_muscu/core/utils/date_format.dart';
import 'package:app_muscu/features/stats/domain/weekly_sessions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  // Dates relatives à aujourd'hui : l'onglet montre la semaine en cours.
  final thisMonday = startOfWeek(DateTime.now());
  final lastMonday = DateTime(
    thisMonday.year,
    thisMonday.month,
    thisMonday.day - 7,
  );
  final lastWednesday = DateTime(
    lastMonday.year,
    lastMonday.month,
    lastMonday.day + 2,
    18,
  );

  Future<void> openStats(WidgetTester tester) async {
    await tester.tap(tab('Stats'));
    await tester.pumpAndSettle();
  }

  testApp('sans séance terminée : un message', (tester) async {
    await openStats(tester);
    expect(find.text('Pas encore de séance'), findsOneWidget);
  });

  testApp(
    'séances par semaine : légende par modèle, séances de la semaine, '
    'résumé en lecture seule (SA-02, SA-03)',
    setUp: (db) async {
      final push = await addTemplate(db, name: 'Push');
      final legs = await addTemplate(db, name: 'Jambes', exerciseId: squatId);
      await addWorkout(
        db,
        name: 'Push',
        templateId: push,
        day: thisMonday.add(const Duration(hours: 7)),
        sets: [TestSet(80, 8)],
      );
      await addWorkout(
        db,
        name: 'Jambes',
        templateId: legs,
        exerciseId: squatId,
        day: lastWednesday,
        sets: [TestSet(100, 5)],
      );
      // Séance d'avant les modèles obligatoires (D14) : « Autres ».
      await addWorkout(
        db,
        name: 'Séance du soir',
        day: lastWednesday.add(const Duration(hours: 2)),
        sets: [TestSet(60, 10)],
      );
    },
    (tester) async {
      await openStats(tester);
      expect(find.text('Séances par semaine'), findsOneWidget);

      // Légende : les modèles dans l'ordre, puis les séances sans modèle.
      for (final label in ['Push', 'Jambes', 'Autres']) {
        expect(find.text(label), findsWidgets);
      }

      // Au départ, la semaine en cours.
      expect(find.text(formatWeekOf(thisMonday)), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Push'), findsOneWidget);
      expect(
        find.text(
          '${formatWeekday(thisMonday.add(const Duration(hours: 7)))} · 1 h 00',
        ),
        findsOneWidget,
      );

      // Toucher la barre de la semaine dernière.
      await tester.tap(find.byKey(ValueKey(lastMonday)));
      await tester.pumpAndSettle();
      expect(find.text(formatWeekOf(lastMonday)), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Push'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Jambes'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Séance du soir'), findsOneWidget);

      // Toucher une séance ouvre son résumé, en lecture seule.
      await tester.tap(find.widgetWithText(ListTile, 'Jambes'));
      await tester.pumpAndSettle();
      expect(find.text('Séance'), findsWidgets);
      expect(find.text('Squat (Barbell)'), findsOneWidget);
      expect(find.text('OK'), findsNothing);
      expect(find.textContaining('diffère du modèle'), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(formatWeekOf(lastMonday)), findsOneWidget);
    },
  );

  testApp(
    'une semaine sans séance le dit',
    setUp: (db) async {
      await addWorkout(db, day: lastWednesday, sets: [TestSet(80, 8)]);
    },
    (tester) async {
      await openStats(tester);
      expect(find.text(formatWeekOf(thisMonday)), findsOneWidget);
      expect(find.text('Aucune séance cette semaine.'), findsOneWidget);
    },
  );

  testApp(
    'appui long sur une séance : la supprimer, annuler (WO-23)',
    setUp: (db) async {
      await addWorkout(
        db,
        name: 'Push',
        day: thisMonday.add(const Duration(hours: 7)),
        sets: [TestSet(80, 8)],
      );
    },
    (tester) async {
      Future<void> deletePush() async {
        await tester.longPress(find.widgetWithText(ListTile, 'Push'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Supprimer la séance'));
        await tester.pumpAndSettle();
      }

      await openStats(tester);

      // Supprimer, puis « Annuler » : la séance revient.
      await deletePush();
      expect(find.text('Séance supprimée'), findsOneWidget);
      expect(find.text('Pas encore de séance'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Push'), findsOneWidget);

      // Supprimer pour de bon : elle disparaît aussi de l'historique.
      await deletePush();
      expect(find.text('Pas encore de séance'), findsOneWidget);
      await tester.tap(tab('Exercices'));
      await tester.pumpAndSettle();
      await tapExercise(tester, 'Bench Press (Barbell)');
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.text("Pas encore d'historique"), findsOneWidget);
    },
  );
}
