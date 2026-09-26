import 'set_type.dart';

/// Libellés de la colonne « Série » (RG-02) : les séries normales sont
/// numérotées 1, 2, 3… ; les autres affichent leur lettre.
///
/// Exemple : `[warmup, normal, normal, dropset]` → `['W', '1', '2', 'D']`.
List<String> setLabels(List<SetType> types) {
  var number = 0;
  return [for (final type in types) type.letter ?? '${++number}'];
}
