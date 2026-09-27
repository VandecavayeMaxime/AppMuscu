// Dates en français, pour les statistiques. L'app n'existe qu'en français :
// quelques tableaux suffisent, sans paquet de traduction.

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

const _shortMonths = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

const _shortWeekdays = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];

/// « 1er » pour le premier du mois, comme on l'écrit en français.
String _day(DateTime date) => date.day == 1 ? '1er' : '${date.day}';

/// Mois abrégé : `'sept.'`.
String formatShortMonth(DateTime date) => _shortMonths[date.month - 1];

/// Jour et mois abrégé : `'12 sept.'`.
String formatDayMonth(DateTime date) =>
    '${_day(date)} ${formatShortMonth(date)}';

/// Jour, mois abrégé et année : `'12 sept. 2026'`.
String formatDayMonthYear(DateTime date) =>
    '${formatDayMonth(date)} ${date.year}';

/// Jour de la semaine abrégé et numéro du jour : `'lun. 21'`.
String formatWeekday(DateTime date) =>
    '${_shortWeekdays[date.weekday - 1]} ${_day(date)}';

/// Titre d'une semaine, d'après son lundi : `'Semaine du 21 septembre'`.
String formatWeekOf(DateTime monday) =>
    'Semaine du ${_day(monday)} ${_months[monday.month - 1]}';

/// Semaine complète (lundi à dimanche), d'après son lundi : `'22 au 28
/// septembre'`, ou `'29 septembre au 5 octobre'` à cheval sur deux mois.
String formatWeekRange(DateTime monday) {
  final sunday = DateTime(monday.year, monday.month, monday.day + 6);
  if (monday.month == sunday.month && monday.year == sunday.year) {
    return '${_day(monday)} au ${_day(sunday)} ${_months[monday.month - 1]}';
  }
  String full(DateTime date) {
    final year = date.year != monday.year ? ' ${date.year}' : '';
    return '${_day(date)} ${_months[date.month - 1]}$year';
  }

  return '${full(monday)} au ${full(sunday)}';
}
