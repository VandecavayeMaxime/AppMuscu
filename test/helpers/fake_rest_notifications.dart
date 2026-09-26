import 'package:app_muscu/features/rest_timer/data/rest_notifications.dart';

/// Fausses notifications : n'affichent rien, notent seulement les appels.
class FakeRestNotifications implements RestNotifications {
  int permissionRequests = 0;

  /// Notifications programmées : heure et exercice suivant.
  final scheduled = <({DateTime at, String nextExercise})>[];
  int cancellations = 0;

  @override
  Future<void> requestPermission() async => permissionRequests++;

  @override
  Future<void> scheduleRestEnd(
    DateTime at, {
    required String nextExercise,
  }) async => scheduled.add((at: at, nextExercise: nextExercise));

  @override
  Future<void> cancelRestEnd() async => cancellations++;
}
