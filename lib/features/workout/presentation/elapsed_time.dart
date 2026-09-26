import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/clock_tick.dart';
import '../../../core/utils/duration_format.dart';

/// Temps écoulé depuis [since], mis à jour chaque seconde (WO-03).
class ElapsedTime extends ConsumerWidget {
  const ElapsedTime(this.since, {super.key, this.style});

  final DateTime since;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockTickProvider).value ?? clock.now();
    final seconds = now.difference(since).inSeconds;
    return Text(formatDuration(seconds < 0 ? 0 : seconds), style: style);
  }
}
