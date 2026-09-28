import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/templates/data/template_repository.dart';
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

/// Ajoute une séance d'un seul exercice (d'une heure, si elle est terminée).
Future<void> addWorkout(
  AppDatabase db, {
  required DateTime day,
  required List<TestSet> sets,
  String name = 'Séance',
  String exerciseId = benchPressId,
  String? templateId,
  bool finished = true,
  bool deleted = false,
}) async {
  final workout = await db
      .into(db.workouts)
      .insertReturning(
        WorkoutsCompanion.insert(
          name: name,
          templateId: Value(templateId),
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

/// Ajoute une mesure datée de [day] (une seule par jour, RG-22) ; les champs
/// non précisés restent vides.
Future<void> addMeasurement(
  AppDatabase db, {
  required DateTime day,
  double? weightKg,
  double? bodyFatPercent,
  double? muscleMassKg,
}) => db
    .into(db.bodyMeasurements)
    .insert(
      BodyMeasurementsCompanion.insert(
        measuredAt: day,
        weightKg: Value(weightKg),
        bodyFatPercent: Value(bodyFatPercent),
        muscleMassKg: Value(muscleMassKg),
      ),
    );

/// Ajoute un modèle sans exercice : le démarrer donne une séance vide, à
/// compléter avec « Ajouter des exercices ». (L'éditeur exige au moins un
/// exercice, la base non : c'est un raccourci pour les tests.)
Future<String> addEmptyTemplate(
  AppDatabase db, {
  String name = 'Séance libre',
}) async {
  final template = await db
      .into(db.templates)
      .insertReturning(TemplatesCompanion.insert(name: name));
  return template.id;
}

/// Ajoute un modèle d'un seul exercice, dont les séries prévues sont données
/// sous la forme (kg, reps) : `addTemplate(db, sets: [(80, 8), (80, null)])`.
Future<String> addTemplate(
  AppDatabase db, {
  String name = 'Push',
  String exerciseId = benchPressId,
  List<(double?, int?)> sets = const [(80, 8)],
}) async {
  final exercise = await (db.select(
    db.exercises,
  )..where((e) => e.id.equals(exerciseId))).getSingle();
  return TemplateRepository(db).saveTemplate(
    TemplateDraft(
      name: name,
      exercises: [
        DraftExercise(exercise, [
          for (final (kg, reps) in sets) DraftSet(weightKg: kg, reps: reps),
        ]),
      ],
    ),
  );
}
