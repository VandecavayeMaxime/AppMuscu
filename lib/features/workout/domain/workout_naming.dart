/// Nom par défaut d'une séance vide, selon l'heure de début (RG-05).
String defaultWorkoutName(DateTime start) {
  final hour = start.hour;
  if (hour >= 5 && hour < 12) return 'Séance du matin';
  if (hour >= 12 && hour < 18) return "Séance de l'après-midi";
  return 'Séance du soir';
}
