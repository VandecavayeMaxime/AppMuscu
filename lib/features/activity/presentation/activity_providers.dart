import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/health_data.dart';
import '../domain/activity_summary.dart';

/// `null` = jamais demandée, sinon accordée (`true`) ou refusée (`false`).
final activityPermissionProvider = FutureProvider<bool?>(
  (ref) => ref.watch(healthDataProvider).hasPermission(),
);

/// Un an d'historique (comme les mesures du corps), récupéré une fois et
/// filtré par période dans l'écran plutôt que redemandé à chaque puce.
final activityHistoryProvider = FutureProvider<List<ActivitySummary>>((
  ref,
) async {
  final now = clock.now();
  final start = DateTime(now.year - 1, now.month, now.day);
  return ref.watch(healthDataProvider).history(start, now);
});
