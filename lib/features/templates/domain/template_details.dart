import '../../../core/database/app_database.dart';

/// Un modèle avec tout son contenu, tel qu'enregistré en base : pour la
/// carte de l'onglet Séance, l'aperçu et la comparaison en fin de séance.
class TemplateDetails {
  TemplateDetails(this.template, {this.lastUsedAt});

  final Template template;

  /// Début de la dernière séance terminée démarrée depuis ce modèle (TP-02).
  final DateTime? lastUsedAt;

  /// Exercices du modèle, dans l'ordre.
  final List<TemplateExerciseDetails> exercises = [];
}

/// Un exercice dans un modèle, avec ses séries prévues.
class TemplateExerciseDetails {
  TemplateExerciseDetails({required this.entry, required this.exercise});

  /// La ligne de la table template_exercises (position…).
  final TemplateExercise entry;

  /// L'exercice de la bibliothèque (nom, type de suivi, unité…).
  final Exercise exercise;

  /// Séries prévues, dans l'ordre.
  final List<TemplateSet> sets = [];
}
