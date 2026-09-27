import 'package:app_muscu/core/utils/date_format.dart';
import 'package:app_muscu/core/utils/duration_format.dart';
import 'package:app_muscu/core/utils/weight_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dates en français', () {
    final monday = DateTime(2026, 9, 21);

    test('jour et mois abrégé, avec ou sans année', () {
      expect(formatDayMonth(DateTime(2026, 9, 12)), '12 sept.');
      expect(formatDayMonthYear(DateTime(2026, 2, 3)), '3 févr. 2026');
      expect(formatShortMonth(DateTime(2026, 8, 30)), 'août');
    });

    test('« 1er » pour le premier du mois', () {
      expect(formatDayMonth(DateTime(2026, 10, 1)), '1er oct.');
      expect(formatWeekOf(DateTime(2026, 6, 1)), 'Semaine du 1er juin');
    });

    test('jour de la semaine abrégé', () {
      expect(formatWeekday(monday), 'lun. 21');
      expect(formatWeekday(DateTime(2026, 9, 27)), 'dim. 27');
    });

    test('titre de la semaine', () {
      expect(formatWeekOf(monday), 'Semaine du 21 septembre');
    });
  });

  test('durée à la minute', () {
    expect(formatMinutes(const Duration(minutes: 52, seconds: 40)), '52 min');
    expect(formatMinutes(const Duration(minutes: 65)), '1 h 05');
    expect(formatMinutes(const Duration(hours: 2)), '2 h 00');
  });

  test('nombre à la française', () {
    expect(formatNumber(1.8), '1,8');
    expect(formatNumber(2), '2');
    expect(formatNumber(1.849), '1,85');
  });
}
