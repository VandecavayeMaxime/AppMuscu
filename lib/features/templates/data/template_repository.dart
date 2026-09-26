import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../workout/domain/workout_details.dart';
import '../domain/template_details.dart';
import '../domain/template_draft.dart';

// Les écrans qui utilisent le repository ont aussi besoin de ces modèles.
export '../domain/template_details.dart';
export '../domain/template_draft.dart';

final templateRepositoryProvider = Provider<TemplateRepository>(
  (ref) => TemplateRepository(ref.watch(appDatabaseProvider)),
);

/// Accès aux modèles de séance (docs/SPEC.md §5.4).
///
/// Un modèle s'enregistre d'un bloc (brouillon → base), dans une
/// transaction : soit tout est écrit, soit rien.
class TemplateRepository {
  TemplateRepository(this._db);

  final AppDatabase _db;

  // ─── Lecture ───────────────────────────────────────────────────────────────

  /// Les modèles (non supprimés), dans l'ordre d'affichage, mis à jour en
  /// direct : aussi quand une séance issue d'un modèle se termine (TP-02).
  Stream<List<TemplateDetails>> watchTemplates() =>
      _query().watch().map(_toDetails);

  /// Un modèle, ou `null` s'il n'existe pas ou a été supprimé.
  Stream<TemplateDetails?> watchTemplate(String templateId) =>
      _query(templateId).watch().map((rows) => _toDetails(rows).firstOrNull);

  /// Comme [watchTemplate], en une seule lecture.
  Future<TemplateDetails?> getTemplate(String templateId) async =>
      _toDetails(await _query(templateId).get()).firstOrNull;

  /// Début de la dernière séance terminée issue du modèle (TP-02). C'est une
  /// sous-requête « corrélée » : calculée pour chaque ligne de modèle.
  late final Expression<DateTime> _lastUsedAt = subqueryExpression(
    _db.selectOnly(_db.workouts)
      ..addColumns([_db.workouts.startedAt.max()])
      ..where(
        _db.workouts.templateId.equalsExp(_db.templates.id) &
            _db.workouts.endedAt.isNotNull() &
            _db.workouts.deletedAt.isNull(),
      ),
  );

  // Une ligne SQL par série, comme pour les séances.
  JoinedSelectStatement<HasResultSet, dynamic> _query([String? templateId]) {
    final template = _db.templates;
    final entry = _db.templateExercises;
    final set = _db.templateSets;
    return _db.select(template).join([
        leftOuterJoin(entry, entry.templateId.equalsExp(template.id)),
        leftOuterJoin(
          _db.exercises,
          _db.exercises.id.equalsExp(entry.exerciseId),
        ),
        leftOuterJoin(set, set.templateExerciseId.equalsExp(entry.id)),
      ])
      ..addColumns([_lastUsedAt])
      ..where(
        template.deletedAt.isNull() &
            (templateId == null
                ? const Constant(true)
                : template.id.equals(templateId)),
      )
      ..orderBy([
        OrderingTerm.asc(template.position),
        OrderingTerm.asc(template.createdAt),
        OrderingTerm.asc(template.id),
        OrderingTerm.asc(entry.position),
        OrderingTerm.asc(set.position),
      ]);
  }

  List<TemplateDetails> _toDetails(List<TypedResult> rows) {
    final templates = <String, TemplateDetails>{};
    final entries = <String, TemplateExerciseDetails>{};
    for (final row in rows) {
      final template = row.readTable(_db.templates);
      final details = templates.putIfAbsent(
        template.id,
        () => TemplateDetails(template, lastUsedAt: row.read(_lastUsedAt)),
      );
      final entry = row.readTableOrNull(_db.templateExercises);
      if (entry == null) continue;
      final item = entries.putIfAbsent(entry.id, () {
        final item = TemplateExerciseDetails(
          entry: entry,
          exercise: row.readTable(_db.exercises),
        );
        details.exercises.add(item);
        return item;
      });
      final set = row.readTableOrNull(_db.templateSets);
      if (set != null) item.sets.add(set);
    }
    return templates.values.toList();
  }

  // ─── Écriture ──────────────────────────────────────────────────────────────

  /// Enregistre le brouillon : crée un modèle (à la fin de la liste) si
  /// [templateId] est `null`, sinon remplace son nom et tout son contenu
  /// (TP-01, TP-03). Renvoie l'identifiant du modèle.
  Future<String> saveTemplate(TemplateDraft draft, {String? templateId}) {
    return _db.transaction(() async {
      final name = draft.name.trim();
      final String id;
      if (templateId == null) {
        final maxPosition = _db.templates.position.max();
        final lastPosition =
            await (_db.selectOnly(_db.templates)..addColumns([maxPosition]))
                .map((row) => row.read(maxPosition))
                .getSingle();
        final template = await _db
            .into(_db.templates)
            .insertReturning(
              TemplatesCompanion.insert(
                name: name,
                position: Value((lastPosition ?? -1) + 1),
              ),
            );
        id = template.id;
      } else {
        await (_db.update(
          _db.templates,
        )..where((t) => t.id.equals(templateId))).write(
          TemplatesCompanion(name: Value(name), updatedAt: Value(clock.now())),
        );
        // Le contenu est remplacé en bloc. Supprimer les exercices supprime
        // aussi leurs séries (clé étrangère « en cascade »).
        await (_db.delete(
          _db.templateExercises,
        )..where((e) => e.templateId.equals(templateId))).go();
        id = templateId;
      }

      for (final (position, item) in draft.exercises.indexed) {
        final entry = await _db
            .into(_db.templateExercises)
            .insertReturning(
              TemplateExercisesCompanion.insert(
                templateId: id,
                exerciseId: item.exercise.id,
                position: position,
              ),
            );
        for (final (setPosition, set) in item.sets.indexed) {
          await _db
              .into(_db.templateSets)
              .insert(
                TemplateSetsCompanion.insert(
                  templateExerciseId: entry.id,
                  position: setPosition,
                  weightKg: Value(set.weightKg),
                  reps: Value(set.reps),
                  durationSeconds: Value(set.durationSeconds),
                  restSeconds: Value(set.restSeconds),
                ),
              );
        }
      }
      return id;
    });
  }

  /// Copie d'un modèle, nommée « … (copie) », en fin de liste (TP-04).
  Future<String?> duplicateTemplate(String templateId) async {
    final details = await getTemplate(templateId);
    if (details == null) return null;
    final draft = TemplateDraft.fromDetails(details)
      ..name = '${details.template.name} (copie)';
    return saveTemplate(draft);
  }

  /// Supprime un modèle (TP-03) : suppression douce (RG-10). Les séances
  /// passées ne sont pas touchées.
  Future<void> deleteTemplate(String templateId) {
    final now = clock.now();
    return (_db.update(
      _db.templates,
    )..where((t) => t.id.equals(templateId))).write(
      TemplatesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  /// Remplace le contenu du modèle par les séries validées de la séance
  /// (TP-07). Le nom du modèle ne change pas.
  Future<void> updateFromWorkout(String templateId, WorkoutDetails workout) {
    return _db.transaction(() async {
      final template = await (_db.select(
        _db.templates,
      )..where((t) => t.id.equals(templateId))).getSingle();
      await saveTemplate(
        TemplateDraft.fromWorkout(workout, name: template.name),
        templateId: templateId,
      );
    });
  }
}
