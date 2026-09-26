import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/workout/data/workout_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

/// Une série dans les données de test : poids, reps, validée ou non.
typedef TestSet = ({double kg, int reps, bool done});

void main() {
  late AppDatabase db;
  late WorkoutRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = WorkoutRepository(db);
  });
  tearDown(() => db.close());

  /// Ajoute une séance d'un seul exercice.
  Future<void> addWorkout({
    required DateTime day,
    required List<TestSet> sets,
    String exerciseId = benchPressId,
    bool finished = true,
    bool deleted = false,
  }) async {
    final workout = await db
        .into(db.workouts)
        .insertReturning(
          WorkoutsCompanion.insert(
            name: 'Séance',
            startedAt: Value(day),
            endedAt: Value(finished ? day.add(const Duration(hours: 1)) : null),
            deletedAt: Value(deleted ? day : null),
          ),
        );
    final exercise = await db
        .into(db.workoutExercises)
        .insertReturning(
          WorkoutExercisesCompanion.insert(
            workoutId: workout.id,
            exerciseId: exerciseId,
            position: 0,
          ),
        );
    for (final (index, set) in sets.indexed) {
      await db
          .into(db.workoutSets)
          .insert(
            WorkoutSetsCompanion.insert(
              workoutExerciseId: exercise.id,
              position: index,
              weightKg: Value(set.kg),
              reps: Value(set.reps),
              completedAt: Value(set.done ? day : null),
            ),
          );
    }
  }

  /// « Précédent » sous forme lisible : ['80.0×8', …].
  Future<List<String>> previous(String exerciseId) async {
    final sets = await repository.previousSets(exerciseId);
    return sets.map((s) => '${s.weightKg}×${s.reps}').toList();
  }

  final monday = DateTime(2026, 9, 21, 18);
  final wednesday = DateTime(2026, 9, 23, 18);

  group('previousSets (RG-03, RG-04)', () {
    test("renvoie une liste vide pour un exercice jamais fait", () async {
      expect(await previous(benchPressId), isEmpty);
    });

    test('renvoie les séries validées de la séance la plus récente, '
        'dans l’ordre', () async {
      await addWorkout(day: monday, sets: [(kg: 70, reps: 10, done: true)]);
      await addWorkout(
        day: wednesday,
        sets: [(kg: 80, reps: 8, done: true), (kg: 80, reps: 7, done: true)],
      );

      expect(await previous(benchPressId), ['80.0×8', '80.0×7']);
    });

    test('ignore la séance en cours', () async {
      await addWorkout(day: monday, sets: [(kg: 70, reps: 10, done: true)]);
      await addWorkout(
        day: wednesday,
        sets: [(kg: 90, reps: 5, done: true)],
        finished: false,
      );

      expect(await previous(benchPressId), ['70.0×10']);
    });

    test('ignore les séances supprimées', () async {
      await addWorkout(day: monday, sets: [(kg: 70, reps: 10, done: true)]);
      await addWorkout(
        day: wednesday,
        sets: [(kg: 90, reps: 5, done: true)],
        deleted: true,
      );

      expect(await previous(benchPressId), ['70.0×10']);
    });

    test(
      'ignore les séries non validées, et les séances sans série validée',
      () async {
        await addWorkout(
          day: monday,
          sets: [
            (kg: 70, reps: 10, done: true),
            (kg: 70, reps: 9, done: false),
          ],
        );
        await addWorkout(
          day: wednesday,
          sets: [(kg: 90, reps: 5, done: false)],
        );

        expect(await previous(benchPressId), ['70.0×10']);
      },
    );

    test('ne mélange pas les exercices', () async {
      await addWorkout(day: monday, sets: [(kg: 70, reps: 10, done: true)]);
      await addWorkout(
        day: wednesday,
        exerciseId: squatId,
        sets: [(kg: 100, reps: 5, done: true)],
      );

      expect(await previous(benchPressId), ['70.0×10']);
      expect(await previous(squatId), ['100.0×5']);
    });
  });
}
