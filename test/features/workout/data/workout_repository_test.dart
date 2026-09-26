import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/workout/data/workout_repository.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = WorkoutRepository(db);
  });
  tearDown(() => db.close());

  String describe(WorkoutSet set) => '${set.weightKg}×${set.reps}';

  final monday = DateTime(2026, 9, 21, 18);
  final wednesday = DateTime(2026, 9, 23, 18);

  group('previousSets (RG-03, RG-04)', () {
    /// « Précédent » sous forme lisible : ['80.0×8', …].
    Future<List<String>> previous(String exerciseId) async =>
        (await repository.previousSets(exerciseId)).map(describe).toList();

    test('renvoie une liste vide pour un exercice jamais fait', () async {
      expect(await previous(benchPressId), isEmpty);
    });

    test('renvoie les séries validées de la séance la plus récente, '
        'dans l’ordre', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(80, 8), const TestSet(80, 7)],
      );

      expect(await previous(benchPressId), ['80.0×8', '80.0×7']);
    });

    test('ignore la séance en cours', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(90, 5)],
        finished: false,
      );

      expect(await previous(benchPressId), ['70.0×10']);
    });

    test('ignore les séances supprimées', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(90, 5)],
        deleted: true,
      );

      expect(await previous(benchPressId), ['70.0×10']);
    });

    test(
      'ignore les séries non validées, et les séances sans série validée',
      () async {
        await addWorkout(
          db,
          day: monday,
          sets: [const TestSet(70, 10), const TestSet(70, 9, done: false)],
        );
        await addWorkout(
          db,
          day: wednesday,
          sets: [const TestSet(90, 5, done: false)],
        );

        expect(await previous(benchPressId), ['70.0×10']);
      },
    );

    test('ne mélange pas les exercices', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        exerciseId: squatId,
        sets: [const TestSet(100, 5)],
      );

      expect(await previous(benchPressId), ['70.0×10']);
      expect(await previous(squatId), ['100.0×5']);
    });
  });

  group('watchExerciseHistory (EX-07)', () {
    Future<List<ExerciseSession>> history(String exerciseId) =>
        repository.watchExerciseHistory(exerciseId).first;

    test('renvoie une liste vide pour un exercice jamais fait', () async {
      expect(await history(benchPressId), isEmpty);
    });

    test('une séance par bloc, de la plus récente à la plus ancienne, '
        'avec ses séries validées dans l’ordre', () async {
      await addWorkout(
        db,
        name: 'Séance du soir',
        day: monday,
        sets: [const TestSet(75, 8)],
      );
      await addWorkout(
        db,
        name: 'Push',
        day: wednesday,
        sets: [
          const TestSet(40, 10, type: SetType.warmup),
          const TestSet(80, 8),
          const TestSet(80, 7, done: false),
        ],
      );

      final sessions = await history(benchPressId);

      expect(sessions.map((s) => s.workoutName), ['Push', 'Séance du soir']);
      expect(sessions.first.date, wednesday);
      expect(sessions.first.sets.map(describe), ['40.0×10', '80.0×8']);
      expect(sessions.first.sets.first.setType, SetType.warmup);
    });

    test('ignore les séances en cours, supprimées ou sans série validée, '
        'et les autres exercices', () async {
      await addWorkout(db, day: monday, sets: [const TestSet(70, 10)]);
      await addWorkout(
        db,
        day: wednesday,
        sets: [const TestSet(90, 5)],
        finished: false,
      );
      await addWorkout(
        db,
        day: DateTime(2026, 9, 22),
        sets: [const TestSet(85, 5)],
        deleted: true,
      );
      await addWorkout(
        db,
        day: DateTime(2026, 9, 20),
        sets: [const TestSet(60, 5, done: false)],
      );
      await addWorkout(
        db,
        day: DateTime(2026, 9, 19),
        exerciseId: squatId,
        sets: [const TestSet(100, 5)],
      );

      final sessions = await history(benchPressId);

      expect(sessions, hasLength(1));
      expect(sessions.single.sets.map(describe), ['70.0×10']);
    });
  });
}
