import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/platform/screen_awake.dart';
import '../features/rest_timer/data/rest_notifications.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/app_theme.dart';
import '../features/workout/data/workout_repository.dart';
import '../features/workout/presentation/workout_providers.dart';
import 'router.dart';
import 'theme.dart';

/// L'écran doit-il rester allumé ? Oui si le réglage est activé et qu'une
/// séance est en cours (ST-04).
final _keepScreenAwakeProvider = Provider<bool>(
  (ref) =>
      (ref.watch(keepScreenOnProvider).value ?? false) &&
      ref.watch(activeWorkoutProvider).value != null,
);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifications = ref.read(restNotificationsProvider);
      notifications.requestPermission();
      notifications.listenToTaps(_openActiveWorkout);
    });
    // Écran allumé ou non (ST-04) : appliqué tout de suite, puis à chaque
    // changement du réglage ou de la séance en cours.
    ref.listenManual(
      _keepScreenAwakeProvider,
      (_, on) => ref.read(screenAwakeProvider).keepOn(on),
      fireImmediately: true,
    );
  }

  /// Toucher la notification de fin de repos ouvre la séance en cours
  /// (RT-10), sauf si elle est déjà affichée.
  Future<void> _openActiveWorkout() async {
    final workout = await ref
        .read(workoutRepositoryProvider)
        .getActiveWorkout();
    if (workout == null || !mounted) return;
    final router = ref.read(routerProvider);
    // L'écran en haut de la pile, y compris ceux ouverts par `push`.
    if (!router.state.matchedLocation.startsWith('/seance-en-cours')) {
      router.push('/seance-en-cours');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider).value ?? AppTheme.system;

    return MaterialApp.router(
      title: 'AppMuscu',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      // Thème choisi dans les réglages (ST-03).
      themeMode: switch (theme) {
        AppTheme.system => ThemeMode.system,
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
      },
      // Textes intégrés de Flutter (boutons de dialogue, sélecteurs…) en français
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
