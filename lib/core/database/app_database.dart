import 'package:clock/clock.dart'; // utilisé par le code généré (dates par défaut)
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/exercises/domain/exercise_enums.dart';
import '../../features/workout/domain/set_type.dart';
import 'app_database.steps.dart';
import 'seed/built_in_exercises.dart';
import 'tables.dart';

// Code généré par Drift à partir des tables (ne pas modifier à la main).
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exercises,
    Templates,
    TemplateExercises,
    TemplateSets,
    Workouts,
    WorkoutExercises,
    WorkoutSets,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Ouvre la base `appmuscu.sqlite` dans le dossier de l'app.
  /// Les tests passent un [executor] en mémoire à la place.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'appmuscu'));

  /// Version de la structure (NF-08). Pour la changer :
  /// 1. modifier tables.dart et incrémenter ce numéro ;
  /// 2. `dart run build_runner build` puis `dart run drift_dev make-migrations` ;
  /// 3. écrire l'étape `fromXToY` ci-dessous et compléter test/drift/.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Premier lancement : création des tables puis de la bibliothèque (EX-01).
    onCreate: (m) async {
      await m.createAll();
      await batch((b) => b.insertAll(exercises, builtInExercises));
    },
    // Base existante plus ancienne : on applique les étapes une par une.
    onUpgrade: stepByStep(
      // v2 : fiche exercice — « notes » devient « instructions », unité par
      // exercice, consignes pour les exercices intégrés.
      from1To2: (m, schema) async {
        await m.renameColumn(
          schema.exercises,
          'notes',
          schema.exercises.instructions,
        );
        await m.addColumn(schema.exercises, schema.exercises.weightUnit);
        for (final MapEntry(key: id, value: text)
            in builtInInstructions.entries) {
          await customUpdate(
            'UPDATE exercises SET instructions = ? WHERE id = ?',
            variables: [Variable(text), Variable(id)],
          );
        }
      },
      // v3 : modèles — valeurs prévues copiées dans les séries de la séance.
      from2To3: (m, schema) async {
        final sets = schema.workoutSets;
        await m.addColumn(sets, sets.plannedWeightKg);
        await m.addColumn(sets, sets.plannedReps);
        await m.addColumn(sets, sets.plannedDurationSeconds);
      },
    ),
    // À chaque ouverture : SQLite n'applique les clés étrangères que si on le demande.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
