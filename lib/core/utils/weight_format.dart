import '../../features/exercises/domain/exercise_enums.dart';

/// Poids enregistré en kg, affiché dans l'unité voulue (RG-14) : virgule
/// française, au plus 2 décimales, zéros inutiles retirés.
///
/// Exemples : 82.5 kg → `'82,5'` ; 100 kg → `'100'` ; 20.41165665 kg en lb → `'45'`.
String formatWeight(double kg, WeightUnit unit) {
  return unit
      .fromKg(kg)
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '')
      .replaceAll('.', ',');
}
