import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/clock_tick.dart';
import '../../../core/utils/duration_format.dart';
import 'rest_timer_providers.dart';

/// Compteur compact du repos en cours (RT-08) : « ⏱ 1:12 », dans l'en-tête
/// de la séance ou la barre de séance réduite. Rien si aucun repos ne tourne.
class RestCountdown extends ConsumerWidget {
  const RestCountdown({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider).value;
    final now = ref.watch(clockTickProvider).value ?? clock.now();
    if (timer == null || !timer.isRunning(now)) return const SizedBox.shrink();

    return ActionChip(
      avatar: const Icon(Icons.timer_outlined, size: 18),
      label: Text(formatDuration(timer.remainingSeconds(now))),
      tooltip: 'Repos en cours',
      onPressed: onTap,
    );
  }
}

/// Fine barre de progression du repos en cours, qui glisse en continu.
/// Rien si aucun repos ne tourne.
class RestProgressLine extends ConsumerWidget {
  const RestProgressLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider).value;
    final now = ref.watch(clockTickProvider).value ?? clock.now();
    if (timer == null || !timer.isRunning(now)) {
      return const SizedBox(height: 3); // même hauteur : la barre ne saute pas
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(end: timer.progress(now)),
      duration: tickInterval,
      builder: (context, value, _) =>
          LinearProgressIndicator(value: value, minHeight: 3),
    );
  }
}
