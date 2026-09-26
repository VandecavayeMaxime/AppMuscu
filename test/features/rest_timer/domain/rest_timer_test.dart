import 'package:app_muscu/features/rest_timer/domain/rest_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('temps de repos effectif : série, sinon exercice, sinon global '
      '(RG-09)', () {
    expect(
      effectiveRestSeconds(setRest: 90, exerciseRest: 60, globalRest: 120),
      90,
    );
    expect(
      effectiveRestSeconds(setRest: null, exerciseRest: 60, globalRest: 120),
      60,
    );
    expect(
      effectiveRestSeconds(setRest: null, exerciseRest: null, globalRest: 120),
      120,
    );
    expect(
      effectiveRestSeconds(setRest: 0, exerciseRest: 60, globalRest: 120),
      0,
    );
  });

  group('RestTimer (RT-06)', () {
    final start = DateTime(2026, 9, 26, 18);
    final timer = RestTimer(
      setId: 's1',
      endsAt: start.add(const Duration(seconds: 120)),
      totalSeconds: 120,
    );

    test('pendant le repos : temps restant et progression', () {
      final now = start.add(const Duration(seconds: 30));

      expect(timer.isRunning(now), isTrue);
      expect(timer.remaining(now), const Duration(seconds: 90));
      expect(timer.progress(now), closeTo(0.25, 0.001));
    });

    test('secondes affichées arrondies au-dessus (compte à rebours)', () {
      expect(timer.remainingSeconds(start), 120);
      expect(
        timer.remainingSeconds(start.add(const Duration(milliseconds: 200))),
        120,
      );
      expect(
        timer.remainingSeconds(start.add(const Duration(milliseconds: 119500))),
        1,
      );
      expect(
        timer.remainingSeconds(start.add(const Duration(seconds: 125))),
        0,
      );
    });

    test('après la fin : plus rien à attendre', () {
      final now = start.add(const Duration(seconds: 130));

      expect(timer.isRunning(now), isFalse);
      expect(timer.remaining(now), Duration.zero);
      expect(timer.progress(now), 1);
    });
  });
}
