import 'package:app_muscu/core/utils/relative_date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 26, 0, 15);

  String ago(DateTime date) => formatRelativeDay(date, now);

  test('jours du calendrier, pas des durées', () {
    expect(ago(DateTime(2026, 9, 26, 0, 5)), "Aujourd'hui");
    expect(ago(DateTime(2026, 9, 25, 23, 50)), 'Hier'); // il y a 25 min
    expect(ago(DateTime(2026, 9, 23, 18)), 'Il y a 3 jours');
  });

  test('semaines, mois, années', () {
    expect(ago(DateTime(2026, 9, 19)), 'Il y a 1 semaine');
    expect(ago(DateTime(2026, 9, 5)), 'Il y a 3 semaines');
    expect(ago(DateTime(2026, 7, 20)), 'Il y a 2 mois');
    expect(ago(DateTime(2025, 9, 1)), 'Il y a 1 an');
    expect(ago(DateTime(2023, 9, 1)), 'Il y a 3 ans');
  });

  test('changement d’heure : un jour de 23 h compte pour un jour', () {
    // En France, on passe à l'heure d'hiver le 25 octobre 2026.
    expect(
      formatRelativeDay(DateTime(2026, 10, 24, 20), DateTime(2026, 10, 26, 8)),
      'Il y a 2 jours',
    );
  });
}
