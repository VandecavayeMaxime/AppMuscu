import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/workout/presentation/active_workout_bar.dart';

/// Écran principal : l'onglet actif au-dessus, la barre d'onglets en bas et,
/// juste au-dessus d'elle, la séance réduite s'il y en a une (WO-20).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  /// Fourni par go_router : connaît l'onglet actif et sait en changer.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ActiveWorkoutBar(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              // Re-taper l'onglet déjà actif ramène à son premier écran.
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.fitness_center),
                label: 'Séance',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Exercices',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Réglages',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
