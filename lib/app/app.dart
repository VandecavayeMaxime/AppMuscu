import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/rest_timer/data/rest_notifications.dart';
import 'router.dart';
import 'theme.dart';

/// Racine de l'application : thème, langue et navigation.
///
/// `ConsumerStatefulWidget` = widget à état qui peut lire des providers
/// Riverpod via `ref`.
class AppMuscu extends ConsumerStatefulWidget {
  const AppMuscu({super.key});

  @override
  ConsumerState<AppMuscu> createState() => _AppMuscuState();
}

class _AppMuscuState extends ConsumerState<AppMuscu> {
  @override
  void initState() {
    super.initState();
    // Autorisation des notifications de fin de repos (RT-05), demandée au
    // lancement une fois le premier écran affiché. Android ne montre la
    // fenêtre qu'une fois : ensuite, cet appel ne fait plus rien.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(restNotificationsProvider).requestPermission(),
    );
  }

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
      routerConfig: ref.watch(routerProvider),
    );
  }
}
