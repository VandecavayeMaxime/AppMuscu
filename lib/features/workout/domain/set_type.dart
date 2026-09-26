/// Type d'une série (docs/SPEC.md §3, RG-02).
///
/// ⚠️ Le nom Dart de chaque valeur est enregistré en base : ne pas le renommer.
enum SetType {
  normal('Normale', null),
  warmup('Échauffement', 'W'),
  dropset('Drop set', 'D'),
  failure('Échec', 'F');

  const SetType(this.label, this.letter);

  final String label;

  /// Lettre affichée à la place du numéro ; `null` pour une série normale (numérotée).
  final String? letter;
}
