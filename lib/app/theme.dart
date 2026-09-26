import 'package:material_ui/material_ui.dart';

/// Couleur de base : Material 3 en dérive toute la palette (boutons, fonds, textes…).
const _seedColor = Color(0xFF2F6FED);

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  ),
);
