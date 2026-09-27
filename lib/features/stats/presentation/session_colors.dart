import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../domain/weekly_sessions.dart';

/// Palette des séances (RG-16) : 8 couleurs bien distinctes, lisibles en
/// thème clair comme en thème sombre.
const sessionPalette = <Color>[
  Color(0xFF3B82F6), // bleu
  Color(0xFFEF4444), // rouge
  Color(0xFF22C55E), // vert
  Color(0xFFF59E0B), // ambre
  Color(0xFFA855F7), // violet
  Color(0xFF14B8A6), // turquoise
  Color(0xFFEC4899), // rose
  Color(0xFFB45309), // brun
];

/// Une entrée de la légende du diagramme.
typedef LegendEntry = ({Color color, String label});

/// Couleur de chaque séance et légende, d'après l'ordre des modèles (RG-16).
class SessionColors {
  SessionColors(List<Template> templates, {required this.others})
    : _names = {for (final t in templates) t.id: t.name},
      _indexes = paletteIndexes([for (final t in templates) t.id]);

  /// Couleur des séances sans modèle connu (« Autres »).
  final Color others;
  final Map<String, String> _names;
  final Map<String, int> _indexes;

  Color of(SessionEntry session) {
    final index = _indexes[session.templateId];
    return index == null ? others : sessionPalette[index];
  }

  /// Les modèles des [sessions], dans l'ordre des couleurs, puis « Autres »
  /// s'il y a des séances sans modèle.
  List<LegendEntry> legend(Iterable<SessionEntry> sessions) {
    final used = {for (final session in sessions) session.templateId};
    return [
      // Une `Map` se parcourt dans l'ordre d'insertion : celui des modèles.
      for (final MapEntry(key: id, value: index) in _indexes.entries)
        if (used.contains(id))
          (color: sessionPalette[index], label: _names[id]!),
      if (used.any((id) => !_indexes.containsKey(id)))
        (color: others, label: 'Autres'),
    ];
  }
}
