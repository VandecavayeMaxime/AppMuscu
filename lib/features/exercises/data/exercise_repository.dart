import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/text_normalizer.dart';
import '../domain/exercise_enums.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(appDatabaseProvider)),
);

/// Accès à la bibliothèque d'exercices (docs/SPEC.md §5.1).
class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  /// Exercices actifs triés par nom, avec recherche (EX-02) et filtres (EX-03).
  ///
  /// Renvoie un `Stream` : la liste est renvoyée à nouveau à chaque
  /// modification de la table, l'écran se met donc à jour tout seul.
  Stream<List<Exercise>> watchExercises({
    String search = '',
    BodyPart? bodyPart,
    Equipment? equipment,
  }) {
    final normalized = normalizeForSearch(search);
    final query = _db.select(_db.exercises)
      ..where((e) => e.deletedAt.isNull())
      ..orderBy([(e) => OrderingTerm.asc(e.nameNormalized)]);
    if (normalized.isNotEmpty) {
      query.where((e) => e.nameNormalized.contains(normalized));
    }
    if (bodyPart != null) {
      query.where((e) => e.bodyPart.equalsValue(bodyPart));
    }
    if (equipment != null) {
      query.where((e) => e.equipment.equalsValue(equipment));
    }
    return query.watch();
  }

  /// L'exercice [id], y compris s'il est archivé ; `null` s'il n'existe pas.
  Future<Exercise?> findById(String id) => _byId(id).getSingleOrNull();

  /// Comme [findById], mais renvoyé à nouveau à chaque modification (fiche).
  Stream<Exercise?> watchExercise(String id) => _byId(id).watchSingleOrNull();

  SimpleSelectStatement<$ExercisesTable, Exercise> _byId(String id) =>
      _db.select(_db.exercises)..where((e) => e.id.equals(id));

  /// Crée un exercice perso (EX-04).
  ///
  /// Lève [DuplicateExerciseNameException] si le nom est déjà pris (EX-06).
  Future<Exercise> createCustom({
    required String name,
    required Equipment equipment,
    required BodyPart bodyPart,
    required TrackingType trackingType,
    String? instructions,
  }) async {
    final cleanName = _cleanName(name);
    await _ensureNameAvailable(cleanName);
    return _db
        .into(_db.exercises)
        .insertReturning(
          ExercisesCompanion.insert(
            name: cleanName,
            nameNormalized: normalizeForSearch(cleanName),
            equipment: equipment,
            bodyPart: bodyPart,
            trackingType: trackingType,
            instructions: Value(instructions),
            isCustom: const Value(true),
          ),
        );
  }

  /// Modifie la définition d'un exercice perso (EX-05). Celle des exercices
  /// intégrés n'est pas modifiable.
  Future<void> updateCustom(
    String id, {
    required String name,
    required Equipment equipment,
    required BodyPart bodyPart,
    required TrackingType trackingType,
    String? instructions,
  }) async {
    final cleanName = _cleanName(name);
    await _ensureNameAvailable(cleanName, exceptId: id);
    await (_db.update(
      _db.exercises,
    )..where((e) => e.id.equals(id) & e.isCustom.equals(true))).write(
      ExercisesCompanion(
        name: Value(cleanName),
        nameNormalized: Value(normalizeForSearch(cleanName)),
        equipment: Value(equipment),
        bodyPart: Value(bodyPart),
        trackingType: Value(trackingType),
        instructions: Value(instructions),
        updatedAt: Value(clock.now()),
      ),
    );
  }

  /// Modifie les préférences d'un exercice, intégré ou perso (EX-08).
  Future<void> updatePreferences(
    String id, {
    required WeightUnit weightUnit,
    required int? defaultRestSeconds,
  }) async {
    await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
      ExercisesCompanion(
        weightUnit: Value(weightUnit),
        defaultRestSeconds: Value(defaultRestSeconds),
        updatedAt: Value(clock.now()),
      ),
    );
  }

  /// Temps de repos par défaut d'un exercice (EX-08), réglé depuis une
  /// ligne de repos (RT-09).
  Future<void> updateDefaultRest(String id, int seconds) async {
    await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
      ExercisesCompanion(
        defaultRestSeconds: Value(seconds),
        updatedAt: Value(clock.now()),
      ),
    );
  }

  /// Note personnelle d'un exercice, intégré ou perso (EX-11) ; vide = aucune.
  Future<void> updateNote(String id, String? note) async {
    final text = note?.trim() ?? '';
    await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
      ExercisesCompanion(
        note: Value(text.isEmpty ? null : text),
        updatedAt: Value(clock.now()),
      ),
    );
  }

  /// Archive un exercice perso (EX-05) : il disparaît de la bibliothèque mais
  /// reste en base, lié aux séances et modèles qui l'utilisent. Son nom
  /// redevient disponible.
  Future<void> archiveCustom(String id) async {
    final now = clock.now();
    await (_db.update(
      _db.exercises,
    )..where((e) => e.id.equals(id) & e.isCustom.equals(true))).write(
      ExercisesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  String _cleanName(String name) {
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Le nom est obligatoire');
    }
    return clean;
  }

  Future<void> _ensureNameAvailable(String name, {String? exceptId}) async {
    final query = _db.select(_db.exercises)
      ..where(
        (e) =>
            e.nameNormalized.equals(normalizeForSearch(name)) &
            e.deletedAt.isNull(),
      );
    if (exceptId != null) {
      query.where((e) => e.id.equals(exceptId).not());
    }
    if (await query.getSingleOrNull() != null) {
      throw DuplicateExerciseNameException(name);
    }
  }
}

/// Un exercice actif porte déjà ce nom (EX-06).
class DuplicateExerciseNameException implements Exception {
  DuplicateExerciseNameException(this.name);

  final String name;

  @override
  String toString() => 'Un exercice nommé « $name » existe déjà.';
}
