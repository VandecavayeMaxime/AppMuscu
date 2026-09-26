import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/empty_state.dart';

/// Onglet « Réglages » : temps de repos par défaut, vibration, thème (M6).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: const EmptyState(
        icon: Icons.settings,
        title: 'Réglages',
        message: 'Arrive au jalon M6.',
      ),
    );
  }
}
