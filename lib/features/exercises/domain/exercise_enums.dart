// Listes de valeurs fixes d'un exercice (docs/SPEC.md §5.1).
//
// ⚠️ Le nom Dart de chaque valeur (`barbell`, `fullBody`…) est ce qui est
// enregistré en base : ne jamais renommer une valeur existante. Le libellé
// français, lui, peut changer librement.

/// Matériel utilisé.
enum Equipment {
  barbell('Barre'),
  dumbbell('Haltères'),
  machine('Machine'),
  cable('Poulie'),
  kettlebell('Kettlebell'),
  bodyweight('Poids du corps'),
  band('Élastique'),
  other('Autre');

  const Equipment(this.label);

  /// Libellé affiché à l'utilisateur.
  final String label;
}

/// Groupe musculaire principal.
enum BodyPart {
  chest('Pectoraux'),
  back('Dos'),
  shoulders('Épaules'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Avant-bras'),
  abs('Abdos'),
  quads('Quadriceps'),
  hamstrings('Ischios'),
  glutes('Fessiers'),
  calves('Mollets'),
  fullBody('Corps entier'),
  cardio('Cardio'),
  other('Autre');

  const BodyPart(this.label);

  final String label;
}

/// Ce qu'on saisit pour chaque série : détermine les colonnes affichées.
enum TrackingType {
  weightReps('Poids + reps'),
  reps('Reps seules'),
  duration('Durée');

  const TrackingType(this.label);

  final String label;
}
