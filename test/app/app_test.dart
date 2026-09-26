import 'package:app_muscu/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets("démarre sur l'onglet Séance et navigue entre les onglets", (
    tester,
  ) async {
    await tester.pumpWidget(const AppMuscu());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Séance'), findsOneWidget);

    await tester.tap(_tab('Exercices'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Exercices'), findsOneWidget);

    await tester.tap(_tab('Réglages'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Réglages'), findsOneWidget);
  });
}

/// Trouve un onglet par son libellé, dans la barre du bas uniquement.
Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));
