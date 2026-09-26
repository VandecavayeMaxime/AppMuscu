import 'package:app_muscu/core/platform/screen_awake.dart';

/// Fausse mise en veille : note seulement les demandes.
class FakeScreenAwake implements ScreenAwake {
  /// Dernière demande : `true` = écran gardé allumé.
  bool keptOn = false;

  @override
  Future<void> keepOn(bool on) async => keptOn = on;
}
