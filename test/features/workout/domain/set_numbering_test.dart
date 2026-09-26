import 'package:app_muscu/features/workout/domain/set_numbering.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'numérote les séries normales et affiche la lettre des autres (RG-02)',
    () {
      expect(
        setLabels([
          SetType.warmup,
          SetType.normal,
          SetType.normal,
          SetType.dropset,
          SetType.normal,
          SetType.failure,
        ]),
        ['W', '1', '2', 'D', '3', 'F'],
      );
    },
  );

  test('liste vide → aucun libellé', () {
    expect(setLabels([]), isEmpty);
  });
}
