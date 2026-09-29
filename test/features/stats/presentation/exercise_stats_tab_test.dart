import 'package:app_muscu/core/utils/date_format.dart';
import 'package:app_muscu/features/stats/presentation/exercise_stats_tab.dart';
import 'package:app_muscu/features/stats/presentation/line_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  final today = DateTime.now();
  DateTime daysAgo(int days) =>
      DateTime(today.year, today.month, today.day - days, 18);

  Future<void> openStats(WidgetTester tester, String exercise) async {
    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
    await tapExercise(tester, exercise);
    await tester.tap(find.text('Statistiques'));
    await tester.pumpAndSettle();
  }

  /// Fait défiler l'onglet jusqu'à [finder].
  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find
            .descendant(
              of: find.byType(ExerciseStatsTab),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  /// Valeur affichée à droite de la ligne [title].
  Finder trailing(String title, String value) => find.descendant(
    of: find.widgetWithText(ListTile, title),
    matching: find.text(value),
  );

  testApp('sans historique : un message', (tester) async {
    await openStats(tester, 'Squat (Barbell)');
    expect(find.text('Pas encore de statistiques'), findsOneWidget);
  });

  testApp(
    'courbe, records, records par reps et fréquence (EX-12 à EX-15)',
    setUp: (db) async {
      await addWorkout(
        db,
        day: daysAgo(20),
        sets: [TestSet(80, 8), TestSet(95, 3)],
      );
      await addWorkout(db, day: daysAgo(10), sets: [TestSet(100, 1)]);
      await addWorkout(
        db,
        day: daysAgo(2),
        sets: [TestSet(90, 5), TestSet(85, 8)],
      );
    },
    (tester) async {
      await openStats(tester, 'Bench Press (Barbell)');

      // Courbe du 1RM estimé : le dernier point est sélectionné.
      // 85 kg × 8 → 85 × (1 + 8/30) = 107,67 kg.
      expect(find.byType(LineChart), findsOneWidget);
      expect(
        find.text('107,67 kg · ${formatDayMonthYear(daysAgo(2))}'),
        findsOneWidget,
      );

      // Autre valeur suivie, puis toucher le premier point.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Poids max'));
      await tester.pumpAndSettle();
      expect(
        find.text('90 kg · ${formatDayMonthYear(daysAgo(2))}'),
        findsOneWidget,
      );
      final chart = tester.getRect(find.byType(LineChart));
      await tester.tapAt(chart.centerLeft + const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(
        find.text('95 kg · ${formatDayMonthYear(daysAgo(20))}'),
        findsOneWidget,
      );

      // Records.
      await scrollTo(tester, find.text('Meilleur volume'));
      expect(trailing('Poids max', '100 kg'), findsOneWidget);
      expect(trailing('Meilleure série', '85 kg × 8'), findsOneWidget);
      // Espace fine insécable entre les milliers (formatVolume).
      expect(trailing('Meilleur volume', '1\u202f130 kg'), findsOneWidget);

      // Records par nombre de reps : 1, 3, 5 et 8 reps. Avec les 2 choix de
      // plus pour la courbe (Reps max/totales, D35), la page est plus
      // longue : on défile jusqu'à chaque valeur plutôt que juste le titre.
      await scrollTo(tester, find.text('Records par nombre de reps'));
      for (final weight in ['100 kg', '95 kg', '90 kg']) {
        await scrollTo(tester, find.text(weight));
        expect(find.text(weight), findsWidgets);
      }

      // Fréquence.
      await scrollTo(tester, find.text('Dernière fois'));
      expect(trailing('Séances', '3'), findsOneWidget);
      expect(trailing('Dernière fois', 'Il y a 2 jours'), findsOneWidget);
    },
  );

  testApp(
    'reps seules : pas de tableau par reps',
    setUp: (db) async {
      await addWorkout(
        db,
        exerciseId: pullUpId,
        day: daysAgo(3),
        sets: [TestSet(0, 12), TestSet(0, 10)],
      );
    },
    (tester) async {
      await openStats(tester, 'Pull-Up');
      expect(
        find.text('12 reps · ${formatDayMonthYear(daysAgo(3))}'),
        findsOneWidget,
      );
      await scrollTo(tester, find.text('Reps max en une séance'));
      expect(trailing('Reps max en une séance', '22 reps'), findsOneWidget);
      expect(find.text('Records par nombre de reps'), findsNothing);
    },
  );
}
