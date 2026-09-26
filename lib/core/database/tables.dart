// Structure de la base de données (docs/ARCHITECTURE.md §3).
//
// Chaque classe décrit une table SQLite. Drift génère à partir d'elles le code
// d'accès (fichier app_database.g.dart) : `dart run build_runner build`.
// Les noms Dart en camelCase deviennent des colonnes en snake_case
// (`startedAt` → `started_at`).
//
// ⚠️ Drift recopie les valeurs par défaut (`clientDefault(...)`) dans le code
// généré, qui fait partie de app_database.dart : tout ce qu'elles utilisent
// doit être public et importé là-bas aussi.

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/exercises/domain/exercise_enums.dart';
import '../../features/workout/domain/set_type.dart';

const _uuid = Uuid();

/// Nouvel identifiant unique (UUID v4), généré sur l'appareil.
String newId() => _uuid.v4();

/// Clé primaire : un UUID généré sur l'appareil (NF-07, prêt pour la sync).
mixin UuidPrimaryKey on Table {
  TextColumn get id => text().clientDefault(newId)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Horodatages et suppression douce (RG-10), pour les racines d'agrégat :
/// exercices, modèles, séances.
mixin Timestamps on Table {
  DateTimeColumn get createdAt => dateTime().clientDefault(clock.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(clock.now)();

  /// Renseignée = supprimé (ou archivé) aux yeux de l'utilisateur.
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ─── Bibliothèque ────────────────────────────────────────────────────────────

/// Deux exercices actifs ne peuvent pas porter le même nom (EX-06).
@TableIndex.sql(
  'CREATE UNIQUE INDEX exercises_active_name ON exercises (name_normalized) '
  'WHERE deleted_at IS NULL',
)
class Exercises extends Table with UuidPrimaryKey, Timestamps {
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Nom en minuscules sans accents, pour la recherche (EX-02).
  TextColumn get nameNormalized => text()();
  TextColumn get equipment => textEnum<Equipment>()();
  TextColumn get bodyPart => textEnum<BodyPart>()();
  TextColumn get trackingType => textEnum<TrackingType>()();

  /// Préférence : temps de repos ; `null` → réglage global (RG-09).
  IntColumn get defaultRestSeconds => integer().nullable()();

  /// Préférence : unité des poids (RG-14).
  TextColumn get weightUnit =>
      textEnum<WeightUnit>().withDefault(const Constant('kg'))();

  /// Consignes d'exécution, affichées dans la fiche (EX-09).
  TextColumn get instructions => text().nullable()();

  /// `false` pour les exercices livrés avec l'app.
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

// ─── Modèles ─────────────────────────────────────────────────────────────────

class Templates extends Table with UuidPrimaryKey, Timestamps {
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();

  /// Ordre d'affichage dans l'onglet Séance.
  IntColumn get position => integer().withDefault(const Constant(0))();
}

class TemplateExercises extends Table with UuidPrimaryKey {
  TextColumn get templateId =>
      text().references(Templates, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get position => integer()();
  TextColumn get notes => text().nullable()();
}

class TemplateSets extends Table with UuidPrimaryKey {
  TextColumn get templateExerciseId =>
      text().references(TemplateExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get setType =>
      textEnum<SetType>().withDefault(const Constant('normal'))();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();

  /// Temps de repos propre à la série ; `null` → RG-09.
  IntColumn get restSeconds => integer().nullable()();
}

// ─── Séances ─────────────────────────────────────────────────────────────────

@TableIndex(name: 'workouts_started_at', columns: {#startedAt})
/// Une seule séance en cours à la fois (WO-02) : toutes les séances en cours
/// ont la même valeur indexée (1), l'unicité empêche d'en avoir deux.
@TableIndex.sql(
  'CREATE UNIQUE INDEX one_active_workout ON workouts ((1)) '
  'WHERE ended_at IS NULL AND deleted_at IS NULL',
)
class Workouts extends Table with UuidPrimaryKey, Timestamps {
  TextColumn get name => text()();

  /// Modèle d'origine, s'il y en a un (TP-05, TP-07).
  TextColumn get templateId => text().nullable().references(
    Templates,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get startedAt => dateTime().clientDefault(clock.now)();

  /// `null` = séance en cours.
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

@TableIndex(name: 'workout_exercises_workout', columns: {#workoutId})
@TableIndex(name: 'workout_exercises_exercise', columns: {#exerciseId})
class WorkoutExercises extends Table with UuidPrimaryKey {
  TextColumn get workoutId =>
      text().references(Workouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get position => integer()();
  TextColumn get notes => text().nullable()();
}

@TableIndex(
  name: 'workout_sets_workout_exercise',
  columns: {#workoutExerciseId},
)
class WorkoutSets extends Table with UuidPrimaryKey {
  TextColumn get workoutExerciseId =>
      text().references(WorkoutExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get setType =>
      textEnum<SetType>().withDefault(const Constant('normal'))();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();

  /// Temps de repos propre à la série ; `null` → RG-09.
  IntColumn get restSeconds => integer().nullable()();

  /// `null` = série pas encore validée.
  DateTimeColumn get completedAt => dateTime().nullable()();
}

// ─── Réglages ────────────────────────────────────────────────────────────────

/// Réglages (ST-*) et état du minuteur de repos, sous forme clé → valeur.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
