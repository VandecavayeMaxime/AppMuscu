import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/body/domain/body_measurement_field.dart';
import '../features/body/presentation/measurement_detail_screen.dart';
import '../features/body/presentation/new_measurement_screen.dart';
import '../features/exercises/presentation/exercise_detail_screen.dart';
import '../features/exercises/presentation/exercise_form_screen.dart';
import '../features/exercises/presentation/exercises_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/templates/presentation/template_editor_screen.dart';
import '../features/workout/presentation/active_workout_screen.dart';
import '../features/workout/presentation/workout_home_screen.dart';
import '../features/workout/presentation/workout_summary_screen.dart';
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
    // Séance en cours : déclarée hors des onglets, elle s'affiche en plein
    // écran par-dessus (navigateur racine).
    GoRoute(
      path: '/seance-en-cours',
      builder: (context, state) => const ActiveWorkoutScreen(),
      routes: _exerciseRoutes((state) => '/seance-en-cours'),
    ),
    // Résumé de fin de séance (WO-18), en plein écran lui aussi.
    GoRoute(
      path: '/resume/:workoutId',
      builder: (context, state) =>
          WorkoutSummaryScreen(workoutId: state.pathParameters['workoutId']!),
    ),
    // Réglages : pas un onglet (D32), une icône en haut des 3 autres y mène,
    // donc hors des branches, comme les autres écrans plein écran ci-dessus.
    GoRoute(
      path: '/reglages',
      builder: (context, state) => const SettingsScreen(),
    ),
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
              routes: [
                // Éditeur de modèle (TP-01, TP-03), dans l'onglet Séance.
                GoRoute(
                  path: 'modeles/nouveau',
                  builder: (context, state) => const TemplateEditorScreen(),
                  routes: _exerciseRoutes((state) => '/seance/modeles/nouveau'),
                ),
                GoRoute(
                  path: 'modeles/:id',
                  builder: (context, state) => TemplateEditorScreen(
                    templateId: state.pathParameters['id'],
                  ),
                  routes: _exerciseRoutes(
                    (state) => '/seance/modeles/${state.pathParameters['id']}',
                  ),
                ),
              ],
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
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
              routes: [
                // Résumé d'une séance passée, en lecture seule (SA-03).
                GoRoute(
                  path: 'seance/:workoutId',
                  builder: (context, state) => WorkoutSummaryScreen(
                    workoutId: state.pathParameters['workoutId']!,
                    readOnly: true,
                  ),
                ),
                // Nouvelle mesure (SA-06) et page d'une mesure (SA-08).
                GoRoute(
                  path: 'mesure/nouvelle',
                  builder: (context, state) => const NewMeasurementScreen(),
                ),
                GoRoute(
                  path: 'mesure/:field',
                  builder: (context, state) => MeasurementDetailScreen(
                    field: BodyMeasurementField.values.byName(
                      state.pathParameters['field']!,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Sous-routes d'un écran qui compose une liste d'exercices (séance en cours
/// ou modèle), situé au chemin renvoyé par [basePath] : le sélecteur
/// d'exercices (WO-04, l'onglet Exercices en mode sélection), la fiche d'un
/// exercice, sans modification possible (WO-22), et la création d'un
/// exercice depuis le sélecteur.
List<RouteBase> _exerciseRoutes(
  String Function(GoRouterState state) basePath,
) => [
  GoRoute(
    path: 'ajouter',
    builder: (context, state) =>
        ExercisesScreen.picker(ownerPath: basePath(state)),
  ),
  GoRoute(
    path: 'exercice/:exerciseId',
    builder: (context, state) => ExerciseDetailScreen(
      exerciseId: state.pathParameters['exerciseId']!,
      allowEditing: false,
    ),
  ),
  GoRoute(
    path: 'nouvel-exercice',
    builder: (context, state) => const ExerciseFormScreen(),
  ),
];
