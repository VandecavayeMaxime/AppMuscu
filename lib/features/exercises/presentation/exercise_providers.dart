import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../workout/data/workout_repository.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise_enums.dart';

/// Critères de la liste d'exercices : texte recherché et filtres (EX-02, EX-03).
typedef ExerciseFilter = ({
  String search,
  BodyPart? bodyPart,
  Equipment? equipment,
});

/// Les deux usages de la liste d'exercices : l'onglet Exercices et le
/// sélecteur (séance, modèle). Chacun garde ses propres critères.
enum ExerciseListMode { library, picker }

/// Critères choisis dans la liste d'exercices. Un `Notifier` garde un état et
/// expose les méthodes pour le modifier ; les écrans qui le regardent sont
/// reconstruits à chaque changement.
class ExerciseFilterNotifier extends Notifier<ExerciseFilter> {
  @override
  ExerciseFilter build() => (search: '', bodyPart: null, equipment: null);

  void search(String text) => state = (
    search: text,
    bodyPart: state.bodyPart,
    equipment: state.equipment,
  );

  void filterBodyPart(BodyPart? bodyPart) => state = (
    search: state.search,
    bodyPart: bodyPart,
    equipment: state.equipment,
  );

  void filterEquipment(Equipment? equipment) => state = (
    search: state.search,
    bodyPart: state.bodyPart,
    equipment: equipment,
  );
}

/// Un jeu de critères par usage (`.family`). `.autoDispose` : ceux du
/// sélecteur repartent de zéro à chaque ouverture.
final exerciseFilterProvider = NotifierProvider.autoDispose
    .family<ExerciseFilterNotifier, ExerciseFilter, ExerciseListMode>(
      (mode) => ExerciseFilterNotifier(),
    );

/// Exercices correspondant aux critères, mis à jour en direct.
final exerciseListProvider = StreamProvider.autoDispose
    .family<List<Exercise>, ExerciseListMode>((ref, mode) {
      final filter = ref.watch(exerciseFilterProvider(mode));
      return ref
          .watch(exerciseRepositoryProvider)
          .watchExercises(
            search: filter.search,
            bodyPart: filter.bodyPart,
            equipment: filter.equipment,
          );
    });

/// Un exercice précis, mis à jour en direct (fiche, formulaire).
///
/// `.family` : un provider par identifiant ; `.autoDispose` : libéré quand
/// plus aucun écran ne l'utilise.
final exerciseProvider = StreamProvider.autoDispose.family<Exercise?, String>(
  (ref, id) => ref.watch(exerciseRepositoryProvider).watchExercise(id),
);

/// Historique d'un exercice (onglet Historique de la fiche).
final exerciseHistoryProvider = StreamProvider.autoDispose
    .family<List<ExerciseSession>, String>(
      (ref, id) =>
          ref.watch(workoutRepositoryProvider).watchExerciseHistory(id),
    );
