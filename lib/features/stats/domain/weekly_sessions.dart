/// Une séance terminée, avec ce qu'en montre le sous-onglet « Séances ».
class SessionEntry {
  const SessionEntry({
    required this.id,
    required this.name,
    required this.templateId,
    required this.startedAt,
    required this.endedAt,
  });

  final String id;
  final String name;

  /// Modèle d'origine : donne la couleur du bloc (RG-16).
  final String? templateId;
  final DateTime startedAt;
  final DateTime endedAt;

  Duration get duration => endedAt.difference(startedAt);
}

/// Les séances d'une semaine, du lundi au dimanche (SA-02).
class WeekSessions {
  WeekSessions(this.monday);

  /// Lundi de la semaine, à minuit.
  final DateTime monday;

  /// Dans l'ordre chronologique.
  final List<SessionEntry> sessions = [];
}

/// Lundi (à minuit) de la semaine de [date].
DateTime startOfWeek(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));

/// Regroupe les séances par semaine, de la plus ancienne à la semaine en
/// cours, sans trou : une semaine sans séance est présente, vide. Il y a au
/// moins [minWeeks] semaines, pour remplir le diagramme (SA-02).
List<WeekSessions> groupByWeek(
  List<SessionEntry> sessions,
  DateTime now, {
  int minWeeks = 12,
}) {
  final current = startOfWeek(now);
  var monday = DateTime(
    current.year,
    current.month,
    current.day - 7 * (minWeeks - 1),
  );
  for (final session in sessions) {
    final week = startOfWeek(session.startedAt);
    if (week.isBefore(monday)) monday = week;
  }

  final weeks = <DateTime, WeekSessions>{};
  while (!monday.isAfter(current)) {
    weeks[monday] = WeekSessions(monday);
    monday = DateTime(monday.year, monday.month, monday.day + 7);
  }
  final sorted = [...sessions]
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  for (final session in sorted) {
    // Une séance datée après la semaine en cours (horloge changée) est ignorée.
    weeks[startOfWeek(session.startedAt)]?.sessions.add(session);
  }
  return weeks.values.toList();
}

/// Position de chaque modèle dans la palette (RG-16), d'après la liste des
/// modèles dans l'ordre : actifs d'abord, puis supprimés. La palette
/// recommence après [paletteSize] modèles.
Map<String, int> paletteIndexes(
  List<String> orderedTemplateIds, {
  int paletteSize = 8,
}) => {
  for (final (index, id) in orderedTemplateIds.indexed) id: index % paletteSize,
};
