import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/stats/data/stats_repository.dart';
import 'package:app_muscu/features/templates/data/template_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late StatsRepository stats;

  setUp(() {
    db = createTestDatabase();
    stats = StatsRepository(db);
  });
  tearDown(() => db.close());

  test('séances terminées et non supprimées, de la plus ancienne à la plus '
      'récente', () async {
    await addWorkout(db, day: DateTime(2026, 9, 20), sets: [TestSet(80, 8)]);
    await addWorkout(db, day: DateTime(2026, 9, 10), sets: [TestSet(80, 8)]);
    await addWorkout(
      db,
      day: DateTime(2026, 9, 15),
      sets: [TestSet(80, 8)],
      deleted: true,
    );
    await addWorkout(
      db,
      day: DateTime(2026, 9, 21),
      sets: [TestSet(80, 8)],
      finished: false,
    );

    final sessions = await stats.watchFinishedSessions().first;
    expect(sessions.map((s) => s.startedAt.day), [10, 20]);
    expect(sessions.first.duration, const Duration(hours: 1));
  });

  test('modèles dans l’ordre des couleurs : actifs dans l’ordre de l’onglet '
      'Séance, puis supprimés (RG-16)', () async {
    final templates = TemplateRepository(db);
    final push = await addTemplate(db, name: 'Push');
    final legs = await addTemplate(db, name: 'Jambes', exerciseId: squatId);
    final pull = await addTemplate(db, name: 'Pull', exerciseId: pullUpId);
    await templates.reorderTemplates([pull, push, legs]);
    await templates.deleteTemplate(push);

    final ordered = await stats.watchTemplatesByColor().first;
    expect(ordered.map((t) => t.name), ['Pull', 'Jambes', 'Push']);
  });
}
