import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../workout/data/workout_repository.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise_enums.dart';

/// Critères de la liste d'exercices : texte recherché et filtres (EX-02,
/// EX-03). Plusieurs valeurs à la fois par catégorie (groupe musculaire,
/// équipement), comme Strong.
typedef ExerciseFilter = ({
  String search,
  Set<BodyPart> bodyParts,
  Set<Equipment> equipment,
});

/// Les deux usages de la liste d'exercices : l'onglet Exercices et le
/// sélecteur (séance, modèle). Chacun garde ses propres critères.
enum ExerciseListMode { library, picker }

/// Critères choisis dans la liste d'exercices. Un `Notifier` garde un état et
/// expose les méthodes pour le modifier ; les écrans qui le regardent sont
/// reconstruits à chaque changement.
class ExerciseFilterNotifier extends Notifier<ExerciseFilter> {
  @override
  ExerciseFilter build() =>
      (search: '', bodyParts: const {}, equipment: const {});

  void search(String text) => state = (
    search: text,
    bodyParts: state.bodyParts,
    equipment: state.equipment,
  );

  void toggleBodyPart(BodyPart bodyPart) => state = (
    search: state.search,
    bodyParts: _toggled(state.bodyParts, bodyPart),
    equipment: state.equipment,
  );

  void toggleEquipment(Equipment equipment) => state = (
    search: state.search,
    bodyParts: state.bodyParts,
    equipment: _toggled(state.equipment, equipment),
  );

  void clearFilters() =>
      state = (search: state.search, bodyParts: const {}, equipment: const {});

  static Set<T> _toggled<T>(Set<T> values, T value) => values.contains(value)
      ? ({...values}..remove(value))
      : {...values, value};
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
            bodyParts: filter.bodyParts,
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
