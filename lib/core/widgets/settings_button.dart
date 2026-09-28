import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Icône Réglages, en haut à droite des 3 onglets principaux (D32) : aussi
/// vite accessible que Séance, Exercices et Stats, sans lui garder un 4e
/// onglet en bas (une icône seule, pas de texte).
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.settings_outlined),
    tooltip: 'Réglages',
    onPressed: () => context.push('/reglages'),
  );
}
