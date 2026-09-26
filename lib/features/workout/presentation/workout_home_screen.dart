import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/empty_state.dart';

/// Onglet « Séance » : démarrer une séance et liste des modèles (M3, M5).
class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Séance')),
      body: const EmptyState(
        icon: Icons.fitness_center,
        title: "Aucun modèle pour l'instant",
        message: 'Les séances arrivent au jalon M3, les modèles au jalon M5.',
      ),
    );
  }
}
