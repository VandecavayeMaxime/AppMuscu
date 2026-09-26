import 'template_details.dart';

/// Aperçu des exercices d'un modèle, une ligne par exercice (TP-02) :
/// « 3 × Développé couché (barre) », « 4 × Squat (barre) ».
List<String> templatePreview(TemplateDetails details) => [
  for (final item in details.exercises)
    '${item.sets.length} × ${item.exercise.name}',
];
