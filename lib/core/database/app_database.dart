import 'package:clock/clock.dart'; // utilisé par le code généré (dates par défaut)
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/exercises/domain/exercise_enums.dart';
import '../../features/workout/domain/set_type.dart';
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

  /// À incrémenter à chaque changement de structure, avec une migration
  /// dans [migration] (NF-08).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Premier lancement : création des tables puis de la bibliothèque (EX-01).
    onCreate: (m) async {
      await m.createAll();
      await batch((b) => b.insertAll(exercises, builtInExercises));
    },
    // À chaque ouverture : SQLite n'applique les clés étrangères que si on le demande.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
