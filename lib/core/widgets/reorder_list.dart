import 'package:material_ui/material_ui.dart';

/// Un élément de la liste de réorganisation.
typedef ReorderItem = ({Key key, String name});

/// Mode « réorganiser », commun aux exercices de la séance (WO-15) et d'un
/// modèle (TP-01), et aux modèles eux-mêmes (TP-08) : chaque élément est
/// réduit à une ligne, pour qu'on puisse le faire glisser facilement. On
/// l'attrape par la poignée ≡ (ou par un appui long sur la ligne), puis
/// « OK » rend l'affichage normal.
class ReorderList extends StatelessWidget {
  const ReorderList({
    super.key,
    required this.items,
    required this.onMove,
    required this.onDone,
    this.hint = 'Glisse les exercices pour changer leur ordre',
  });

  final List<ReorderItem> items;

  /// L'élément de la place [from] va à la place [to] (dans la liste finale).
  final void Function(int from, int to) onMove;

  final VoidCallback onDone;

  /// Consigne affichée au-dessus de la liste.
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Material(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                FilledButton(onPressed: onDone, child: const Text('OK')),
              ],
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            // Poignées placées à la main : à gauche, et actives tout de suite.
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: onMove,
            itemBuilder: (context, index) {
              final item = items[index];
              return ReorderableDelayedDragStartListener(
                key: item.key,
                index: index,
                child: ListTile(
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(item.name),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
