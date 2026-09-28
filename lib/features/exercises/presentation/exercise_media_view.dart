import 'package:material_ui/material_ui.dart';

import '../../../core/database/seed/exercise_media.dart';

/// Illustration d'un exercice, dans l'onglet « À propos » (EX-07) : son
/// image RepDB si elle est disponible, sinon l'icône générique. Crédit
/// affiché une fois pour toutes dans Réglages (licence RepDB : pas besoin
/// de le répéter sous chaque image).
class ExerciseMediaView extends StatelessWidget {
  const ExerciseMediaView(this.media, {super.key});

  final ExerciseMedia? media;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;
    if (media?.imageAsset case final imageAsset?) {
      // `contain`, pas `cover` : les images RepDB sont carrées (voir
      // docs/ARCHITECTURE.md §4), un recadrage en 16:9 coupait le dessin.
      child = Image.asset(imageAsset, fit: BoxFit.contain);
    } else {
      child = Icon(
        Icons.fitness_center,
        size: 72,
        color: theme.colorScheme.outline,
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
