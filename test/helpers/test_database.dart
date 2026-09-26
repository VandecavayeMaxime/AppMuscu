import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Base SQLite neuve, en mémoire : chaque test part de zéro, avec les
/// 10 exercices de base.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Identifiants fixes de trois exercices de base (voir built_in_exercises.dart).
const benchPressId = '509d3ccf-bf4e-411b-a5db-2d2e491f586c';
const squatId = 'c152f391-b038-44f6-b8df-cfef1d1a789d';
const pullUpId = 'd160b037-2046-44ac-ba37-97784a8cade2';

/// Une série dans les données de test : `TestSet(80, 8)` = 80 kg × 8, validée.
class TestSet {
  const TestSet(
    this.kg,
    this.reps, {
    this.done = true,
    this.type = SetType.normal,
  });

  final double kg;
  final int reps;
  final bool done;
  final SetType type;
}

/// Ajoute une séance d'un seul exercice.
Future<void> addWorkout(
  AppDatabase db, {
  required DateTime day,
  required List<TestSet> sets,
  String name = 'Séance',
  String exerciseId = benchPressId,
  bool finished = true,
  bool deleted = false,
}) async {
  final workout = await db
      .into(db.workouts)
      .insertReturning(
        WorkoutsCompanion.insert(
          name: name,
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
            setType: Value(set.type),
            weightKg: Value(set.kg),
            reps: Value(set.reps),
            completedAt: Value(set.done ? day : null),
          ),
        );
  }
}
