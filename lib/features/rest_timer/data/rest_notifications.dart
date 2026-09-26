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

  /// Programme la notification « Repos terminé » à l'heure [at], avec ou
  /// sans son et vibration (ST-02).
  Future<void> scheduleRestEnd(
    DateTime at, {
    required String nextExercise,
    bool sound = true,
    bool vibration = true,
  });

  /// Annule la notification programmée, s'il y en a une.
  Future<void> cancelRestEnd();
}

/// Implémentation réelle, avec flutter_local_notifications.
///
/// La notification s'affiche que l'app soit ouverte ou non : avec le son et
/// la vibration du téléphone (sauf si on les coupe dans les réglages), elle
/// prévient dans les deux cas.
class LocalRestNotifications implements RestNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  /// Toujours le même identifiant : programmer un nouveau repos remplace
  /// la notification précédente.
  static const _restEndId = 1;

  /// Android fige le son et la vibration d'un « canal » de notifications à
  /// sa création : il faut donc un canal par combinaison (ST-02).
  static NotificationDetails _details({
    required bool sound,
    required bool vibration,
  }) {
    final (channelId, channelName) = switch ((sound, vibration)) {
      (true, true) => ('rest_timer', 'Fin du repos'),
      (true, false) => ('rest_timer_sound', 'Fin du repos (son seul)'),
      (false, true) => (
        'rest_timer_vibration',
        'Fin du repos (vibration seule)',
      ),
      (false, false) => ('rest_timer_silent', 'Fin du repos (silencieuse)'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Prévient quand le temps de repos est écoulé',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_stat_rest',
        playSound: sound,
        enableVibration: vibration,
      ),
    );
  }

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
    bool sound = true,
    bool vibration = true,
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
        notificationDetails: _details(sound: sound, vibration: vibration),
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
