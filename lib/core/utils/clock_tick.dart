import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// L'heure actuelle, renvoyée chaque seconde : fait avancer les chronomètres
/// (WO-03). Les tests le remplacent par un flux immobile, sinon
/// `pumpAndSettle` attendrait indéfiniment la fin des mises à jour.
final clockTickProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (_) => clock.now()),
);
