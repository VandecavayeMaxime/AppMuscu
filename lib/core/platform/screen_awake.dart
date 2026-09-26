import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Garder l'écran allumé (ST-04). Les tests la remplacent par une fausse
/// implémentation.
final screenAwakeProvider = Provider<ScreenAwake>(
  (ref) => const PlatformScreenAwake(),
);

abstract interface class ScreenAwake {
  /// Empêche (ou non) l'écran de s'éteindre tant que l'app est affichée.
  Future<void> keepOn(bool on);
}

/// Implémentation réelle, par un « canal de plateforme » : Dart envoie un
/// message au code Android natif (MainActivity.kt), qui pose ou retire le
/// drapeau FLAG_KEEP_SCREEN_ON sur la fenêtre de l'app.
class PlatformScreenAwake implements ScreenAwake {
  const PlatformScreenAwake();

  static const _channel = MethodChannel('appmuscu/screen');

  @override
  Future<void> keepOn(bool on) async {
    try {
      await _channel.invokeMethod<void>('keepOn', on);
    } on Exception catch (error) {
      // Rien de grave : l'écran s'éteindra simplement comme d'habitude.
      debugPrint('Réglage de la mise en veille impossible : $error');
    }
  }
}
