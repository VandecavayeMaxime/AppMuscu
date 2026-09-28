import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  testApp("démarre sur l'onglet Séance, navigue entre les onglets, et vers "
      'Réglages (D32)', (tester) async {
    expect(find.widgetWithText(AppBar, 'Séance'), findsOneWidget);

    await tester.tap(tab('Exercices'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);

    // Pas un onglet du bas (D32) : une icône en haut de chacun des 3.
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Réglages'), findsOneWidget);
  });

  testApp('demande l’autorisation des notifications au lancement (RT-05)', (
    tester,
  ) async {
    expect(notificationsOf(tester).permissionRequests, 1);
  });
}
