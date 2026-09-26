import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';

/// Point d'entrée : Flutter appelle `main()` au lancement de l'app.
void main() {
  // ProviderScope : le conteneur Riverpod qui garde l'état de tous les providers.
  runApp(const ProviderScope(child: AppMuscu()));
}
