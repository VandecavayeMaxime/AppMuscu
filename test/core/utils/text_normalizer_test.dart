import 'package:app_muscu/core/utils/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeForSearch', () {
    test('met en minuscules et retire les accents', () {
      expect(normalizeForSearch('Développé Couché'), 'developpe couche');
      expect(normalizeForSearch('ÉPAULES à la poulie'), 'epaules a la poulie');
      expect(normalizeForSearch('Café à emporter'), 'cafe a emporter');
    });

    test('remplace les ligatures', () {
      expect(normalizeForSearch('Cœur Æ'), 'coeur ae');
    });

    test('ignore les accents « détachés »', () {
      expect(normalizeForSearch('Developpé'), 'developpe');
    });

    test('retire les espaces superflus', () {
      expect(normalizeForSearch('  Squat    (barre) '), 'squat (barre)');
    });

    test('laisse intacts les chiffres et la ponctuation', () {
      expect(normalizeForSearch('Curl 21s (EZ-bar)'), 'curl 21s (ez-bar)');
    });
  });
}
