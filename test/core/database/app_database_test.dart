import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  group('bibliothèque initiale (EX-01)', () {
    test('contient les 83 exercices de base', () async {
      final exercises = await db.select(db.exercises).get();

      expect(exercises, hasLength(83));
      expect(
        exercises.every((e) => !e.isCustom && e.deletedAt == null),
        isTrue,
      );
      expect(
        exercises.map((e) => e.name),
        containsAll([
          'Bench Press (Barbell)',
          'Squat (Barbell)',
          'Pull-Up',
          'Plank',
        ]),
      );
    });

    test('couvre les trois types de suivi', () async {
      final exercises = await db.select(db.exercises).get();

      expect(
        exercises.map((e) => e.trackingType).toSet(),
        TrackingType.values.toSet(),
      );
    });
  });

  group('séance en cours (WO-02)', () {
    test('refuse une deuxième séance en cours', () async {
      await db.into(db.workouts).insert(WorkoutsCompanion.insert(name: 'A'));

      await expectLater(
        db.into(db.workouts).insert(WorkoutsCompanion.insert(name: 'B')),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'accepte une nouvelle séance quand la précédente est terminée',
      () async {
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                name: 'A',
                endedAt: Value(DateTime(2026)),
              ),
            );
        await db.into(db.workouts).insert(WorkoutsCompanion.insert(name: 'B'));

        expect(await db.select(db.workouts).get(), hasLength(2));
      },
    );

    test(
      'accepte une nouvelle séance quand la précédente est supprimée',
      () async {
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                name: 'A',
                deletedAt: Value(DateTime(2026)),
              ),
            );
        await db.into(db.workouts).insert(WorkoutsCompanion.insert(name: 'B'));

        expect(await db.select(db.workouts).get(), hasLength(2));
      },
    );
  });

  group('intégrité', () {
    test('refuse une référence vers un élément inexistant', () async {
      await expectLater(
        db
            .into(db.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                workoutId: 'inexistant',
                exerciseId: benchPressId,
                position: 0,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test("supprimer une séance supprime ses exercices et ses séries", () async {
      final workout = await db
          .into(db.workouts)
          .insertReturning(WorkoutsCompanion.insert(name: 'A'));
      final exercise = await db
          .into(db.workoutExercises)
          .insertReturning(
            WorkoutExercisesCompanion.insert(
              workoutId: workout.id,
              exerciseId: benchPressId,
              position: 0,
            ),
          );
      await db
          .into(db.workoutSets)
          .insert(
            WorkoutSetsCompanion.insert(
              workoutExerciseId: exercise.id,
              position: 0,
            ),
          );

      await db.delete(db.workouts).delete(workout);

      expect(await db.select(db.workoutExercises).get(), isEmpty);
      expect(await db.select(db.workoutSets).get(), isEmpty);
    });
  });
}
