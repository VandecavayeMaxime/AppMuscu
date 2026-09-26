import 'package:material_ui/material_ui.dart';

/// Un exercice dans la liste de réorganisation.
typedef ReorderItem = ({Key key, String name});

/// Mode « réorganiser » (WO-15, TP-01), commun à la séance et à l'éditeur de
/// modèle : les exercices sont réduits à une ligne, sans leurs séries, pour
/// qu'on puisse les faire glisser facilement. On les attrape par la poignée
/// ≡ (ou par un appui long sur la ligne), puis « OK » rend l'affichage
/// normal.
class ExerciseReorderList extends StatelessWidget {
  const ExerciseReorderList({
    super.key,
    required this.items,
    required this.onMove,
    required this.onDone,
  });

  final List<ReorderItem> items;

  /// L'exercice de la place [from] va à la place [to] (dans la liste finale).
  final void Function(int from, int to) onMove;

  final VoidCallback onDone;

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
                    'Glisse les exercices pour changer leur ordre',
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
