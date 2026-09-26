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

/// Critères choisis dans l'onglet Exercices. Un `Notifier` garde un état et
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

final exerciseFilterProvider =
    NotifierProvider<ExerciseFilterNotifier, ExerciseFilter>(
      ExerciseFilterNotifier.new,
    );

/// Exercices correspondant aux critères, mis à jour en direct.
final exerciseListProvider = StreamProvider<List<Exercise>>((ref) {
  final filter = ref.watch(exerciseFilterProvider);
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
