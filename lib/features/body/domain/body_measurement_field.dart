// Les 12 champs d'une mesure (SA-06 à SA-08), et leurs bornes (RG-22).

import '../../../core/database/app_database.dart';

/// Un champ d'une mesure : poids, masse grasse, masse musculaire, ou un des
/// 9 tours. Chaque champ a son propre historique et son propre écart
/// (RG-21) : on les traite un par un plutôt que la mesure entière.
enum BodyMeasurementField {
  weight('Poids', 'kg', 1, 500),
  bodyFat('Masse grasse', '%', 1, 100),
  muscleMass('Masse musculaire', 'kg', 1, 500),
  neck('Cou', 'cm', 1, 300),
  chest('Poitrine', 'cm', 1, 300),
  arm('Bras', 'cm', 1, 300),
  forearm('Avant-bras', 'cm', 1, 300),
  waist('Taille', 'cm', 1, 300),
  hips('Hanches', 'cm', 1, 300),
  glutes('Fesses', 'cm', 1, 300),
  thigh('Cuisse', 'cm', 1, 300),
  calf('Mollet', 'cm', 1, 300);

  const BodyMeasurementField(this.label, this.unit, this.min, this.max);

  final String label;
  final String unit;

  /// Bornes acceptées (RG-22), au centième près.
  final double min;
  final double max;

  bool accepts(double value) => value >= min && value <= max;

  /// Les 9 tours, dans l'ordre du formulaire et de la liste « Corps » (SA-06,
  /// SA-07).
  static const circumferences = [
    neck,
    chest,
    arm,
    forearm,
    waist,
    hips,
    glutes,
    thigh,
    calf,
  ];

  /// La valeur de ce champ dans [row], ou `null` si absente ce jour-là.
  double? valueOf(BodyMeasurement row) => switch (this) {
    weight => row.weightKg,
    bodyFat => row.bodyFatPercent,
    muscleMass => row.muscleMassKg,
    neck => row.neckCm,
    chest => row.chestCm,
    arm => row.armCm,
    forearm => row.forearmCm,
    waist => row.waistCm,
    hips => row.hipsCm,
    glutes => row.glutesCm,
    thigh => row.thighCm,
    calf => row.calfCm,
  };
}
