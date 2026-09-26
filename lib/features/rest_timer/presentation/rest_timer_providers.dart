import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/data/settings_repository.dart';
import '../data/rest_notifications.dart';
import '../data/rest_timer_repository.dart';
import '../domain/rest_timer.dart';

/// Le minuteur enregistré, mis à jour en direct.
final restTimerProvider = StreamProvider<RestTimer?>(
  (ref) => ref.watch(restTimerRepositoryProvider).watch(),
);

final restTimerControllerProvider = Provider<RestTimerController>(
  (ref) => RestTimerController(
    ref.watch(restTimerRepositoryProvider),
    ref.watch(restNotificationsProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);

/// Démarre et arrête le minuteur de repos : état enregistré en base (RT-06)
/// et notification de fin programmée (RT-05), avec le son et la vibration
/// choisis dans les réglages (ST-02).
class RestTimerController {
  RestTimerController(this._repository, this._notifications, this._settings);

  final RestTimerRepository _repository;
  final RestNotifications _notifications;
  final SettingsRepository _settings;

  /// Démarre (ou redémarre) le repos de la série [setId] (RT-02).
  /// Avec 0 seconde, le minuteur est simplement arrêté (RT-01).
  Future<void> start({
    required String setId,
    required int seconds,
    required String nextExercise,
  }) async {
    if (seconds <= 0) return stop();
    final endsAt = clock.now().add(Duration(seconds: seconds));
    await _repository.save(
      RestTimer(setId: setId, endsAt: endsAt, totalSeconds: seconds),
    );
    final alert = await _settings.readRestAlert();
    await _notifications.scheduleRestEnd(
      endsAt,
      nextExercise: nextExercise,
      sound: alert.sound,
      vibration: alert.vibration,
    );
  }

  /// Arrête le minuteur (RT-04 : fin ou abandon de la séance).
  Future<void> stop() async {
    await _repository.clear();
    await _notifications.cancelRestEnd();
  }

  /// Arrête le minuteur s'il tourne pour l'une de ces séries : série
  /// dévalidée, supprimée, ou exercice retiré (RT-02).
  Future<void> stopIfFor(Iterable<String> setIds) async {
    final current = await _repository.read();
    if (current != null && setIds.contains(current.setId)) await stop();
  }
}
