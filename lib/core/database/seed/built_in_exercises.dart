import 'package:drift/drift.dart';

import '../../../features/exercises/domain/exercise_enums.dart';
import '../../utils/text_normalizer.dart';
import '../app_database.dart';

/// Les exercices livrés avec l'app (docs/SPEC.md §5.1, EX-01) : les 10 du
/// MVP, puis 73 de plus (migration v6 → v7, D21) pour qu'aucun groupe
/// musculaire ne reste sans exercice.
///
/// Les identifiants sont fixes : une migration peut ainsi corriger ou
/// compléter ces exercices sans créer de doublons.
typedef _BuiltIn = ({
  String id,
  String name,
  Equipment equipment,
  BodyPart bodyPart,
  List<BodyPart> secondaryMuscles,
  TrackingType trackingType,
  String instructions,
});

const _builtIns = <_BuiltIn>[
  (
    id: '509d3ccf-bf4e-411b-a5db-2d2e491f586c',
    name: 'Bench Press (Barbell)',
    secondaryMuscles: [BodyPart.triceps, BodyPart.shoulders],
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
    name: 'Squat (Barbell)',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
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
    name: 'Deadlift (Barbell)',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings, BodyPart.forearms],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds largeur de hanches, barre au-dessus du milieu du pied.\n'
        '2. Saisis la barre juste à l’extérieur des jambes, dos plat, épaules au-dessus de la barre.\n'
        '3. Pousse dans le sol en tendant hanches et genoux ensemble, barre collée aux jambes.\n'
        '4. Redescends en contrôle par le même trajet.',
  ),
  (
    id: '3b49eab5-f756-427e-8ee6-62ab6d6114bb',
    name: 'Overhead Press (Barbell)',
    secondaryMuscles: [BodyPart.triceps],
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
    name: 'Barbell Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Genoux légèrement fléchis, buste penché vers l’avant, dos plat.\n'
        '2. Prise paumes vers toi, un peu plus large que les épaules.\n'
        '3. Tire la barre vers le bas du ventre en serrant les omoplates.\n'
        '4. Redescends en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '5bc61b55-5623-4618-a35e-f8dc3469c2ab',
    name: 'Leg Press',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
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
    name: 'Bicep Curl (Dumbbell)',
    secondaryMuscles: [BodyPart.forearms],
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
    name: 'Tricep Pushdown (Cable)',
    secondaryMuscles: [],
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
    name: 'Pull-Up',
    secondaryMuscles: [BodyPart.biceps, BodyPart.forearms],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.reps,
    instructions:
        '1. Suspends-toi à la barre, paumes vers l’avant, prise un peu plus large que les épaules.\n'
        '2. Serre les omoplates et gaine les abdos.\n'
        '3. Tire jusqu’à passer le menton au-dessus de la barre.\n'
        '4. Redescends en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: 'a6a15280-2533-4e58-9161-ba084762cae2',
    name: 'Plank',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.duration,
    instructions:
        '1. En appui sur les avant-bras et la pointe des pieds, coudes sous les épaules.\n'
        '2. Corps aligné de la tête aux talons : ni fesses en l’air, ni dos creusé.\n'
        '3. Contracte abdos et fessiers, respire normalement.\n'
        '4. Tiens la position pendant la durée voulue.',
  ),
  (
    id: '38ddc93c-6f92-455b-b95e-5691c1795135',
    name: 'Bench Press (Dumbbell)',
    secondaryMuscles: [BodyPart.triceps, BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le banc, un haltère dans chaque main au niveau de la poitrine.\n'
        '2. Serre les omoplates, pieds à plat au sol.\n'
        '3. Pousse les haltères à la verticale, sans les entrechoquer.\n'
        '4. Redescends en contrôle jusqu’à sentir l’étirement des pectoraux.',
  ),
  (
    id: '73749ee2-e236-4518-9b61-cb40ec2a43de',
    name: 'Incline Bench Press (Barbell)',
    secondaryMuscles: [BodyPart.triceps, BodyPart.shoulders],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Banc incliné à 30-45°, prise un peu plus large que les épaules.\n'
        '2. Descends la barre en contrôle jusqu’au haut des pectoraux.\n'
        '3. Pousse jusqu’à tendre les bras, sans verrouiller les coudes.\n'
        '4. Garde les omoplates serrées tout au long du mouvement.',
  ),
  (
    id: '098dda1c-fc74-4fdb-a642-ba7ea248ec5f',
    name: 'Incline Bench Press (Dumbbell)',
    secondaryMuscles: [BodyPart.triceps, BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Banc incliné à 30-45°, un haltère dans chaque main.\n'
        '2. Descends les haltères de chaque côté de la poitrine.\n'
        '3. Pousse à la verticale en contractant les pectoraux.\n'
        '4. Redescends lentement jusqu’à l’étirement.',
  ),
  (
    id: '47583cc9-fca6-419e-b35e-fff36173a232',
    name: 'Chest Fly (Dumbbell)',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le banc, haltères tendus au-dessus de la poitrine, légère flexion des coudes.\n'
        '2. Ouvre les bras en arc de cercle jusqu’à sentir l’étirement des pectoraux.\n'
        '3. Remonte les haltères en refermant les bras, comme pour enlacer un arbre.\n'
        '4. Garde les coudes légèrement fléchis tout du long.',
  ),
  (
    id: '245bdee8-147f-4d37-94cc-e181332b7ad1',
    name: 'Cable Fly',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.cable,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout entre deux poulies hautes, une poignée dans chaque main.\n'
        '2. Buste légèrement penché en avant, bras tendus sur les côtés.\n'
        '3. Ramène les mains devant toi en arc de cercle jusqu’à hauteur de poitrine.\n'
        '4. Reviens en contrôle jusqu’à l’étirement.',
  ),
  (
    id: '8c41cbe2-1578-43dd-86df-6564ca27b38a',
    name: 'Pec Deck (Machine)',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.machine,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, dos plaqué au dossier, avant-bras contre les appuis.\n'
        '2. Ramène les bras l’un vers l’autre devant la poitrine.\n'
        '3. Contracte une seconde en position fermée.\n'
        '4. Reviens en contrôle jusqu’à l’étirement, sans à-coup.',
  ),
  (
    id: '6fe95f09-8d9c-4d5d-947b-45c764b20235',
    name: 'Push-Up',
    secondaryMuscles: [BodyPart.triceps, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Mains au sol un peu plus larges que les épaules, corps aligné.\n'
        '2. Gaine les abdos et les fessiers.\n'
        '3. Descends jusqu’à effleurer le sol avec la poitrine.\n'
        '4. Pousse jusqu’à tendre les bras, sans casser l’alignement du dos.',
  ),
  (
    id: '5190e591-346d-4944-85aa-1204579521d0',
    name: 'Chest Dip',
    secondaryMuscles: [BodyPart.triceps, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. En appui sur des barres parallèles, buste penché en avant.\n'
        '2. Descends en fléchissant les coudes, jusqu’à sentir l’étirement des pectoraux.\n'
        '3. Pousse jusqu’à tendre les bras.\n'
        '4. Garde le buste incliné pour cibler les pectoraux plutôt que les triceps.',
  ),
  (
    id: 'f60801a4-8ec9-47bb-83ff-bbf9666388b7',
    name: 'Shrug (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.trapezius,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main, bras le long du corps.\n'
        '2. Monte les épaules vers les oreilles, sans fléchir les coudes.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à l’étirement.',
  ),
  (
    id: '7ab07103-9606-4546-a5bb-64f177a69d9d',
    name: 'Shrug (Barbell)',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.trapezius,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue devant les cuisses, prise un peu plus large que les épaules.\n'
        '2. Monte les épaules vers les oreilles, sans fléchir les coudes.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: '03d4a6fc-2db5-4dc5-8d44-a2a259a69adb',
    name: 'Upright Row (Barbell)',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.biceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.trapezius,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue devant les cuisses, prise resserrée.\n'
        '2. Tire la barre à la verticale, coudes hauts, jusqu’au menton.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '75458925-1deb-4d8f-9e4d-acc867a239c3',
    name: 'Face Pull (Cable)',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.cable,
    bodyPart: BodyPart.trapezius,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Poulie haute avec corde, prise en marteau.\n'
        '2. Tire la corde vers le visage en écartant les mains.\n'
        '3. Serre les omoplates en fin de mouvement.\n'
        '4. Reviens en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '34f65d65-43f7-4514-bbca-53564d21598c',
    name: 'Lat Pulldown (Cable)',
    secondaryMuscles: [BodyPart.biceps],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie haute, cuisses bloquées, prise large.\n'
        '2. Tire la barre vers le haut de la poitrine en serrant les omoplates.\n'
        '3. Marque un temps d’arrêt en bas.\n'
        '4. Remonte en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '5179741d-05aa-4990-ad16-9665a20dbd92',
    name: 'One-Arm Dumbbell Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un genou et une main en appui sur un banc, dos plat.\n'
        '2. Tire l’haltère vers la hanche en serrant l’omoplate.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à tendre le bras.',
  ),
  (
    id: '79eccf4c-fc23-49ab-b784-89751a22fd73',
    name: 'Seated Cable Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie basse, genoux légèrement fléchis, dos plat.\n'
        '2. Tire la poignée vers le ventre en serrant les omoplates.\n'
        '3. Marque un temps d’arrêt, coudes proches du corps.\n'
        '4. Reviens en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '301363f4-72bb-444e-8d4f-d8b88d6335b5',
    name: 'Chest-Supported Row (Machine)',
    secondaryMuscles: [BodyPart.biceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, poitrine contre l’appui, prise large.\n'
        '2. Tire les poignées vers toi en serrant les omoplates.\n'
        '3. Marque un temps d’arrêt.\n'
        '4. Reviens en contrôle jusqu’à l’étirement.',
  ),
  (
    id: 'a24f7342-c801-4117-b4b3-6ade8e74c56f',
    name: 'Dumbbell Pullover',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé en travers d’un banc, un haltère tenu à deux mains au-dessus de la poitrine.\n'
        '2. Descends l’haltère en arrière de la tête, bras presque tendus.\n'
        '3. Ramène l’haltère au-dessus de la poitrine en contractant le dos.\n'
        '4. Respire profondément à chaque répétition.',
  ),
  (
    id: '13f28c0f-077c-4fa9-84d8-30d648df14d3',
    name: 'T-Bar Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, barre entre les jambes, prise en V.\n'
        '2. Tire la barre vers le buste en serrant les omoplates.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à tendre les bras.',
  ),
  (
    id: '9a30a91e-15af-47f4-ad8f-85e319946015',
    name: 'Good Morning (Barbell)',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.glutes],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, comme pour un squat, genoux légèrement fléchis.\n'
        '2. Penche le buste vers l’avant en poussant les hanches en arrière, dos plat.\n'
        '3. Descends jusqu’à sentir l’étirement des ischios.\n'
        '4. Remonte en poussant les hanches vers l’avant.',
  ),
  (
    id: '6740a133-6c05-41ed-8127-8f1f6164c9e5',
    name: 'Back Extension',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.reps,
    instructions:
        '1. Sur un banc à lombaires, bassin en appui, buste plié vers le sol.\n'
        '2. Gaine les abdos et remonte le buste jusqu’à l’aligner avec les jambes.\n'
        '3. Contracte les lombaires et les fessiers en haut.\n'
        '4. Redescends en contrôle sans cambrer excessivement.',
  ),
  (
    id: '7bb3b65e-5521-4984-9c86-2febbf926946',
    name: 'Superman',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé face contre le sol, bras tendus devant toi.\n'
        '2. Soulève bras et jambes en même temps, en contractant les lombaires.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: 'f2a5e95c-2e81-412e-a09b-195be6a0187e',
    name: 'Overhead Press (Dumbbell)',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis ou debout, un haltère dans chaque main à hauteur d’épaules.\n'
        '2. Gaine les abdos et pousse les haltères à la verticale.\n'
        '3. Rapproche légèrement les haltères en haut, sans les cogner.\n'
        '4. Redescends en contrôle jusqu’à hauteur d’épaules.',
  ),
  (
    id: '89338203-11f8-4b91-9679-ceb8b8007859',
    name: 'Arnold Press',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, haltères devant les épaules, paumes tournées vers toi.\n'
        '2. Pousse les haltères vers le haut en tournant les poignets, paumes vers l’avant en fin de mouvement.\n'
        '3. Redescends en effectuant la rotation inverse.\n'
        '4. Garde le mouvement fluide, sans à-coup.',
  ),
  (
    id: '9a930805-d3a8-4ec7-8bd7-e56d102526f6',
    name: 'Lateral Raise (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main le long du corps.\n'
        '2. Lève les bras sur les côtés jusqu’à hauteur d’épaules, légère flexion des coudes.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle sans balancer le buste.',
  ),
  (
    id: 'a4557387-0d8b-4bcf-a076-073f5bd0fa42',
    name: 'Lateral Raise (Cable)',
    secondaryMuscles: [],
    equipment: Equipment.cable,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout à côté d’une poulie basse, poignée dans la main éloignée.\n'
        '2. Lève le bras sur le côté jusqu’à hauteur d’épaule.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: 'b9a7bb05-91e6-4d93-a091-8ed7f960ef2b',
    name: 'Rear Delt Fly (Dumbbell)',
    secondaryMuscles: [BodyPart.trapezius],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, un haltère dans chaque main, bras presque tendus.\n'
        '2. Lève les bras sur les côtés en serrant les omoplates.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à l’étirement.',
  ),
  (
    id: '180bde98-3580-4f1b-9590-6d3da06a3545',
    name: 'Front Raise (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main devant les cuisses.\n'
        '2. Lève un bras tendu devant toi jusqu’à hauteur d’épaule.\n'
        '3. Redescends en contrôle et alterne les bras.\n'
        '4. Garde le buste immobile, sans élan.',
  ),
  (
    id: 'edb104a5-69ae-4d91-b9a6-e75301c69d9e',
    name: 'Shoulder Press (Machine)',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, dos calé contre le dossier, poignées à hauteur d’épaules.\n'
        '2. Pousse les poignées vers le haut, sans verrouiller les coudes.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: '958cebc1-cc66-46a3-8953-e5165f3aab3b',
    name: 'Bicep Curl (Barbell)',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue à deux mains, bras le long du corps.\n'
        '2. Garde les coudes fixes contre le buste.\n'
        '3. Monte la barre en fléchissant les coudes.\n'
        '4. Redescends lentement jusqu’à tendre les bras.',
  ),
  (
    id: '43fda7d6-f669-4451-b8b8-c35ad7f78de2',
    name: 'Hammer Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main, paumes face à face.\n'
        '2. Garde les coudes fixes contre le buste.\n'
        '3. Monte les haltères sans tourner les poignets.\n'
        '4. Redescends lentement jusqu’à tendre les bras.',
  ),
  (
    id: '623e03b7-0c53-4fc0-8a24-ca8f540d2024',
    name: 'Preacher Curl (Barbell)',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, bras posés sur le pupitre incliné, barre tenue en prise supination.\n'
        '2. Monte la barre en fléchissant les coudes.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends lentement jusqu’à tendre les bras.',
  ),
  (
    id: '5c1a1069-dcce-4766-bf32-9ea9b41364ad',
    name: 'Concentration Curl',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, coude calé contre l’intérieur de la cuisse, haltère en main.\n'
        '2. Monte l’haltère en fléchissant le coude, sans bouger l’épaule.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends lentement jusqu’à tendre le bras.',
  ),
  (
    id: '92727fe7-e5ff-45c1-b78b-49167e10f597',
    name: 'Cable Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.cable,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout face à la poulie basse, barre ou poignée en main.\n'
        '2. Garde les coudes fixes contre le buste.\n'
        '3. Monte la poignée en fléchissant les coudes.\n'
        '4. Redescends lentement jusqu’à tendre les bras.',
  ),
  (
    id: 'f198852a-9922-4172-b96d-5788dbce93b0',
    name: 'Close-Grip Bench Press',
    secondaryMuscles: [BodyPart.chest, BodyPart.shoulders],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le banc, prise resserrée (largeur d’épaules).\n'
        '2. Descends la barre en contrôle jusqu’au bas de la poitrine, coudes proches du corps.\n'
        '3. Pousse jusqu’à tendre les bras.\n'
        '4. Garde les coudes serrés tout au long du mouvement.',
  ),
  (
    id: '5871b2cb-cb62-4433-af1d-69da2e1d3c4d',
    name: 'Tricep Dip',
    secondaryMuscles: [BodyPart.chest, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.reps,
    instructions:
        '1. En appui sur des barres parallèles, buste bien droit.\n'
        '2. Descends en fléchissant les coudes, sans trop pencher le buste.\n'
        '3. Pousse jusqu’à tendre les bras.\n'
        '4. Garde les coudes proches du corps pour cibler les triceps.',
  ),
  (
    id: '0eb0d8dd-a111-4723-829d-898eb7510e07',
    name: 'Overhead Tricep Extension (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis ou debout, un haltère tenu à deux mains derrière la tête.\n'
        '2. Garde les coudes fixes, pointés vers le plafond.\n'
        '3. Tends les bras vers le haut.\n'
        '4. Redescends lentement jusqu’à l’étirement.',
  ),
  (
    id: 'dfe7d960-2a1d-46d4-b776-06753ca4742d',
    name: 'Skull Crusher (Barbell)',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le banc, barre tenue à bout de bras au-dessus du front.\n'
        '2. Descends la barre vers le front en fléchissant seulement les coudes.\n'
        '3. Tends les bras jusqu’en haut.\n'
        '4. Garde les coudes fixes, sans les écarter.',
  ),
  (
    id: 'dfea8e4c-893a-4cb5-8169-b2c760909197',
    name: 'Tricep Kickback',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, bras collé au corps, coude fléchi à 90°.\n'
        '2. Tends le bras vers l’arrière, sans bouger l’épaule.\n'
        '3. Marque un temps d’arrêt en position tendue.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: '2a3695a8-e321-41e8-b813-8d670d4e6d9a',
    name: 'Wrist Curl (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, paumes vers le haut, haltères en main.\n'
        '2. Laisse les haltères rouler vers les doigts.\n'
        '3. Remonte en fléchissant les poignets.\n'
        '4. Répète sans bouger les avant-bras.',
  ),
  (
    id: '29340dd4-9001-41af-9487-497cc9d509ea',
    name: 'Reverse Wrist Curl (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, paumes vers le bas, haltères en main.\n'
        '2. Laisse les haltères descendre en étirant les poignets.\n'
        '3. Remonte en fléchissant les poignets vers le haut.\n'
        '4. Répète sans bouger les avant-bras.',
  ),
  (
    id: '0799de68-e598-417c-94b5-6337886ff79e',
    name: 'Reverse Curl (Barbell)',
    secondaryMuscles: [BodyPart.biceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue en prise pronation (paumes vers le bas).\n'
        '2. Garde les coudes fixes contre le buste.\n'
        '3. Monte la barre en fléchissant les coudes.\n'
        '4. Redescends lentement jusqu’à tendre les bras.',
  ),
  (
    id: 'af9a04b8-51ea-4471-9ac6-b4dcace7374b',
    name: 'Dead Hang',
    secondaryMuscles: [BodyPart.lats],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.duration,
    instructions:
        '1. Suspends-toi à une barre fixe, bras tendus.\n'
        '2. Serre fort la barre et gaine les abdos.\n'
        '3. Tiens la position le plus longtemps possible.\n'
        '4. Redescends en contrôle à la fin.',
  ),
  (
    id: 'dacaab3c-a348-42ac-a10d-3af05c04217e',
    name: 'Crunch',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, genoux fléchis, mains derrière la tête.\n'
        '2. Décolle les épaules du sol en contractant les abdos.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle sans reposer complètement la tête.',
  ),
  (
    id: '668d3ce5-cd09-489c-9d08-9a8c5a9b4624',
    name: 'Hanging Leg Raise',
    secondaryMuscles: [BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Suspendu à une barre fixe, jambes tendues.\n'
        '2. Relève les jambes devant toi en contractant les abdos.\n'
        '3. Monte le plus haut possible sans balancer le corps.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: '2ac9d721-8efa-49b3-9515-e801adeb2d32',
    name: 'Cable Crunch',
    secondaryMuscles: [],
    equipment: Equipment.cable,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Agenouillé face à la poulie haute, corde tenue près du visage.\n'
        '2. Enroule le buste vers le bas en contractant les abdos.\n'
        '3. Marque un temps d’arrêt en position basse.\n'
        '4. Reviens en contrôle sans tirer avec les bras.',
  ),
  (
    id: '00b3ba27-4c08-4434-9872-5c417020fc47',
    name: 'Ab Wheel Rollout',
    secondaryMuscles: [BodyPart.lats, BodyPart.shoulders],
    equipment: Equipment.other,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. À genoux, roue abdominale tenue à deux mains devant toi.\n'
        '2. Fais rouler la roue vers l’avant en gardant le dos droit.\n'
        '3. Va aussi loin que possible sans creuser le dos.\n'
        '4. Reviens en position de départ en contractant les abdos.',
  ),
  (
    id: 'd950f88f-43aa-42a5-bb72-5f1e0ae6818d',
    name: 'Reverse Crunch',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, jambes tendues vers le plafond.\n'
        '2. Décolle le bassin du sol en contractant le bas des abdos.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle sans balancer les jambes.',
  ),
  (
    id: 'c0c14625-bb5f-429f-9991-65163766915f',
    name: 'Cable Woodchop',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.cable,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, poulie haute réglée sur le côté, poignée tenue à deux mains.\n'
        '2. Fais pivoter le buste en diagonale vers le bas opposé, hanches fixes.\n'
        '3. Reviens en contrôle jusqu’à la position de départ.\n'
        '4. Termine toutes les répétitions d’un côté avant de changer.',
  ),
  (
    id: 'e18ff616-b6a3-4144-ba8d-160abf2c9702',
    name: 'Side Plank',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le côté, en appui sur l’avant-bras et le bord du pied.\n'
        '2. Soulève les hanches pour aligner le corps de la tête aux pieds.\n'
        '3. Gaine les abdos et tiens la position.\n'
        '4. Change de côté à la fin du temps prévu.',
  ),
  (
    id: '213996e0-9cd0-4331-a00d-af603fed5ba4',
    name: 'Oblique Crunch',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, genoux fléchis, mains derrière la tête.\n'
        '2. Enroule le buste en amenant un coude vers le genou opposé.\n'
        '3. Redescends en contrôle.\n'
        '4. Alterne les côtés à chaque répétition.',
  ),
  (
    id: 'dd431227-4976-4d15-99bd-3b4761f72d42',
    name: 'Side Bend (Dumbbell)',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans une main, l’autre derrière la tête.\n'
        '2. Penche le buste sur le côté de l’haltère, sans tourner le buste.\n'
        '3. Remonte en contractant les obliques du côté opposé.\n'
        '4. Termine toutes les répétitions d’un côté avant de changer.',
  ),
  (
    id: '7ed2d047-670c-4504-bf79-2af4410294fe',
    name: 'Lunge (Dumbbell)',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main, buste droit.\n'
        '2. Fais un grand pas en avant et descends jusqu’à ce que le genou arrière frôle le sol.\n'
        '3. Pousse sur la jambe avant pour revenir à la position de départ.\n'
        '4. Alterne les jambes à chaque répétition.',
  ),
  (
    id: 'faa9e60c-fb50-4a03-9f6c-2b23a39e4c93',
    name: 'Leg Extension',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, dos calé contre le dossier, tibias sous le rouleau.\n'
        '2. Tends les jambes vers l’avant.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle sans lâcher la charge.',
  ),
  (
    id: '161c2e50-cdca-40db-93fc-46d382ad07d5',
    name: 'Goblet Squat',
    secondaryMuscles: [BodyPart.glutes, BodyPart.adductors],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, kettlebell tenue à deux mains contre la poitrine.\n'
        '2. Descends en squat, genoux vers l’extérieur, dos droit.\n'
        '3. Descends jusqu’à ce que les cuisses soient parallèles au sol.\n'
        '4. Remonte en poussant dans les talons.',
  ),
  (
    id: '1c1f27ab-1bc0-4cca-a2bb-efcbdb90210c',
    name: 'Bulgarian Split Squat',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, pied arrière posé sur un banc, un haltère dans chaque main.\n'
        '2. Descends en fléchissant le genou avant, jusqu’à ce que la cuisse arrière frôle le sol.\n'
        '3. Remonte en poussant dans le talon avant.\n'
        '4. Termine toutes les répétitions d’une jambe avant de changer.',
  ),
  (
    id: 'b2fc25d3-6822-440c-bb4a-27ee6451b09f',
    name: 'Hack Squat',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.machine,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos et épaules calés contre les appuis, pieds à plat sur la plateforme.\n'
        '2. Déverrouille la charge et fléchis les genoux.\n'
        '3. Descends jusqu’à un angle confortable, sans décoller les talons.\n'
        '4. Pousse jusqu’à tendre les jambes, sans verrouiller les genoux.',
  ),
  (
    id: 'f0ad8526-d436-4e42-a091-2f83435d8298',
    name: 'Walking Lunge',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main, buste droit.\n'
        '2. Avance d’un grand pas et descends jusqu’à ce que le genou arrière frôle le sol.\n'
        '3. Pousse pour te redresser et avance l’autre jambe.\n'
        '4. Continue d’avancer à chaque répétition.',
  ),
  (
    id: 'aa2b9ace-e01b-4e50-b42f-9e1cf9c11ae8',
    name: 'Hip Adductor (Machine)',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, jambes écartées contre les appuis de la machine.\n'
        '2. Ramène les jambes l’une vers l’autre.\n'
        '3. Marque un temps d’arrêt en position fermée.\n'
        '4. Reviens en contrôle jusqu’à l’étirement.',
  ),
  (
    id: '923831df-b011-48a2-bceb-76c43352ec6e',
    name: 'Sumo Squat',
    secondaryMuscles: [BodyPart.quads, BodyPart.glutes],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds bien plus larges que les épaules, pointes ouvertes, haltère tenu à deux mains.\n'
        '2. Descends en squat en poussant les genoux vers l’extérieur.\n'
        '3. Descends jusqu’à ce que les cuisses soient parallèles au sol.\n'
        '4. Remonte en poussant dans les talons.',
  ),
  (
    id: '65579ec3-9c6b-4ea6-9095-6f6f046b6991',
    name: 'Lateral Lunge',
    secondaryMuscles: [BodyPart.quads, BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, pieds joints, mains devant la poitrine.\n'
        '2. Fais un grand pas sur le côté et fléchis ce genou, l’autre jambe restant tendue.\n'
        '3. Pousse pour revenir à la position de départ.\n'
        '4. Alterne les côtés à chaque répétition.',
  ),
  (
    id: '15e96124-a809-4909-b4e3-fb2c35d95ee7',
    name: 'Lying Leg Curl',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre la machine, chevilles sous le rouleau.\n'
        '2. Fléchis les genoux pour amener les talons vers les fessiers.\n'
        '3. Marque un temps d’arrêt en position fléchie.\n'
        '4. Redescends en contrôle sans lâcher la charge.',
  ),
  (
    id: 'c5a032a7-1202-4a42-b798-59cd894e4f4d',
    name: 'Seated Leg Curl',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, dos calé contre le dossier, chevilles contre le rouleau.\n'
        '2. Fléchis les genoux pour amener les talons vers le siège.\n'
        '3. Marque un temps d’arrêt en position fléchie.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: 'c9488234-a6f9-4608-b44d-efba7e0fa00f',
    name: 'Stiff-Leg Deadlift',
    secondaryMuscles: [BodyPart.glutes, BodyPart.lowerBack],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue devant les cuisses, jambes presque tendues.\n'
        '2. Descends la barre le long des jambes en poussant les hanches vers l’arrière, dos plat.\n'
        '3. Descends jusqu’à sentir l’étirement des ischios.\n'
        '4. Remonte en poussant les hanches vers l’avant.',
  ),
  (
    id: 'e4d19cd8-90dc-4f55-a2e8-f28fb0aad261',
    name: 'Nordic Curl',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.reps,
    instructions:
        '1. Agenouillé, chevilles bloquées par un partenaire ou un support.\n'
        '2. Penche le buste vers l’avant le plus lentement possible, jambes qui résistent.\n'
        '3. Utilise les mains pour amortir la descente si besoin.\n'
        '4. Remonte en contractant les ischios, en t’aidant des mains si besoin.',
  ),
  (
    id: '403f7bb2-9e0c-473c-aa45-520def47f63f',
    name: 'Hip Thrust (Barbell)',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos calé contre un banc, barre posée sur les hanches, pieds à plat au sol.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Marque un temps d’arrêt en haut, corps aligné des épaules aux genoux.\n'
        '4. Redescends en contrôle sans reposer le bassin.',
  ),
  (
    id: '2b07a0d8-e3c3-4ca7-8dde-d1cacda2ec86',
    name: 'Glute Bridge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, genoux fléchis, pieds à plat au sol.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle.',
  ),
  (
    id: '2860931c-d217-417d-bf03-47a66b2fc4c2',
    name: 'Cable Glute Kickback',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.cable,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie basse, sangle à la cheville, en appui sur l’autre jambe.\n'
        '2. Tends la jambe vers l’arrière en contractant le fessier.\n'
        '3. Marque un temps d’arrêt en position tendue.\n'
        '4. Reviens en contrôle sans balancer le buste.',
  ),
  (
    id: '4a7a6a75-bd4e-4634-bfb0-ce24c5d3076b',
    name: 'Hip Abduction (Machine)',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, jambes serrées contre les appuis de la machine.\n'
        '2. Écarte les jambes contre la résistance.\n'
        '3. Marque un temps d’arrêt en position ouverte.\n'
        '4. Reviens en contrôle.',
  ),
  (
    id: '6defcd07-d1d2-45ef-9aa6-5f3db12987ea',
    name: 'Step-Up (Dumbbell)',
    secondaryMuscles: [BodyPart.quads, BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout devant un banc ou une plateforme, un haltère dans chaque main.\n'
        '2. Monte sur le banc en poussant avec la jambe du dessus.\n'
        '3. Redescends en contrôle avec la même jambe.\n'
        '4. Termine toutes les répétitions d’une jambe avant de changer.',
  ),
  (
    id: '439a5a42-c4ed-4326-97ec-89ac5eade633',
    name: 'Standing Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sous les appuis de la machine, avant-pieds sur la plateforme.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à l’étirement.',
  ),
  (
    id: '0b702e73-365c-4e1b-914d-d24efd8e37ea',
    name: 'Seated Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, genoux sous les appuis, avant-pieds sur la plateforme.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à l’étirement.',
  ),
  (
    id: 'a010d43c-a711-4554-8adc-3e1b35e10da2',
    name: 'Leg Press Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la presse à cuisses, jambes tendues, avant-pieds sur la plateforme.\n'
        '2. Pousse la plateforme en pointant les pieds.\n'
        '3. Marque un temps d’arrêt en position tendue.\n'
        '4. Reviens en contrôle jusqu’à l’étirement.',
  ),
  (
    id: 'a886b5f2-b265-4f4f-89fb-b24e63e6848d',
    name: 'Single-Leg Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une marche, avant-pied en appui, haltère dans une main.\n'
        '2. Monte sur la pointe du pied le plus haut possible.\n'
        '3. Marque un temps d’arrêt en haut.\n'
        '4. Redescends en contrôle jusqu’à l’étirement, puis change de jambe.',
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
      secondaryMuscles: Value(e.secondaryMuscles),
      trackingType: e.trackingType,
      instructions: Value(e.instructions),
    ),
];

/// Consignes par identifiant d'exercice (migration v1 → v2).
Map<String, String> get builtInInstructions => {
  for (final e in _builtIns) e.id: e.instructions,
};

/// Muscles secondaires par identifiant d'exercice (migration v4 → v5), ceux
/// qui en ont au moins un.
Map<String, List<BodyPart>> get builtInSecondaryMuscles => {
  for (final e in _builtIns)
    if (e.secondaryMuscles.isNotEmpty) e.id: e.secondaryMuscles,
};

/// Groupe musculaire par identifiant d'exercice (migration v5 → v6, D20) :
/// sert à corriger les trois exercices intégrés qui utilisaient « Dos »
/// (Rowing, Tractions, Soulevé de terre), désormais plus précis.
Map<String, BodyPart> get builtInBodyParts => {
  for (final e in _builtIns) e.id: e.bodyPart,
};

const _addedInV7 = <String>{
  '38ddc93c-6f92-455b-b95e-5691c1795135',
  '73749ee2-e236-4518-9b61-cb40ec2a43de',
  '098dda1c-fc74-4fdb-a642-ba7ea248ec5f',
  '47583cc9-fca6-419e-b35e-fff36173a232',
  '245bdee8-147f-4d37-94cc-e181332b7ad1',
  '8c41cbe2-1578-43dd-86df-6564ca27b38a',
  '6fe95f09-8d9c-4d5d-947b-45c764b20235',
  '5190e591-346d-4944-85aa-1204579521d0',
  'f60801a4-8ec9-47bb-83ff-bbf9666388b7',
  '7ab07103-9606-4546-a5bb-64f177a69d9d',
  '03d4a6fc-2db5-4dc5-8d44-a2a259a69adb',
  '75458925-1deb-4d8f-9e4d-acc867a239c3',
  '34f65d65-43f7-4514-bbca-53564d21598c',
  '5179741d-05aa-4990-ad16-9665a20dbd92',
  '79eccf4c-fc23-49ab-b784-89751a22fd73',
  '301363f4-72bb-444e-8d4f-d8b88d6335b5',
  'a24f7342-c801-4117-b4b3-6ade8e74c56f',
  '13f28c0f-077c-4fa9-84d8-30d648df14d3',
  '9a30a91e-15af-47f4-ad8f-85e319946015',
  '6740a133-6c05-41ed-8127-8f1f6164c9e5',
  '7bb3b65e-5521-4984-9c86-2febbf926946',
  'f2a5e95c-2e81-412e-a09b-195be6a0187e',
  '89338203-11f8-4b91-9679-ceb8b8007859',
  '9a930805-d3a8-4ec7-8bd7-e56d102526f6',
  'a4557387-0d8b-4bcf-a076-073f5bd0fa42',
  'b9a7bb05-91e6-4d93-a091-8ed7f960ef2b',
  '180bde98-3580-4f1b-9590-6d3da06a3545',
  'edb104a5-69ae-4d91-b9a6-e75301c69d9e',
  '958cebc1-cc66-46a3-8953-e5165f3aab3b',
  '43fda7d6-f669-4451-b8b8-c35ad7f78de2',
  '623e03b7-0c53-4fc0-8a24-ca8f540d2024',
  '5c1a1069-dcce-4766-bf32-9ea9b41364ad',
  '92727fe7-e5ff-45c1-b78b-49167e10f597',
  'f198852a-9922-4172-b96d-5788dbce93b0',
  '5871b2cb-cb62-4433-af1d-69da2e1d3c4d',
  '0eb0d8dd-a111-4723-829d-898eb7510e07',
  'dfe7d960-2a1d-46d4-b776-06753ca4742d',
  'dfea8e4c-893a-4cb5-8169-b2c760909197',
  '2a3695a8-e321-41e8-b813-8d670d4e6d9a',
  '29340dd4-9001-41af-9487-497cc9d509ea',
  '0799de68-e598-417c-94b5-6337886ff79e',
  'af9a04b8-51ea-4471-9ac6-b4dcace7374b',
  'dacaab3c-a348-42ac-a10d-3af05c04217e',
  '668d3ce5-cd09-489c-9d08-9a8c5a9b4624',
  '2ac9d721-8efa-49b3-9515-e801adeb2d32',
  '00b3ba27-4c08-4434-9872-5c417020fc47',
  'd950f88f-43aa-42a5-bb72-5f1e0ae6818d',
  'c0c14625-bb5f-429f-9991-65163766915f',
  'e18ff616-b6a3-4144-ba8d-160abf2c9702',
  '213996e0-9cd0-4331-a00d-af603fed5ba4',
  'dd431227-4976-4d15-99bd-3b4761f72d42',
  '7ed2d047-670c-4504-bf79-2af4410294fe',
  'faa9e60c-fb50-4a03-9f6c-2b23a39e4c93',
  '161c2e50-cdca-40db-93fc-46d382ad07d5',
  '1c1f27ab-1bc0-4cca-a2bb-efcbdb90210c',
  'b2fc25d3-6822-440c-bb4a-27ee6451b09f',
  'f0ad8526-d436-4e42-a091-2f83435d8298',
  'aa2b9ace-e01b-4e50-b42f-9e1cf9c11ae8',
  '923831df-b011-48a2-bceb-76c43352ec6e',
  '65579ec3-9c6b-4ea6-9095-6f6f046b6991',
  '15e96124-a809-4909-b4e3-fb2c35d95ee7',
  'c5a032a7-1202-4a42-b798-59cd894e4f4d',
  'c9488234-a6f9-4608-b44d-efba7e0fa00f',
  'e4d19cd8-90dc-4f55-a2e8-f28fb0aad261',
  '403f7bb2-9e0c-473c-aa45-520def47f63f',
  '2b07a0d8-e3c3-4ca7-8dde-d1cacda2ec86',
  '2860931c-d217-417d-bf03-47a66b2fc4c2',
  '4a7a6a75-bd4e-4634-bfb0-ce24c5d3076b',
  '6defcd07-d1d2-45ef-9aa6-5f3db12987ea',
  '439a5a42-c4ed-4326-97ec-89ac5eade633',
  '0b702e73-365c-4e1b-914d-d24efd8e37ea',
  'a010d43c-a711-4554-8adc-3e1b35e10da2',
  'a886b5f2-b265-4f4f-89fb-b24e63e6848d',
};

/// Nouveaux exercices intégrés (migration v6 → v7, D21) : ils comblent les
/// groupes musculaires qui n'avaient encore aucun exercice principal.
List<ExercisesCompanion> get builtInExercisesAddedInV7 => [
  for (final e in _builtIns)
    if (_addedInV7.contains(e.id))
      ExercisesCompanion.insert(
        id: Value(e.id),
        name: e.name,
        nameNormalized: normalizeForSearch(e.name),
        equipment: e.equipment,
        bodyPart: e.bodyPart,
        secondaryMuscles: Value(e.secondaryMuscles),
        trackingType: e.trackingType,
        instructions: Value(e.instructions),
      ),
];

/// Nom par identifiant d'exercice (migration v7 → v8, D22) : les noms des
/// exercices intégrés sont ceux utilisés en salle, en anglais, plutôt qu'une
/// traduction française.
Map<String, String> get builtInNames => {
  for (final e in _builtIns) e.id: e.name,
};
