import 'package:material_ui/material_ui.dart';

import 'router.dart';
import 'theme.dart';

/// Racine de l'application : thème, langue et navigation.
class AppMuscu extends StatelessWidget {
  const AppMuscu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AppMuscu',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      // Suit le réglage clair/sombre du téléphone ; réglable dans l'app plus tard (ST-03)
      themeMode: ThemeMode.system,
      // Textes intégrés de Flutter (boutons de dialogue, sélecteurs…) en français
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    );
  }
}
