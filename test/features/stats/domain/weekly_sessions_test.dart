import 'package:app_muscu/features/stats/domain/stats_period.dart';
import 'package:app_muscu/features/stats/domain/weekly_sessions.dart';
import 'package:flutter_test/flutter_test.dart';

SessionEntry _session(DateTime startedAt, {String? templateId}) => SessionEntry(
  id: '$startedAt',
  name: 'Push',
  templateId: templateId,
  startedAt: startedAt,
  endedAt: startedAt.add(const Duration(hours: 1)),
);

void main() {
  group('startOfWeek', () {
    test('le lundi à minuit, même un dimanche soir', () {
      expect(startOfWeek(DateTime(2026, 9, 27, 22, 30)), DateTime(2026, 9, 21));
      expect(startOfWeek(DateTime(2026, 9, 21, 0, 5)), DateTime(2026, 9, 21));
    });

    test('à cheval sur deux mois', () {
      expect(startOfWeek(DateTime(2026, 10, 2)), DateTime(2026, 9, 28));
    });

    test('la semaine du passage à l’heure d’hiver (25 octobre 2026)', () {
      expect(startOfWeek(DateTime(2026, 10, 28)), DateTime(2026, 10, 26));
      expect(startOfWeek(DateTime(2026, 10, 25, 20)), DateTime(2026, 10, 19));
    });
  });

  group('groupByWeek (SA-02)', () {
    final now = DateTime(2026, 9, 26, 18); // un samedi

    test('au moins 12 semaines, la semaine en cours en dernier', () {
      final weeks = groupByWeek([], now);
      expect(weeks, hasLength(12));
      expect(weeks.last.monday, DateTime(2026, 9, 21));
      expect(weeks.first.monday, DateTime(2026, 7, 6));
    });

    test('chaque séance dans sa semaine, dans l’ordre, semaines vides '
        'comprises', () {
      final weeks = groupByWeek([
        _session(DateTime(2026, 9, 25, 18)),
        _session(DateTime(2026, 9, 21, 7)),
        _session(DateTime(2026, 9, 9, 12)),
      ], now);

      expect(weeks.last.sessions.map((s) => s.startedAt), [
        DateTime(2026, 9, 21, 7),
        DateTime(2026, 9, 25, 18),
      ]);
      expect(weeks[weeks.length - 2].sessions, isEmpty); // semaine du 14
      expect(weeks[weeks.length - 3].sessions, hasLength(1)); // semaine du 7
    });

    test('remonte jusqu’à la première séance si elle est plus ancienne', () {
      final weeks = groupByWeek([_session(DateTime(2026, 1, 7))], now);
      expect(weeks.first.monday, DateTime(2026, 1, 5));
      expect(weeks.first.sessions, hasLength(1));
      // Toutes les semaines se suivent, de 7 jours en 7 jours.
      for (var i = 1; i < weeks.length; i++) {
        final previous = weeks[i - 1].monday;
        expect(
          weeks[i].monday,
          DateTime(previous.year, previous.month, previous.day + 7),
        );
      }
    });
  });

  test('paletteIndexes : une couleur par modèle, dans l’ordre, en boucle '
      '(RG-16)', () {
    final ids = [for (var i = 0; i < 10; i++) 't$i'];
    final indexes = paletteIndexes(ids);
    expect(indexes['t0'], 0);
    expect(indexes['t7'], 7);
    expect(indexes['t8'], 0);
    expect(indexes['t9'], 1);
  });

  group('StatsPeriod.start', () {
    final now = DateTime(2026, 9, 26, 18);

    test('7 j = aujourd’hui et les 6 jours d’avant, à minuit', () {
      expect(StatsPeriod.days7.start(now), DateTime(2026, 9, 20));
      expect(StatsPeriod.days30.start(now), DateTime(2026, 8, 28));
    });

    test('mois et années du calendrier', () {
      expect(StatsPeriod.months3.start(now), DateTime(2026, 6, 26));
      expect(StatsPeriod.year1.start(now), DateTime(2025, 9, 26));
      expect(StatsPeriod.all.start(now), isNull);
    });
  });
}
