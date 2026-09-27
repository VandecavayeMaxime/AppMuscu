import 'package:material_ui/material_ui.dart';

/// Durée d'affichage d'un message « Annuler », avant qu'il ne disparaisse
/// tout seul.
const undoSnackBarDuration = Duration(seconds: 3);

/// Message avec un bouton « Annuler », qui disparaît de lui-même après
/// [undoSnackBarDuration] : son fond se remplit d'une teinte plus claire, de
/// gauche à droite, pour montrer qu'il reste peu de temps pour agir.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: undoSnackBarDuration,
        padding: EdgeInsets.zero,
        backgroundColor: colors.inverseSurface,
        content: _UndoContent(
          message: message,
          onUndo: onUndo,
          fill: colors.onInverseSurface,
        ),
      ),
    );
}

class _UndoContent extends StatefulWidget {
  const _UndoContent({
    required this.message,
    required this.onUndo,
    required this.fill,
  });

  final String message;
  final VoidCallback onUndo;

  /// Couleur du texte, réutilisée pour la teinte qui progresse (à faible
  /// opacité) : elle reste dans la même famille que le fond du message.
  final Color fill;

  @override
  State<_UndoContent> createState() => _UndoContentState();
}

class _UndoContentState extends State<_UndoContent>
    with SingleTickerProviderStateMixin {
  // Contrôle l'animation nous-mêmes (plutôt que `TweenAnimationBuilder`, qui
  // ne rejoue pas son animation au premier affichage) : elle doit démarrer
  // dès l'ouverture du message.
  late final _controller = AnimationController(
    vsync: this,
    duration: undoSnackBarDuration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond animé, sous le texte : une teinte proche de celle du fond
        // (pas une couleur d'accent contrastée), qui progresse de gauche à
        // droite. `Positioned.fill` lui donne la taille du contenu au-dessus
        // (la ligne de texte), qui fixe la taille du `Stack`.
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _controller.value,
              child: ColoredBox(color: widget.fill.withValues(alpha: 0.16)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(child: Text(widget.message)),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  widget.onUndo();
                },
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
