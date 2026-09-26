import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'features/settings/data/settings_repository.dart';

/// Point d'entrée : Flutter appelle `main()` au lancement de l'app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Le conteneur Riverpod, qui garde l'état de tous les providers. On le crée
  // avant l'app pour lire le thème choisi (ST-03) avant le premier affichage :
  // sinon l'app s'afficherait un instant en clair avant de passer en sombre.
  final container = ProviderContainer();
  try {
    await container
        .read(appThemeProvider.future)
        .timeout(const Duration(seconds: 1));
  } on Object {
    // Base lente ou illisible : l'app démarre quand même, thème du système.
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const AppMuscu()),
  );
}
