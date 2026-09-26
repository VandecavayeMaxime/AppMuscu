import 'package:material_ui/material_ui.dart';

import '../../templates/presentation/template_list.dart';

/// Onglet « Séance » : les modèles, d'où démarre toute séance (WO-01). La
/// séance en cours, elle, se reprend depuis la barre au-dessus des onglets
/// (WO-20).
class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Séance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [TemplateSection()],
      ),
    );
  }
}
