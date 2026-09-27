/// Périodes proposées par les statistiques. Chaque écran n'en montre que
/// quelques-unes (fiche exercice : 3 mois, 1 an, tout).
enum StatsPeriod {
  days7('7 j'),
  days30('30 j'),
  month1('1 mois'),
  months3('3 mois'),
  year1('1 an'),
  all('Tout');

  const StatsPeriod(this.label);

  /// Libellé court, pour les puces de choix (« 7 j », « 1 an »…).
  final String label;

  /// Libellé complet, pour un titre de section (« Séries sur 30 jours »).
  String get longLabel => switch (this) {
    days7 => '7 jours',
    days30 => '30 jours',
    month1 => '1 mois',
    months3 => '3 mois',
    year1 => '1 an',
    all => 'toute la période',
  };

  /// Début de la période qui se termine aujourd'hui (à minuit), `null` pour
  /// « Tout ». « 7 j » = aujourd'hui et les 6 jours d'avant (RG-17).
  ///
  /// Les dates sont construites jour par jour (`DateTime(année, mois, jour)`)
  /// plutôt qu'en retirant des durées : un jour de changement d'heure dure
  /// 23 ou 25 heures. Dart accepte les jours et mois hors limites
  /// (le « 0 septembre » est le 31 août).
  DateTime? start(DateTime now) => switch (this) {
    days7 => DateTime(now.year, now.month, now.day - 6),
    days30 => DateTime(now.year, now.month, now.day - 29),
    month1 => DateTime(now.year, now.month - 1, now.day),
    months3 => DateTime(now.year, now.month - 3, now.day),
    year1 => DateTime(now.year - 1, now.month, now.day),
    all => null,
  };
}
