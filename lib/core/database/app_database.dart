import 'package:clock/clock.dart'; // utilisé par le code généré (dates par défaut)
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/exercises/domain/exercise_enums.dart';
import '../../features/workout/domain/set_type.dart';
import '../utils/text_normalizer.dart';
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
    BodyMeasurements,
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
  int get schemaVersion => 13;

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
      // v4 : la note est attachée à l'exercice, et non plus à la séance.
      // Chaque exercice reprend la dernière note prise pendant une séance.
      from3To4: (m, schema) async {
        await m.addColumn(schema.exercises, schema.exercises.note);
        await customStatement('''
          UPDATE exercises SET note = (
            SELECT we.notes FROM workout_exercises we
            JOIN workouts w ON w.id = we.workout_id
            WHERE we.exercise_id = exercises.id AND we.notes <> ''
            ORDER BY w.started_at DESC
            LIMIT 1
          )
        ''');
      },
      // v5 : muscles secondaires (carte des muscles, SA-04). Les exercices
      // intégrés reçoivent d'office ceux du tableau de la bibliothèque.
      from4To5: (m, schema) async {
        await m.addColumn(schema.exercises, schema.exercises.secondaryMuscles);
        for (final MapEntry(key: id, value: muscles)
            in builtInSecondaryMuscles.entries) {
          await customUpdate(
            'UPDATE exercises SET secondary_muscles = ? WHERE id = ?',
            variables: [
              Variable(muscles.map((part) => part.name).join(',')),
              Variable(id),
            ],
          );
        }
      },
      // v6 : découpage plus fin des groupes musculaires (D20) : « Dos »
      // devient trapèzes / dorsaux / lombaires, « Abdos » gagne les
      // obliques, « Quadriceps » gagne les adducteurs. La structure ne
      // change pas (aucune colonne ajoutée) : seules les valeurs stockées
      // sont corrigées, sur `body_part` et dans les listes de
      // `secondary_muscles`.
      from5To6: (m, schema) async {
        // Par défaut, un exercice perso « Dos » devient « Dorsaux » (le
        // sens le plus courant). Puis on précise les 3 exercices intégrés
        // qui utilisaient « Dos » (Rowing, Tractions, Soulevé de terre).
        await customStatement(
          "UPDATE exercises SET body_part = 'lats' WHERE body_part = 'back'",
        );
        for (final MapEntry(key: id, value: bodyPart)
            in builtInBodyParts.entries) {
          await customUpdate(
            'UPDATE exercises SET body_part = ? WHERE id = ?',
            variables: [Variable(bodyPart.name), Variable(id)],
          );
        }
        // Aucun exercice intégré n'avait « Dos » en muscle secondaire, mais
        // un exercice perso aurait pu : même bascule vers « dorsaux ». Sans
        // risque de confusion : aucune autre valeur ne contient « back »
        // (« lowerBack » s'écrit avec un B majuscule).
        await customStatement(
          "UPDATE exercises SET secondary_muscles = "
          "REPLACE(secondary_muscles, 'back', 'lats')",
        );
      },
      // v7 : bibliothèque élargie (D21) — 73 exercices de plus, pour que
      // chaque groupe musculaire de la carte des muscles ait au moins un
      // exercice. Aucune colonne ajoutée : la structure ne change pas, donc
      // on écrit avec la table réelle (`exercices`), pas `schema.exercises`.
      from6To7: (m, schema) async {
        await batch((b) => b.insertAll(exercises, builtInExercisesAddedInV7));
      },
      // v8 : les exercices intégrés reprennent leur nom d'usage en salle, en
      // anglais (D22), plutôt qu'une traduction française.
      from7To8: (m, schema) async {
        for (final MapEntry(key: id, value: name) in builtInNames.entries) {
          await customUpdate(
            'UPDATE exercises SET name = ?, name_normalized = ? WHERE id = ?',
            variables: [
              Variable(name),
              Variable(normalizeForSearch(name)),
              Variable(id),
            ],
          );
        }
      },
      // v9 : poids et mensurations (SA-06 à SA-08).
      from8To9: (m, schema) async {
        await m.createTable(schema.bodyMeasurements);
        await m.createIndex(schema.bodyMeasurementsDay);
      },
      // v10 : tours de fesses et d'avant-bras en plus (SA-06).
      from9To10: (m, schema) async {
        final measurements = schema.bodyMeasurements;
        await m.addColumn(measurements, measurements.forearmCm);
        await m.addColumn(measurements, measurements.glutesCm);
      },
      // v11 : Chest Dip et Tricep Dip passent en poids + reps, pour suivre
      // une charge ajoutée à la ceinture (D28).
      from10To11: (m, schema) async {
        for (final id in builtInWeightRepsInV11) {
          await customUpdate(
            "UPDATE exercises SET tracking_type = 'weightReps' WHERE id = ?",
            variables: [Variable(id)],
          );
        }
      },
      // v12 : « Trapèzes » scindé en haut et milieu/bas (D29), sans rien
      // structurel (même colonne texte). Les exercices intégrés concernés
      // sont réattribués ; un exercice perso avec « trapezius » (groupe
      // principal ou secondaire) bascule par défaut vers le haut.
      from11To12: (m, schema) async {
        await customStatement(
          "UPDATE exercises SET body_part = 'trapeziusUpper' "
          "WHERE body_part = 'trapezius'",
        );
        await customStatement(
          "UPDATE exercises SET secondary_muscles = "
          "REPLACE(secondary_muscles, 'trapezius', 'trapeziusUpper') "
          "WHERE secondary_muscles LIKE '%trapezius%'",
        );
        for (final id in builtInTrapeziusUpperInV12) {
          await customUpdate(
            "UPDATE exercises SET body_part = 'trapeziusUpper' WHERE id = ?",
            variables: [Variable(id)],
          );
        }
        for (final id in builtInTrapeziusLowerInV12) {
          await customUpdate(
            "UPDATE exercises SET body_part = 'trapeziusLower' WHERE id = ?",
            variables: [Variable(id)],
          );
        }
        for (final id in builtInTrapeziusLowerSecondaryInV12) {
          await customUpdate(
            "UPDATE exercises SET secondary_muscles = 'trapeziusLower' "
            'WHERE id = ?',
            variables: [Variable(id)],
          );
        }
      },
      // v13 : bibliothèque très largement élargie (D30) — 445 exercices de
      // plus, à partir du jeu de données ouvert RepDB (illustrations
      // cohérentes, voir docs/ARCHITECTURE.md §4). Aucune colonne ajoutée.
      from12To13: (m, schema) async {
        await batch((b) => b.insertAll(exercises, builtInExercisesAddedInV13));
      },
    ),
    // À chaque ouverture : SQLite n'applique les clés étrangères que si on le demande.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
