import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification de fin de repos (RT-05). Les tests la remplacent par une
/// fausse implémentation qui se contente de noter les appels.
final restNotificationsProvider = Provider<RestNotifications>(
  (ref) => LocalRestNotifications(),
);

abstract interface class RestNotifications {
  /// Demande l'autorisation d'afficher des notifications (Android 13+).
  Future<void> requestPermission();

  /// Programme la notification « Repos terminé » à l'heure [at].
  Future<void> scheduleRestEnd(DateTime at, {required String nextExercise});

  /// Annule la notification programmée, s'il y en a une.
  Future<void> cancelRestEnd();
}

/// Implémentation réelle, avec flutter_local_notifications.
///
/// La notification s'affiche que l'app soit ouverte ou non : avec le son et
/// la vibration du téléphone, elle prévient dans les deux cas.
class LocalRestNotifications implements RestNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  /// Toujours le même identifiant : programmer un nouveau repos remplace
  /// la notification précédente.
  static const _restEndId = 1;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'rest_timer',
      'Fin du repos',
      channelDescription: 'Prévient quand le temps de repos est écoulé',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_rest',
    ),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> _ensureInitialized() => _initialization ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_rest'),
        ),
      )
      .then((_) {});

  @override
  Future<void> requestPermission() async {
    await _ensureInitialized();
    await _android?.requestNotificationsPermission();
  }

  @override
  Future<void> scheduleRestEnd(
    DateTime at, {
    required String nextExercise,
  }) async {
    try {
      await _ensureInitialized();
      // À la seconde près si les alarmes exactes sont permises, sinon
      // « à peu près » (Android peut alors retarder un peu la notification).
      final exact = await _android?.canScheduleExactNotifications() ?? false;
      await _plugin.zonedSchedule(
        id: _restEndId,
        // Heure absolue exprimée en UTC : pas besoin du fuseau du téléphone.
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        title: 'Repos terminé',
        body: 'Prochaine série : $nextExercise',
      );
    } catch (error) {
      // Le minuteur reste visible dans l'app même sans notification.
      debugPrint('Notification de repos impossible : $error');
    }
  }

  @override
  Future<void> cancelRestEnd() async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _restEndId);
    } catch (error) {
      debugPrint('Annulation de la notification impossible : $error');
    }
  }
}
