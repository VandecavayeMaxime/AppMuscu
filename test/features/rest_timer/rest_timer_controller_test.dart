import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/rest_timer/data/rest_timer_repository.dart';
import 'package:app_muscu/features/rest_timer/presentation/rest_timer_providers.dart';
import 'package:app_muscu/features/settings/data/settings_repository.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_rest_notifications.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late RestTimerRepository repository;
  late FakeRestNotifications notifications;
  late RestTimerController controller;
  final now = DateTime(2026, 9, 26, 18);

  setUp(() {
    db = createTestDatabase();
    repository = RestTimerRepository(db);
    notifications = FakeRestNotifications();
    controller = RestTimerController(
      repository,
      notifications,
      SettingsRepository(db),
    );
  });
  tearDown(() => db.close());

  Future<void> start(String setId, int seconds) => withClock(
    Clock.fixed(now),
    () => controller.start(
      setId: setId,
      seconds: seconds,
      nextExercise: 'Squat (Barbell)',
    ),
  );

  test('démarrer enregistre l’heure de fin et programme la notification '
      '(RT-02, RT-05)', () async {
    await start('s1', 90);

    final timer = await repository.read();
    expect(timer!.setId, 's1');
    expect(timer.endsAt, now.add(const Duration(seconds: 90)));
    expect(timer.totalSeconds, 90);
    expect(notifications.scheduled.single.at, timer.endsAt);
    expect(notifications.scheduled.single.nextExercise, 'Squat (Barbell)');
  });

  test('un nouveau repos remplace le précédent', () async {
    await start('s1', 90);
    await start('s2', 60);

    expect((await repository.read())!.setId, 's2');
    expect(notifications.scheduled, hasLength(2));
  });

  test('0 seconde : pas de minuteur (RT-01)', () async {
    await start('s1', 90);
    await start('s2', 0);

    expect(await repository.read(), isNull);
    expect(notifications.cancellations, 1);
  });

  test('stopIfFor n’arrête que le minuteur des séries concernées', () async {
    await start('s1', 90);

    await controller.stopIfFor(['autre']);
    expect(await repository.read(), isNotNull);

    await controller.stopIfFor(['s1', 's2']);
    expect(await repository.read(), isNull);
    expect(notifications.cancellations, 1);
  });

  test('le minuteur enregistré est aussi renvoyé en direct', () async {
    await start('s1', 90);

    expect((await repository.watch().first)!.setId, 's1');
  });

  test('réglage global du repos : 2:00 par défaut, modifiable', () async {
    final settings = SettingsRepository(db);

    expect(await settings.watchDefaultRestSeconds().first, 120);
    await settings.setDefaultRestSeconds(90);
    expect(await settings.watchDefaultRestSeconds().first, 90);
  });
}
