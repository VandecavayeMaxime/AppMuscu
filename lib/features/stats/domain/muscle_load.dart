// Charge par muscle (SA-04, SA-05, RG-17), à partir des séries validées des
// séances terminées d'une période.

import '../../exercises/domain/exercise_enums.dart';

/// Ce qu'il faut savoir d'une série validée pour la compter dans la charge
/// musculaire : le groupe principal et les muscles secondaires de son
/// exercice (RG-17). Une entrée par série (pas par exercice).
typedef CountedSet = ({BodyPart main, List<BodyPart> secondary});

/// Séries par muscle (RG-17) : chaque entrée de [sets] compte 1 pour son
/// groupe principal et ½ pour chacun de ses muscles secondaires. Les muscles
/// sans aucune série n'apparaissent pas dans le résultat.
Map<BodyPart, double> muscleLoad(Iterable<CountedSet> sets) {
  final load = <BodyPart, double>{};
  for (final set in sets) {
    load[set.main] = (load[set.main] ?? 0) + 1;
    for (final secondary in set.secondary) {
      load[secondary] = (load[secondary] ?? 0) + 0.5;
    }
  }
  return load;
}

/// Un repère (bas, haut) en séries par semaine, pour juger si un muscle a
/// été assez travaillé (SA-04) : sous [low], insuffisant ; entre [low] et
/// [high], correct à optimal ; au-delà, volume élevé (RG-23). Popularisés
/// par le Dr Mike Israetel (Renaissance Periodization) à partir des
/// méta-analyses de Schoenfeld sur le volume d'entraînement : des repères de
/// coach, pas une mesure exacte au muscle près — donc ajustables ici.
typedef VolumeLandmark = ({int low, int high});

/// Repère utilisé quand un muscle n'a pas d'entrée (ne devrait pas arriver :
/// [muscleMapBodyParts] couvre tous les muscles suivis).
const _defaultLandmark = (low: 6, high: 16);

const muscleVolumeLandmarks = <BodyPart, VolumeLandmark>{
  BodyPart.chest: (low: 6, high: 20),
  BodyPart.lats: (low: 8, high: 22),
  BodyPart.trapezius: (low: 4, high: 16),
  BodyPart.lowerBack: (low: 3, high: 16),
  BodyPart.shoulders: (low: 6, high: 26),
  BodyPart.biceps: (low: 6, high: 20),
  BodyPart.triceps: (low: 6, high: 18),
  BodyPart.forearms: (low: 4, high: 16),
  BodyPart.abs: (low: 4, high: 25),
  BodyPart.obliques: (low: 3, high: 20),
  BodyPart.quads: (low: 6, high: 20),
  BodyPart.adductors: (low: 3, high: 16),
  BodyPart.hamstrings: (low: 4, high: 16),
  BodyPart.glutes: (low: 3, high: 16),
  BodyPart.calves: (low: 6, high: 16),
};

/// Position d'un muscle sur l'échelle de couleur (SA-04), un nombre continu
/// entre 0 et 3 : 0 = jamais travaillé, ]0, 1[ = insuffisant, 1 = repère
/// bas, ]1, 2[ = correct à optimal, 2 = repère haut, ]2, 3] = volume élevé
/// (plafonné à une fois et demie le repère haut). Sert à teinter la
/// silhouette (voir `muscleColor`, presentation/body_silhouette.dart) : un
/// dégradé continu, mais avec un changement net à chaque repère.
double muscleZoneProgress(BodyPart part, double sets) {
  if (sets <= 0) return 0;
  final landmark = muscleVolumeLandmarks[part] ?? _defaultLandmark;
  if (sets <= landmark.low) return sets / landmark.low;
  if (sets <= landmark.high) {
    return 1 + (sets - landmark.low) / (landmark.high - landmark.low);
  }
  final over = (sets - landmark.high) / (landmark.high * 0.5);
  return 2 + over.clamp(0, 1);
}

/// Les muscles de [load], du plus au moins travaillé (SA-05). En cas
/// d'égalité, l'ordre de [BodyPart] (celui de la bibliothèque) départage.
List<MapEntry<BodyPart, double>> rankedMuscles(Map<BodyPart, double> load) {
  final entries = load.entries.toList()
    ..sort((a, b) {
      final byLoad = b.value.compareTo(a.value);
      return byLoad != 0 ? byLoad : a.key.index.compareTo(b.key.index);
    });
  return entries;
}
