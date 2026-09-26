import '../../../core/database/app_database.dart';

/// Une séance avec tout son contenu, pour l'écran « Séance en cours ».
class WorkoutDetails {
  WorkoutDetails(this.workout);

  final Workout workout;

  /// Exercices de la séance, dans l'ordre.
  final List<WorkoutExerciseDetails> exercises = [];
}

/// Un exercice dans une séance, avec ses séries.
class WorkoutExerciseDetails {
  WorkoutExerciseDetails({required this.entry, required this.exercise});

  /// La ligne de la table workout_exercises (position, note…).
  final WorkoutExercise entry;

  /// L'exercice de la bibliothèque (nom, type de suivi, unité…).
  final Exercise exercise;

  /// Séries, dans l'ordre.
  final List<WorkoutSet> sets = [];
}

/// Une séance où un exercice a été fait (onglet Historique de la fiche, EX-10).
class ExerciseSession {
  ExerciseSession({required this.workoutName, required this.date});

  final String workoutName;
  final DateTime date;

  /// Séries validées de l'exercice dans cette séance, dans l'ordre.
  final List<WorkoutSet> sets = [];
}
