import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/workout/domain/set_rules.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:app_muscu/features/workout/domain/workout_details.dart';
import 'package:app_muscu/features/workout/domain/workout_summary.dart';
import 'package:flutter_test/flutter_test.dart';

final _start = DateTime(2026, 9, 26, 18);

WorkoutSet _set({
  double? kg,
  int? reps,
  int? seconds,
  bool done = true,
  SetType type = SetType.normal,
}) {
  return WorkoutSet(
    id: 'id',
    workoutExerciseId: 'we',
    position: 0,
    setType: type,
    weightKg: kg,
    reps: reps,
    durationSeconds: seconds,
    completedAt: done ? _start : null,
  );
}

Exercise _exercise(TrackingType type) => Exercise(
  id: type.name,
  createdAt: _start,
  updatedAt: _start,
  name: type.label,
  nameNormalized: type.name,
  equipment: Equipment.barbell,
  bodyPart: BodyPart.chest,
  trackingType: type,
  weightUnit: WeightUnit.kg,
  isCustom: false,
);

void main() {
  group('isSetEmpty / isSetReady (WO-17)', () {
    test('série vide : aucune valeur', () {
      expect(isSetEmpty(_set()), isTrue);
      expect(isSetEmpty(_set(kg: 80)), isFalse);
    });

    test('série prête : toutes les valeurs du type de suivi', () {
      expect(
        isSetReady(_set(kg: 80, reps: 8), TrackingType.weightReps),
        isTrue,
      );
      expect(isSetReady(_set(kg: 80), TrackingType.weightReps), isFalse);
      expect(isSetReady(_set(reps: 12), TrackingType.reps), isTrue);
      expect(isSetReady(_set(seconds: 60), TrackingType.duration), isTrue);
      expect(isSetReady(_set(reps: 12), TrackingType.duration), isFalse);
    });
  });

  group('setVolumeKg (RG-01)', () {
    test('kg × reps pour une série validée', () {
      expect(setVolumeKg(_set(kg: 80, reps: 8), TrackingType.weightReps), 640);
    });

    test('0 pour un échauffement, une série non validée ou sans poids', () {
      expect(
        setVolumeKg(
          _set(kg: 40, reps: 10, type: SetType.warmup),
          TrackingType.weightReps,
        ),
        0,
      );
      expect(
        setVolumeKg(
          _set(kg: 80, reps: 8, done: false),
          TrackingType.weightReps,
        ),
        0,
      );
      expect(setVolumeKg(_set(reps: 12), TrackingType.reps), 0);
    });
  });

  test('WorkoutSummary : durée, exercices, séries et volume validés', () {
    final details =
        WorkoutDetails(
            Workout(
              id: 'w',
              createdAt: _start,
              updatedAt: _start,
              name: 'Push',
              startedAt: _start,
              endedAt: _start.add(const Duration(minutes: 52, seconds: 10)),
            ),
          )
          ..exercises.addAll([
            WorkoutExerciseDetails(
                entry: const WorkoutExercise(
                  id: 'a',
                  workoutId: 'w',
                  exerciseId: 'bench',
                  position: 0,
                ),
                exercise: _exercise(TrackingType.weightReps),
              )
              ..sets.addAll([
                _set(kg: 40, reps: 10, type: SetType.warmup),
                _set(kg: 80, reps: 8),
                _set(kg: 80, reps: 7),
              ]),
            WorkoutExerciseDetails(
              entry: const WorkoutExercise(
                id: 'b',
                workoutId: 'w',
                exerciseId: 'pullup',
                position: 1,
              ),
              exercise: _exercise(TrackingType.reps),
            )..sets.add(_set(reps: 12)),
          ]);

    final summary = WorkoutSummary.of(details);

    expect(summary.duration, const Duration(minutes: 52, seconds: 10));
    expect(summary.exerciseCount, 2);
    expect(summary.setCount, 4);
    expect(summary.volumeKg, 80 * 8 + 80 * 7);
  });
}
