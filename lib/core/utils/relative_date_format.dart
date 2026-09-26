/// Jour relatif à aujourd'hui : « Aujourd'hui », « Hier », « Il y a 3 jours »,
/// « Il y a 2 semaines », « Il y a 4 mois », « Il y a 1 an ».
String formatRelativeDay(DateTime date, DateTime now) {
  // On compare des jours du calendrier, pas des durées : hier à 23 h, c'est
  // « Hier » même s'il est minuit et quart.
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  // Arrondi : un jour de changement d'heure dure 23 ou 25 heures.
  final days = (today.difference(day).inHours / 24).round();

  if (days <= 0) return "Aujourd'hui";
  if (days == 1) return 'Hier';
  if (days < 7) return 'Il y a $days jours';
  if (days < 30) return _ago(days ~/ 7, 'semaine', 'semaines');
  if (days < 365) return 'Il y a ${days ~/ 30} mois';
  return _ago(days ~/ 365, 'an', 'ans');
}

String _ago(int count, String singular, String plural) =>
    'Il y a $count ${count == 1 ? singular : plural}';
