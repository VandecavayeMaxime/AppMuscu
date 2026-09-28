import 'package:material_ui/material_ui.dart';

/// Fond rouge révélé en balayant un élément vers la gauche pour le
/// supprimer (WO-11).
class SwipeDeleteBackground extends StatelessWidget {
  const SwipeDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
    );
  }
}
