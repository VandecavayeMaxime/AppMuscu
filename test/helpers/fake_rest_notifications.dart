import 'package:app_muscu/features/rest_timer/data/rest_notifications.dart';

/// Fausses notifications : n'affichent rien, notent seulement les appels.
class FakeRestNotifications implements RestNotifications {
  int permissionRequests = 0;

  /// Notifications programmées : heure, exercice suivant, son et vibration.
  final scheduled =
      <({DateTime at, String nextExercise, bool sound, bool vibration})>[];
  int cancellations = 0;

  @override
  Future<void> requestPermission() async => permissionRequests++;

  @override
  Future<void> scheduleRestEnd(
    DateTime at, {
    required String nextExercise,
    bool sound = true,
    bool vibration = true,
  }) async => scheduled.add((
    at: at,
    nextExercise: nextExercise,
    sound: sound,
    vibration: vibration,
  ));

  @override
  Future<void> cancelRestEnd() async => cancellations++;

  void Function()? _onTap;

  @override
  Future<void> listenToTaps(void Function() onTap) async => _onTap = onTap;

  /// Simule un toucher sur la notification de fin de repos.
  void tap() => _onTap?.call();
}
