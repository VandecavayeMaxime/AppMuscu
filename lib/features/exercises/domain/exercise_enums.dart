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

/// Unité de saisie et d'affichage des poids, choisie par exercice (EX-08).
/// En base, les poids sont toujours en kg (RG-14).
enum WeightUnit {
  kg('kg', 1),
  lb('lb', 0.45359237);

  const WeightUnit(this.label, this.kilograms);

  final String label;

  /// Valeur d'une unité, en kg.
  final double kilograms;

  /// Convertit une valeur saisie dans cette unité en kg.
  double toKg(double value) => value * kilograms;

  /// Convertit des kg vers cette unité.
  double fromKg(double kg) => kg / kilograms;
}

/// Ce qu'on saisit pour chaque série : détermine les colonnes affichées.
enum TrackingType {
  weightReps('Poids + reps'),
  reps('Reps seules'),
  duration('Durée');

  const TrackingType(this.label);

  final String label;
}
