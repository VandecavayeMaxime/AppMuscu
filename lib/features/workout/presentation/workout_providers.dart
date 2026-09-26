import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/workout_repository.dart';

/// La séance en cours, ou `null` (WO-02 : au plus une).
final activeWorkoutProvider = StreamProvider<Workout?>(
  (ref) => ref.watch(workoutRepositoryProvider).watchActiveWorkout(),
);

/// Une séance avec ses exercices et ses séries, mis à jour en direct.
final workoutDetailsProvider = StreamProvider.autoDispose
    .family<WorkoutDetails?, String>(
      (ref, workoutId) =>
          ref.watch(workoutRepositoryProvider).watchWorkoutDetails(workoutId),
    );

/// Séries de la dernière séance contenant l'exercice (colonne « Précédent »).
final previousSetsProvider = FutureProvider.autoDispose
    .family<List<WorkoutSet>, String>(
      (ref, exerciseId) =>
          ref.watch(workoutRepositoryProvider).previousSets(exerciseId),
    );
