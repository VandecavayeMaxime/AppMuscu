import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  testApp("démarre sur l'onglet Séance et navigue entre les onglets", (
    tester,
  ) async {
    expect(find.widgetWithText(AppBar, 'Séance'), findsOneWidget);

    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);

    await tester.tap(tab('Réglages'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Réglages'), findsOneWidget);
  });

  testApp('demande l’autorisation des notifications au lancement (RT-05)', (
    tester,
  ) async {
    expect(notificationsOf(tester).permissionRequests, 1);
  });
}
