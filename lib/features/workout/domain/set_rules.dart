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

/// Valeurs grisées des champs d'une série (RG-11), champ par champ : celle
/// prévue par le modèle, sinon celle de la même série la dernière fois
/// ([previous], colonne « Précédent »), sinon rien. Valider une série sans
/// rien saisir reprend ces valeurs (WO-08).
({double? weightKg, int? reps, int? durationSeconds}) placeholdersOf(
  WorkoutSet set,
  WorkoutSet? previous,
) => (
  weightKg: set.plannedWeightKg ?? previous?.weightKg,
  reps: set.plannedReps ?? previous?.reps,
  durationSeconds: set.plannedDurationSeconds ?? previous?.durationSeconds,
);
