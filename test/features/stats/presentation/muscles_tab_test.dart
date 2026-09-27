import 'package:app_muscu/core/utils/date_format.dart';
import 'package:app_muscu/features/stats/domain/weekly_sessions.dart';
import 'package:app_muscu/features/stats/presentation/body_silhouette.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

void main() {
  final thisMonday = startOfWeek(DateTime.now());
  final lastMonday = DateTime(
    thisMonday.year,
    thisMonday.month,
    thisMonday.day - 7,
  );
  DateTime inWeek(DateTime monday, int offsetDays) =>
      DateTime(monday.year, monday.month, monday.day + offsetDays, 18);

  Future<void> openMuscles(WidgetTester tester) async {
    await tester.tap(tab('Stats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muscles'));
    await tester.pumpAndSettle();
  }

  /// Touche le muscle situé à [point] (repère de dessin) sur la silhouette
  /// [view] (SA-04, la première pour la face, la deuxième pour le dos).
  Future<void> tapMuscle(
    WidgetTester tester,
    BodyView view,
    Offset point,
  ) async {
    final finder = find.descendant(
      of: find.byKey(const ValueKey('current-week-silhouettes')),
      matching: find.byType(BodySilhouette),
    );
    final index = view == BodyView.front ? 0 : 1;
    final rect = tester.getRect(finder.at(index));
    await tester.tapAt(
      rect.topLeft +
          Offset(
            rect.width * point.dx / bodyWidth,
            rect.height * point.dy / bodyHeight,
          ),
    );
    await tester.pumpAndSettle();
  }

  double? rowHighlightAlpha(WidgetTester tester, String label) {
    final box = tester.widget<ColoredBox>(
      find.descendant(
        of: find.widgetWithText(InkWell, label),
        matching: find.byType(ColoredBox),
      ),
    );
    return box.color.a;
  }

  /// Glisse sur la silhouette pour changer de semaine (SA-04) : vers la
  /// droite pour reculer, vers la gauche pour avancer.
  Future<void> swipeWeek(WidgetTester tester, {required bool forward}) async {
    // Le centre de la zone entière tombe pile sur l'espace vide entre les
    // deux silhouettes (face/dos) : on vise plutôt la première (face).
    await tester.fling(
      find
          .descendant(
            of: find.byKey(const ValueKey('current-week-silhouettes')),
            matching: find.byType(BodySilhouette),
          )
          .first,
      Offset(forward ? -300 : 300, 0),
      800,
    );
    await tester.pumpAndSettle();
  }

  testApp('sans série validée : un message', (tester) async {
    await openMuscles(tester);
    expect(find.text('Pas encore de statistiques'), findsOneWidget);
  });

  testApp(
    'une semaine à la fois, du lundi au dimanche, navigable (SA-04, SA-05, '
    'RG-17)',
    setUp: (db) async {
      // Bench press (chest + triceps, épaules) : cette semaine, 2 séries.
      await addWorkout(
        db,
        day: inWeek(thisMonday, 2),
        sets: [TestSet(80, 8), TestSet(80, 8)],
      );
      // Squat (quads + fessiers, ischios) : la semaine dernière, 1 série.
      await addWorkout(
        db,
        day: inWeek(lastMonday, 2),
        exerciseId: squatId,
        sets: [TestSet(100, 5)],
      );
    },
    (tester) async {
      await openMuscles(tester);

      // Semaine en cours par défaut : seul le bench press compte, et on ne
      // peut pas avancer plus loin.
      expect(find.text(formatWeekRange(thisMonday)), findsOneWidget);
      expect(find.text('Revenir à cette semaine'), findsNothing);
      // Glisser vers l'avant ne fait rien : jamais de semaine future.
      await swipeWeek(tester, forward: true);
      expect(find.text(formatWeekRange(thisMonday)), findsOneWidget);
      final orderThisWeek = ['Pectoraux', 'Épaules', 'Triceps'];
      for (final label in orderThisWeek) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Quadriceps'), findsNothing);
      double top(String s) => tester.getTopLeft(find.text(s)).dy;
      for (var i = 1; i < orderThisWeek.length; i++) {
        expect(top(orderThisWeek[i - 1]), lessThan(top(orderThisWeek[i])));
      }

      // Semaine précédente : le squat, pas le bench press.
      await swipeWeek(tester, forward: false);
      expect(find.text(formatWeekRange(lastMonday)), findsOneWidget);
      expect(find.text('Revenir à cette semaine'), findsOneWidget);
      expect(find.text('Pectoraux'), findsNothing);
      final orderLastWeek = ['Quadriceps', 'Ischios', 'Fessiers'];
      for (final label in orderLastWeek) {
        expect(find.text(label), findsOneWidget);
      }
      for (var i = 1; i < orderLastWeek.length; i++) {
        expect(top(orderLastWeek[i - 1]), lessThan(top(orderLastWeek[i])));
      }
      expect(find.text('0,5'), findsNWidgets(2)); // Ischios et Fessiers

      // Encore avant : aucune séance cette semaine-là (mais pas l'écran
      // « pas encore de statistiques », réservé à l'absence totale de séance).
      await swipeWeek(tester, forward: false);
      expect(
        find.text('Aucune série validée cette semaine-là.'),
        findsOneWidget,
      );

      // Retour direct à la semaine en cours.
      await tester.tap(find.text('Revenir à cette semaine'));
      await tester.pumpAndSettle();
      expect(find.text(formatWeekRange(thisMonday)), findsOneWidget);
      expect(find.text('Pectoraux'), findsOneWidget);

      // Toucher les pectoraux sur la silhouette de face les met en avant.
      expect(rowHighlightAlpha(tester, 'Pectoraux'), closeTo(0.3, 0.001));
      await tapMuscle(tester, BodyView.front, const Offset(305, 377));
      expect(rowHighlightAlpha(tester, 'Pectoraux'), closeTo(0.55, 0.001));

      // Toucher à nouveau retire la mise en avant.
      await tapMuscle(tester, BodyView.front, const Offset(305, 377));
      expect(rowHighlightAlpha(tester, 'Pectoraux'), closeTo(0.3, 0.001));
    },
  );
}
