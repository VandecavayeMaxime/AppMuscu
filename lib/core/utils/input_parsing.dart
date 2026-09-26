// Lecture des nombres saisis au clavier (WO-07). Chaque fonction renvoie
// `null` si le texte est vide ou invalide.

/// Nombre décimal, avec virgule ou point : `'82,5'` → 82.5.
double? parseDecimal(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  return (value == null || value < 0) ? null : value;
}

/// Nombre entier positif : `'8'` → 8.
int? parseInteger(String text) {
  final value = int.tryParse(text.trim());
  return (value == null || value < 0) ? null : value;
}

/// Durée en « m:ss » ou en secondes : `'1:30'` → 90, `'45'` → 45.
int? parseDuration(String text) {
  final parts = text.trim().split(':');
  if (parts.length == 1) return parseInteger(parts.single);
  if (parts.length != 2) return null;
  final minutes = parseInteger(parts[0]);
  final seconds = parseInteger(parts[1]);
  if (minutes == null || seconds == null || seconds >= 60) return null;
  return minutes * 60 + seconds;
}
