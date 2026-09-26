import '../../../core/database/app_database.dart';
import '../../workout/domain/workout_details.dart';
import 'template_details.dart';

/// Brouillon d'un modèle en cours de modification (TP-01, TP-03).
///
/// Contrairement à une séance, écrite en base à chaque saisie, un modèle
/// n'est enregistré qu'au moment où on touche « Enregistrer » : d'ici là,
/// toutes les modifications vivent dans ce brouillon, en mémoire.
class TemplateDraft {
  TemplateDraft({this.name = '', List<DraftExercise>? exercises})
    : exercises = exercises ?? [];

  /// Brouillon d'un modèle existant, pour le modifier ou le dupliquer.
  factory TemplateDraft.fromDetails(TemplateDetails details) => TemplateDraft(
    name: details.template.name,
    exercises: [
      for (final item in details.exercises)
        DraftExercise(item.exercise, [
          for (final set in item.sets)
            DraftSet(
              weightKg: set.weightKg,
              reps: set.reps,
              durationSeconds: set.durationSeconds,
              restSeconds: set.restSeconds,
            ),
        ]),
    ],
  );

  /// Brouillon reprenant les séries validées d'une séance, pour mettre le
  /// modèle à jour depuis le résumé (TP-07).
  factory TemplateDraft.fromWorkout(WorkoutDetails details, {String? name}) {
    final exercises = <DraftExercise>[];
    for (final item in details.exercises) {
      final sets = [
        for (final set in item.sets)
          if (set.completedAt != null)
            DraftSet(
              weightKg: set.weightKg,
              reps: set.reps,
              durationSeconds: set.durationSeconds,
              restSeconds: set.restSeconds,
            ),
      ];
      if (sets.isNotEmpty) exercises.add(DraftExercise(item.exercise, sets));
    }
    return TemplateDraft(
      name: name ?? details.workout.name,
      exercises: exercises,
    );
  }

  String name;

  /// Exercices, dans l'ordre (TP-01).
  final List<DraftExercise> exercises;

  /// Déplace l'exercice de la place [from] à la place [to] (glisser-déposer).
  void moveExercise(int from, int to) {
    exercises.insert(to, exercises.removeAt(from));
  }
}

/// Un exercice du brouillon. Il a toujours au moins une série.
class DraftExercise {
  DraftExercise(this.exercise, [List<DraftSet>? sets])
    : sets = sets == null || sets.isEmpty ? [DraftSet()] : sets;

  final Exercise exercise;
  final List<DraftSet> sets;

  /// Ajoute une série en bas, copie de celle du dessus : valeurs prévues et
  /// temps de repos (RG-15). On tape ainsi « 80 × 8 » une seule fois.
  void addSet() => sets.add(sets.last.copy());

  /// Même temps de repos pour toutes les séries (RT-07).
  void setRestForAll(int? seconds) {
    for (final set in sets) {
      set.restSeconds = seconds;
    }
  }
}

/// Une série prévue du brouillon ; chaque valeur est facultative.
class DraftSet {
  DraftSet({this.weightKg, this.reps, this.durationSeconds, this.restSeconds});

  double? weightKg;
  int? reps;
  int? durationSeconds;

  /// Temps de repos propre à la série ; `null` → RG-09.
  int? restSeconds;

  DraftSet copy() => DraftSet(
    weightKg: weightKg,
    reps: reps,
    durationSeconds: durationSeconds,
    restSeconds: restSeconds,
  );
}
