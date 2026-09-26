import 'package:app_muscu/app/app.dart';
import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/core/database/database_provider.dart';
import 'package:app_muscu/core/utils/clock_tick.dart';
import 'package:app_muscu/features/rest_timer/data/rest_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_rest_notifications.dart';
import 'test_database.dart';

/// Comme `testWidgets`, mais avec l'app complète sur un écran de téléphone
/// (360 × 1200 dp), une base de test en mémoire préparée par [setUp], et de
/// fausses notifications (voir [notificationsOf]).
void testApp(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  Future<void> Function(AppDatabase db)? setUp,
}) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = createTestDatabase();
    await setUp?.call(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // Chronomètres figés : un flux qui avance chaque seconde empêcherait
          // `pumpAndSettle` de se terminer.
          clockTickProvider.overrideWith((ref) => const Stream.empty()),
          restNotificationsProvider.overrideWithValue(FakeRestNotifications()),
        ],
        child: const AppMuscu(),
      ),
    );
    await tester.pumpAndSettle();

    await body(tester);

    // On démonte l'app avant la fin du test : Drift ferme ses flux avec un
    // minuteur de durée nulle, qu'il faut laisser s'écouler.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await db.close();
  });
}

/// Les fausses notifications de l'app en cours de test.
FakeRestNotifications notificationsOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(AppMuscu)))
            .read(restNotificationsProvider)
        as FakeRestNotifications;

/// Trouve un onglet par son libellé, dans la barre du bas uniquement.
Finder tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));
