import '../../../core/database/app_database.dart';
import '../../exercises/domain/exercise_enums.dart';

/// Aucune valeur saisie : la série est supprimée sans question à la fin de
/// la séance (WO-17).
bool isSetEmpty(WorkoutSet set) =>
    set.weightKg == null && set.reps == null && set.durationSeconds == null;

/// Toutes les valeurs requises par le type de suivi sont saisies : la série
/// peut être validée telle quelle (« Tout valider », WO-17).
bool isSetReady(WorkoutSet set, TrackingType trackingType) {
  return switch (trackingType) {
    TrackingType.weightReps => set.weightKg != null && set.reps != null,
    TrackingType.reps => set.reps != null,
    TrackingType.duration => set.durationSeconds != null,
  };
}

typedef SetPlaceholders = ({double? weightKg, int? reps, int? durationSeconds});

/// Valeurs grisées des champs d'une série (RG-11), champ par champ : celle
/// prévue par le modèle, sinon celle de la même série la dernière fois
/// ([previous], colonne « Précédent »), sinon rien. Valider une série sans
/// rien saisir reprend ces valeurs (WO-08).
SetPlaceholders placeholdersOf(WorkoutSet set, WorkoutSet? previous) => (
  weightKg: set.plannedWeightKg ?? previous?.weightKg,
  reps: set.plannedReps ?? previous?.reps,
  durationSeconds: set.plannedDurationSeconds ?? previous?.durationSeconds,
);

/// [placeholdersOf] pour chaque série de [sets] (même ordre), avec un
/// dernier repli, champ par champ : la valeur (réelle, ou déjà préremplie)
/// de la série d'avant dans la séance en cours — pour qu'une série ajoutée
/// sans équivalent la dernière fois ([previousSets], même rang) reprenne
/// quand même quelque chose plutôt que de rester vide (WO-10).
List<SetPlaceholders> placeholdersOfAll(
  List<WorkoutSet> sets,
  List<WorkoutSet> previousSets,
) {
  final result = <SetPlaceholders>[];
  SetPlaceholders? sessionPrevious;
  for (final (index, set) in sets.indexed) {
    final previous = index < previousSets.length ? previousSets[index] : null;
    final base = placeholdersOf(set, previous);
    final placeholder = (
      weightKg: base.weightKg ?? sessionPrevious?.weightKg,
      reps: base.reps ?? sessionPrevious?.reps,
      durationSeconds: base.durationSeconds ?? sessionPrevious?.durationSeconds,
    );
    result.add(placeholder);
    sessionPrevious = (
      weightKg: set.weightKg ?? placeholder.weightKg,
      reps: set.reps ?? placeholder.reps,
      durationSeconds: set.durationSeconds ?? placeholder.durationSeconds,
    );
  }
  return result;
}
