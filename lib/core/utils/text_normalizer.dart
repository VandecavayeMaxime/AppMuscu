/// Met un texte sous une forme facile à comparer : minuscules, sans accents,
/// espaces superflus retirés.
///
/// Exemple : `'  Développé   COUCHÉ '` → `'developpe couche'`.
/// Sert à la recherche (EX-02) et à l'unicité des noms d'exercices (EX-06).
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    // Accent « détaché » (é écrit e + ́) : on ignore simplement l'accent.
    if (rune >= 0x300 && rune <= 0x36F) continue;
    final char = String.fromCharCode(rune);
    final index = _accents.indexOf(char);
    buffer.write(switch (char) {
      'æ' => 'ae',
      'œ' => 'oe',
      _ when index >= 0 => _letters[index],
      _ => char,
    });
  }
  return buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
}

// Chaque lettre accentuée est remplacée par la lettre à la même position.
const _accents = 'àâäáãåçéèêëîïíìôöóòõùûüúÿýñ';
const _letters = 'aaaaaaceeeeiiiiooooouuuuyyn';
