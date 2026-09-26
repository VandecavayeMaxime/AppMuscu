import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/exercises/presentation/exercise_detail_screen.dart';
import '../features/exercises/presentation/exercise_form_screen.dart';
import '../features/exercises/presentation/exercises_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/workout/presentation/workout_home_screen.dart';
import 'home_shell.dart';

/// Le routeur de l'app. Fourni par Riverpod pour qu'il soit créé une seule
/// fois par app (et recréé à neuf pour chaque test).
final routerProvider = Provider<GoRouter>((ref) {
  final router = _createRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Toutes les routes de l'app. Liste cible complète : docs/ARCHITECTURE.md §2.
GoRouter _createRouter() => GoRouter(
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
              routes: [
                // `nouveau` avant `:id`, sinon « nouveau » serait lu comme un id.
                GoRoute(
                  path: 'nouveau',
                  builder: (context, state) => const ExerciseFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ExerciseDetailScreen(
                    exerciseId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'modifier',
                      builder: (context, state) => ExerciseFormScreen(
                        exerciseId: state.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
              ],
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
