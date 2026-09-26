import 'package:app_muscu/features/workout/domain/workout_naming.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String nameAt(int hour, [int minute = 0]) =>
      defaultWorkoutName(DateTime(2026, 9, 26, hour, minute));

  test('nom par défaut selon l’heure de début (RG-05)', () {
    expect(nameAt(5), 'Séance du matin');
    expect(nameAt(11, 59), 'Séance du matin');
    expect(nameAt(12), "Séance de l'après-midi");
    expect(nameAt(17, 59), "Séance de l'après-midi");
    expect(nameAt(18), 'Séance du soir');
    expect(nameAt(23), 'Séance du soir');
    expect(nameAt(4, 59), 'Séance du soir');
  });
}
