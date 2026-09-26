import 'package:app_muscu/core/utils/weight_format.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatWeight (RG-14)', () {
    test('kg : virgule française, zéros inutiles retirés', () {
      expect(formatWeight(82.5, WeightUnit.kg), '82,5');
      expect(formatWeight(100, WeightUnit.kg), '100');
      expect(formatWeight(1.25, WeightUnit.kg), '1,25');
      expect(formatWeight(0, WeightUnit.kg), '0');
    });

    test('lb : un poids saisi en lb se réaffiche à l’identique', () {
      expect(formatWeight(WeightUnit.lb.toKg(45), WeightUnit.lb), '45');
      expect(formatWeight(WeightUnit.lb.toKg(102.5), WeightUnit.lb), '102,5');
    });

    test('conversion kg → lb arrondie à 2 décimales', () {
      expect(formatWeight(100, WeightUnit.lb), '220,46');
    });
  });
}
