// Activité quotidienne (D36) : pas, distance, calories actives et sommeil,
// lus sur le téléphone (Health Connect ou Apple Santé) plutôt que saisis à
// la main.

/// Les 4 mesures suivies, chacune avec son historique et son propre
/// graphique (comme `BodyMeasurementField` pour les mesures du corps).
enum ActivityMetric {
  steps('Pas'),
  distance('Distance'),
  calories('Calories'),
  sleep('Sommeil');

  const ActivityMetric(this.label);

  final String label;

  /// La valeur de ce champ dans [summary] (pas, mètres, kcal ou minutes), ou
  /// `null` si absente ce jour-là.
  double? valueOf(ActivitySummary summary) => switch (this) {
    steps => summary.steps?.toDouble(),
    distance => summary.distanceMeters,
    calories => summary.activeCalories,
    sleep => summary.sleepMinutes?.toDouble(),
  };
}

/// Une journée d'activité ; tout est nullable sauf la date, une journée
/// pouvant n'avoir que certaines mesures (ex. pas mais pas de sommeil).
typedef ActivitySummary = ({
  DateTime date,
  int? steps,
  double? distanceMeters,
  double? activeCalories,
  int? sleepMinutes,
});

/// Un échantillon brut d'une seule mesure sur un intervalle de temps : le
/// format commun avant agrégation par jour, indépendant du paquet de santé
/// utilisé (aucun de ses types ici), pour rester testable sans lui.
typedef ActivitySample = ({
  DateTime from,
  DateTime to,
  ActivityMetric metric,
  double value,
});

/// Regroupe des échantillons bruts en une ligne par jour civil, en sommant
/// les valeurs qui tombent ce jour-là (plusieurs séances de marche ou
/// segments de sommeil dans la même journée s'additionnent). Un échantillon
/// à cheval sur deux jours (ex. une nuit de sommeil) compte pour le jour de
/// son début, faute de mieux — assez pour un premier suivi, pas une horloge
/// de précision. Résultat trié du plus ancien au plus récent.
List<ActivitySummary> aggregateByDay(List<ActivitySample> samples) {
  final byDay = <DateTime, Map<ActivityMetric, double>>{};
  for (final sample in samples) {
    final day = DateTime(sample.from.year, sample.from.month, sample.from.day);
    final metrics = byDay.putIfAbsent(day, () => {});
    metrics[sample.metric] = (metrics[sample.metric] ?? 0) + sample.value;
  }

  final days = byDay.keys.toList()..sort();
  return [
    for (final day in days)
      (
        date: day,
        steps: byDay[day]![ActivityMetric.steps]?.round(),
        distanceMeters: byDay[day]![ActivityMetric.distance],
        activeCalories: byDay[day]![ActivityMetric.calories],
        sleepMinutes: byDay[day]![ActivityMetric.sleep]?.round(),
      ),
  ];
}
