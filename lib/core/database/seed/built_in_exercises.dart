import 'package:drift/drift.dart';

import '../../../features/exercises/domain/exercise_enums.dart';
import '../../utils/text_normalizer.dart';
import '../app_database.dart';

/// Les 10 exercices livrés avec l'app (docs/SPEC.md §5.1, EX-01).
///
/// Les identifiants sont fixes : une migration peut ainsi corriger ou
/// compléter ces exercices sans créer de doublons.
typedef _BuiltIn = ({
  String id,
  String name,
  Equipment equipment,
  BodyPart bodyPart,
  TrackingType trackingType,
  String instructions,
});

const _builtIns = <_BuiltIn>[
  (
    id: '509d3ccf-bf4e-411b-a5db-2d2e491f586c',
    name: 'Développé couché (barre)',
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allonge-toi sur le banc, les yeux sous la barre, pieds à plat au sol.\n'
        '2. Serre les omoplates, prise un peu plus large que les épaules.\n'
        '3. Descends la barre en contrôle jusqu’au bas des pectoraux.\n'
        '4. Pousse jusqu’à tendre les bras, sans décoller les fesses du banc.',
  ),
  (
    id: 'c152f391-b038-44f6-b8df-cfef1d1a789d',
    name: 'Squat (barre)',
    equipment: Equipment.barbell,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, pieds largeur d’épaules, pointes légèrement ouvertes.\n'
        '2. Gaine les abdos, poitrine sortie, regard devant.\n'
        '3. Descends en poussant les hanches en arrière et en ouvrant les genoux, '
        'jusqu’à avoir les cuisses au moins parallèles au sol.\n'
        '4. Remonte en poussant dans le sol, le dos droit.',
  ),
  (
    id: '7c098dc4-7640-4b19-9dda-14dd6f4cb30a',
    name: 'Soulevé de terre (barre)',
    equipment: Equipment.barbell,
    bodyPart: BodyPart.back,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds largeur de hanches, barre au-dessus du milieu du pied.\n'
        '2. Saisis la barre juste à l’extérieur des jambes, dos plat, épaules au-dessus de la barre.\n'
        '3. Pousse dans le sol en tendant hanches et genoux ensemble, barre collée aux jambes.\n'
        '4. Redescends en contrôle par le même trajet.',
  ),
  (
    id: '3b49eab5-f756-427e-8ee6-62ab6d6114bb',
    name: 'Développé militaire (barre)',
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre sur le haut de la poitrine, prise légèrement plus large que les épaules.\n'
        '2. Gaine les abdos et serre les fessiers.\n'
        '3. Pousse la barre à la verticale au-dessus de la tête ; avance la tête une fois la barre passée.\n'
        '4. Redescends en contrôle jusqu’à la poitrine.',
  ),
  (
    id: '8087a454-a438-4c79-be98-f6670785da3e',
    name: 'Rowing (barre)',
    equipment: Equipment.barbell,
    bodyPart: BodyPart.back,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Genoux légèrement fléchis, buste penché vers l’avant, dos plat.\n'
        '2. Prise paumes vers toi, un peu plus large que les épaules.\n'
        '3. Tire la barre vers le bas du ventre en serrant les omoplates.\n'
        '4. Redescends en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '5bc61b55-5623-4618-a35e-f8dc3469c2ab',
    name: 'Presse à cuisses',
    equipment: Equipment.machine,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos et bassin plaqués contre le dossier, pieds largeur d’épaules sur la plateforme.\n'
        '2. Déverrouille la charge et fléchis les genoux vers la poitrine.\n'
        '3. Arrête-toi avant que le bas du dos ne décolle.\n'
        '4. Pousse jusqu’à tendre les jambes, sans verrouiller les genoux.',
  ),
  (
    id: 'eba26f67-c29f-44b6-99c6-0de4a0f8538c',
    name: 'Curl biceps (haltères)',
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main, bras le long du corps, paumes vers l’avant.\n'
        '2. Garde les coudes fixes contre le buste.\n'
        '3. Monte les haltères en fléchissant les coudes, sans balancer le buste.\n'
        '4. Redescends lentement jusqu’à tendre les bras.',
  ),
  (
    id: 'd5702b62-5375-434d-a0bb-f2c807c0b16a',
    name: 'Extension triceps (poulie)',
    equipment: Equipment.cable,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie haute, saisis la barre ou la corde, coudes collés au corps.\n'
        '2. Buste légèrement penché, abdos gainés.\n'
        '3. Pousse vers le bas jusqu’à tendre complètement les bras.\n'
        '4. Remonte en contrôle sans décoller les coudes.',
  ),
  (
    id: 'd160b037-2046-44ac-ba37-97784a8cade2',
    name: 'Tractions',
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.back,
    trackingType: TrackingType.reps,
    instructions:
        '1. Suspends-toi à la barre, paumes vers l’avant, prise un peu plus large que les épaules.\n'
        '2. Serre les omoplates et gaine les abdos.\n'
        '3. Tire jusqu’à passer le menton au-dessus de la barre.\n'
        '4. Redescends en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: 'a6a15280-2533-4e58-9161-ba084762cae2',
    name: 'Gainage (planche)',
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.duration,
    instructions:
        '1. En appui sur les avant-bras et la pointe des pieds, coudes sous les épaules.\n'
        '2. Corps aligné de la tête aux talons : ni fesses en l’air, ni dos creusé.\n'
        '3. Contracte abdos et fessiers, respire normalement.\n'
        '4. Tiens la position pendant la durée voulue.',
  ),
];

/// Lignes insérées à la création de la base.
List<ExercisesCompanion> get builtInExercises => [
  for (final e in _builtIns)
    ExercisesCompanion.insert(
      id: Value(e.id),
      name: e.name,
      nameNormalized: normalizeForSearch(e.name),
      equipment: e.equipment,
      bodyPart: e.bodyPart,
      trackingType: e.trackingType,
      instructions: Value(e.instructions),
    ),
];

/// Consignes par identifiant d'exercice (migration v1 → v2).
Map<String, String> get builtInInstructions => {
  for (final e in _builtIns) e.id: e.instructions,
};
