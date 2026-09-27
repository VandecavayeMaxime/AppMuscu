// Données de test pour les règles des modèles, sans base de données.
import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/templates/domain/template_details.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:app_muscu/features/workout/domain/workout_details.dart';

final day = DateTime(2026, 9, 26, 18);

Exercise exercise(String name, [TrackingType type = TrackingType.weightReps]) =>
    Exercise(
      id: name,
      createdAt: day,
      updatedAt: day,
      name: name,
      nameNormalized: name.toLowerCase(),
      equipment: Equipment.barbell,
      bodyPart: BodyPart.chest,
      secondaryMuscles: const [],
      trackingType: type,
      weightUnit: WeightUnit.kg,
      isCustom: false,
    );

/// Série réalisée : `done(80, 8)` = 80 kg × 8, validée.
WorkoutSet done(
  double? kg,
  int? reps, {
  int? seconds,
  int? rest,
  bool completed = true,
}) => WorkoutSet(
  id: 'set',
  workoutExerciseId: 'we',
  position: 0,
  setType: SetType.normal,
  weightKg: kg,
  reps: reps,
  durationSeconds: seconds,
  restSeconds: rest,
  completedAt: completed ? day : null,
);

/// Série prévue : `planned(80, 8)`.
TemplateSet planned(double? kg, int? reps, {int? seconds, int? rest}) =>
    TemplateSet(
      id: 'tset',
      templateExerciseId: 'te',
      position: 0,
      setType: SetType.normal,
      weightKg: kg,
      reps: reps,
      durationSeconds: seconds,
      restSeconds: rest,
    );

/// Séance terminée : exercice → séries.
WorkoutDetails workout(Map<Exercise, List<WorkoutSet>> content) {
  final details = WorkoutDetails(
    Workout(
      id: 'w',
      createdAt: day,
      updatedAt: day,
      name: 'Push',
      startedAt: day,
      endedAt: day.add(const Duration(hours: 1)),
    ),
  );
  for (final MapEntry(key: exercise, value: sets) in content.entries) {
    details.exercises.add(
      WorkoutExerciseDetails(
        entry: WorkoutExercise(
          id: 'we-${exercise.id}',
          workoutId: 'w',
          exerciseId: exercise.id,
          position: details.exercises.length,
        ),
        exercise: exercise,
      )..sets.addAll(sets),
    );
  }
  return details;
}

/// Modèle : exercice → séries prévues.
TemplateDetails template(Map<Exercise, List<TemplateSet>> content) {
  final details = TemplateDetails(
    Template(
      id: 't',
      createdAt: day,
      updatedAt: day,
      name: 'Push',
      position: 0,
    ),
  );
  for (final MapEntry(key: exercise, value: sets) in content.entries) {
    details.exercises.add(
      TemplateExerciseDetails(
        entry: TemplateExercise(
          id: 'te-${exercise.id}',
          templateId: 't',
          exerciseId: exercise.id,
          position: details.exercises.length,
        ),
        exercise: exercise,
      )..sets.addAll(sets),
    );
  }
  return details;
}
