import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/empty_state.dart';

/// Onglet « Exercices » : bibliothèque, recherche, exercices perso (M2).
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercices')),
      body: const EmptyState(
        icon: Icons.menu_book,
        title: "Bibliothèque d'exercices",
        message: 'Arrive au jalon M2.',
      ),
    );
  }
}
