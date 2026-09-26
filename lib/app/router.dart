import 'package:go_router/go_router.dart';

import '../features/exercises/presentation/exercises_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/workout/presentation/workout_home_screen.dart';
import 'home_shell.dart';

/// Toutes les routes de l'app. Liste cible complète : docs/ARCHITECTURE.md §2.
final appRouter = GoRouter(
  initialLocation: '/seance',
  routes: [
    // Les 3 onglets. Chaque branche garde sa propre pile d'écrans :
    // on retrouve l'onglet dans l'état où on l'a laissé.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/seance',
              builder: (context, state) => const WorkoutHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exercices',
              builder: (context, state) => const ExercisesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reglages',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
