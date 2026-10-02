import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';

/// Point d'entrée : Flutter appelle `main()` au lancement de l'app.
///
/// Pas d'attente du thème choisi (ST-03) avant `runApp` (essayé, puis
/// abandonné, D39) : sur certains téléphones, lire la base avant le premier
/// affichage ne se termine jamais à temps, même avec une bonne marge — un
/// coût garanti pour un bénéfice qui n'arrive jamais. `AppMuscu` applique
/// déjà le thème du système en attendant (`ref.watch(appThemeProvider).value
/// ?? AppTheme.system`), puis bascule sur le vrai thème dès qu'il arrive.
void main() {
  runApp(ProviderScope(child: const AppMuscu()));
}
