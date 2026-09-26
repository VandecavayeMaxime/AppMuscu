/// Temps de repos effectif d'une série (RG-09) : sa valeur propre, sinon
/// celle de l'exercice, sinon le réglage global. 0 = pas de minuteur.
int effectiveRestSeconds({
  required int? setRest,
  required int? exerciseRest,
  required int globalRest,
}) => setRest ?? exerciseRest ?? globalRest;

/// Minuteur de repos lancé à la validation d'une série (RT-02).
///
/// Il repose sur une heure de fin absolue et non sur un décompte : il reste
/// exact même si l'app passe en arrière-plan ou est fermée (RT-06).
class RestTimer {
  const RestTimer({
    required this.setId,
    required this.endsAt,
    required this.totalSeconds,
  });

  /// La série validée, sous laquelle s'affiche le décompte (RT-03).
  final String setId;
  final DateTime endsAt;
  final int totalSeconds;

  bool isRunning(DateTime now) => now.isBefore(endsAt);

  Duration remaining(DateTime now) {
    final left = endsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Secondes restantes à afficher, arrondies au-dessus comme un compte à
  /// rebours : « 2:00 » au départ, « 0:01 » pendant la dernière seconde.
  int remainingSeconds(DateTime now) =>
      (remaining(now).inMilliseconds / 1000).ceil();

  /// Part du repos écoulée, de 0 (début) à 1 (fin).
  double progress(DateTime now) {
    if (totalSeconds <= 0) return 1;
    final left = remaining(now).inMilliseconds / (totalSeconds * 1000);
    return (1 - left).clamp(0.0, 1.0);
  }
}
