/// Thème de l'app (ST-03).
enum AppTheme {
  system('Système'),
  light('Clair'),
  dark('Sombre');

  const AppTheme(this.label);

  final String label;
}
