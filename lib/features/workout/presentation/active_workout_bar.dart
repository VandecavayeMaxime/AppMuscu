import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../rest_timer/presentation/rest_countdown.dart';
import 'elapsed_time.dart';
import 'workout_providers.dart';

/// Séance réduite (WO-20) : barre au-dessus des onglets, visible tant
/// qu'une séance est en cours. Elle montre le nom, le chrono et le repos en
/// cours (RT-08) ; la toucher rouvre la séance. Rien s'il n'y a pas de
/// séance en cours.
class ActiveWorkoutBar extends ConsumerWidget {
  const ActiveWorkoutBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutProvider).value;
    if (workout == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    void open() => context.push('/seance-en-cours');

    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: open,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RestProgressLine(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        ElapsedTime(
                          workout.startedAt,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  RestCountdown(onTap: open),
                  IconButton(
                    tooltip: 'Reprendre la séance',
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: open,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
