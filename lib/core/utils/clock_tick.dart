import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// L'heure actuelle, renvoyée 5 fois par seconde : fait avancer les
/// chronomètres (WO-03) et le minuteur de repos (RT-03) de façon fluide,
/// sans sauter de seconde à l'affichage.
///
/// Les tests le remplacent par un flux immobile, sinon `pumpAndSettle`
/// attendrait indéfiniment la fin des mises à jour.
final clockTickProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(tickInterval, (_) => clock.now()),
);

/// Intervalle entre deux mises à jour de l'heure.
const tickInterval = Duration(milliseconds: 200);
