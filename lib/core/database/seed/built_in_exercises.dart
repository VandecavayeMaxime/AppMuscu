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
    trackingType: TrackingType.weightReps,
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
    bodyPart: BodyPart.trapeziusUpper,
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
    bodyPart: BodyPart.trapeziusUpper,
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
    bodyPart: BodyPart.trapeziusUpper,
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
    bodyPart: BodyPart.trapeziusLower,
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
    secondaryMuscles: [BodyPart.trapeziusLower],
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
    trackingType: TrackingType.weightReps,
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
  (
    id: '2a79d1bd-c3b5-4628-8a5b-ddeace90fc13',
    name: 'Air Bike',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis sur le vélo, dossier réglé, pieds sur les pédales.\n'
        '2. Pédale à intensité soutenue en poussant avec les jambes et en tirant avec les bras sur le guidon mobile.\n'
        '3. Garde un rythme régulier pendant la durée prévue.',
  ),
  (
    id: '55bcf59a-8db9-458d-82de-c5311ab9e540',
    name: 'Archer Pull Ups',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.forearms,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre en prise large.\n'
        '2. Tire-toi d\'un côté en tendant l\'autre bras latéralement.\n'
        '3. Redescends en contrôle et alterne les côtés.',
  ),
  (
    id: '105db7bb-9081-41c7-b1fa-dbeb4a8f6d8e',
    name: 'Archer Push Ups',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.abs, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains bien écartées.\n'
        '2. Descends d\'un côté en tendant l\'autre bras sur le côté.\n'
        '3. Repousse et alterne les côtés.',
  ),
  (
    id: '794b5675-7a1b-493b-b887-00e1a6314e28',
    name: 'Machine Assisted Dips',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.trapeziusUpper],
    equipment: Equipment.machine,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Règle le contrepoids de la machine à dips.\n'
        '2. Monte sur les plateformes, bras tendus.\n'
        '3. Descends en pliant les coudes jusqu\'à 90°, puis remonte.',
  ),
  (
    id: '703db9b6-438a-49a5-959e-4c601ca562af',
    name: 'Assisted Pull Ups',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.forearms,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.machine,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Règle le contrepoids de la machine.\n'
        '2. Agrippe la barre, genoux sur le coussin.\n'
        '3. Tire-toi jusqu\'au menton au-dessus de la barre, puis redescends.',
  ),
  (
    id: 'c933a066-df8f-4161-89be-acaaed331864',
    name: 'Back Lever',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.glutes, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, prise en pronation.\n'
        '2. Bascule le corps à l\'horizontale, dos vers le sol, en gainant tout le corps.\n'
        '3. Tiens la position, puis reviens en contrôle.',
  ),
  (
    id: '611359a0-989a-4441-8002-8afe7dfcb074',
    name: 'Stability Ball Leg Curl',
    secondaryMuscles: [BodyPart.calves, BodyPart.glutes],
    equipment: Equipment.other,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allonge-toi au sol, talons posés sur un swiss ball.\n'
        '2. Soulève les hanches et roule le ballon vers les fesses en pliant les genoux.\n'
        '3. Étends les jambes pour revenir, sans lâcher les hanches.',
  ),
  (
    id: '77ada746-1af8-444d-9cf6-4a7d566740ff',
    name: 'Ball Pike',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.quads, BodyPart.chest],
    equipment: Equipment.other,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Position de planche, tibias posés sur un swiss ball.\n'
        '2. Roule le ballon vers les mains en levant les hanches, jambes tendues.\n'
        '3. Reviens en position de planche en contrôle.',
  ),
  (
    id: 'd0ca37e6-d409-475a-943a-2def9a83033b',
    name: 'Band Assisted Pull Ups',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.forearms,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.band,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Fixe un élastique en haut de la barre, passe un genou ou un pied dedans.\n'
        '2. Tire-toi jusqu\'au menton au-dessus de la barre.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '23b06c18-563a-4524-a856-951442e370d4',
    name: 'Band Pull Apart',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.band,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Tiens un élastique à deux mains, bras tendus devant toi.\n'
        '2. Écarte les bras pour étirer l\'élastique jusqu\'à la poitrine.\n'
        '3. Reviens en contrôle sans le relâcher complètement.',
  ),
  (
    id: '423707f1-ed08-41c2-b869-6a652ae570f7',
    name: 'Banded Clamshell',
    secondaryMuscles: [],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allonge-toi sur le côté, élastique autour des cuisses, genoux pliés.\n'
        '2. Ouvre le genou du dessus en gardant les pieds joints.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'f2d7addf-7592-4b86-994a-877a31d8aded',
    name: 'Banded Fire Hydrant',
    secondaryMuscles: [],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. À quatre pattes, élastique au-dessus des genoux.\n'
        '2. Lève un genou sur le côté à hauteur de hanche, jambe pliée.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '0535ecbb-802e-4116-b633-5d8e6f63b8f0',
    name: 'Banded Glute Bridge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allonge-toi sur le dos, élastique au-dessus des genoux, pieds à plat.\n'
        '2. Pousse les hanches vers le haut en écartant légèrement les genoux contre l\'élastique.\n'
        '3. Redescends sans reposer les fesses au sol.',
  ),
  (
    id: 'e59833c9-bf4c-4f7c-881d-05af04efe489',
    name: 'Banded Good Morning',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur l\'élastique, l\'autre extrémité derrière la nuque.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '97809c17-a63c-4cbb-a30f-c73eff146608',
    name: 'Banded Hip Thrust',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos appuyé contre un banc, élastique au-dessus des genoux, pieds à plat.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'aa650871-168f-4366-bc00-ccb97fd62160',
    name: 'Banded Kneeling Hip Thrust',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. À genoux, élastique au-dessus des genoux, buste incliné en avant.\n'
        '2. Pousse les hanches vers l\'avant en contractant les fessiers.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '185cc545-f9ac-4843-9634-009567667baa',
    name: 'Banded Lateral Walk',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique au-dessus des genoux ou des chevilles, légèrement fléchi sur les jambes.\n'
        '2. Fais des pas latéraux en gardant la tension dans l\'élastique.\n'
        '3. Répète dans l\'autre sens.',
  ),
  (
    id: 'ee0c19bf-ebdc-410b-85fc-2f113fe4fa43',
    name: 'Banded Romanian Deadlift',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur l\'élastique, pieds largeur de hanches.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat, jambes presque tendues.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: 'd867f7be-4255-4515-8681-45da58b60544',
    name: 'Banded Seated Hip Abduction',
    secondaryMuscles: [],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, élastique au-dessus des genoux, pieds à plat.\n'
        '2. Écarte les genoux contre la résistance.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '3e977114-10bc-449e-bbf1-57eaa4d80d38',
    name: 'Banded Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique au-dessus des genoux ou sous les pieds et sur les épaules.\n'
        '2. Descends en squat, genoux poussés vers l\'extérieur.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'ebd16805-ac3c-48f9-9e89-e6d610e31e60',
    name: 'Banded Standing Leg Curl',
    secondaryMuscles: [BodyPart.calves],
    equipment: Equipment.band,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique fixé bas, attaché à une cheville.\n'
        '2. Plie le genou pour amener le talon vers la fesse.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '46385882-42da-4dc1-9d18-bc261a9a5b7d',
    name: 'Banded Standing Hip Abduction',
    secondaryMuscles: [],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique fixé bas, attaché à une cheville, debout de profil.\n'
        '2. Écarte la jambe sur le côté contre la résistance.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'e238e8c5-5ae7-410c-abb3-c5f828c0084f',
    name: 'Banded Standing Hip Adduction',
    secondaryMuscles: [],
    equipment: Equipment.band,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique fixé bas, attaché à une cheville, debout de profil.\n'
        '2. Ramène la jambe vers l\'intérieur contre la résistance.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '235c8187-5aa5-4d6d-a7dd-7efb9bbb3c32',
    name: 'Banded Sumo Walk',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.band,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique au-dessus des chevilles, jambes fléchies, pieds larges.\n'
        '2. Fais des pas latéraux en gardant les genoux poussés vers l\'extérieur.\n'
        '3. Répète dans l\'autre sens.',
  ),
  (
    id: '5e084351-37a2-46df-b976-5a6bfb2cb90b',
    name: 'Banded Terminal Knee Extension',
    secondaryMuscles: [],
    equipment: Equipment.band,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Élastique fixé derrière toi, à hauteur de genou.\n'
        '2. Genou légèrement fléchi, tends la jambe en poussant le genou vers l\'arrière.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'ddd71953-ed83-4765-8e6f-e9990aa95ec9',
    name: 'Barbell Ab Rollout',
    secondaryMuscles: [BodyPart.lats, BodyPart.obliques],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. À genoux, barre chargée de petits disques devant toi.\n'
        '2. Roule la barre vers l\'avant en gainant les abdos, corps qui s\'étend.\n'
        '3. Ramène la barre vers les genoux en contractant les abdos.',
  ),
  (
    id: '8cd2cf23-fa67-4d32-bbf6-82535e547690',
    name: 'Barbell Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, debout, pointes de pied sur une surélévation si possible.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: '9290f2aa-6d82-4832-a63f-8b3fcb8001bd',
    name: 'Barbell Front Raise',
    secondaryMuscles: [BodyPart.chest],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue devant les cuisses, prise pronation.\n'
        '2. Lève la barre tendue devant toi jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'e94ef660-0038-44ac-8159-51def07a06e8',
    name: 'Barbell Glute Bridge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allonge-toi, barre posée sur les hanches (protégée), genoux pliés.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b7e2465e-6436-486f-81fa-6196d69886ba',
    name: 'Barbell Lunge',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, debout.\n'
        '2. Fais un grand pas en avant et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: 'bfd8ef44-9b4a-43ac-ab0a-61de2eec9e72',
    name: 'Barbell Overhead Extension',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout ou assis, barre tenue à bout de bras au-dessus de la tête.\n'
        '2. Descends la barre derrière la tête en pliant les coudes.\n'
        '3. Retends les bras vers le haut.',
  ),
  (
    id: '57c58244-2315-4603-a408-3fc979636b86',
    name: 'Barbell Pullover',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre tenue à bout de bras au-dessus de la poitrine.\n'
        '2. Descends la barre derrière la tête en gardant les bras presque tendus.\n'
        '3. Remonte la barre au-dessus de la poitrine.',
  ),
  (
    id: 'f578ac63-1318-4cc9-9b1f-6af6e3ae1996',
    name: 'Barbell Rear Delt Row',
    secondaryMuscles: [BodyPart.lats, BodyPart.trapeziusUpper],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, barre tenue bras tendus.\n'
        '2. Tire la barre vers le haut du ventre en écartant les coudes.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '56674d24-6938-4ce7-bea4-8cb14559a1b5',
    name: 'Barbell Reverse Lunge',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, debout.\n'
        '2. Fais un grand pas en arrière et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: 'a2afbca0-2286-4a35-8cd6-d971becf00a3',
    name: 'Barbell Wrist Curl',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, barre tenue en pronation inversée, poignets hors des genoux.\n'
        '2. Plie les poignets pour lever la barre.\n'
        '3. Redescends en étirant les poignets.',
  ),
  (
    id: '1b888480-4273-4af3-a2dd-76b9ea21c103',
    name: 'Battle Rope Double Slam',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Tiens une corde lestée par extrémité, jambes fléchies.\n'
        '2. Lève les deux bras puis frappe le sol avec les cordes simultanément.\n'
        '3. Répète à un rythme soutenu.',
  ),
  (
    id: '56f6bcf0-3dcc-427a-b73a-c6cc3b0cc2b7',
    name: 'Battle Ropes',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Tiens une corde lestée par extrémité, jambes fléchies.\n'
        '2. Fais onduler les cordes en alternant les bras.\n'
        '3. Garde un rythme soutenu pendant la durée prévue.',
  ),
  (
    id: 'b5c5a175-587f-4b03-b6f0-8ebfa14e1b12',
    name: 'Bear Crawl',
    secondaryMuscles: [BodyPart.obliques, BodyPart.quads, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. À quatre pattes, genoux légèrement décollés du sol.\n'
        '2. Avance en bougeant une main et le pied opposé en même temps.\n'
        '3. Garde le dos plat et les hanches basses.',
  ),
  (
    id: '392e2093-992c-4754-aa83-6b76eca95c53',
    name: 'Behind the Back Barbell Shrug',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue derrière le dos, bras tendus.\n'
        '2. Monte les épaules le plus haut possible.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '7039d147-4a23-4633-80ab-e14fc5dbdf8c',
    name: 'Behind-the-Neck Lat Pulldown',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.trapeziusUpper],
    equipment: Equipment.machine,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie haute, prise large.\n'
        '2. Tire la barre derrière la nuque en rapprochant les omoplates.\n'
        '3. Remonte en contrôle.',
  ),
  (
    id: '657ea91a-2513-4035-90bb-07cfcd06c645',
    name: 'Behind the Neck Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, prise large.\n'
        '2. Pousse la barre au-dessus de la tête, vers l\'arrière.\n'
        '3. Redescends derrière la nuque en contrôle.',
  ),
  (
    id: '5f38dd0e-4cbe-4466-8be5-a14924394728',
    name: 'Behind-the-Neck Pull-Up',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, prise large.\n'
        '2. Tire-toi jusqu\'à ce que la barre passe derrière la nuque.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'a0a5538b-b6cc-49b7-bff2-d9cd06b4d86f',
    name: 'Bench Leg Pull-In',
    secondaryMuscles: [BodyPart.quads, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis au bord d\'un banc, mains posées derrière toi, jambes tendues.\n'
        '2. Ramène les genoux vers la poitrine.\n'
        '3. Retends les jambes en contrôle.',
  ),
  (
    id: '7642406e-6d19-4453-b963-173382b61849',
    name: 'Bench Pull',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre un banc incliné, barre sous le banc.\n'
        '2. Tire la barre vers le buste en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '9669c58a-0436-4884-9d88-7d7c3931fad3',
    name: 'Bent Arm Barbell Pullover',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre tenue au-dessus de la poitrine, coudes légèrement pliés.\n'
        '2. Descends la barre derrière la tête.\n'
        '3. Remonte au-dessus de la poitrine.',
  ),
  (
    id: 'f8b37a64-0e9e-4cf3-a6f3-b723945a8374',
    name: 'Bent-Arm EZ-Bar Pullover',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre EZ tenue au-dessus de la poitrine, coudes légèrement pliés.\n'
        '2. Descends la barre derrière la tête.\n'
        '3. Remonte au-dessus de la poitrine.',
  ),
  (
    id: '68f9d01d-7732-404a-a9a5-471f7114a513',
    name: 'Bent-Over Dumbbell Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, un haltère dans chaque main, dos plat.\n'
        '2. Tire les haltères vers les hanches en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'fd86a1d2-cd39-4466-9614-86647b56114b',
    name: 'Bent-Over EZ-Bar Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, barre EZ tenue bras tendus.\n'
        '2. Tire la barre vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '798791fe-ec47-43d3-a641-491989a676be',
    name: 'Bicycle Crunch',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, mains derrière la tête, jambes en l\'air genoux pliés.\n'
        '2. Amène un coude vers le genou opposé en pédalant avec les jambes.\n'
        '3. Alterne les côtés.',
  ),
  (
    id: '9b6e5003-2c9d-438b-ad02-8b297306002c',
    name: 'Bird-Dog',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.reps,
    instructions:
        '1. À quatre pattes, dos plat.\n'
        '2. Tends un bras devant toi et la jambe opposée derrière, en équilibre.\n'
        '3. Reviens et alterne les côtés.',
  ),
  (
    id: '7d34003d-c6cf-430b-8d6b-4039f58d8387',
    name: 'Bird Dog Hold',
    secondaryMuscles: [BodyPart.glutes, BodyPart.obliques, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.duration,
    instructions:
        '1. À quatre pattes, dos plat.\n'
        '2. Tends un bras devant toi et la jambe opposée derrière, en équilibre.\n'
        '3. Tiens la position en gainant les abdos, puis change de côté.',
  ),
  (
    id: 'a69d8acb-812f-4cf0-8955-a245b9370b7e',
    name: 'Boat Pose',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis, genoux pliés, mains au sol derrière les hanches.\n'
        '2. Lève les pieds et tends les jambes en équilibre sur les fessiers.\n'
        '3. Tends les bras devant toi et tiens la position.',
  ),
  (
    id: '4f3c6b9a-199a-4d70-b1b9-f1a04b553b21',
    name: 'Bodyweight Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, pointes de pied sur une surélévation si possible.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: '91a65243-57b4-4c4b-8f1f-3f17fb07c41b',
    name: 'Bodyweight Good Morning',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, mains derrière la tête ou croisées sur la poitrine.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '70d34e87-e00d-44c4-a3f4-092fba548046',
    name: 'Bodyweight Lateral Raise',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, bras le long du corps.\n'
        '2. Lève les bras sur les côtés jusqu\'à hauteur d\'épaule, en contractant les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'de24ff72-66d2-448f-8397-12cf12500349',
    name: 'Bodyweight Overhead Press',
    secondaryMuscles: [BodyPart.chest, BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout ou en position de pike (fesses en l\'air, mains au sol).\n'
        '2. Plie les coudes pour descendre la tête vers le sol.\n'
        '3. Repousse pour revenir à la position de départ.',
  ),
  (
    id: 'ac8077a6-a36d-4e1e-914c-42b2fa8c7bde',
    name: 'Bodyweight Reverse Lunge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, mains sur les hanches.\n'
        '2. Fais un grand pas en arrière et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: '3bd501b2-e32f-4d78-93a5-b6db62e066c0',
    name: 'Bodyweight Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, pieds largeur d\'épaules.\n'
        '2. Descends en poussant les hanches en arrière, comme pour t\'asseoir.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '0d1c4df9-635e-49ee-a056-596a73256840',
    name: 'Bow Pose',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.chest],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le ventre, plie les genoux et attrape les chevilles.\n'
        '2. Soulève la poitrine et les cuisses du sol en tirant sur les chevilles.\n'
        '3. Tiens la position.',
  ),
  (
    id: '8929f745-d8ab-473a-80a4-67e94d13217f',
    name: 'Box Jump',
    secondaryMuscles: [BodyPart.calves, BodyPart.hamstrings],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout devant une box, jambes fléchies.\n'
        '2. Saute des deux pieds sur la box en te réceptionnant genoux fléchis.\n'
        '3. Redescends en contrôle et répète.',
  ),
  (
    id: '87412fd9-6835-48b4-ae5a-3b4f8df3b3e4',
    name: 'Box Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout devant un banc ou une box, pieds largeur d\'épaules.\n'
        '2. Descends jusqu\'à toucher légèrement la box avec les fessiers.\n'
        '3. Remonte en poussant dans le sol, sans t\'asseoir complètement.',
  ),
  (
    id: '87993ccb-1a17-4fa6-b5b8-80ed83656cfd',
    name: 'Burpees',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, descends en squat et pose les mains au sol.\n'
        '2. Envoie les jambes en arrière pour une position de planche, fais une pompe si possible.\n'
        '3. Ramène les pieds vers les mains et saute en l\'air, bras tendus.',
  ),
  (
    id: 'c3409eab-add7-475b-9b6f-a8d1dbc170bc',
    name: 'Cable Bent-Over Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie basse, buste penché en avant, dos plat.\n'
        '2. Tire la poignée vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '4399c09c-6b24-4c96-8e58-f5668e127aeb',
    name: 'Cable Chest Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.cable,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, dos à la poulie, poignées tenues à hauteur de poitrine.\n'
        '2. Pousse les poignées devant toi jusqu\'à tendre les bras.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '07132602-7bf7-4e64-b694-797a40f78e63',
    name: 'Cable External Rotation',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.cable,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Coude collé au corps, plié à 90°, poignée tenue devant le ventre.\n'
        '2. Tourne l\'avant-bras vers l\'extérieur, coude toujours collé au corps.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'c3b01bdc-ccac-4048-bfa1-111496207740',
    name: 'Cable Front Raise',
    secondaryMuscles: [BodyPart.chest],
    equipment: Equipment.cable,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos à la poulie basse, poignée tenue devant les cuisses.\n'
        '2. Lève le bras tendu devant toi jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'fb0dd56c-7ed0-4379-836f-55aa717289a1',
    name: 'Cable Hammer Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.cable,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie basse, poignée en prise neutre (paume vers l\'intérieur).\n'
        '2. Plie le coude pour monter la poignée vers l\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '4d14ee2e-c88f-44d0-82b8-350a48130ebc',
    name: 'Cable Pallof Press',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.glutes,
      BodyPart.abs,
    ],
    equipment: Equipment.cable,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout de profil par rapport à la poulie, poignée tenue devant la poitrine.\n'
        '2. Pousse la poignée devant toi en résistant à la rotation du buste.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '4b34345c-89d3-47fd-b797-81e69ed6b7ed',
    name: 'Cable Tricep Kickback',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.cable,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, coude collé au corps, plié à 90°, poignée en main.\n'
        '2. Tends le bras vers l\'arrière en gardant le coude fixe.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'f838b38a-98e5-475b-a87a-dea7e2ad6331',
    name: 'Cable Upright Row',
    secondaryMuscles: [BodyPart.biceps],
    equipment: Equipment.cable,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout face à la poulie basse, barre tenue devant les cuisses.\n'
        '2. Tire la barre vers le haut, coudes qui sortent sur les côtés, jusqu\'à hauteur de poitrine.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5749cc60-3d4d-439f-8456-17a726c14482',
    name: 'Cable Wrist Curl',
    secondaryMuscles: [],
    equipment: Equipment.cable,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, poignée tenue en pronation inversée, poignets hors des genoux.\n'
        '2. Plie les poignets pour lever la poignée.\n'
        '3. Redescends en étirant les poignets.',
  ),
  (
    id: '0217590a-9ca5-4fd5-abc9-45313c390f8a',
    name: 'Captain\'s Chair Knee Raise',
    secondaryMuscles: [BodyPart.obliques, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Appuyé sur les avant-bras dans une chaise romaine, dos plat.\n'
        '2. Remonte les genoux vers la poitrine.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'a595a6b1-c4f3-4dea-9cc0-0a9431f531a9',
    name: 'Captain\'s Chair Leg Raise',
    secondaryMuscles: [BodyPart.obliques, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Appuyé sur les avant-bras dans une chaise romaine, dos plat.\n'
        '2. Remonte les jambes tendues devant toi.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '18092716-c8a7-4492-ad2f-78050a0b6d65',
    name: 'Chair Pose',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.lowerBack],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, pieds joints.\n'
        '2. Plie les genoux comme pour t\'asseoir, bras tendus au-dessus de la tête.\n'
        '3. Tiens la position.',
  ),
  (
    id: '6fc97062-4655-40a1-a9d5-10d36a1567d4',
    name: 'Cheat Curl',
    secondaryMuscles: [BodyPart.forearms, BodyPart.lowerBack],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue en pronation, prise largeur d\'épaules.\n'
        '2. Utilise une légère impulsion des hanches pour lancer la barre vers le haut.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'ea18253d-b686-4136-8c0d-c6b749d47ddb',
    name: 'Machine Chest Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la machine, poignées à hauteur de poitrine.\n'
        '2. Pousse les poignées devant toi jusqu\'à tendre les bras.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'ec6b3059-3127-412a-925e-36264358fb37',
    name: 'Chest-Supported Dumbbell Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre un banc incliné, un haltère dans chaque main.\n'
        '2. Tire les haltères vers les hanches en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'c4ce8001-8719-4691-91b0-cc647a5354c2',
    name: 'Chest Supported Dumbbell Shrug',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre un banc incliné, un haltère dans chaque main, bras tendus.\n'
        '2. Monte les épaules le plus haut possible.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '7f377fc6-9445-4afe-b114-705c6e6656cf',
    name: 'Chest-Supported Kettlebell Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre un banc incliné, un kettlebell dans chaque main.\n'
        '2. Tire les kettlebells vers les hanches en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '8b10c013-b224-4126-8edc-399ca9927ca5',
    name: 'Chin Tuck Hold',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis ou debout, dos droit.\n'
        '2. Rentre le menton en gardant le regard horizontal, comme pour former un double menton.\n'
        '3. Tiens la position.',
  ),
  (
    id: 'e355ffe8-7720-42a7-967f-9224a03da6f9',
    name: 'Chin-Ups',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, prise en supination (paumes vers toi), largeur d\'épaules.\n'
        '2. Tire-toi jusqu\'au menton au-dessus de la barre.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '97ef1d5a-f5ac-4602-96d3-5ae619cb4551',
    name: 'Clamshells',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allonge-toi sur le côté, genoux pliés, pieds joints.\n'
        '2. Ouvre le genou du dessus en gardant les pieds joints.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'f6f7361d-b11d-4663-8027-a274ae6220e4',
    name: 'Clamshell Hold',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allonge-toi sur le côté, genoux pliés, pieds joints.\n'
        '2. Ouvre le genou du dessus et tiens la position.\n'
        '3. Redescends après la durée prévue.',
  ),
  (
    id: '3cdd0e4b-1cbc-42de-a1d1-958e4fc6fa54',
    name: 'Clap Push-Ups',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains sous les épaules.\n'
        '2. Descends puis repousse explosivement pour décoller les mains du sol et taper des mains.\n'
        '3. Réceptionne-toi en contrôle et enchaîne.',
  ),
  (
    id: 'a29d240f-2485-494e-80d0-6f5bff2616de',
    name: 'Clean',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.hamstrings,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre au sol, pieds largeur de hanches.\n'
        '2. Tire la barre en tendant les hanches et les genoux, puis tire-la vers le haut.\n'
        '3. Passe sous la barre pour la réceptionner sur les épaules, jambes fléchies, puis remonte debout.',
  ),
  (
    id: '04d803ef-e339-459a-b4e8-c4e3ae1ebe10',
    name: 'Clean and Jerk',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Réalise un clean pour amener la barre sur les épaules.\n'
        '2. Plie légèrement les jambes puis pousse la barre au-dessus de la tête en fendant une jambe devant.\n'
        '3. Ramène les pieds ensemble, bras tendus au-dessus de la tête.',
  ),
  (
    id: '83d912ef-2dee-4256-9a56-627b918885b2',
    name: 'Close-Grip Barbell Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue en pronation, mains rapprochées.\n'
        '2. Plie les coudes pour monter la barre vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'bb138595-60e6-4eb9-b783-5105ab76e6fc',
    name: 'Close-Grip Dumbbell Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.chest],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, un haltère dans chaque main, coudes proches du corps.\n'
        '2. Descends les haltères vers la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'a2952370-fab1-40ee-b01d-9e9ccbfdef91',
    name: 'Close-Grip EZ-Bar Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.chest],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre EZ tenue mains rapprochées.\n'
        '2. Descends la barre vers la poitrine, coudes proches du corps.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '3847a1d6-5818-428f-a31e-ddc764ea805c',
    name: 'Close-Grip EZ-Bar Curl',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue mains rapprochées sur la partie centrale.\n'
        '2. Plie les coudes pour monter la barre vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '348d0ef8-d9c0-40c5-b2bd-a6e3bd70347d',
    name: 'Close-Grip Incline Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.chest],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, barre tenue mains rapprochées.\n'
        '2. Descends la barre vers le haut de la poitrine, coudes proches du corps.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '7323de34-2cd7-4f0f-b736-b638276ae075',
    name: 'Close Grip Lat Pulldown',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie haute, poignée resserrée en prise neutre.\n'
        '2. Tire la poignée vers le haut de la poitrine.\n'
        '3. Remonte en contrôle.',
  ),
  (
    id: '008a0633-394b-4ca6-9568-29232ab85ddc',
    name: 'Close-Grip Pull-Ups',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, mains rapprochées.\n'
        '2. Tire-toi jusqu\'au menton au-dessus de la barre.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'dd121a38-44cc-40fe-8062-3cfeaa267728',
    name: 'Close Grip Push Ups',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains rapprochées sous la poitrine.\n'
        '2. Descends en gardant les coudes proches du corps.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '42868baf-3ade-4aaf-b843-b5d194790900',
    name: 'Close-Stance Leg Press',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la presse à cuisses, pieds rapprochés au centre de la plateforme.\n'
        '2. Plie les genoux vers la poitrine.\n'
        '3. Repousse la plateforme sans tendre complètement les genoux.',
  ),
  (
    id: 'a60b9cd0-f487-4402-bd9b-92660afaae78',
    name: 'Cocoons',
    secondaryMuscles: [BodyPart.quads, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, bras et jambes tendus.\n'
        '2. Ramène simultanément les genoux vers la poitrine et le buste vers les genoux.\n'
        '3. Retends bras et jambes en contrôle.',
  ),
  (
    id: '94d1f14c-a7ad-4207-8508-923d166be5a6',
    name: 'Cossack Squat',
    secondaryMuscles: [BodyPart.adductors, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, pieds très écartés.\n'
        '2. Descends d\'un côté en pliant un genou, l\'autre jambe tendue sur le côté.\n'
        '3. Repousse pour revenir au centre et change de côté.',
  ),
  (
    id: '8cd64d24-20a5-4c0a-923a-9b826da44783',
    name: 'Crab Dips',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.glutes, BodyPart.chest],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis, mains au sol derrière toi, jambes tendues devant, fessiers décollés du sol.\n'
        '2. Plie les coudes pour descendre les fessiers vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '9663028d-f4df-42d2-990c-5b2956376ba1',
    name: 'Crescent Lunge',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Fais un grand pas en avant, genou avant plié à 90°.\n'
        '2. Lève les bras au-dessus de la tête, buste droit.\n'
        '3. Tiens la position, puis change de jambe.',
  ),
  (
    id: 'd3f4779f-cbc3-4f54-82df-6bcf083d116e',
    name: 'Cross-Body Crunch',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, mains derrière la tête, genoux pliés.\n'
        '2. Amène un coude vers le genou opposé en relevant le buste en torsion.\n'
        '3. Redescends en contrôle et alterne.',
  ),
  (
    id: '1ac06ed7-eb23-45cd-9c64-4163aa8fec90',
    name: 'Cross Body Hammer Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main, prise neutre.\n'
        '2. Plie un coude pour amener l\'haltère vers l\'épaule opposée.\n'
        '3. Redescends en contrôle et alterne les bras.',
  ),
  (
    id: '7e8d7ccd-a4d4-4b20-9c3a-3839cbf30bfd',
    name: 'Crow Pose',
    secondaryMuscles: [BodyPart.abs, BodyPart.chest],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.duration,
    instructions:
        '1. Accroupi, mains au sol, genoux calés sur l\'arrière des bras.\n'
        '2. Penche le poids vers l\'avant et décolle les pieds du sol.\n'
        '3. Tiens l\'équilibre sur les mains.',
  ),
  (
    id: '727398fb-66d3-4ad3-897b-2078242eea2d',
    name: 'Dancer Pose',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout sur une jambe, attrape l\'autre cheville derrière toi.\n'
        '2. Penche le buste vers l\'avant en levant la jambe tenue vers l\'arrière.\n'
        '3. Tiens l\'équilibre, puis change de jambe.',
  ),
  (
    id: '9e753f77-c697-46c6-8d6f-8d33d96c0a06',
    name: 'Dumbbell Kickstand Deadlift',
    secondaryMuscles: [BodyPart.adductors, BodyPart.lowerBack],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un pied légèrement en retrait sur la pointe, haltères en main.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '1888d084-c635-4386-89e6-d9d448444e9e',
    name: 'Dumbbell Overhead Carry',
    secondaryMuscles: [
      BodyPart.obliques,
      BodyPart.lowerBack,
      BodyPart.chest,
      BodyPart.abs,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Haltères tenus à bout de bras au-dessus de la tête.\n'
        '2. Marche droit devant toi en gardant les bras tendus et le gainage serré.\n'
        '3. Continue sur la distance ou la durée prévue.',
  ),
  (
    id: 'de9e221b-6909-4a26-9fa0-58e49190753d',
    name: 'Dumbbell Reverse Curl',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères tenus en pronation (paumes vers le bas).\n'
        '2. Plie les coudes pour monter les haltères vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '95ece427-7c91-4b19-963c-20c92915e256',
    name: 'Dumbbell Skull Crusher',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, haltères tenus à bout de bras au-dessus de la poitrine.\n'
        '2. Plie les coudes pour descendre les haltères vers le front.\n'
        '3. Retends les bras.',
  ),
  (
    id: 'af9b3bd9-6eb6-47fd-9740-9a9c178d4929',
    name: 'Dumbbell Somersault Squat',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.obliques],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère tenu à deux mains devant toi.\n'
        '2. Descends en squat en faisant passer l\'haltère entre les jambes.\n'
        '3. Remonte en ramenant l\'haltère devant la poitrine.',
  ),
  (
    id: '6a9c2e12-eeb4-46ff-92b8-a275537e8f59',
    name: 'Dumbbell Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main le long du corps.\n'
        '2. Descends en poussant les hanches en arrière.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'd35dc3a3-d550-4656-a588-67be5ea351c5',
    name: 'Dumbbell Sumo Squat',
    secondaryMuscles: [BodyPart.adductors, BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds larges, pointes ouvertes, un haltère tenu à deux mains devant toi.\n'
        '2. Descends en poussant les genoux vers l\'extérieur.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'ddb41974-5323-4770-a51f-e9df8f9446c1',
    name: 'Dumbbell Svend Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, presse deux petits disques ou haltères entre les paumes devant la poitrine.\n'
        '2. Pousse-les devant toi en gardant la pression.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '343707a9-e3e8-4299-b4ed-f6423e0c32f5',
    name: 'Dead Bug',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, bras tendus vers le plafond, genoux pliés à 90°.\n'
        '2. Descends un bras derrière la tête et la jambe opposée vers le sol.\n'
        '3. Reviens et alterne les côtés en gardant le bas du dos plaqué au sol.',
  ),
  (
    id: '0135d048-4704-4888-8848-843ab40a134d',
    name: 'Dead Bug Hold',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le dos, bras tendus vers le plafond, genoux pliés à 90°.\n'
        '2. Descends un bras derrière la tête et la jambe opposée vers le sol.\n'
        '3. Tiens la position sans creuser le bas du dos.',
  ),
  (
    id: 'ae893317-cf5b-4677-8439-bc126bcc1406',
    name: 'Decline Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc décliné, un haltère dans chaque main au-dessus de la poitrine.\n'
        '2. Descends les haltères vers le bas de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'e1e5cb62-57eb-4f6e-9fb5-ef9ec78a47df',
    name: 'Decline Barbell Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc décliné, barre tenue au-dessus de la poitrine.\n'
        '2. Descends la barre vers le bas de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '5ccf52b7-558c-4876-993e-ff9c2dbffc04',
    name: 'Decline EZ-Bar Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc décliné, barre EZ tenue au-dessus de la poitrine.\n'
        '2. Descends la barre vers le bas de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '76482391-3586-42bc-b813-4c5964699930',
    name: 'Decline Crunch',
    secondaryMuscles: [BodyPart.quads, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur un banc décliné, pieds calés, mains derrière la tête.\n'
        '2. Relève le buste vers les genoux en contractant les abdos.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '0b306edc-bba1-47d8-b2e9-389d935c85e3',
    name: 'Decline Dumbbell Fly',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc décliné, haltères tenus au-dessus de la poitrine, bras légèrement fléchis.\n'
        '2. Ouvre les bras sur les côtés jusqu\'à sentir l\'étirement.\n'
        '3. Remonte les haltères en refermant les bras.',
  ),
  (
    id: '9a746e54-55c8-4e7b-95c7-2bf7c6a5f32b',
    name: 'Decline Push-Up',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, pieds surélevés sur un banc.\n'
        '2. Descends la poitrine vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '7adbce18-f343-4b87-8421-b231d38e7130',
    name: 'Deficit Deadlift',
    secondaryMuscles: [BodyPart.lats, BodyPart.quads, BodyPart.trapeziusUpper],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une surélévation, barre au sol devant toi.\n'
        '2. Penche-toi et saisis la barre, dos plat.\n'
        '3. Tends les hanches et les genoux pour te redresser.',
  ),
  (
    id: '203d8f1f-9580-491a-a0c7-7df37c71e23b',
    name: 'Deficit Push Ups',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Mains posées sur des supports surélevés, écartement largeur d\'épaules.\n'
        '2. Descends la poitrine plus bas qu\'une pompe classique.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'df02d4e9-5529-4228-9bc7-8328ac79fed3',
    name: 'Diamond Push Ups',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains rapprochées formant un losange sous la poitrine.\n'
        '2. Descends la poitrine vers les mains.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '46a7bdf6-e2a9-4674-ad18-3de4a8c9b305',
    name: 'Dolphin Pose',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.chest],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.duration,
    instructions:
        '1. Avant-bras au sol, mains jointes, hanches levées comme un chien tête en bas.\n'
        '2. Garde le dos droit et les talons qui cherchent le sol.\n'
        '3. Tiens la position.',
  ),
  (
    id: 'd599c721-98e8-447e-80c5-bbb00b99bca0',
    name: 'Donkey Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.reps,
    instructions:
        '1. Buste penché en avant, appuyé sur un support, avant-pieds sur une surélévation.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: '4524d98c-e548-4741-bdc3-f38904e4595f',
    name: 'Double Dumbbell Kickstand Deadlift',
    secondaryMuscles: [BodyPart.adductors, BodyPart.lowerBack],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un pied légèrement en retrait sur la pointe, un haltère dans chaque main.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '0e1e9a69-1f0c-40f3-8e7e-f1a78c339074',
    name: 'Double Dumbbell Overhead Carry',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.chest,
      BodyPart.abs,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux haltères tenus à bout de bras au-dessus de la tête.\n'
        '2. Marche droit devant toi en gardant les bras tendus et le gainage serré.\n'
        '3. Continue sur la distance ou la durée prévue.',
  ),
  (
    id: '0bfa393d-dfcf-44c9-840a-242f9d26f750',
    name: 'Double Kettlebell Bicep Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un kettlebell dans chaque main, bras tendus.\n'
        '2. Plie les coudes pour monter les kettlebells vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b619dc24-e4b9-42a7-8864-4f92fbc5cbca',
    name: 'Double Kettlebell Clean',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells au sol entre les pieds.\n'
        '2. Tire-les vers le haut en tendant les hanches, puis retourne-les sur les avant-bras à hauteur d\'épaule.\n'
        '3. Redescends-les en contrôle.',
  ),
  (
    id: 'a4ed5818-bdb5-414c-98a6-e256bc52fa19',
    name: 'Double Kettlebell Clean and Press',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.quads,
      BodyPart.abs,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Réalise un clean pour amener les deux kettlebells à hauteur d\'épaule.\n'
        '2. Pousse-les au-dessus de la tête jusqu\'à tendre les bras.\n'
        '3. Redescends-les en contrôle jusqu\'aux épaules puis au sol.',
  ),
  (
    id: 'cc55202e-9762-4725-92f2-5f66a3981c04',
    name: 'Double Kettlebell Dead Clean',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.quads,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells au sol entre les pieds, dos plat.\n'
        '2. Tire-les vers le haut en tendant les hanches et les genoux d\'un même mouvement.\n'
        '3. Retourne-les sur les avant-bras à hauteur d\'épaule.',
  ),
  (
    id: '3afa3729-d570-4eea-886d-1948e2ff5516',
    name: 'Double Kettlebell Dead Split Snatch',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.hamstrings,
      BodyPart.quads,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells au sol entre les pieds.\n'
        '2. Tire-les d\'un coup au-dessus de la tête en fendant une jambe devant.\n'
        '3. Ramène les pieds ensemble, bras tendus au-dessus de la tête.',
  ),
  (
    id: 'bacbde0b-5350-4b0d-8a5a-fffb59105861',
    name: 'Double Kettlebell Jerk',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells à hauteur d\'épaule.\n'
        '2. Plie légèrement les jambes puis pousse les kettlebells au-dessus de la tête en fendant une jambe devant.\n'
        '3. Ramène les pieds ensemble, bras tendus.',
  ),
  (
    id: '0e72424b-0122-4bf0-a729-eccf9fb085e1',
    name: 'Double Kettlebell Overhead Carry',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.chest,
      BodyPart.abs,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells tenus à bout de bras au-dessus de la tête.\n'
        '2. Marche droit devant toi en gardant les bras tendus et le gainage serré.\n'
        '3. Continue sur la distance ou la durée prévue.',
  ),
  (
    id: '9c782953-a669-4817-97ec-7f2d3e237477',
    name: 'Double Kettlebell Overhead Press',
    secondaryMuscles: [BodyPart.abs, BodyPart.chest, BodyPart.trapeziusUpper],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells à hauteur d\'épaule.\n'
        '2. Pousse-les au-dessus de la tête jusqu\'à tendre les bras.\n'
        '3. Redescends-les en contrôle.',
  ),
  (
    id: '076999df-dbdd-4cb3-adc2-3cc98e0704e4',
    name: 'Double Kettlebell Push Press',
    secondaryMuscles: [BodyPart.glutes, BodyPart.quads, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells à hauteur d\'épaule, jambes légèrement fléchies.\n'
        '2. Pousse sur les jambes puis avec les bras pour envoyer les kettlebells au-dessus de la tête.\n'
        '3. Redescends-les en contrôle.',
  ),
  (
    id: 'd08a5f9a-dc61-4c81-9bb5-855e2b04126b',
    name: 'Double Kettlebell Rear Delt Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.lowerBack,
      BodyPart.lats,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, un kettlebell dans chaque main, bras tendus.\n'
        '2. Tire les kettlebells vers le haut en écartant les coudes.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '6e199077-7d2b-4b45-9870-dcfb52ba6efe',
    name: 'Double Kettlebell Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.lowerBack,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, un kettlebell dans chaque main, bras tendus.\n'
        '2. Tire les kettlebells vers les hanches en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '40be005d-6099-4f59-b8d6-5f9ab9b2ff08',
    name: 'Double Kettlebell Split Jerk',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells à hauteur d\'épaule.\n'
        '2. Plie légèrement les jambes puis pousse les kettlebells au-dessus de la tête en fendant une jambe devant.\n'
        '3. Ramène les pieds ensemble, bras tendus.',
  ),
  (
    id: '70cd2005-fd18-4b1f-9bb5-e7000c212d81',
    name: 'Double Kettlebell Swing Snatch',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Deux kettlebells entre les jambes, dos plat.\n'
        '2. Fais-les swinguer entre les jambes puis tends les hanches pour les envoyer directement au-dessus de la tête.\n'
        '3. Redescends-les en contrôle entre les jambes.',
  ),
  (
    id: 'fe657b03-8e3a-4de4-b9ea-93ca048c772c',
    name: 'Downward Dog Knee Tuck',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.chest, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. En position de chien tête en bas, hanches hautes.\n'
        '2. Amène un genou vers la poitrine en arrondissant le dos.\n'
        '3. Reviens à la position de départ et alterne.',
  ),
  (
    id: '630c03e7-9a63-4fd0-a28f-d3a2c29577d4',
    name: 'Downward Dog to Knee Drive',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.glutes, BodyPart.chest],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. En position de chien tête en bas.\n'
        '2. Lève une jambe tendue vers l\'arrière, puis ramène le genou vers la poitrine.\n'
        '3. Retends la jambe et répète, puis change de côté.',
  ),
  (
    id: '2fe490b4-2089-44ed-8ed9-f1213efdd433',
    name: 'Downward Dog to Plank',
    secondaryMuscles: [
      BodyPart.hamstrings,
      BodyPart.chest,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.duration,
    instructions:
        '1. En position de chien tête en bas.\n'
        '2. Avance le corps vers l\'avant jusqu\'en position de planche, épaules au-dessus des mains.\n'
        '3. Reviens en chien tête en bas et tiens l\'alternance.',
  ),
  (
    id: 'b1710958-f5df-41d0-9ffd-3b835025695e',
    name: 'Downward Dog to Upward Dog',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. En position de chien tête en bas.\n'
        '2. Avance vers l\'avant en creusant le dos jusqu\'en chien tête en haut, bras tendus.\n'
        '3. Reviens en chien tête en bas.',
  ),
  (
    id: '3ce4b10d-b366-424c-8d7c-9261c7d832ff',
    name: 'Drag Curl',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue en pronation devant les cuisses.\n'
        '2. Monte la barre en la faisant glisser le long du corps, coudes vers l\'arrière.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '7e039720-8fb9-43f0-87ca-3698a92ba9df',
    name: 'Dragon Flag',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur un banc, mains agrippées derrière la tête pour te stabiliser.\n'
        '2. Lève tout le corps en bloc, gainé, jusqu\'à la verticale sur les épaules.\n'
        '3. Redescends en contrôle sans casser la ligne du corps.',
  ),
  (
    id: '8435ba3b-9853-4608-85f7-90fc2d2d06a7',
    name: 'Dumbbell Bench Pull',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre un banc incliné, haltères tenus bras tendus.\n'
        '2. Tire les haltères vers le buste en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '28c2d825-6da9-4f6b-9d86-f1d2431d7a5a',
    name: 'Dumbbell Calf Raise',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères en main, pointes de pied sur une surélévation si possible.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: '2836bf5c-7006-4020-af7e-ad9598b388a9',
    name: 'Dumbbell Deadlift',
    secondaryMuscles: [BodyPart.lats, BodyPart.quads, BodyPart.trapeziusUpper],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère dans chaque main devant les cuisses.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '0ddf510a-c964-47ec-acd9-fb1f9277fffa',
    name: 'Dumbbell Face Pull',
    secondaryMuscles: [BodyPart.biceps, BodyPart.trapeziusUpper],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, haltères tenus bras tendus devant toi.\n'
        '2. Tire les haltères vers le visage en écartant les coudes.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'eb5b6233-f868-4b8d-9cf4-f0663a8d397f',
    name: 'Dumbbell Farmer\'s Walk',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.obliques,
      BodyPart.quads,
      BodyPart.abs,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un haltère lourd dans chaque main, le long du corps.\n'
        '2. Marche droit devant toi en gardant les épaules basses et le gainage serré.\n'
        '3. Continue sur la distance ou la durée prévue.',
  ),
  (
    id: '3a57c13f-992a-4f5a-a04c-2af9b59b86e6',
    name: 'Dumbbell Floor Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, haltères tenus au-dessus de la poitrine.\n'
        '2. Descends les coudes jusqu\'à toucher le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '3977af7b-b392-49e8-8542-a11e9477edd8',
    name: 'Dumbbell Front Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings, BodyPart.abs],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères tenus à hauteur d\'épaule, coudes hauts.\n'
        '2. Descends en squat, buste droit.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'e91c5fca-d17a-49d5-a141-f6f5629ba8e0',
    name: 'Dumbbell Hip Thrust',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos appuyé contre un banc, un haltère posé sur les hanches, pieds à plat.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'a62ed0d6-7a74-4003-8e06-69e572b2ca07',
    name: 'Dumbbell Pistol Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une jambe, haltère tenu devant la poitrine, autre jambe tendue devant toi.\n'
        '2. Descends en squat sur la jambe d\'appui le plus bas possible.\n'
        '3. Remonte en poussant dans le sol, puis change de jambe.',
  ),
  (
    id: '2ff90875-3d2a-4914-90e9-dd62e5978ab8',
    name: 'Dumbbell Push Press',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.quads,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Haltères à hauteur d\'épaule, jambes légèrement fléchies.\n'
        '2. Pousse sur les jambes puis avec les bras pour envoyer les haltères au-dessus de la tête.\n'
        '3. Redescends-les en contrôle.',
  ),
  (
    id: '01a769ec-4b90-4dfe-86c9-ecb2a169e489',
    name: 'Dumbbell Reverse Fly',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, haltères tenus sous les épaules, bras légèrement fléchis.\n'
        '2. Écarte les bras sur les côtés en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '4334a753-6919-4a79-bbf7-2f478ecf734e',
    name: 'Dumbbell Romanian Deadlift',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères tenus devant les cuisses.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, jambes presque tendues, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: 'd829b73d-80c9-48e9-9cca-8e1a8cdc8020',
    name: 'Dumbbell Snatch',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un haltère au sol entre les pieds.\n'
        '2. Tire-le d\'un coup au-dessus de la tête en tendant les hanches et les jambes.\n'
        '3. Redescends-le en contrôle, puis change de bras.',
  ),
  (
    id: '7242b72f-4541-4d92-b394-e72c2155c770',
    name: 'Dumbbell Split Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un pied devant, l\'autre en fente arrière, haltères en main.\n'
        '2. Descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '42ef9127-a691-4616-9636-25f15b4959c8',
    name: 'Dumbbell Upright Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.trapeziusUpper],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères tenus devant les cuisses.\n'
        '2. Tire les haltères vers le haut, coudes qui sortent sur les côtés, jusqu\'à hauteur de poitrine.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'cbf35bf3-3dbf-4a2c-abd5-d2a51241d1b3',
    name: 'Dumbbell Windmill',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un haltère tenu au-dessus de la tête, pieds écartés.\n'
        '2. Penche le buste sur le côté en gardant le bras tendu vers le plafond, l\'autre main glisse vers le pied.\n'
        '3. Reviens à la verticale, puis change de côté.',
  ),
  (
    id: '42326ed2-bc62-4a8e-84a9-a03997cffcc1',
    name: 'Eagle Pose',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, croise une cuisse sur l\'autre, puis les bras devant toi.\n'
        '2. Plie légèrement le genou d\'appui et tiens l\'équilibre.\n'
        '3. Change de côté après la durée prévue.',
  ),
  (
    id: '4ac40ec7-1647-4a19-8383-05406bd7cc43',
    name: 'Elliptical Trainer',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Monte sur l\'appareil, pieds sur les pédales, mains sur les poignées mobiles.\n'
        '2. Pédale en poussant et tirant avec les bras à un rythme régulier.\n'
        '3. Continue pendant la durée prévue.',
  ),
  (
    id: '828a3dcf-aa93-4eb4-a539-31dff2fcae34',
    name: 'Extended Side Angle Pose',
    secondaryMuscles: [BodyPart.adductors, BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.duration,
    instructions:
        '1. Fais un grand pas de côté, un genou plié à 90°.\n'
        '2. Pose l\'avant-bras sur la cuisse et tends l\'autre bras au-dessus de la tête.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: 'a35ddc4f-e66d-4c86-a0fd-a94f33c3b09b',
    name: 'EZ-Bar Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre EZ tenue au-dessus de la poitrine.\n'
        '2. Descends la barre vers la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '60c3e4aa-da42-4379-93ec-4b5b683ec331',
    name: 'EZ-Bar Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue en pronation, largeur d\'épaules.\n'
        '2. Plie les coudes pour monter la barre vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '3cc261d6-4763-49f5-8cd1-36d299c8015e',
    name: 'EZ-Bar Front Raise',
    secondaryMuscles: [BodyPart.chest],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue devant les cuisses.\n'
        '2. Lève la barre tendue devant toi jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '26151e87-7d3f-43fa-9ad5-820e0d435b2e',
    name: 'EZ-Bar Lying Triceps Extension',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre EZ tenue à bout de bras au-dessus de la poitrine.\n'
        '2. Plie les coudes pour descendre la barre vers le front.\n'
        '3. Retends les bras.',
  ),
  (
    id: '3c3d950e-c322-4313-a3e5-22e49c9ff6da',
    name: 'EZ-Bar Overhead Tricep Extension',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout ou assis, barre EZ tenue à bout de bras au-dessus de la tête.\n'
        '2. Descends la barre derrière la tête en pliant les coudes.\n'
        '3. Retends les bras vers le haut.',
  ),
  (
    id: '2c96ed80-431d-4a6f-a25d-8c2af10375f6',
    name: 'EZ Bar Pullover',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre EZ tenue au-dessus de la poitrine, bras presque tendus.\n'
        '2. Descends la barre derrière la tête.\n'
        '3. Remonte au-dessus de la poitrine.',
  ),
  (
    id: 'd213fcef-c1bf-4bc8-bca3-7d75b862ba9d',
    name: 'EZ-Bar Reverse Curl',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue en pronation (paumes vers le bas).\n'
        '2. Plie les coudes pour monter la barre vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '284cc910-fad0-4a3b-9df5-d9bc22f4eece',
    name: 'EZ Bar Reverse Grip Row',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.trapeziusUpper],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, barre EZ tenue en supination.\n'
        '2. Tire la barre vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'c8eb25e5-c252-4696-8ef9-cef2f065d86d',
    name: 'EZ-Bar Romanian Deadlift',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue devant les cuisses.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, jambes presque tendues, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '908ba582-47b6-4bc7-8371-b3d51c6134d1',
    name: 'EZ-Bar Shrug',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue devant les cuisses, bras tendus.\n'
        '2. Monte les épaules le plus haut possible.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '8ecce382-b1de-4099-977c-93a09931dd93',
    name: 'EZ Bar Spider Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste appuyé sur un pupitre incliné, barre EZ tenue bras tendus vers le bas.\n'
        '2. Plie les coudes pour monter la barre vers le front.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'c1b193cd-bd5f-4d4d-b026-e34d115c8145',
    name: 'EZ-Bar Upright Row',
    secondaryMuscles: [BodyPart.biceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre EZ tenue devant les cuisses.\n'
        '2. Tire la barre vers le haut, coudes qui sortent sur les côtés, jusqu\'à hauteur de poitrine.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '082238ea-51de-407e-94dd-8b17fe1e2ac9',
    name: 'EZ-Bar Wrist Curl',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, barre EZ tenue en pronation inversée, poignets hors des genoux.\n'
        '2. Plie les poignets pour lever la barre.\n'
        '3. Redescends en étirant les poignets.',
  ),
  (
    id: '80e5b4f2-4609-41bb-9b00-f8483956feca',
    name: 'Floor EZ-Bar Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, barre EZ tenue au-dessus de la poitrine.\n'
        '2. Descends les coudes jusqu\'à toucher le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'b82d18d2-155a-41b5-8cbd-dda43b326720',
    name: 'Floor Kettlebell Pullover',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, kettlebell tenu à bout de bras au-dessus de la poitrine.\n'
        '2. Descends le kettlebell derrière la tête jusqu\'à toucher le sol.\n'
        '3. Remonte au-dessus de la poitrine.',
  ),
  (
    id: '2d4c510c-ccc7-47ae-bc92-35783694b47b',
    name: 'Floor Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, barre tenue au-dessus de la poitrine.\n'
        '2. Descends les coudes jusqu\'à toucher le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '4a16e8ba-bc47-4bc2-8706-ecaa54696170',
    name: 'Flutter Kicks',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, mains sous les fessiers, jambes tendues légèrement décollées du sol.\n'
        '2. Alterne de petits battements de jambes verticaux.\n'
        '3. Continue pendant la durée ou le nombre de répétitions prévu.',
  ),
  (
    id: 'b3d38a02-ead7-4d48-ac4e-0301b9fc71d5',
    name: 'Front Lever',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.biceps,
      BodyPart.lowerBack,
      BodyPart.abs,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, prise en pronation.\n'
        '2. Bascule le corps à l\'horizontale, face au sol, en gainant tout le corps.\n'
        '3. Tiens la position, puis reviens en contrôle.',
  ),
  (
    id: '6af7e57a-e809-49a2-96f4-5a7d89993955',
    name: 'Front Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre tenue à hauteur d\'épaule, coudes hauts.\n'
        '2. Descends en squat, buste droit.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'b5a7fa85-a5f3-4cc7-909a-1fc474cf4bbc',
    name: 'Glute Bridge Hold',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le dos, genoux pliés, pieds à plat.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Tiens la position en haut.',
  ),
  (
    id: 'b2de097b-a6b3-46af-89c9-7a04946348ff',
    name: 'Glute Kickback',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. À quatre pattes, dos plat.\n'
        '2. Tends une jambe vers l\'arrière et vers le haut, sans cambrer le dos.\n'
        '3. Redescends en contrôle et alterne.',
  ),
  (
    id: '531035ef-4015-4b55-8202-6dedd4e229a7',
    name: 'Glute Kickback Hold',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. À quatre pattes, dos plat.\n'
        '2. Tends une jambe vers l\'arrière et vers le haut.\n'
        '3. Tiens la position, puis change de jambe.',
  ),
  (
    id: '0fc2902a-2633-46a1-91aa-a8e621ca5f92',
    name: 'Half Moon Pose',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, penche le buste en avant et pose une main au sol.\n'
        '2. Lève l\'autre jambe à l\'horizontale et l\'autre bras vers le plafond.\n'
        '3. Tiens l\'équilibre, puis change de côté.',
  ),
  (
    id: '03242c97-8554-46c9-a4cc-06654b05da77',
    name: 'Handstand Push Ups',
    secondaryMuscles: [BodyPart.abs, BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. En appui tendu renversé contre un mur, mains au sol.\n'
        '2. Plie les coudes pour descendre la tête vers le sol.\n'
        '3. Repousse pour remonter en position tendue.',
  ),
  (
    id: 'a8d586c2-111b-4669-8f48-843eaa6aabda',
    name: 'Hang Clean',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.hamstrings,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre tenue devant les cuisses, buste légèrement penché.\n'
        '2. Tends les hanches et les genoux d\'un coup sec pour tirer la barre vers le haut.\n'
        '3. Passe rapidement sous la barre pour la réceptionner sur les épaules, puis remonte debout.',
  ),
  (
    id: 'afbe7f11-9741-40de-828d-7a772c0a3dc7',
    name: 'Hang Power Clean',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre tenue devant les cuisses, buste légèrement penché.\n'
        '2. Tends les hanches et les genoux d\'un coup sec pour tirer la barre vers le haut.\n'
        '3. Réceptionne la barre sur les épaules sans descendre en squat complet.',
  ),
  (
    id: '1a99414d-de74-449c-b451-18df65a578f9',
    name: 'Hanging Knee Raise',
    secondaryMuscles: [BodyPart.forearms, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Suspends-toi à la barre, bras tendus.\n'
        '2. Remonte les genoux vers la poitrine en contractant les abdos.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b4344c5d-d5e6-4d6f-bf94-5c56ef099c27',
    name: 'Hanging Pike',
    secondaryMuscles: [BodyPart.forearms, BodyPart.quads, BodyPart.lats],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Suspends-toi à la barre, bras tendus.\n'
        '2. Remonte les jambes tendues à l\'horizontale ou plus haut.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '966b26d0-e790-45f0-ba56-ac43392a1ef6',
    name: 'Heel-Elevated Squat',
    secondaryMuscles: [
      BodyPart.adductors,
      BodyPart.lowerBack,
      BodyPart.hamstrings,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Talons posés sur une petite surélévation, barre sur le haut du dos.\n'
        '2. Descends en squat, buste droit.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '5dd5d556-4c80-441d-bac7-9a5dff9e2829',
    name: 'Heel-to-Toe Walk',
    secondaryMuscles: [BodyPart.calves, BodyPart.quads, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, pieds joints.\n'
        '2. Avance en posant chaque pas talon contre pointe, en ligne droite.\n'
        '3. Continue sur la distance prévue en gardant l\'équilibre.',
  ),
  (
    id: 'd499a026-bf98-4b63-8e13-987ea3b7cac6',
    name: 'Hex Bar Deadlift',
    secondaryMuscles: [
      BodyPart.forearms,
      BodyPart.hamstrings,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout à l\'intérieur de la barre hexagonale, poignées de chaque côté.\n'
        '2. Penche-toi et saisis les poignées, dos plat.\n'
        '3. Tends les hanches et les genoux pour te redresser.',
  ),
  (
    id: 'fb679dc3-1615-43f0-b2e0-b326cbbe8d54',
    name: 'High-Foot Leg Press',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la presse à cuisses, pieds hauts sur la plateforme.\n'
        '2. Plie les genoux vers la poitrine.\n'
        '3. Repousse la plateforme sans tendre complètement les genoux.',
  ),
  (
    id: '5d9f9e8b-2837-4096-9c1e-1a23db381e8f',
    name: 'High Knees',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, cours sur place en montant les genoux le plus haut possible.\n'
        '2. Garde un rythme soutenu, bras qui accompagnent le mouvement.\n'
        '3. Continue pendant la durée prévue.',
  ),
  (
    id: '0920f160-678c-4a53-b7f3-b4fc13d9ef9e',
    name: 'High Plank',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.duration,
    instructions:
        '1. Position de planche, mains sous les épaules, bras tendus.\n'
        '2. Garde le corps aligné, tête aux talons, abdos gainés.\n'
        '3. Tiens la position.',
  ),
  (
    id: 'a1034b9a-87b2-4286-8814-0332f8285156',
    name: 'Hollow Body Hold',
    secondaryMuscles: [BodyPart.quads, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le dos, bras tendus derrière la tête, jambes tendues.\n'
        '2. Décolle les épaules et les jambes du sol en creusant le bas du dos vers le sol.\n'
        '3. Tiens la position en gainant les abdos.',
  ),
  (
    id: '4ccd8eec-3dbb-4fda-8158-24aaedacebf6',
    name: 'Horizontal Leg Press',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la presse à cuisses horizontale, pieds sur la plateforme.\n'
        '2. Plie les genoux vers la poitrine.\n'
        '3. Repousse la plateforme sans tendre complètement les genoux.',
  ),
  (
    id: '82057819-31dc-468b-8dc4-3f5dc8372d9a',
    name: 'Human Flag',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.glutes,
      BodyPart.chest,
      BodyPart.abs,
      BodyPart.triceps,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Agrippe une barre verticale, une main en haut, une en bas.\n'
        '2. Lève le corps tendu à l\'horizontale, gainé de la tête aux pieds.\n'
        '3. Tiens la position, puis redescends en contrôle.',
  ),
  (
    id: 'c01e16e0-e651-42ff-aef6-3a507a24fa15',
    name: 'Incline EZ-Bar Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, barre EZ tenue au-dessus de la poitrine.\n'
        '2. Descends la barre vers le haut de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'cf82f953-384a-445e-9a8f-1f7817f299e2',
    name: 'Incline Dumbbell Curl',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, bras pendants le long du corps, haltères en main.\n'
        '2. Plie les coudes pour monter les haltères vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'de83439a-c328-4970-bc6b-76cc22065a62',
    name: 'Incline Dumbbell Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, un haltère dans chaque main au-dessus de la poitrine.\n'
        '2. Descends les haltères vers le haut de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'a8f4a8b3-ff9a-48ee-a89e-2d7aae3dcccc',
    name: 'Incline Dumbbell Fly',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.biceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, haltères tenus au-dessus de la poitrine, bras légèrement fléchis.\n'
        '2. Ouvre les bras sur les côtés jusqu\'à sentir l\'étirement.\n'
        '3. Remonte les haltères en refermant les bras.',
  ),
  (
    id: '8dcc9c79-c124-4d77-8ebb-2701384ad75b',
    name: 'Incline Hammer Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, bras pendants, haltères en prise neutre.\n'
        '2. Plie les coudes pour monter les haltères vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5150644b-c284-4203-b42f-63317bf52ee0',
    name: 'Incline Push-Up',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Mains posées sur un support surélevé, corps aligné.\n'
        '2. Descends la poitrine vers le support.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'fda0ee88-4064-4292-a056-613d9e3ef3aa',
    name: 'Incline Treadmill Walk',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Règle le tapis avec une inclinaison.\n'
        '2. Marche à allure soutenue en te tenant droit.\n'
        '3. Continue pendant la durée prévue.',
  ),
  (
    id: '0e2f1cae-6ebc-49a6-9e44-28d46d103acb',
    name: 'Inverted Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders, BodyPart.abs],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sous une barre fixée à hauteur de bassin, mains en prise pronation.\n'
        '2. Tire la poitrine vers la barre, corps gainé et aligné.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b17947a4-1fac-42ca-8b17-02b541b077ba',
    name: 'Isometric Neck Lateral Flexion',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis ou debout, place une main sur le côté de la tête.\n'
        '2. Pousse la tête contre la main sans bouger, en résistant.\n'
        '3. Tiens la contraction, puis change de côté.',
  ),
  (
    id: '725fd641-54f2-4107-8aa3-2491edb551ef',
    name: 'Jackknife Sit-Up',
    secondaryMuscles: [BodyPart.quads, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, bras tendus derrière la tête, jambes tendues.\n'
        '2. Relève simultanément le buste et les jambes pour toucher les pieds avec les mains.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '1e1b3bc4-9fa0-42a0-97e8-0b8a04767886',
    name: 'Jefferson Curl',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une surélévation, haltère tenu devant les cuisses.\n'
        '2. Enroule le dos vertèbre par vertèbre en descendant vers le sol, jambes presque tendues.\n'
        '3. Redéroule le dos pour revenir debout.',
  ),
  (
    id: 'c9dfb3b6-2093-47a1-b8a7-af405b93dde6',
    name: 'Jump Rope',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Corde à sauter en main, poignets qui font tourner la corde.\n'
        '2. Saute par petits bonds au moment où la corde passe sous les pieds.\n'
        '3. Garde un rythme régulier pendant la durée prévue.',
  ),
  (
    id: 'e5ffe689-6c6b-409c-afb2-4eef0c887030',
    name: 'Jump Squat',
    secondaryMuscles: [BodyPart.calves, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, pieds largeur d\'épaules.\n'
        '2. Descends en squat puis saute le plus haut possible.\n'
        '3. Réceptionne-toi genoux fléchis et enchaîne.',
  ),
  (
    id: 'b24a1e27-79bc-48a7-ab0b-9db4279efd3d',
    name: 'Jumping Jacks',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, bras le long du corps, pieds joints.\n'
        '2. Saute en écartant les jambes et en levant les bras au-dessus de la tête.\n'
        '3. Saute pour revenir à la position de départ, à un rythme soutenu.',
  ),
  (
    id: 'a677b733-3844-4bd5-9522-e75d1a3846bb',
    name: 'Kettlebell Bulgarian Split Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pied arrière posé sur un banc, kettlebell tenu en main ou en goblet.\n'
        '2. Descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '9cb7c8a6-4cce-4fe1-b775-137614d50d6d',
    name: 'Kettlebell Close-Grip Floor Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.chest],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, kettlebells tenus au-dessus de la poitrine, mains rapprochées.\n'
        '2. Descends les coudes jusqu\'à toucher le sol, coudes proches du corps.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'cd926638-36f1-4496-aebe-788409097716',
    name: 'Kettlebell Concentration Curl',
    secondaryMuscles: [],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, coude calé contre l\'intérieur de la cuisse, kettlebell en main.\n'
        '2. Plie le coude pour monter le kettlebell vers l\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '537f1255-61cf-4f9e-925a-dc2b8e32bd46',
    name: 'Kettlebell Deadlift',
    secondaryMuscles: [BodyPart.forearms, BodyPart.quads],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell au sol entre les pieds.\n'
        '2. Penche-toi et saisis le kettlebell, dos plat.\n'
        '3. Tends les hanches et les genoux pour te redresser.',
  ),
  (
    id: 'f8d46f77-04c4-4118-8408-f2d7c33eae66',
    name: 'Kettlebell Farmer\'s Walk',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.glutes,
      BodyPart.quads,
      BodyPart.abs,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un kettlebell lourd dans chaque main, le long du corps.\n'
        '2. Marche droit devant toi en gardant les épaules basses et le gainage serré.\n'
        '3. Continue sur la distance ou la durée prévue.',
  ),
  (
    id: 'c9427eb3-2af8-4be9-8f53-b63fedd2b016',
    name: 'Kettlebell Floor Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, kettlebells tenus au-dessus de la poitrine.\n'
        '2. Descends les coudes jusqu\'à toucher le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '2f195e79-f330-4073-b1c8-8ec4582ccc40',
    name: 'Kettlebell Goblet Lunge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu contre la poitrine à deux mains.\n'
        '2. Fais un grand pas en avant et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: '54b192da-bfb8-4bc4-a6c8-f391baa59f6d',
    name: 'Kettlebell Halo',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, kettlebell tenu à deux mains devant la poitrine.\n'
        '2. Fais-le tourner autour de la tête en gardant les coudes proches.\n'
        '3. Répète dans l\'autre sens.',
  ),
  (
    id: 'aa08d0f9-9995-4ac7-8fb5-002029ba20ec',
    name: 'Kettlebell Hammer Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, kettlebells tenus en prise neutre.\n'
        '2. Plie les coudes pour monter les kettlebells vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '97f65eca-a86a-4501-9bd9-da77f19616cc',
    name: 'Kettlebell Hip Thrust',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos appuyé contre un banc, kettlebell posé sur les hanches, pieds à plat.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '56436b4f-0725-44ec-8e1d-8cd969b45c08',
    name: 'Kettlebell Kickstand Deadlift',
    secondaryMuscles: [BodyPart.adductors, BodyPart.lowerBack],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un pied légèrement en retrait sur la pointe, kettlebell en main.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '31782d1b-4c18-4249-9379-aa8294184b28',
    name: 'Kettlebell Lunge Press',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.abs, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu à hauteur d\'épaule.\n'
        '2. Fais un pas en avant en fente tout en poussant le kettlebell au-dessus de la tête.\n'
        '3. Reviens debout en redescendant le kettlebell, alterne les jambes.',
  ),
  (
    id: '2451cd64-d00f-4c1d-8bce-4310487f9ae2',
    name: 'Kettlebell Offset Reverse Lunge and Press',
    secondaryMuscles: [
      BodyPart.hamstrings,
      BodyPart.obliques,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu d\'un côté à hauteur d\'épaule.\n'
        '2. Fais un pas en arrière en fente tout en poussant le kettlebell au-dessus de la tête.\n'
        '3. Reviens debout, répète puis change de côté.',
  ),
  (
    id: '0b2aec62-73ee-4b6c-8f0a-c43bd30ade1f',
    name: 'Kettlebell Overhead Carry',
    secondaryMuscles: [
      BodyPart.forearms,
      BodyPart.obliques,
      BodyPart.lowerBack,
      BodyPart.chest,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu à bout de bras au-dessus de la tête.\n'
        '2. Marche droit devant toi en gardant le bras tendu et le gainage serré.\n'
        '3. Continue sur la distance prévue, puis change de bras.',
  ),
  (
    id: 'fe6d974a-695e-4b53-a609-ebb80444a520',
    name: 'Kettlebell Overhead Tricep Extension',
    secondaryMuscles: [],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout ou assis, kettlebell tenu à bout de bras au-dessus de la tête.\n'
        '2. Descends le kettlebell derrière la tête en pliant les coudes.\n'
        '3. Retends les bras vers le haut.',
  ),
  (
    id: '6165d627-7009-4bc3-a1d7-5e0d85f483b6',
    name: 'Kettlebell Pistol Squat',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.abs],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une jambe, kettlebell tenu devant la poitrine, autre jambe tendue devant toi.\n'
        '2. Descends en squat sur la jambe d\'appui le plus bas possible.\n'
        '3. Remonte en poussant dans le sol, puis change de jambe.',
  ),
  (
    id: '8f649c56-5004-4604-8759-378ffab08177',
    name: 'Kettlebell Pullover',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, kettlebell tenu à bout de bras au-dessus de la poitrine.\n'
        '2. Descends le kettlebell derrière la tête.\n'
        '3. Remonte au-dessus de la poitrine.',
  ),
  (
    id: '7c32ad0e-f0d9-4472-8ba6-a86bb20564b1',
    name: 'Kettlebell Reverse Lunge',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.obliques],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, kettlebell tenu en goblet ou le long du corps.\n'
        '2. Fais un grand pas en arrière et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: '824e77e5-86f2-48de-8d97-040f36886035',
    name: 'Kettlebell Reverse Wrist Curl',
    secondaryMuscles: [],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, kettlebell tenu en pronation, poignets hors des genoux.\n'
        '2. Lève les poignets vers le haut.\n'
        '3. Redescends en étirant les poignets.',
  ),
  (
    id: 'dae3e6b7-742a-4b24-83e7-69259f0e2d35',
    name: 'Kettlebell Rotational Lunge',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.obliques],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu devant la poitrine.\n'
        '2. Fais un pas en avant en fente tout en tournant le buste vers la jambe avant.\n'
        '3. Reviens debout, alterne les côtés.',
  ),
  (
    id: '57822d48-941d-42d5-aa53-cae3e00dff9d',
    name: 'Kettlebell Russian Twist',
    secondaryMuscles: [BodyPart.quads, BodyPart.abs],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, buste incliné en arrière, pieds décollés du sol, kettlebell tenu à deux mains.\n'
        '2. Tourne le buste d\'un côté puis de l\'autre en touchant le sol avec le kettlebell.\n'
        '3. Garde les abdos gainés pendant le mouvement.',
  ),
  (
    id: '16b9c59b-8d27-4e2a-9af2-605a28c591df',
    name: 'Kettlebell Shrug',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, kettlebells tenus le long du corps, bras tendus.\n'
        '2. Monte les épaules le plus haut possible.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '9284fb9c-7bcc-4813-88d5-4f4e4a643bfc',
    name: 'Kettlebell Single Leg Deadlift',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une jambe, kettlebell en main.\n'
        '2. Penche le buste vers l\'avant en tendant la jambe libre vers l\'arrière, dos plat.\n'
        '3. Reviens à la verticale, puis change de jambe.',
  ),
  (
    id: '913bf57e-5d1f-4983-a925-95fb4668ea1b',
    name: 'Kettlebell Skull Crusher',
    secondaryMuscles: [],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, kettlebell tenu à bout de bras au-dessus de la poitrine.\n'
        '2. Plie les coudes pour descendre le kettlebell vers le front.\n'
        '3. Retends les bras.',
  ),
  (
    id: 'ecba1aba-c325-4ed3-abbc-481eb8e3968e',
    name: 'Kettlebell Squat',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu en goblet contre la poitrine.\n'
        '2. Descends en squat, coudes entre les genoux.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '6c1821c9-b446-4f58-9660-3f7e2a0655fb',
    name: 'Kettlebell Sumo Deadlift',
    secondaryMuscles: [
      BodyPart.adductors,
      BodyPart.lowerBack,
      BodyPart.hamstrings,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds larges, pointes ouvertes, kettlebell au sol entre les pieds.\n'
        '2. Penche-toi et saisis le kettlebell, dos plat.\n'
        '3. Tends les hanches et les genoux pour te redresser.',
  ),
  (
    id: 'b6aacff4-02cc-49ac-8ae5-57d3661f27f7',
    name: 'Kettlebell Sumo High Pull',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.hamstrings,
      BodyPart.shoulders,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds larges, pointes ouvertes, kettlebell tenu à deux mains entre les jambes.\n'
        '2. Tends les hanches et tire le kettlebell vers le menton, coudes hauts.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'e13b172d-7725-4a43-9d0c-ade84c2fdd2c',
    name: 'Kettlebell Svend Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, presse un kettlebell entre les mains devant la poitrine.\n'
        '2. Pousse-le devant toi en gardant la pression.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '932dc483-6091-40fc-a1fd-7515024e8e91',
    name: 'Kettlebell Swing',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell au sol devant toi, pieds largeur d\'épaules.\n'
        '2. Fais-le passer entre les jambes puis tends les hanches pour le projeter jusqu\'à hauteur d\'épaule.\n'
        '3. Laisse-le redescendre entre les jambes et répète.',
  ),
  (
    id: 'ad6083a8-4105-45c1-b1f5-6f35f6b4b439',
    name: 'Kettlebell Swing Clean',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Fais swinguer le kettlebell entre les jambes.\n'
        '2. Tends les hanches et tire le kettlebell pour le retourner sur l\'avant-bras à hauteur d\'épaule.\n'
        '3. Redescends-le en contrôle.',
  ),
  (
    id: 'a6b874aa-1f28-4c95-afa9-71d603d8481e',
    name: 'Kettlebell Turkish Get Ups',
    secondaryMuscles: [BodyPart.obliques, BodyPart.quads, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le dos, kettlebell tenu à bout de bras au-dessus de l\'épaule.\n'
        '2. Relève-toi progressivement jusqu\'à la position debout, sans jamais quitter le kettlebell des yeux.\n'
        '3. Redescends en suivant le chemin inverse.',
  ),
  (
    id: '5022cce8-272f-407c-af19-4609f428f7a3',
    name: 'Kettlebell Windmills',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.glutes,
      BodyPart.hamstrings,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, un kettlebell tenu au-dessus de la tête, pieds écartés.\n'
        '2. Penche le buste sur le côté en gardant le bras tendu vers le plafond, l\'autre main glisse vers le pied.\n'
        '3. Reviens à la verticale, puis change de côté.',
  ),
  (
    id: '4abe0564-16f2-4d5a-b451-5f5bf6d90769',
    name: 'Kettlebell Wrist Curl',
    secondaryMuscles: [],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, kettlebell tenu en pronation inversée, poignets hors des genoux.\n'
        '2. Plie les poignets pour lever le kettlebell.\n'
        '3. Redescends en étirant les poignets.',
  ),
  (
    id: '497be902-6e38-478f-b0e6-ca53994b0dab',
    name: 'Knee Push Ups',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.abs, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, genoux au sol.\n'
        '2. Descends la poitrine vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '683988d5-be0f-4170-acce-d2b674a91e8c',
    name: 'Kneeling Cable Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. À genoux face à la poulie basse, poignée en main.\n'
        '2. Tire la poignée vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'acb53799-5aa9-46a3-9f2c-1888ddffaec6',
    name: 'L Sit',
    secondaryMuscles: [BodyPart.lats, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.duration,
    instructions:
        '1. Appuie-toi sur des barres parallèles ou le sol, bras tendus.\n'
        '2. Lève les jambes tendues à l\'horizontale, corps en équerre.\n'
        '3. Tiens la position en gainant les abdos.',
  ),
  (
    id: 'e6eb2226-92df-4a20-97ac-9f3c3a42cfb9',
    name: 'Landmine Press',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Une extrémité de la barre calée dans un coin, l\'autre tenue à hauteur d\'épaule.\n'
        '2. Pousse la barre devant toi en diagonale jusqu\'à tendre le bras.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '9c7343bb-83c6-4d17-9178-7b485fc23076',
    name: 'Locust Pose',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le ventre, bras le long du corps.\n'
        '2. Soulève la poitrine, les bras et les jambes du sol.\n'
        '3. Tiens la position en contractant le bas du dos.',
  ),
  (
    id: '093b8c50-6ee0-4f57-b455-e916bfdf8d32',
    name: 'Lunge',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout, mains sur les hanches.\n'
        '2. Fais un grand pas en avant et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: 'c56d936d-481b-4456-a96d-605c7eed13d7',
    name: 'Lying Leg Raise',
    secondaryMuscles: [BodyPart.obliques, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, jambes tendues, mains sous les fessiers.\n'
        '2. Lève les jambes tendues vers le plafond.\n'
        '3. Redescends en contrôle sans toucher le sol.',
  ),
  (
    id: '88886693-9386-4322-af65-694e77784898',
    name: 'Lying Tricep Extension',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, haltères tenus à bout de bras au-dessus de la poitrine.\n'
        '2. Plie les coudes pour descendre les haltères vers le front.\n'
        '3. Retends les bras.',
  ),
  (
    id: 'b129a2cd-9e9f-412c-a754-901544175b9a',
    name: 'Machine Back Extension',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings],
    equipment: Equipment.other,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis ou allongé sur la machine, buste calé, jambes bloquées.\n'
        '2. Penche le buste vers l\'avant en contrôle.\n'
        '3. Redresse le buste en contractant le bas du dos.',
  ),
  (
    id: 'c8b921a4-0c2b-448f-b1b6-d6d944793410',
    name: 'Machine Bicep Curl',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, coudes calés sur le pupitre.\n'
        '2. Plie les coudes pour monter la poignée vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '2b1b79b1-6e30-4b71-b42e-af7276430cc3',
    name: 'Machine Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis ou debout à la machine, épaules ou genoux sous les coussins, avant-pieds sur la plateforme.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: 'b5a8a7dc-9be4-4459-bc25-d4f08df7a23f',
    name: 'Machine Chest Fly',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, bras posés sur les leviers, coudes légèrement pliés.\n'
        '2. Rapproche les bras devant la poitrine.\n'
        '3. Reviens en contrôle jusqu\'à l\'étirement.',
  ),
  (
    id: 'b50979b7-2f81-4594-a33c-a18248eb49bf',
    name: 'Machine Preacher Curl',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, coudes calés sur le pupitre incliné.\n'
        '2. Plie les coudes pour monter la poignée vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '0e1a706b-c872-43af-8b75-dc468dfbc1e9',
    name: 'Machine Seated Crunch',
    secondaryMuscles: [BodyPart.obliques],
    equipment: Equipment.other,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, buste calé contre le coussin supérieur.\n'
        '2. Plie le buste vers l\'avant en contractant les abdos.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'd7237e28-2668-483f-933d-c9f9d6494858',
    name: 'Machine Triceps Extension',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, coudes calés, mains sur les poignées.\n'
        '2. Tends les bras vers le bas.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '6b8bbe41-0b72-440d-9dee-d5740079270d',
    name: 'Medicine Ball Slam',
    secondaryMuscles: [BodyPart.glutes, BodyPart.lats, BodyPart.obliques],
    equipment: Equipment.other,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, médecine-ball tenu à deux mains au-dessus de la tête.\n'
        '2. Projette le ballon au sol de toutes tes forces en gainant les abdos.\n'
        '3. Ramasse le ballon et répète.',
  ),
  (
    id: '95d19606-2b98-4dd8-a89b-7af57f33f5bc',
    name: 'Mountain Climbers',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Position de planche, mains sous les épaules.\n'
        '2. Amène un genou vers la poitrine puis change rapidement de jambe.\n'
        '3. Garde un rythme soutenu pendant la durée prévue.',
  ),
  (
    id: '31b05d84-c41e-45b1-b462-381ae7ff2e79',
    name: 'Muscle Snatch',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.glutes,
      BodyPart.hamstrings,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre tenue devant les cuisses.\n'
        '2. Tire la barre le long du corps jusqu\'au-dessus de la tête en un seul mouvement, sans passer sous la barre.\n'
        '3. Redescends la barre en contrôle.',
  ),
  (
    id: 'c0022d52-1060-4366-93b0-1b6434760140',
    name: 'Muscle Ups',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.biceps, BodyPart.chest],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, prise large.\n'
        '2. Tire-toi puissamment puis passe le buste au-dessus de la barre en poussant sur les bras.\n'
        '3. Redescends en contrôle jusqu\'à la position suspendue.',
  ),
  (
    id: 'a55b2b1a-e7df-4fb5-8258-0d432803666c',
    name: 'Negative Pull Ups',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.forearms,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Saute ou monte pour avoir le menton au-dessus de la barre.\n'
        '2. Descends le plus lentement possible jusqu\'à tendre les bras.\n'
        '3. Remonte comme tu peux et répète.',
  ),
  (
    id: '4248d7cf-7a76-41e2-aec8-921f803e951c',
    name: 'Neutral Grip Pull Ups',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.forearms,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à des poignées parallèles, paumes face à face.\n'
        '2. Tire-toi jusqu\'au menton au-dessus des mains.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'e7ea1afd-d808-42ac-a9d1-59ff2e3a55da',
    name: 'One-Arm Dumbbell Push Press',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.obliques,
      BodyPart.quads,
      BodyPart.triceps,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Haltère tenu à hauteur d\'épaule, jambes légèrement fléchies.\n'
        '2. Pousse sur les jambes puis avec le bras pour envoyer l\'haltère au-dessus de la tête.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '56f03156-90a3-4d69-baa3-5e9a60f35dbb',
    name: 'One-Arm Dumbbell Swing',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.shoulders,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Haltère au sol devant toi, pieds largeur d\'épaules.\n'
        '2. Fais-le passer entre les jambes puis tends les hanches pour le projeter jusqu\'à hauteur d\'épaule.\n'
        '3. Laisse-le redescendre entre les jambes, puis change de bras.',
  ),
  (
    id: '863382f5-9dd8-4d2f-8ab6-526878d0cb3d',
    name: 'One Arm Kettlebell Bicep Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, kettlebell tenu en main, bras tendu.\n'
        '2. Plie le coude pour monter le kettlebell vers l\'épaule.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '2108ca80-a34d-43b2-b6d5-0f4960509214',
    name: 'One-Arm Kettlebell Bottoms-Up Press',
    secondaryMuscles: [BodyPart.forearms, BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu retourné, poids vers le haut, à hauteur d\'épaule.\n'
        '2. Pousse-le au-dessus de la tête en gardant l\'équilibre.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '0b529620-69f1-4b11-ac06-acb22f616bbd',
    name: 'One Arm Kettlebell Floor Glute Bridge Press',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.hamstrings,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, kettlebell tenu à bout de bras au-dessus de l\'épaule.\n'
        '2. Pousse les hanches vers le haut tout en tendant le bras vers le plafond.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '89e61fef-2dd8-4f9b-8768-4aed08491ae8',
    name: 'One Arm Kettlebell Floor Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé au sol, genoux pliés, kettlebell tenu au-dessus de la poitrine.\n'
        '2. Descends le coude jusqu\'à toucher le sol.\n'
        '3. Repousse jusqu\'à tendre le bras, puis change de bras.',
  ),
  (
    id: '912ad2a0-2851-4c0e-864a-17dfbd0165f2',
    name: 'One Arm Kettlebell Front Squat',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.hamstrings,
      BodyPart.obliques,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu à hauteur d\'épaule d\'un côté.\n'
        '2. Descends en squat, buste droit.\n'
        '3. Remonte en poussant dans le sol, puis change de côté.',
  ),
  (
    id: '66357519-2fe0-4e1f-b9ed-56f4e0107865',
    name: 'One Arm Kettlebell Push Press',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.quads,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu à hauteur d\'épaule, jambes légèrement fléchies.\n'
        '2. Pousse sur les jambes puis avec le bras pour envoyer le kettlebell au-dessus de la tête.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: 'ab998327-fd55-4e07-8b58-decafc29b0db',
    name: 'One Arm Kettlebell Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, kettlebell tenu bras tendu.\n'
        '2. Tire le kettlebell vers la hanche en rapprochant l\'omoplate.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: 'e038aaab-ddbc-4f03-a1d2-05ec0e438d3e',
    name: 'One Arm Kettlebell Shoulder Press',
    secondaryMuscles: [
      BodyPart.obliques,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell tenu à hauteur d\'épaule.\n'
        '2. Pousse-le au-dessus de la tête jusqu\'à tendre le bras.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '078292f9-3799-409c-ae6e-509ab3ac1475',
    name: 'One Arm Kettlebell Swing',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.lowerBack,
      BodyPart.obliques,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Kettlebell au sol devant toi, pieds largeur d\'épaules.\n'
        '2. Fais-le passer entre les jambes puis tends les hanches pour le projeter jusqu\'à hauteur d\'épaule.\n'
        '3. Laisse-le redescendre entre les jambes, puis change de bras.',
  ),
  (
    id: '151646b6-751b-447f-baa5-87e5048320bf',
    name: 'One-Arm Kettlebell Tricep Kickback',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, coude collé au corps, kettlebell en main.\n'
        '2. Tends le bras vers l\'arrière en gardant le coude fixe.\n'
        '3. Reviens en contrôle, puis change de bras.',
  ),
  (
    id: 'e51980b5-9ca9-46bc-ab67-d60be87b2708',
    name: 'One-Arm Landmine Press',
    secondaryMuscles: [BodyPart.obliques, BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Une extrémité de la barre calée dans un coin, l\'autre tenue d\'une main à hauteur d\'épaule.\n'
        '2. Pousse la barre devant toi en diagonale jusqu\'à tendre le bras.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: 'f0bb6adf-81c9-405f-bd73-f6006f59da15',
    name: 'One-Arm Lat Pulldown',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie haute, poignée simple tenue d\'une main.\n'
        '2. Tire la poignée vers le bas jusqu\'à la hanche.\n'
        '3. Remonte en contrôle, puis change de bras.',
  ),
  (
    id: '3c0747e5-9862-430b-a867-87f9e9a56db8',
    name: 'One-Arm Single-Leg Dumbbell Romanian Deadlift',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.obliques,
    ],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une jambe, haltère tenu de l\'autre main.\n'
        '2. Penche le buste vers l\'avant en tendant la jambe libre vers l\'arrière, dos plat.\n'
        '3. Reviens à la verticale, puis change de côté.',
  ),
  (
    id: '9ae2ef55-a2ba-4cc6-9f07-bdc5bfc9198f',
    name: 'One-Arm Single-Leg Kettlebell Romanian Deadlift',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.forearms,
      BodyPart.obliques,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une jambe, kettlebell tenu de l\'autre main.\n'
        '2. Penche le buste vers l\'avant en tendant la jambe libre vers l\'arrière, dos plat.\n'
        '3. Reviens à la verticale, puis change de côté.',
  ),
  (
    id: 'cf89f6c1-a22d-424d-8389-3dedfdf273a2',
    name: 'Overhead Squat',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre tenue à bout de bras au-dessus de la tête, prise large.\n'
        '2. Descends en squat en gardant la barre au-dessus de la tête.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '1c3058a5-4f3c-40df-a1fc-9702b71aca3b',
    name: 'Overhead Tricep Extension',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout ou assis, haltère tenu à deux mains au-dessus de la tête.\n'
        '2. Descends l\'haltère derrière la tête en pliant les coudes.\n'
        '3. Retends les bras vers le haut.',
  ),
  (
    id: '2f9b598b-ab0e-445a-9a3c-c90a7c401c01',
    name: 'Pause Deadlift',
    secondaryMuscles: [BodyPart.quads, BodyPart.trapeziusUpper],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre au sol, pieds largeur de hanches.\n'
        '2. Tire la barre jusqu\'à hauteur de genou et marque une pause.\n'
        '3. Termine le mouvement en tendant les hanches.',
  ),
  (
    id: '63b1faeb-f72c-4d4e-b00f-80d089af71bb',
    name: 'Pause Pull-Up',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, bras tendus.\n'
        '2. Tire-toi jusqu\'au menton au-dessus de la barre et marque une pause.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'a57603aa-2b00-4fa2-bcd5-90177723b9a9',
    name: 'Pause Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut du dos, debout.\n'
        '2. Descends en squat et marque une pause en bas.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'a8b4983a-10f9-47cc-b30a-3db5a37b5a0f',
    name: 'Paused Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre tenue au-dessus de la poitrine.\n'
        '2. Descends la barre et marque une pause juste au-dessus de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '46514fa5-8a8e-4a5d-af99-8c76fccfdcb1',
    name: 'Paused Incline Bench Press',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné, barre tenue au-dessus de la poitrine.\n'
        '2. Descends la barre et marque une pause juste au-dessus de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '4444ad68-b524-40a7-b51a-06dd2976bbcb',
    name: 'Paused Overhead Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre sur le haut de la poitrine, debout.\n'
        '2. Pousse la barre au-dessus de la tête et marque une pause en haut.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '208bda6f-eb8d-4bec-8ac0-33c661297436',
    name: 'Pendlay Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.lowerBack, BodyPart.shoulders],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché à l\'horizontale, barre au sol sous les épaules.\n'
        '2. Tire la barre vers le ventre d\'un coup sec, dos plat.\n'
        '3. Repose la barre au sol entre chaque répétition.',
  ),
  (
    id: '35ad6771-6f9f-4145-b032-70191466c441',
    name: 'Pike Push Ups',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. Fesses hautes, mains et pieds au sol, corps en V inversé.\n'
        '2. Plie les coudes pour descendre la tête vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '0629267b-f3a0-4124-b219-7a0c54bcb986',
    name: 'Pilates Kneeling Side Kick',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. À quatre pattes, tends une jambe sur le côté à hauteur de hanche.\n'
        '2. Balance la jambe tendue vers l\'avant puis vers l\'arrière.\n'
        '3. Répète puis change de jambe.',
  ),
  (
    id: '9f69e8dd-8da1-42e8-87ee-945acbb86fdd',
    name: 'Pilates Leg Pull Back',
    secondaryMuscles: [
      BodyPart.hamstrings,
      BodyPart.shoulders,
      BodyPart.triceps,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis, mains au sol derrière toi, jambes tendues devant, corps en ligne.\n'
        '2. Lève une jambe tendue vers le plafond.\n'
        '3. Redescends en contrôle et alterne.',
  ),
  (
    id: 'd3b7ae7e-f21d-47c7-858b-4e78c8492540',
    name: 'Pilates Leg Pull Front',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.lowerBack, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. En position de planche, appuyé sur les mains.\n'
        '2. Lève une jambe tendue vers le plafond.\n'
        '3. Redescends en contrôle et alterne.',
  ),
  (
    id: '0dd361b9-776a-407c-bdcf-d5de515b111f',
    name: 'Pilates Roll Over',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, jambes tendues vers le plafond.\n'
        '2. Enroule le bassin pour amener les jambes au-dessus de la tête.\n'
        '3. Redéroule la colonne pour revenir en contrôle.',
  ),
  (
    id: 'e99b3886-6813-42dd-bf5f-1e597a7dd8b8',
    name: 'Pilates Side Bend',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis sur la hanche, jambes empilées, une main au sol.\n'
        '2. Lève les hanches du sol pour former une ligne droite.\n'
        '3. Redescends en contrôle, puis change de côté.',
  ),
  (
    id: '362282f4-2385-49e4-a4b9-fefdd78c2773',
    name: 'Pistol Squat',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Debout sur une jambe, autre jambe tendue devant toi, bras tendus devant pour l\'équilibre.\n'
        '2. Descends en squat sur la jambe d\'appui le plus bas possible.\n'
        '3. Remonte en poussant dans le sol, puis change de jambe.',
  ),
  (
    id: '77f6e0e9-1795-4325-8936-80e345b74257',
    name: 'Planche',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.duration,
    instructions:
        '1. Mains au sol, bras tendus, corps penché vers l\'avant.\n'
        '2. Décolle les pieds du sol et aligne le corps à l\'horizontale, gainé.\n'
        '3. Tiens la position le plus longtemps possible.',
  ),
  (
    id: '3a2bb9ad-65f9-485e-aaa7-4c45f6811834',
    name: 'Plate-Loaded Donkey Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant sur la machine, disques chargés sur les hanches, avant-pieds sur la plateforme.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: '3206cebf-6179-4f4c-8f5a-93c9a68dce72',
    name: 'Plate-Loaded Glute Drive',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos calé contre le support de la machine, pieds à plat sur la plateforme.\n'
        '2. Pousse la plateforme en tendant les hanches, fessiers contractés.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '62942ed8-5bba-4466-acf4-21bc26f864b3',
    name: 'Plate-Loaded Lateral Raise',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis ou debout à la machine, bras posés sur les leviers.\n'
        '2. Lève les bras sur les côtés jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'a37045c2-b081-4b0c-bb95-eb77a3ee2780',
    name: 'Plate-Loaded Shrug',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.other,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout à la machine, poignées tenues le long du corps.\n'
        '2. Monte les épaules le plus haut possible.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5e7771e7-6c9c-48c1-82b4-8031ac8b60e3',
    name: 'Plate Pinch',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.other,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pince deux disques face à face entre le pouce et les doigts.\n'
        '2. Tiens-les serrés, bras le long du corps ou légèrement tendu.\n'
        '3. Maintiens la prise pendant la durée prévue.',
  ),
  (
    id: '8d3c66eb-b5e6-4df9-887e-077c0ac371da',
    name: 'Plate Pullover',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, disque tenu à deux mains au-dessus de la poitrine.\n'
        '2. Descends le disque derrière la tête, bras presque tendus.\n'
        '3. Remonte au-dessus de la poitrine.',
  ),
  (
    id: '3c2f7dfa-68ee-4fae-8804-f839e89e6dfe',
    name: 'Plyo Lunge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de fente, un pied devant, un derrière.\n'
        '2. Saute pour changer de jambe en l\'air.\n'
        '3. Réceptionne-toi en fente de l\'autre côté et enchaîne.',
  ),
  (
    id: 'cf3086e8-5ec0-4a6f-b36c-f8e9701fdf36',
    name: 'Plyo Push-Up',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains sous les épaules.\n'
        '2. Descends puis repousse explosivement pour décoller les mains du sol.\n'
        '3. Réceptionne-toi en contrôle et enchaîne.',
  ),
  (
    id: 'ffc2e8c2-dd9c-48cb-a067-70df475e20f7',
    name: 'Preacher Curl',
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste appuyé sur un pupitre incliné, barre tenue bras tendus vers le bas.\n'
        '2. Plie les coudes pour monter la barre vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '99e4f20c-1eca-4bb1-8b44-a92f0b4329a7',
    name: 'Preacher Hammer Curl',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste appuyé sur un pupitre incliné, haltères tenus en prise neutre.\n'
        '2. Plie les coudes pour monter les haltères vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b88bba08-bd78-4e2b-bff1-be5eabebc52e',
    name: 'Pseudo Planche Push Ups',
    secondaryMuscles: [BodyPart.chest, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains tournées vers les pieds, placées au niveau des hanches.\n'
        '2. Penche le corps vers l\'avant en descendant la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '9a19473e-7eb8-4dfd-9194-57cc1a16e888',
    name: 'Push Jerk',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.quads,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre à hauteur d\'épaule, jambes légèrement fléchies.\n'
        '2. Pousse sur les jambes puis avec les bras pour envoyer la barre au-dessus de la tête, jambes qui refléchissent légèrement à la réception.\n'
        '3. Redescends la barre en contrôle.',
  ),
  (
    id: '686ff7f6-1845-40ce-9304-b70bbd2ada65',
    name: 'Push Press',
    secondaryMuscles: [BodyPart.quads, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre à hauteur d\'épaule, jambes légèrement fléchies.\n'
        '2. Pousse sur les jambes puis avec les bras pour envoyer la barre au-dessus de la tête.\n'
        '3. Redescends la barre en contrôle.',
  ),
  (
    id: '6e1219f5-3011-4c66-af27-1d0608ba133c',
    name: 'Rack Pull',
    secondaryMuscles: [BodyPart.forearms, BodyPart.lats],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre positionnée en hauteur (à hauteur de genou) sur des supports.\n'
        '2. Saisis la barre, dos plat.\n'
        '3. Tends les hanches et les genoux pour te redresser.',
  ),
  (
    id: '6389c895-1658-4693-8467-fe8ddb5814f5',
    name: 'Reverse Grip Bent Over Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.lowerBack,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, barre tenue en supination (paumes vers toi).\n'
        '2. Tire la barre vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5e60f560-44f2-4f4f-944d-815d61ed3089',
    name: 'Reverse Grip Lat Pulldown',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.trapeziusUpper],
    equipment: Equipment.cable,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie haute, prise en supination, mains rapprochées.\n'
        '2. Tire la barre vers le haut de la poitrine.\n'
        '3. Remonte en contrôle.',
  ),
  (
    id: 'eaec95e4-9cca-4069-b72f-90f9484d17eb',
    name: 'Reverse Lunge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères en main.\n'
        '2. Fais un grand pas en arrière et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: '15062e13-a81d-4740-94c6-9d802c9f07d7',
    name: 'Reverse Nordic Curl',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. À genoux, chevilles bloquées, buste droit.\n'
        '2. Penche le buste vers l\'arrière en gardant les hanches tendues, le plus loin possible.\n'
        '3. Reviens à la position de départ en contractant les quadriceps.',
  ),
  (
    id: '0ec6aad0-8836-436c-9511-5850833dec7e',
    name: 'Reverse Plank',
    secondaryMuscles: [
      BodyPart.hamstrings,
      BodyPart.shoulders,
      BodyPart.triceps,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis, jambes tendues, mains au sol derrière les hanches.\n'
        '2. Pousse les hanches vers le haut pour aligner le corps des épaules aux talons.\n'
        '3. Tiens la position.',
  ),
  (
    id: '958fedb6-f049-441f-9503-310ca7f4a4dd',
    name: 'Reverse Plank Dips',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.glutes, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.duration,
    instructions:
        '1. En position de planche inversée, mains sous les épaules, jambes tendues.\n'
        '2. Plie les coudes pour descendre les fessiers vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'f7aed666-a7b5-4576-8696-c6b410f0278a',
    name: 'Reverse Tabletop Hip Pulses',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de table inversée, mains et pieds au sol, hanches levées.\n'
        '2. Fais de petits mouvements de bas en haut avec les hanches.\n'
        '3. Continue pendant la durée ou le nombre de répétitions prévu.',
  ),
  (
    id: '9c6e9045-c3d4-4a4b-b0b6-33b88dbb0663',
    name: 'Reverse Tabletop Hold',
    secondaryMuscles: [
      BodyPart.hamstrings,
      BodyPart.shoulders,
      BodyPart.triceps,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.duration,
    instructions:
        '1. Position de table inversée, mains et pieds au sol, hanches levées, corps aligné.\n'
        '2. Contracte les fessiers et gaine les abdos.\n'
        '3. Tiens la position.',
  ),
  (
    id: '2a699940-1bb3-4862-873e-0bbc814e2e92',
    name: 'Revolved Chair Pose',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.glutes],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout, plie les genoux comme pour t\'asseoir.\n'
        '2. Tourne le buste et pose un coude sur le genou opposé, mains jointes.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: '215479e6-fb0d-4735-bc6a-e2ef5eb077d4',
    name: 'Revolved Crescent Lunge',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.reps,
    instructions:
        '1. Fais un grand pas en avant, genou avant plié à 90°.\n'
        '2. Tourne le buste vers la jambe avant, mains jointes ou bras écartés.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: '042676ed-1820-4ee6-a30d-9a7a907c7c90',
    name: 'Ring Dead Hang',
    secondaryMuscles: [BodyPart.lats, BodyPart.abs, BodyPart.trapeziusUpper],
    equipment: Equipment.other,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.duration,
    instructions:
        '1. Agrippe deux anneaux, bras tendus.\n'
        '2. Laisse le corps pendre librement, épaules relâchées.\n'
        '3. Tiens la position le plus longtemps possible.',
  ),
  (
    id: 'ad90707d-f93e-415e-943a-b85672fa23ec',
    name: 'Ring Dips',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. En appui sur deux anneaux, bras tendus.\n'
        '2. Descends en pliant les coudes jusqu\'à 90°.\n'
        '3. Repousse pour remonter, anneaux stabilisés.',
  ),
  (
    id: '055844d8-d086-48d6-9fe2-4aa37f3ee430',
    name: 'Ring Face Pull',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.other,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Anneaux tenus devant toi, corps incliné en arrière.\n'
        '2. Tire les anneaux vers le visage en écartant les coudes.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'ee6979d5-aa9d-4b75-aacc-d5ba8692cca8',
    name: 'Ring Muscle-Up',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.biceps,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à deux anneaux, bras tendus.\n'
        '2. Tire-toi puissamment puis passe le buste au-dessus des anneaux en poussant sur les bras.\n'
        '3. Redescends en contrôle jusqu\'à la position suspendue.',
  ),
  (
    id: 'cb4fded0-96b5-4109-95d0-a8041527a6a0',
    name: 'Ring Push-Up',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Mains sur deux anneaux, position de pompe.\n'
        '2. Descends la poitrine vers les anneaux en stabilisant les bras.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '2f5c31b1-78d0-45fc-9cf1-0775a7ae7b4c',
    name: 'Ring Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sous deux anneaux réglés bas, corps incliné, pieds au sol.\n'
        '2. Tire la poitrine vers les anneaux.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '82d0cc29-1a57-484a-a180-eeda6a37e0ab',
    name: 'Rings Inverted Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.forearms,
      BodyPart.shoulders,
      BodyPart.abs,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sous deux anneaux réglés à hauteur de bassin, corps gainé.\n'
        '2. Tire la poitrine vers les anneaux.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5e1c95e2-17b2-49e0-b257-273e31cba14e',
    name: 'Romanian Deadlift',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, barre tenue devant les cuisses.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, jambes presque tendues, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: 'de3d55b3-33ee-436d-bf68-c1891b248afe',
    name: 'Rope Climb',
    secondaryMuscles: [BodyPart.biceps, BodyPart.forearms, BodyPart.abs],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Agrippe la corde à deux mains au-dessus de toi.\n'
        '2. Grimpe en tirant avec les bras et en t\'aidant des jambes si besoin.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'e16ebb64-a761-4c7e-a830-7ccc4a9cb367',
    name: 'Rowing Machine',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis, pieds calés, poignée en main, jambes fléchies.\n'
        '2. Pousse avec les jambes puis tire la poignée vers le buste.\n'
        '3. Reviens en sens inverse et répète à un rythme régulier.',
  ),
  (
    id: 'c2c08680-3a8a-432d-964d-932a4aa89ade',
    name: 'Running',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Cours à une allure régulière, buste droit, foulée naturelle.\n'
        '2. Garde une respiration régulière.\n'
        '3. Continue pendant la durée ou la distance prévue.',
  ),
  (
    id: '240276c4-0816-4eeb-816a-d9eb6232c3ed',
    name: 'Russian Twist',
    secondaryMuscles: [BodyPart.quads],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis, buste incliné en arrière, pieds décollés du sol.\n'
        '2. Tourne le buste d\'un côté puis de l\'autre, mains jointes ou avec un poids.\n'
        '3. Garde les abdos gainés pendant le mouvement.',
  ),
  (
    id: 'fc49190a-bba1-403c-9571-329ae931a662',
    name: 'Scapular Pull Ups',
    secondaryMuscles: [BodyPart.forearms, BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, bras tendus.\n'
        '2. Monte les épaules vers les oreilles puis abaisse-les en rapprochant les omoplates, sans plier les coudes.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '982d58a0-6245-41b3-8bd3-40ae5f453b21',
    name: 'Scissor Kicks',
    secondaryMuscles: [BodyPart.obliques, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, jambes tendues légèrement décollées du sol.\n'
        '2. Croise les jambes en ciseaux, l\'une au-dessus de l\'autre.\n'
        '3. Continue pendant la durée ou le nombre de répétitions prévu.',
  ),
  (
    id: '30db32fd-5c46-4f99-ac8c-abd87734d748',
    name: 'Seated Barbell Overhead Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, barre tenue à hauteur d\'épaule.\n'
        '2. Pousse la barre au-dessus de la tête jusqu\'à tendre les bras.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '970c33ac-e99e-403e-b52c-1a970fb3c07b',
    name: 'Seated Dumbbell Shoulder Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, un haltère dans chaque main à hauteur d\'épaule.\n'
        '2. Pousse les haltères au-dessus de la tête.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '8af6af84-fd20-49ce-b5d6-60890e6c8154',
    name: 'Seated Dumbbell Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, haltères tenus en pronation, bras le long du corps.\n'
        '2. Plie les coudes pour monter les haltères vers les épaules.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '84d3bec6-c999-40b8-8568-d8a5777a609e',
    name: 'Seated Dumbbell Lateral Raise',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, un haltère dans chaque main le long du corps.\n'
        '2. Lève les bras sur les côtés jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '3ce554ad-d54b-4a40-8717-044b024e07fc',
    name: 'Seated Dumbbell Tricep Extension',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, haltère tenu à deux mains au-dessus de la tête.\n'
        '2. Descends l\'haltère derrière la tête en pliant les coudes.\n'
        '3. Retends les bras vers le haut.',
  ),
  (
    id: 'a05abb3e-41c2-48a8-bfc4-c257a377aeaf',
    name: 'Seated Smith Machine Shoulder Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis sous la barre guidée, à hauteur d\'épaule.\n'
        '2. Pousse la barre au-dessus de la tête jusqu\'à tendre les bras.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'f33239e8-fbfa-4de3-a45e-26758754fcb5',
    name: 'Side-Lying Hip Abduction',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le côté, jambes tendues, l\'une sur l\'autre.\n'
        '2. Lève la jambe du dessus vers le plafond.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'e6980a99-0937-457e-815f-4cd953bcaf8c',
    name: 'Side-Lying Hip Abduction Hold',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le côté, jambes tendues, l\'une sur l\'autre.\n'
        '2. Lève la jambe du dessus vers le plafond.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: '688c951f-6cc7-41e6-911c-22f97227757d',
    name: 'Side Lying Hip Adduction',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le côté, jambe du dessus pliée devant, jambe du dessous tendue.\n'
        '2. Lève la jambe du dessous vers le plafond.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '398d7b39-91bb-4c71-b3f9-9e1721d39a6e',
    name: 'Side-Lying Hip Adduction Hold',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le côté, jambe du dessus pliée devant, jambe du dessous tendue.\n'
        '2. Lève la jambe du dessous vers le plafond.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: '49393d78-8141-4fe8-a9e9-a8e1d775ff47',
    name: 'Side-Lying Lateral Raise',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le côté, haltère tenu dans la main du dessus.\n'
        '2. Lève le bras tendu vers le plafond.\n'
        '3. Redescends en contrôle, puis change de côté.',
  ),
  (
    id: '20363a9b-d379-4872-9e71-d1ec8990f332',
    name: 'Side Plank with Leg Lift',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Position de planche latérale, appuyé sur un avant-bras.\n'
        '2. Lève la jambe du dessus vers le plafond.\n'
        '3. Tiens la position en gainant le tronc.',
  ),
  (
    id: '9c12f378-eb9e-4e05-9c38-00aefd1da693',
    name: 'Side Plank Leg Lift Hold',
    secondaryMuscles: [BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Position de planche latérale, appuyé sur un avant-bras.\n'
        '2. Lève la jambe du dessus vers le plafond.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: 'de610412-aee6-46e3-9759-375b81e73496',
    name: 'Single-Arm Chest-Supported Dumbbell Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé face contre un banc incliné, haltère tenu d\'une main.\n'
        '2. Tire l\'haltère vers la hanche en rapprochant l\'omoplate.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '550cbd1d-a4db-415a-879f-fde291fbd0bc',
    name: 'Single-Arm Dumbbell Overhead Tricep Extension',
    secondaryMuscles: [BodyPart.obliques],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout ou assis, haltère tenu à bout de bras au-dessus de la tête.\n'
        '2. Descends l\'haltère derrière la tête en pliant le coude.\n'
        '3. Retends le bras, puis change de bras.',
  ),
  (
    id: '2c497cdc-ed65-4232-a3bb-30daf8f8085d',
    name: 'Single-Arm Hammer Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltère tenu en prise neutre.\n'
        '2. Plie le coude pour monter l\'haltère vers l\'épaule.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: 'fdb3fc0c-4fc5-4ad4-8b0c-b48159aea5f2',
    name: 'Single-Arm Machine Shoulder Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, poignée tenue d\'une main à hauteur d\'épaule.\n'
        '2. Pousse la poignée au-dessus de la tête.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '16b15846-8bb6-486d-be3b-cbc5ea49f277',
    name: 'Single-Arm Plate-Loaded Lateral Raise',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout à la machine, bras posé sur le levier.\n'
        '2. Lève le bras sur le côté jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle, puis change de bras.',
  ),
  (
    id: '95cd4bba-a3cf-4a09-8c11-d43d1f637026',
    name: 'Single Arm Tricep Pushdown',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.cable,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie haute, poignée simple tenue d\'une main, coude collé au corps.\n'
        '2. Tends le bras vers le bas.\n'
        '3. Remonte en contrôle, puis change de bras.',
  ),
  (
    id: '9048d99f-145c-4350-8a2c-8adcb67b3f88',
    name: 'Single Dumbbell Svend Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, presse un haltère entre les paumes devant la poitrine.\n'
        '2. Pousse-le devant toi en gardant la pression.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'c7227e3b-1cb6-4a1a-9dc5-12012ea75a58',
    name: 'Single Leg Extension',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la machine, tibia calé derrière le rouleau, une jambe engagée.\n'
        '2. Tends le genou pour lever la charge.\n'
        '3. Redescends en contrôle, puis change de jambe.',
  ),
  (
    id: '4d679a6c-0141-4c89-b637-1ae251a71e46',
    name: 'Single Leg Glute Bridge',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, une jambe pliée pied à plat, l\'autre tendue en l\'air.\n'
        '2. Pousse les hanches vers le haut en contractant le fessier.\n'
        '3. Redescends en contrôle, puis change de jambe.',
  ),
  (
    id: '56314d18-ffb9-4e0c-b309-1f4e8ae0bfab',
    name: 'Single-Leg Glute Bridge Hold',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le dos, une jambe pliée pied à plat, l\'autre tendue en l\'air.\n'
        '2. Pousse les hanches vers le haut en contractant le fessier.\n'
        '3. Tiens la position, puis change de jambe.',
  ),
  (
    id: '46b9e7fc-a130-4c2b-8590-7c0142efe8ef',
    name: 'Single Leg Lying Leg Curl',
    secondaryMuscles: [BodyPart.calves],
    equipment: Equipment.machine,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur la machine, une cheville calée sous le rouleau.\n'
        '2. Plie le genou pour amener le talon vers la fesse.\n'
        '3. Redescends en contrôle, puis change de jambe.',
  ),
  (
    id: '0caad64d-69c5-4f52-83b8-7d17461191db',
    name: 'Single Leg Press',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la presse à cuisses, un pied sur la plateforme.\n'
        '2. Plie le genou vers la poitrine.\n'
        '3. Repousse la plateforme sans tendre complètement le genou, puis change de jambe.',
  ),
  (
    id: 'f848d2ed-4d87-4039-acd1-78ad88945c80',
    name: 'Single Leg Romanian Deadlift',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sur une jambe, haltère tenu de l\'autre main.\n'
        '2. Penche le buste vers l\'avant en tendant la jambe libre vers l\'arrière, dos plat.\n'
        '3. Reviens à la verticale, puis change de côté.',
  ),
  (
    id: '1b4bd57f-52b6-49e2-9a13-f07c6c7f2a9f',
    name: 'Sit-Ups',
    secondaryMuscles: [BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, genoux pliés, mains derrière la tête.\n'
        '2. Relève tout le buste jusqu\'à toucher les genoux.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b1a4e9a7-21f7-47c4-b5c3-ae22b054f144',
    name: 'Sled Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.glutes,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Corde ou sangle du traîneau tenue à deux mains, buste penché en arrière.\n'
        '2. Tire le traîneau vers toi en pliant les coudes.\n'
        '3. Relâche en contrôle et répète.',
  ),
  (
    id: '0f1e4d96-d410-44fb-be2b-98d24bd08de6',
    name: 'Smith Machine Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc sous la barre guidée, mains largeur d\'épaules.\n'
        '2. Descends la barre vers la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'e8ccdf4c-c05e-4a4e-9dbe-c51fd2c0b965',
    name: 'Smith Machine Bent Over Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.lowerBack,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.machine,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant sous la barre guidée.\n'
        '2. Tire la barre vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'd0139cb3-a609-4e0f-950e-6e3b96aff444',
    name: 'Smith Machine Bulgarian Split Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pied arrière posé sur un banc, sous la barre guidée sur le haut du dos.\n'
        '2. Descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: 'e298b4b5-7887-419c-914d-cf3dc3617d49',
    name: 'Smith Machine Calf Raise',
    secondaryMuscles: [],
    equipment: Equipment.machine,
    bodyPart: BodyPart.calves,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sous la barre guidée, avant-pieds sur une surélévation.\n'
        '2. Monte sur la pointe des pieds le plus haut possible.\n'
        '3. Redescends en étirant les mollets.',
  ),
  (
    id: 'c00a69c5-8169-49c7-9ceb-f79bc53b0905',
    name: 'Smith Machine Decline Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc décliné sous la barre guidée.\n'
        '2. Descends la barre vers le bas de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '69fc3266-0968-40db-8880-c3300556e502',
    name: 'Smith Machine Front Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre guidée tenue à hauteur d\'épaule, coudes hauts.\n'
        '2. Descends en squat, buste droit.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '5d533bc1-86bd-473e-b7c0-fba71f36c6c8',
    name: 'Smith Machine Good Morning',
    secondaryMuscles: [BodyPart.glutes],
    equipment: Equipment.machine,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre guidée sur le haut du dos, debout.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '2c71401f-908b-415b-bd85-118f601d9172',
    name: 'Smith Machine Hip Thrust',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos appuyé contre un banc, barre guidée sur les hanches, pieds à plat.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b43ebcab-405a-4c63-a570-5a485399d1d7',
    name: 'Smith Machine Incline Bench Press',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc incliné sous la barre guidée.\n'
        '2. Descends la barre vers le haut de la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'f3adf777-9fd7-497b-8ae0-e229231999f8',
    name: 'Smith Machine Romanian Deadlift',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.glutes,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.machine,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sous la barre guidée, tenue devant les cuisses.\n'
        '2. Penche le buste vers l\'avant, hanches reculées, jambes presque tendues, dos plat.\n'
        '3. Reviens à la verticale en poussant les hanches.',
  ),
  (
    id: '18ef3003-6279-468f-a5cd-d168871a7e7a',
    name: 'Smith Machine Reverse Grip Bent Over Row',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.trapeziusUpper],
    equipment: Equipment.machine,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste penché en avant, barre guidée tenue en supination.\n'
        '2. Tire la barre vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'ebf49926-f060-4e04-b57f-2b85e688d37a',
    name: 'Smith Machine Reverse Lunge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre guidée sur le haut du dos, debout.\n'
        '2. Fais un grand pas en arrière et descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Repousse pour revenir debout, alterne les jambes.',
  ),
  (
    id: '40fd996e-4da4-4e02-bd07-ca855ee86585',
    name: 'Smith Machine Shoulder Press',
    secondaryMuscles: [BodyPart.trapeziusUpper, BodyPart.triceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis ou debout sous la barre guidée, à hauteur d\'épaule.\n'
        '2. Pousse la barre au-dessus de la tête.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '0311016a-5628-46f4-a9df-4b5b319afb0e',
    name: 'Smith Machine Shrug',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.machine,
    bodyPart: BodyPart.trapeziusUpper,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sous la barre guidée, tenue devant les cuisses.\n'
        '2. Monte les épaules le plus haut possible.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '0828be13-92f2-4aed-9da0-e871b66b4abf',
    name: 'Smith Machine Split Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un pied devant, l\'autre en fente arrière, sous la barre guidée.\n'
        '2. Descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '6da55a17-6a12-4391-9460-150c8d5f9e62',
    name: 'Smith Machine Squat',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.machine,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre guidée sur le haut du dos, debout.\n'
        '2. Descends en squat, buste droit.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '7b478788-9fd5-4a30-b9c6-88409aa29a7e',
    name: 'Smith Machine Upright Row',
    secondaryMuscles: [BodyPart.biceps],
    equipment: Equipment.machine,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout sous la barre guidée, tenue devant les cuisses.\n'
        '2. Tire la barre vers le haut, coudes qui sortent sur les côtés.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '4942890f-4ba8-4f7e-a39d-3d8538010ff8',
    name: 'Snatch',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.hamstrings,
      BodyPart.shoulders,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre au sol, prise large.\n'
        '2. Tire la barre d\'un coup au-dessus de la tête en tendant les hanches et les jambes.\n'
        '3. Passe rapidement sous la barre pour la réceptionner bras tendus, puis remonte debout.',
  ),
  (
    id: '26bfcf1c-a778-477f-92f8-17bcb360f23d',
    name: 'Spider Curl',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Buste appuyé face contre un pupitre incliné, haltères tenus bras tendus vers le bas.\n'
        '2. Plie les coudes pour monter les haltères vers le front.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'e2545fcd-9060-407a-8df5-9803bc7b77d0',
    name: 'Split Jerk',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre à hauteur d\'épaule.\n'
        '2. Plie légèrement les jambes puis pousse la barre au-dessus de la tête en fendant une jambe devant.\n'
        '3. Ramène les pieds ensemble, bras tendus.',
  ),
  (
    id: '96bcd91c-78f9-40b6-b7e2-11d8e11fb343',
    name: 'Split Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.reps,
    instructions:
        '1. Un pied devant, l\'autre en fente arrière.\n'
        '2. Descends jusqu\'à ce que le genou arrière frôle le sol.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '552f1efc-c035-4b7b-802f-7cc32c731d77',
    name: 'Spoto Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre tenue au-dessus de la poitrine.\n'
        '2. Descends la barre et marque une pause juste au-dessus de la poitrine, sans la toucher.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'feab3448-1976-4e76-846d-4588615a6634',
    name: 'Stability Ball Hip Bridge',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.abs],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le dos, talons posés sur un swiss ball, bras au sol.\n'
        '2. Pousse les hanches vers le haut en contractant les fessiers.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '3cb7dda4-9510-44c7-8509-d4dd27f565b4',
    name: 'Stability Ball Knee Tuck',
    secondaryMuscles: [
      BodyPart.shoulders,
      BodyPart.quads,
      BodyPart.obliques,
      BodyPart.chest,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Position de planche, tibias posés sur un swiss ball.\n'
        '2. Roule le ballon vers les mains en ramenant les genoux vers la poitrine.\n'
        '3. Retends les jambes pour revenir en planche.',
  ),
  (
    id: '11ef5872-cc00-4d5a-822a-35f5d487f974',
    name: 'Stability Ball Push-Up',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.abs, BodyPart.triceps],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds posés sur un swiss ball, mains au sol, position de pompe.\n'
        '2. Descends la poitrine vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'c7a3bc07-7f5c-41e4-a88c-a6e3bf9a9453',
    name: 'Stability Ball Push-Up (Hands on Ball)',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.abs, BodyPart.triceps],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Mains posées sur un swiss ball, pieds au sol, position de pompe.\n'
        '2. Descends la poitrine vers le ballon.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '8ebe21cd-85e1-4f31-9437-96f2b9d7fc1c',
    name: 'Stability Ball Wall Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Swiss ball calé entre le dos et un mur.\n'
        '2. Descends en squat en laissant le ballon rouler le long du dos.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '6b580612-d381-4225-9ecc-2eabba0b0897',
    name: 'Stair Climber',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Monte sur l\'appareil, mains sur les rampes si besoin.\n'
        '2. Monte les marches à un rythme régulier.\n'
        '3. Continue pendant la durée prévue.',
  ),
  (
    id: '04564799-c5cc-4962-9bfd-8c6fde5f4020',
    name: 'Stationary Bike',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Assis sur le vélo, selle réglée à hauteur de hanche.\n'
        '2. Pédale à intensité régulière.\n'
        '3. Continue pendant la durée prévue.',
  ),
  (
    id: '06d6d07b-3a8a-4d00-98d4-dccd6d958e55',
    name: 'Straight-Arm Pulldown',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie haute, bras tendus, barre en main.\n'
        '2. Descends la barre vers les cuisses en gardant les bras tendus.\n'
        '3. Remonte en contrôle.',
  ),
  (
    id: '589b501a-bf0a-474a-860f-21bdf67dfbfb',
    name: 'Straight-Bar Cable Front Raise',
    secondaryMuscles: [BodyPart.chest],
    equipment: Equipment.cable,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos à la poulie basse, barre tenue devant les cuisses.\n'
        '2. Lève la barre tendue devant toi jusqu\'à hauteur d\'épaule.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5157a335-1217-4783-9744-a29bfaa67ade',
    name: 'Straight Bar Dips',
    secondaryMuscles: [BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. En appui sur une barre droite, bras tendus.\n'
        '2. Descends en pliant les coudes jusqu\'à 90°.\n'
        '3. Repousse pour remonter.',
  ),
  (
    id: '377f2a01-e696-4ad7-bf9b-3c2471ed015c',
    name: 'Strict Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, dos calé contre un mur, haltères tenus en pronation.\n'
        '2. Plie les coudes pour monter les haltères vers les épaules, sans bouger le buste.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '4c1a0f7c-f2dd-49dd-9923-57fd0b95088c',
    name: 'Suitcase Carry',
    secondaryMuscles: [
      BodyPart.lowerBack,
      BodyPart.glutes,
      BodyPart.quads,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.kettlebell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un kettlebell lourd dans une main, le long du corps.\n'
        '2. Marche droit devant toi en résistant à l\'inclinaison du buste.\n'
        '3. Continue sur la distance prévue, puis change de main.',
  ),
  (
    id: 'aa26ef48-b473-43e6-ad0e-defa11df126d',
    name: 'Sumo Deadlift',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.hamstrings],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Pieds larges, pointes ouvertes, barre au sol devant toi.\n'
        '2. Saisis la barre à l\'intérieur des jambes, dos plat.\n'
        '3. Tends les hanches et les genoux pour te redresser.',
  ),
  (
    id: 'f0ca46e3-1194-4204-8865-387dbfb3da3e',
    name: 'Supine Windshield Wipers',
    secondaryMuscles: [BodyPart.quads, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, bras écartés, jambes tendues vers le plafond.\n'
        '2. Fais basculer les jambes d\'un côté puis de l\'autre, comme des essuie-glaces.\n'
        '3. Garde les épaules au sol pendant le mouvement.',
  ),
  (
    id: 'd52d0c28-7b66-4286-b3f6-488f7b4509d9',
    name: 'Supported Shoulderstand',
    secondaryMuscles: [BodyPart.glutes, BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.duration,
    instructions:
        '1. Allongé sur le dos, mains sous les hanches pour te soutenir.\n'
        '2. Monte les jambes et les hanches à la verticale.\n'
        '3. Tiens la position en gainant le tronc.',
  ),
  (
    id: 'fbd02086-13ba-4bd4-9240-856acee664b4',
    name: 'Svend Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, presse une plaque ou un coussin entre les mains devant la poitrine.\n'
        '2. Pousse-le devant toi en gardant la pression.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '7aa4355d-6294-491b-98db-e0c93d349dd4',
    name: 'Thoracic Bridge',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lowerBack,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis, une main au sol derrière toi, jambes pliées.\n'
        '2. Pousse les hanches vers le haut en tournant le buste vers le plafond, autre bras tendu.\n'
        '3. Reviens en contrôle, puis change de côté.',
  ),
  (
    id: '7790ef99-c1ed-410b-96dd-9ed3852e869f',
    name: 'Three-Legged Downward Dog',
    secondaryMuscles: [BodyPart.hamstrings, BodyPart.trapeziusUpper],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.reps,
    instructions:
        '1. En position de chien tête en bas.\n'
        '2. Lève une jambe tendue vers le plafond en gardant les hanches carrées.\n'
        '3. Redescends en contrôle, puis change de jambe.',
  ),
  (
    id: '25c4362d-159d-4732-8a17-602cddc64961',
    name: 'Thruster',
    secondaryMuscles: [
      BodyPart.glutes,
      BodyPart.trapeziusUpper,
      BodyPart.triceps,
    ],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Barre à hauteur d\'épaule, descends en squat complet.\n'
        '2. Remonte du squat en enchaînant directement sur une poussée de la barre au-dessus de la tête.\n'
        '3. Redescends la barre à hauteur d\'épaule et répète.',
  ),
  (
    id: 'd9f2b354-40f5-40b4-9700-d0bf2d80262b',
    name: 'Toes to Bar',
    secondaryMuscles: [BodyPart.forearms, BodyPart.lats, BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Suspends-toi à la barre, bras tendus.\n'
        '2. Remonte les jambes tendues jusqu\'à toucher la barre avec les pieds.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '0f088283-24e5-493e-abc8-3a4b568b80b9',
    name: 'Treadmill Running',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Règle la vitesse du tapis.\n'
        '2. Cours à allure régulière, buste droit.\n'
        '3. Continue pendant la durée prévue.',
  ),
  (
    id: '03c451ed-d7b0-49f9-af3a-f488b7aa2b3e',
    name: 'Tree Pose',
    secondaryMuscles: [BodyPart.lowerBack, BodyPart.calves],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout sur une jambe, place le pied de l\'autre jambe contre la cuisse ou le mollet.\n'
        '2. Joins les mains devant la poitrine ou au-dessus de la tête.\n'
        '3. Tiens l\'équilibre, puis change de jambe.',
  ),
  (
    id: '6768eea4-c769-4b50-9e4e-0c689ccf1689',
    name: 'TRX Bicep Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.other,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues, corps incliné en arrière, bras tendus.\n'
        '2. Plie les coudes pour tirer le corps vers les mains.\n'
        '3. Retends les bras en contrôle.',
  ),
  (
    id: '9821517a-c9c6-477a-8010-9a6039e0cd76',
    name: 'TRX Chest Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.abs, BodyPart.triceps],
    equipment: Equipment.other,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues, corps incliné en avant, bras tendus devant toi.\n'
        '2. Plie les coudes pour descendre la poitrine vers les mains.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '217ff03b-60a4-4cc4-8f8a-008331733b97',
    name: 'TRX Face Pull',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.other,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues, corps incliné en arrière, bras tendus devant toi.\n'
        '2. Tire les mains vers le visage en écartant les coudes.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: '3dc4958b-95dd-4f9f-8ff7-3fc5106950a0',
    name: 'TRX Hamstring Curl',
    secondaryMuscles: [BodyPart.calves, BodyPart.glutes],
    equipment: Equipment.other,
    bodyPart: BodyPart.hamstrings,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur le dos, talons dans les sangles, hanches levées.\n'
        '2. Plie les genoux pour ramener les talons vers les fessiers.\n'
        '3. Retends les jambes en contrôle.',
  ),
  (
    id: '5a1f0053-b332-482e-91eb-83a73444b822',
    name: 'TRX Lunge',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Un pied dans la sangle, tenue derrière toi.\n'
        '2. Descends en fente, le pied arrière suspendu dans la sangle.\n'
        '3. Remonte en poussant dans le sol, puis change de jambe.',
  ),
  (
    id: 'd22df6fc-da6f-4994-89ce-4553dc0f65f2',
    name: 'TRX Pistol Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Une main tenant une sangle pour l\'équilibre, debout sur une jambe.\n'
        '2. Descends en squat sur la jambe d\'appui.\n'
        '3. Remonte en poussant dans le sol, puis change de jambe.',
  ),
  (
    id: '39946b4b-df7d-460b-bb4e-84e3c488c755',
    name: 'TRX Plank',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.obliques],
    equipment: Equipment.other,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.duration,
    instructions:
        '1. Pieds dans les sangles, mains au sol, position de planche.\n'
        '2. Garde le corps aligné, tête aux talons, abdos gainés.\n'
        '3. Tiens la position.',
  ),
  (
    id: 'c47bfbd5-0732-4505-bfaa-613f317923ce',
    name: 'TRX Row',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.other,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues, corps incliné en arrière, bras tendus devant toi.\n'
        '2. Tire la poitrine vers les mains en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'b9ddf0ba-8ab8-4340-85a9-f92921ebebd0',
    name: 'TRX Side Plank',
    secondaryMuscles: [BodyPart.glutes, BodyPart.shoulders],
    equipment: Equipment.other,
    bodyPart: BodyPart.obliques,
    trackingType: TrackingType.duration,
    instructions:
        '1. Un pied dans la sangle, position de planche latérale, appuyé sur un avant-bras.\n'
        '2. Garde le corps aligné, hanches hautes.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: '90c2940e-bcf4-4b59-a77d-8c3087b04e22',
    name: 'TRX Squat',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.other,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues à deux mains, pieds largeur d\'épaules.\n'
        '2. Descends en squat en te retenant légèrement aux sangles.\n'
        '3. Remonte en poussant dans le sol.',
  ),
  (
    id: '4d976e57-12b6-4085-b47c-84f501253b9c',
    name: 'TRX Triceps Extension',
    secondaryMuscles: [],
    equipment: Equipment.other,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues, corps incliné en avant, mains près du front.\n'
        '2. Tends les bras devant toi.\n'
        '3. Reviens en contrôle en pliant les coudes.',
  ),
  (
    id: 'f2aa53ed-eb39-4f65-8443-d3af0e66d275',
    name: 'TRX Y-Fly',
    secondaryMuscles: [BodyPart.trapeziusUpper],
    equipment: Equipment.other,
    bodyPart: BodyPart.shoulders,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Sangles tenues, corps incliné en arrière, bras tendus devant toi.\n'
        '2. Lève les bras en formant un Y en rapprochant les omoplates.\n'
        '3. Reviens en contrôle.',
  ),
  (
    id: 'caaa25f3-7fec-4461-ae66-98848e9c3c9e',
    name: 'V-Bar Lat Pulldown',
    secondaryMuscles: [BodyPart.biceps, BodyPart.trapeziusUpper],
    equipment: Equipment.machine,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie haute, poignée en V tenue en prise neutre.\n'
        '2. Tire la poignée vers le haut de la poitrine.\n'
        '3. Remonte en contrôle.',
  ),
  (
    id: '3e66e1df-03df-49c7-ad1c-574ad80e7591',
    name: 'V-Bar Tricep Pushdown',
    secondaryMuscles: [],
    equipment: Equipment.cable,
    bodyPart: BodyPart.triceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Face à la poulie haute, poignée en V, coudes collés au corps.\n'
        '2. Tends les bras vers le bas.\n'
        '3. Remonte en contrôle.',
  ),
  (
    id: '06b662a1-ff3f-4d91-94ed-27f46abdc39a',
    name: 'V-Sit',
    secondaryMuscles: [BodyPart.obliques],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Assis, mains au sol derrière les hanches.\n'
        '2. Lève les jambes tendues et le buste pour former un V.\n'
        '3. Tiens la position en gainant les abdos.',
  ),
  (
    id: 'cab6604b-9db5-44d6-a884-e99566dfaf26',
    name: 'V Ups',
    secondaryMuscles: [BodyPart.obliques, BodyPart.abs],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.quads,
    trackingType: TrackingType.reps,
    instructions:
        '1. Allongé sur le dos, bras tendus derrière la tête, jambes tendues.\n'
        '2. Relève simultanément le buste et les jambes pour toucher les pieds avec les mains.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '82dbea5a-e85a-42f9-a130-72784b593afe',
    name: 'Walking',
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.cardio,
    trackingType: TrackingType.duration,
    instructions:
        '1. Marche à un rythme soutenu, buste droit.\n'
        '2. Garde une foulée régulière et une respiration naturelle.\n'
        '3. Continue pendant la durée ou la distance prévue.',
  ),
  (
    id: 'b92038ff-4fe6-4a00-8a18-7fb3f161fd4d',
    name: 'Wall Push Ups',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Mains posées sur un mur à hauteur d\'épaule, corps incliné.\n'
        '2. Plie les coudes pour rapprocher la poitrine du mur.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: 'd9187c0d-df0d-43a7-b485-be3ffa10f3eb',
    name: 'Wall Sit',
    secondaryMuscles: [BodyPart.hamstrings],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Dos calé contre un mur, descends comme pour t\'asseoir jusqu\'à cuisses parallèles au sol.\n'
        '2. Garde les genoux à 90°, bras le long du corps.\n'
        '3. Tiens la position.',
  ),
  (
    id: 'b84f3317-da55-44ac-8822-6c7011257f21',
    name: 'Warrior I',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.lowerBack],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Fais un grand pas en avant, genou avant plié à 90°.\n'
        '2. Lève les bras au-dessus de la tête, hanches face à l\'avant.\n'
        '3. Tiens la position, puis change de jambe.',
  ),
  (
    id: '1f9cf866-25c6-4106-9d05-dfcd89cbc4ad',
    name: 'Warrior III',
    secondaryMuscles: [BodyPart.lowerBack],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Debout sur une jambe, penche le buste vers l\'avant à l\'horizontale.\n'
        '2. Tends l\'autre jambe vers l\'arrière, bras tendus devant toi.\n'
        '3. Tiens l\'équilibre, puis change de jambe.',
  ),
  (
    id: 'b93d80cd-0ac6-4d78-81f1-d6a10adee82f',
    name: 'Warrior II',
    secondaryMuscles: [BodyPart.adductors, BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.glutes,
    trackingType: TrackingType.duration,
    instructions:
        '1. Fais un grand pas de côté, genou avant plié à 90°.\n'
        '2. Tends les bras à l\'horizontale, regard vers la main avant.\n'
        '3. Tiens la position, puis change de côté.',
  ),
  (
    id: 'a035b305-56ed-4d7b-9061-3987eccdf7f0',
    name: 'Weighted Dips',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. En appui sur des barres parallèles, poids lesté attaché à la ceinture.\n'
        '2. Descends en pliant les coudes jusqu\'à 90°.\n'
        '3. Repousse pour remonter.',
  ),
  (
    id: 'ebdaadfa-082c-4dd2-ad29-9025b431e181',
    name: 'Weighted Pull-Up',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, poids lesté attaché à la ceinture.\n'
        '2. Tire-toi jusqu\'au menton au-dessus de la barre.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'acadee82-15f1-4166-9429-55dbb49953b5',
    name: 'Weighted Wall Crunch',
    secondaryMuscles: [BodyPart.obliques],
    equipment: Equipment.other,
    bodyPart: BodyPart.abs,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Dos au sol, pieds calés contre un mur, genoux à 90°, poids tenu sur la poitrine.\n'
        '2. Relève le buste en contractant les abdos.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '5a1743a2-e672-4749-adf9-1ee74a12f20c',
    name: 'Wide-Grip Bench Press',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.barbell,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Allongé sur un banc, barre tenue en prise large.\n'
        '2. Descends la barre vers la poitrine.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '0d00864d-3cf8-41fc-9953-6f6a100115a3',
    name: 'Wide Grip Pull Ups',
    secondaryMuscles: [
      BodyPart.biceps,
      BodyPart.shoulders,
      BodyPart.trapeziusUpper,
    ],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Suspends-toi à la barre, prise large.\n'
        '2. Tire-toi jusqu\'au menton au-dessus de la barre.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: '9cc590df-dc2c-4df7-bafa-8db48c1c5571',
    name: 'Wide Grip Push Ups',
    secondaryMuscles: [BodyPart.shoulders, BodyPart.triceps],
    equipment: Equipment.bodyweight,
    bodyPart: BodyPart.chest,
    trackingType: TrackingType.reps,
    instructions:
        '1. Position de pompe, mains bien écartées, plus larges que les épaules.\n'
        '2. Descends la poitrine vers le sol.\n'
        '3. Repousse jusqu\'à tendre les bras.',
  ),
  (
    id: '3449ca54-8d74-4d37-9a9f-c369f1bc29b9',
    name: 'Wide Grip Seated Cable Row',
    secondaryMuscles: [BodyPart.biceps, BodyPart.shoulders],
    equipment: Equipment.cable,
    bodyPart: BodyPart.lats,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis face à la poulie basse, barre large en main.\n'
        '2. Tire la barre vers le ventre en rapprochant les omoplates.\n'
        '3. Redescends en contrôle.',
  ),
  (
    id: 'a9328f6f-476b-464d-873c-8828dcf5d6b1',
    name: 'Wide-Stance Leg Press',
    secondaryMuscles: [BodyPart.glutes, BodyPart.hamstrings, BodyPart.quads],
    equipment: Equipment.machine,
    bodyPart: BodyPart.adductors,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis à la presse à cuisses, pieds larges sur la plateforme.\n'
        '2. Plie les genoux vers la poitrine.\n'
        '3. Repousse la plateforme sans tendre complètement les genoux.',
  ),
  (
    id: '4315fcda-cf8a-487b-b63d-85f263ba6ae4',
    name: 'Bilateral Dumbbell Wrist Curl',
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Assis, avant-bras posés sur les cuisses, haltères tenus en pronation inversée, poignets hors des genoux.\n'
        '2. Plie les poignets pour lever les haltères.\n'
        '3. Redescends en étirant les poignets.',
  ),
  (
    id: '98f9a6c2-df94-43f4-9a18-b6fa90348aaa',
    name: 'Wrist Roller',
    secondaryMuscles: [BodyPart.shoulders],
    equipment: Equipment.other,
    bodyPart: BodyPart.forearms,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Tiens un rouleau à deux mains, bras tendus devant toi, corde lestée qui pend.\n'
        '2. Enroule la corde en tournant les poignets.\n'
        '3. Déroule-la en contrôle, puis répète dans l\'autre sens.',
  ),
  (
    id: '3d46e28e-617a-4d80-b390-6f18a6426e04',
    name: 'Zottman Curl',
    secondaryMuscles: [BodyPart.forearms],
    equipment: Equipment.dumbbell,
    bodyPart: BodyPart.biceps,
    trackingType: TrackingType.weightReps,
    instructions:
        '1. Debout, haltères tenus en pronation (paumes vers le haut).\n'
        '2. Plie les coudes pour monter les haltères vers les épaules.\n'
        '3. Tourne les poignets (paumes vers le bas) et redescends en contrôle.',
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

/// Chest Dip et Tricep Dip (migration v10 → v11, D28) : poids du corps avec
/// une ceinture de lest possible, donc « poids + reps » plutôt que reps
/// seules, pour suivre la charge ajoutée.
const builtInWeightRepsInV11 = <String>{
  '5190e591-346d-4944-85aa-1204579521d0', // Chest Dip
  '5871b2cb-cb62-4433-af1d-69da2e1d3c4d', // Tricep Dip
};

/// Trapèzes divisés en haut et milieu/bas (migration v11 → v12, D29) : les
/// haussements d'épaules (shrugs, tirage menton) ciblent surtout le haut, les
/// mouvements de rétraction des omoplates (face pull) le milieu/bas.
const builtInTrapeziusUpperInV12 = <String>{
  'f60801a4-8ec9-47bb-83ff-bbf9666388b7', // Shrug (Dumbbell)
  '7ab07103-9606-4546-a5bb-64f177a69d9d', // Shrug (Barbell)
  '03d4a6fc-2db5-4dc5-8d44-a2a259a69adb', // Upright Row (Barbell)
};
const builtInTrapeziusLowerInV12 = <String>{
  '75458925-1deb-4d8f-9e4d-acc867a239c3', // Face Pull (Cable)
};

/// Idem, mais en muscle secondaire (Rear Delt Fly), pas en groupe principal.
const builtInTrapeziusLowerSecondaryInV12 = <String>{
  'b9a7bb05-91e6-4d93-a091-8ed7f960ef2b', // Rear Delt Fly (Dumbbell)
};

/// Nouveaux exercices intégrés (migration v12 → v13, D30) : bibliothèque
/// très largement élargie, à partir du jeu de données ouvert RepDB.
const _addedInV13 = <String>{
  '2a79d1bd-c3b5-4628-8a5b-ddeace90fc13',
  '55bcf59a-8db9-458d-82de-c5311ab9e540',
  '105db7bb-9081-41c7-b1fa-dbeb4a8f6d8e',
  '794b5675-7a1b-493b-b887-00e1a6314e28',
  '703db9b6-438a-49a5-959e-4c601ca562af',
  'c933a066-df8f-4161-89be-acaaed331864',
  '611359a0-989a-4441-8002-8afe7dfcb074',
  '77ada746-1af8-444d-9cf6-4a7d566740ff',
  'd0ca37e6-d409-475a-943a-2def9a83033b',
  '23b06c18-563a-4524-a856-951442e370d4',
  '423707f1-ed08-41c2-b869-6a652ae570f7',
  'f2d7addf-7592-4b86-994a-877a31d8aded',
  '0535ecbb-802e-4116-b633-5d8e6f63b8f0',
  'e59833c9-bf4c-4f7c-881d-05af04efe489',
  '97809c17-a63c-4cbb-a30f-c73eff146608',
  'aa650871-168f-4366-bc00-ccb97fd62160',
  '185cc545-f9ac-4843-9634-009567667baa',
  'ee0c19bf-ebdc-410b-85fc-2f113fe4fa43',
  'd867f7be-4255-4515-8681-45da58b60544',
  '3e977114-10bc-449e-bbf1-57eaa4d80d38',
  'ebd16805-ac3c-48f9-9e89-e6d610e31e60',
  '46385882-42da-4dc1-9d18-bc261a9a5b7d',
  'e238e8c5-5ae7-410c-abb3-c5f828c0084f',
  '235c8187-5aa5-4d6d-a7dd-7efb9bbb3c32',
  '5e084351-37a2-46df-b976-5a6bfb2cb90b',
  'ddd71953-ed83-4765-8e6f-e9990aa95ec9',
  '8cd2cf23-fa67-4d32-bbf6-82535e547690',
  '9290f2aa-6d82-4832-a63f-8b3fcb8001bd',
  'e94ef660-0038-44ac-8159-51def07a06e8',
  'b7e2465e-6436-486f-81fa-6196d69886ba',
  'bfd8ef44-9b4a-43ac-ab0a-61de2eec9e72',
  '57c58244-2315-4603-a408-3fc979636b86',
  'f578ac63-1318-4cc9-9b1f-6af6e3ae1996',
  '56674d24-6938-4ce7-bea4-8cb14559a1b5',
  'a2afbca0-2286-4a35-8cd6-d971becf00a3',
  '1b888480-4273-4af3-a2dd-76b9ea21c103',
  '56f6bcf0-3dcc-427a-b73a-c6cc3b0cc2b7',
  'b5c5a175-587f-4b03-b6f0-8ebfa14e1b12',
  '392e2093-992c-4754-aa83-6b76eca95c53',
  '7039d147-4a23-4633-80ab-e14fc5dbdf8c',
  '657ea91a-2513-4035-90bb-07cfcd06c645',
  '5f38dd0e-4cbe-4466-8be5-a14924394728',
  'a0a5538b-b6cc-49b7-bff2-d9cd06b4d86f',
  '7642406e-6d19-4453-b963-173382b61849',
  '9669c58a-0436-4884-9d88-7d7c3931fad3',
  'f8b37a64-0e9e-4cf3-a6f3-b723945a8374',
  '68f9d01d-7732-404a-a9a5-471f7114a513',
  'fd86a1d2-cd39-4466-9614-86647b56114b',
  '798791fe-ec47-43d3-a641-491989a676be',
  '9b6e5003-2c9d-438b-ad02-8b297306002c',
  '7d34003d-c6cf-430b-8d6b-4039f58d8387',
  'a69d8acb-812f-4cf0-8955-a245b9370b7e',
  '4f3c6b9a-199a-4d70-b1b9-f1a04b553b21',
  '91a65243-57b4-4c4b-8f1f-3f17fb07c41b',
  '70d34e87-e00d-44c4-a3f4-092fba548046',
  'de24ff72-66d2-448f-8397-12cf12500349',
  'ac8077a6-a36d-4e1e-914c-42b2fa8c7bde',
  '3bd501b2-e32f-4d78-93a5-b6db62e066c0',
  '0d1c4df9-635e-49ee-a056-596a73256840',
  '8929f745-d8ab-473a-80a4-67e94d13217f',
  '87412fd9-6835-48b4-ae5a-3b4f8df3b3e4',
  '87993ccb-1a17-4fa6-b5b8-80ed83656cfd',
  'c3409eab-add7-475b-9b6f-a8d1dbc170bc',
  '4399c09c-6b24-4c96-8e58-f5668e127aeb',
  '07132602-7bf7-4e64-b694-797a40f78e63',
  'c3b01bdc-ccac-4048-bfa1-111496207740',
  'fb0dd56c-7ed0-4379-836f-55aa717289a1',
  '4d14ee2e-c88f-44d0-82b8-350a48130ebc',
  '4b34345c-89d3-47fd-b797-81e69ed6b7ed',
  'f838b38a-98e5-475b-a87a-dea7e2ad6331',
  '5749cc60-3d4d-439f-8456-17a726c14482',
  '0217590a-9ca5-4fd5-abc9-45313c390f8a',
  'a595a6b1-c4f3-4dea-9cc0-0a9431f531a9',
  '18092716-c8a7-4492-ad2f-78050a0b6d65',
  '6fc97062-4655-40a1-a9d5-10d36a1567d4',
  'ea18253d-b686-4136-8c0d-c6b749d47ddb',
  'ec6b3059-3127-412a-925e-36264358fb37',
  'c4ce8001-8719-4691-91b0-cc647a5354c2',
  '7f377fc6-9445-4afe-b114-705c6e6656cf',
  '8b10c013-b224-4126-8edc-399ca9927ca5',
  'e355ffe8-7720-42a7-967f-9224a03da6f9',
  '97ef1d5a-f5ac-4602-96d3-5ae619cb4551',
  'f6f7361d-b11d-4663-8027-a274ae6220e4',
  '3cdd0e4b-1cbc-42de-a1d1-958e4fc6fa54',
  'a29d240f-2485-494e-80d0-6f5bff2616de',
  '04d803ef-e339-459a-b4e8-c4e3ae1ebe10',
  '83d912ef-2dee-4256-9a56-627b918885b2',
  'bb138595-60e6-4eb9-b783-5105ab76e6fc',
  'a2952370-fab1-40ee-b01d-9e9ccbfdef91',
  '3847a1d6-5818-428f-a31e-ddc764ea805c',
  '348d0ef8-d9c0-40c5-b2bd-a6e3bd70347d',
  '7323de34-2cd7-4f0f-b736-b638276ae075',
  '008a0633-394b-4ca6-9568-29232ab85ddc',
  'dd121a38-44cc-40fe-8062-3cfeaa267728',
  '42868baf-3ade-4aaf-b843-b5d194790900',
  'a60b9cd0-f487-4402-bd9b-92660afaae78',
  '94d1f14c-a7ad-4207-8508-923d166be5a6',
  '8cd64d24-20a5-4c0a-923a-9b826da44783',
  '9663028d-f4df-42d2-990c-5b2956376ba1',
  'd3f4779f-cbc3-4f54-82df-6bcf083d116e',
  '1ac06ed7-eb23-45cd-9c64-4163aa8fec90',
  '7e8d7ccd-a4d4-4b20-9c3a-3839cbf30bfd',
  '727398fb-66d3-4ad3-897b-2078242eea2d',
  '9e753f77-c697-46c6-8d6f-8d33d96c0a06',
  '1888d084-c635-4386-89e6-d9d448444e9e',
  'de9e221b-6909-4a26-9fa0-58e49190753d',
  '95ece427-7c91-4b19-963c-20c92915e256',
  'af9b3bd9-6eb6-47fd-9740-9a9c178d4929',
  '6a9c2e12-eeb4-46ff-92b8-a275537e8f59',
  'd35dc3a3-d550-4656-a588-67be5ea351c5',
  'ddb41974-5323-4770-a51f-e9df8f9446c1',
  '343707a9-e3e8-4299-b4ed-f6423e0c32f5',
  '0135d048-4704-4888-8848-843ab40a134d',
  'ae893317-cf5b-4677-8439-bc126bcc1406',
  'e1e5cb62-57eb-4f6e-9fb5-ef9ec78a47df',
  '5ccf52b7-558c-4876-993e-ff9c2dbffc04',
  '76482391-3586-42bc-b813-4c5964699930',
  '0b306edc-bba1-47d8-b2e9-389d935c85e3',
  '9a746e54-55c8-4e7b-95c7-2bf7c6a5f32b',
  '7adbce18-f343-4b87-8421-b231d38e7130',
  '203d8f1f-9580-491a-a0c7-7df37c71e23b',
  'df02d4e9-5529-4228-9bc7-8328ac79fed3',
  '46a7bdf6-e2a9-4674-ad18-3de4a8c9b305',
  'd599c721-98e8-447e-80c5-bbb00b99bca0',
  '4524d98c-e548-4741-bdc3-f38904e4595f',
  '0e1e9a69-1f0c-40f3-8e7e-f1a78c339074',
  '0bfa393d-dfcf-44c9-840a-242f9d26f750',
  'b619dc24-e4b9-42a7-8864-4f92fbc5cbca',
  'a4ed5818-bdb5-414c-98a6-e256bc52fa19',
  'cc55202e-9762-4725-92f2-5f66a3981c04',
  '3afa3729-d570-4eea-886d-1948e2ff5516',
  'bacbde0b-5350-4b0d-8a5a-fffb59105861',
  '0e72424b-0122-4bf0-a729-eccf9fb085e1',
  '9c782953-a669-4817-97ec-7f2d3e237477',
  '076999df-dbdd-4cb3-adc2-3cc98e0704e4',
  'd08a5f9a-dc61-4c81-9bb5-855e2b04126b',
  '6e199077-7d2b-4b45-9870-dcfb52ba6efe',
  '40be005d-6099-4f59-b8d6-5f9ab9b2ff08',
  '70cd2005-fd18-4b1f-9bb5-e7000c212d81',
  'fe657b03-8e3a-4de4-b9ea-93ca048c772c',
  '630c03e7-9a63-4fd0-a28f-d3a2c29577d4',
  '2fe490b4-2089-44ed-8ed9-f1213efdd433',
  'b1710958-f5df-41d0-9ffd-3b835025695e',
  '3ce4b10d-b366-424c-8d7c-9261c7d832ff',
  '7e039720-8fb9-43f0-87ca-3698a92ba9df',
  '8435ba3b-9853-4608-85f7-90fc2d2d06a7',
  '28c2d825-6da9-4f6b-9d86-f1d2431d7a5a',
  '2836bf5c-7006-4020-af7e-ad9598b388a9',
  '0ddf510a-c964-47ec-acd9-fb1f9277fffa',
  'eb5b6233-f868-4b8d-9cf4-f0663a8d397f',
  '3a57c13f-992a-4f5a-a04c-2af9b59b86e6',
  '3977af7b-b392-49e8-8542-a11e9477edd8',
  'e91c5fca-d17a-49d5-a141-f6f5629ba8e0',
  'a62ed0d6-7a74-4003-8e06-69e572b2ca07',
  '2ff90875-3d2a-4914-90e9-dd62e5978ab8',
  '01a769ec-4b90-4dfe-86c9-ecb2a169e489',
  '4334a753-6919-4a79-bbf7-2f478ecf734e',
  'd829b73d-80c9-48e9-9cca-8e1a8cdc8020',
  '7242b72f-4541-4d92-b394-e72c2155c770',
  '42ef9127-a691-4616-9636-25f15b4959c8',
  'cbf35bf3-3dbf-4a2c-abd5-d2a51241d1b3',
  '42326ed2-bc62-4a8e-84a9-a03997cffcc1',
  '4ac40ec7-1647-4a19-8383-05406bd7cc43',
  '828a3dcf-aa93-4eb4-a539-31dff2fcae34',
  'a35ddc4f-e66d-4c86-a0fd-a94f33c3b09b',
  '60c3e4aa-da42-4379-93ec-4b5b683ec331',
  '3cc261d6-4763-49f5-8cd1-36d299c8015e',
  '26151e87-7d3f-43fa-9ad5-820e0d435b2e',
  '3c3d950e-c322-4313-a3e5-22e49c9ff6da',
  '2c96ed80-431d-4a6f-a25d-8c2af10375f6',
  'd213fcef-c1bf-4bc8-bca3-7d75b862ba9d',
  '284cc910-fad0-4a3b-9df5-d9bc22f4eece',
  'c8eb25e5-c252-4696-8ef9-cef2f065d86d',
  '908ba582-47b6-4bc7-8371-b3d51c6134d1',
  '8ecce382-b1de-4099-977c-93a09931dd93',
  'c1b193cd-bd5f-4d4d-b026-e34d115c8145',
  '082238ea-51de-407e-94dd-8b17fe1e2ac9',
  '80e5b4f2-4609-41bb-9b00-f8483956feca',
  'b82d18d2-155a-41b5-8cbd-dda43b326720',
  '2d4c510c-ccc7-47ae-bc92-35783694b47b',
  '4a16e8ba-bc47-4bc2-8706-ecaa54696170',
  'b3d38a02-ead7-4d48-ac4e-0301b9fc71d5',
  '6af7e57a-e809-49a2-96f4-5a7d89993955',
  'b5a7fa85-a5f3-4cc7-909a-1fc474cf4bbc',
  'b2de097b-a6b3-46af-89c9-7a04946348ff',
  '531035ef-4015-4b55-8202-6dedd4e229a7',
  '0fc2902a-2633-46a1-91aa-a8e621ca5f92',
  '03242c97-8554-46c9-a4cc-06654b05da77',
  'a8d586c2-111b-4669-8f48-843eaa6aabda',
  'afbe7f11-9741-40de-828d-7a772c0a3dc7',
  '1a99414d-de74-449c-b451-18df65a578f9',
  'b4344c5d-d5e6-4d6f-bf94-5c56ef099c27',
  '966b26d0-e790-45f0-ba56-ac43392a1ef6',
  '5dd5d556-4c80-441d-bac7-9a5dff9e2829',
  'd499a026-bf98-4b63-8e13-987ea3b7cac6',
  'fb679dc3-1615-43f0-b2e0-b326cbbe8d54',
  '5d9f9e8b-2837-4096-9c1e-1a23db381e8f',
  '0920f160-678c-4a53-b7f3-b4fc13d9ef9e',
  'a1034b9a-87b2-4286-8814-0332f8285156',
  '4ccd8eec-3dbb-4fda-8158-24aaedacebf6',
  '82057819-31dc-468b-8dc4-3f5dc8372d9a',
  'c01e16e0-e651-42ff-aef6-3a507a24fa15',
  'cf82f953-384a-445e-9a8f-1f7817f299e2',
  'de83439a-c328-4970-bc6b-76cc22065a62',
  'a8f4a8b3-ff9a-48ee-a89e-2d7aae3dcccc',
  '8dcc9c79-c124-4d77-8ebb-2701384ad75b',
  '5150644b-c284-4203-b42f-63317bf52ee0',
  'fda0ee88-4064-4292-a056-613d9e3ef3aa',
  '0e2f1cae-6ebc-49a6-9e44-28d46d103acb',
  'b17947a4-1fac-42ca-8b17-02b541b077ba',
  '725fd641-54f2-4107-8aa3-2491edb551ef',
  '1e1b3bc4-9fa0-42a0-97e8-0b8a04767886',
  'c9dfb3b6-2093-47a1-b8a7-af405b93dde6',
  'e5ffe689-6c6b-409c-afb2-4eef0c887030',
  'b24a1e27-79bc-48a7-ab0b-9db4279efd3d',
  'a677b733-3844-4bd5-9522-e75d1a3846bb',
  '9cb7c8a6-4cce-4fe1-b775-137614d50d6d',
  'cd926638-36f1-4496-aebe-788409097716',
  '537f1255-61cf-4f9e-925a-dc2b8e32bd46',
  'f8d46f77-04c4-4118-8408-f2d7c33eae66',
  'c9427eb3-2af8-4be9-8f53-b63fedd2b016',
  '2f195e79-f330-4073-b1c8-8ec4582ccc40',
  '54b192da-bfb8-4bc4-a6c8-f391baa59f6d',
  'aa08d0f9-9995-4ac7-8fb5-002029ba20ec',
  '97f65eca-a86a-4501-9bd9-da77f19616cc',
  '56436b4f-0725-44ec-8e1d-8cd969b45c08',
  '31782d1b-4c18-4249-9379-aa8294184b28',
  '2451cd64-d00f-4c1d-8bce-4310487f9ae2',
  '0b2aec62-73ee-4b6c-8f0a-c43bd30ade1f',
  'fe6d974a-695e-4b53-a609-ebb80444a520',
  '6165d627-7009-4bc3-a1d7-5e0d85f483b6',
  '8f649c56-5004-4604-8759-378ffab08177',
  '7c32ad0e-f0d9-4472-8ba6-a86bb20564b1',
  '824e77e5-86f2-48de-8d97-040f36886035',
  'dae3e6b7-742a-4b24-83e7-69259f0e2d35',
  '57822d48-941d-42d5-aa53-cae3e00dff9d',
  '16b9c59b-8d27-4e2a-9af2-605a28c591df',
  '9284fb9c-7bcc-4813-88d5-4f4e4a643bfc',
  '913bf57e-5d1f-4983-a925-95fb4668ea1b',
  'ecba1aba-c325-4ed3-abbc-481eb8e3968e',
  '6c1821c9-b446-4f58-9660-3f7e2a0655fb',
  'b6aacff4-02cc-49ac-8ae5-57d3661f27f7',
  'e13b172d-7725-4a43-9d0c-ade84c2fdd2c',
  '932dc483-6091-40fc-a1fd-7515024e8e91',
  'ad6083a8-4105-45c1-b1f5-6f35f6b4b439',
  'a6b874aa-1f28-4c95-afa9-71d603d8481e',
  '5022cce8-272f-407c-af19-4609f428f7a3',
  '4abe0564-16f2-4d5a-b451-5f5bf6d90769',
  '497be902-6e38-478f-b0e6-ca53994b0dab',
  '683988d5-be0f-4170-acce-d2b674a91e8c',
  'acb53799-5aa9-46a3-9f2c-1888ddffaec6',
  'e6eb2226-92df-4a20-97ac-9f3c3a42cfb9',
  '9c7343bb-83c6-4d17-9178-7b485fc23076',
  '093b8c50-6ee0-4f57-b455-e916bfdf8d32',
  'c56d936d-481b-4456-a96d-605c7eed13d7',
  '88886693-9386-4322-af65-694e77784898',
  'b129a2cd-9e9f-412c-a754-901544175b9a',
  'c8b921a4-0c2b-448f-b1b6-d6d944793410',
  '2b1b79b1-6e30-4b71-b42e-af7276430cc3',
  'b5a8a7dc-9be4-4459-bc25-d4f08df7a23f',
  'b50979b7-2f81-4594-a33c-a18248eb49bf',
  '0e1a706b-c872-43af-8b75-dc468dfbc1e9',
  'd7237e28-2668-483f-933d-c9f9d6494858',
  '6b8bbe41-0b72-440d-9dee-d5740079270d',
  '95d19606-2b98-4dd8-a89b-7af57f33f5bc',
  '31b05d84-c41e-45b1-b462-381ae7ff2e79',
  'c0022d52-1060-4366-93b0-1b6434760140',
  'a55b2b1a-e7df-4fb5-8258-0d432803666c',
  '4248d7cf-7a76-41e2-aec8-921f803e951c',
  'e7ea1afd-d808-42ac-a9d1-59ff2e3a55da',
  '56f03156-90a3-4d69-baa3-5e9a60f35dbb',
  '863382f5-9dd8-4d2f-8ab6-526878d0cb3d',
  '2108ca80-a34d-43b2-b6d5-0f4960509214',
  '0b529620-69f1-4b11-ac06-acb22f616bbd',
  '89e61fef-2dd8-4f9b-8768-4aed08491ae8',
  '912ad2a0-2851-4c0e-864a-17dfbd0165f2',
  '66357519-2fe0-4e1f-b9ed-56f4e0107865',
  'ab998327-fd55-4e07-8b58-decafc29b0db',
  'e038aaab-ddbc-4f03-a1d2-05ec0e438d3e',
  '078292f9-3799-409c-ae6e-509ab3ac1475',
  '151646b6-751b-447f-baa5-87e5048320bf',
  'e51980b5-9ca9-46bc-ab67-d60be87b2708',
  'f0bb6adf-81c9-405f-bd73-f6006f59da15',
  '3c0747e5-9862-430b-a867-87f9e9a56db8',
  '9ae2ef55-a2ba-4cc6-9f07-bdc5bfc9198f',
  'cf89f6c1-a22d-424d-8389-3dedfdf273a2',
  '1c3058a5-4f3c-40df-a1fc-9702b71aca3b',
  '2f9b598b-ab0e-445a-9a3c-c90a7c401c01',
  '63b1faeb-f72c-4d4e-b00f-80d089af71bb',
  'a57603aa-2b00-4fa2-bcd5-90177723b9a9',
  'a8b4983a-10f9-47cc-b30a-3db5a37b5a0f',
  '46514fa5-8a8e-4a5d-af99-8c76fccfdcb1',
  '4444ad68-b524-40a7-b51a-06dd2976bbcb',
  '208bda6f-eb8d-4bec-8ac0-33c661297436',
  '35ad6771-6f9f-4145-b032-70191466c441',
  '0629267b-f3a0-4124-b219-7a0c54bcb986',
  '9f69e8dd-8da1-42e8-87ee-945acbb86fdd',
  'd3b7ae7e-f21d-47c7-858b-4e78c8492540',
  '0dd361b9-776a-407c-bdcf-d5de515b111f',
  'e99b3886-6813-42dd-bf5f-1e597a7dd8b8',
  '362282f4-2385-49e4-a4b9-fefdd78c2773',
  '77f6e0e9-1795-4325-8936-80e345b74257',
  '3a2bb9ad-65f9-485e-aaa7-4c45f6811834',
  '3206cebf-6179-4f4c-8f5a-93c9a68dce72',
  '62942ed8-5bba-4466-acf4-21bc26f864b3',
  'a37045c2-b081-4b0c-bb95-eb77a3ee2780',
  '5e7771e7-6c9c-48c1-82b4-8031ac8b60e3',
  '8d3c66eb-b5e6-4df9-887e-077c0ac371da',
  '3c2f7dfa-68ee-4fae-8804-f839e89e6dfe',
  'cf3086e8-5ec0-4a6f-b36c-f8e9701fdf36',
  'ffc2e8c2-dd9c-48cb-a067-70df475e20f7',
  '99e4f20c-1eca-4bb1-8b44-a92f0b4329a7',
  'b88bba08-bd78-4e2b-bff1-be5eabebc52e',
  '9a19473e-7eb8-4dfd-9194-57cc1a16e888',
  '686ff7f6-1845-40ce-9304-b70bbd2ada65',
  '6e1219f5-3011-4c66-af27-1d0608ba133c',
  '6389c895-1658-4693-8467-fe8ddb5814f5',
  '5e60f560-44f2-4f4f-944d-815d61ed3089',
  'eaec95e4-9cca-4069-b72f-90f9484d17eb',
  '15062e13-a81d-4740-94c6-9d802c9f07d7',
  '0ec6aad0-8836-436c-9511-5850833dec7e',
  '958fedb6-f049-441f-9503-310ca7f4a4dd',
  'f7aed666-a7b5-4576-8696-c6b410f0278a',
  '9c6e9045-c3d4-4a4b-b0b6-33b88dbb0663',
  '2a699940-1bb3-4862-873e-0bbc814e2e92',
  '215479e6-fb0d-4735-bc6a-e2ef5eb077d4',
  '042676ed-1820-4ee6-a30d-9a7a907c7c90',
  'ad90707d-f93e-415e-943a-b85672fa23ec',
  '055844d8-d086-48d6-9fe2-4aa37f3ee430',
  'ee6979d5-aa9d-4b75-aacc-d5ba8692cca8',
  'cb4fded0-96b5-4109-95d0-a8041527a6a0',
  '2f5c31b1-78d0-45fc-9cf1-0775a7ae7b4c',
  '82d0cc29-1a57-484a-a180-eeda6a37e0ab',
  '5e1c95e2-17b2-49e0-b257-273e31cba14e',
  'de3d55b3-33ee-436d-bf68-c1891b248afe',
  'e16ebb64-a761-4c7e-a830-7ccc4a9cb367',
  'c2c08680-3a8a-432d-964d-932a4aa89ade',
  '240276c4-0816-4eeb-816a-d9eb6232c3ed',
  'fc49190a-bba1-403c-9571-329ae931a662',
  '982d58a0-6245-41b3-8bd3-40ae5f453b21',
  '30db32fd-5c46-4f99-ac8c-abd87734d748',
  '970c33ac-e99e-403e-b52c-1a970fb3c07b',
  '8af6af84-fd20-49ce-b5d6-60890e6c8154',
  '84d3bec6-c999-40b8-8568-d8a5777a609e',
  '3ce554ad-d54b-4a40-8717-044b024e07fc',
  'a05abb3e-41c2-48a8-bfc4-c257a377aeaf',
  'f33239e8-fbfa-4de3-a45e-26758754fcb5',
  'e6980a99-0937-457e-815f-4cd953bcaf8c',
  '688c951f-6cc7-41e6-911c-22f97227757d',
  '398d7b39-91bb-4c71-b3f9-9e1721d39a6e',
  '49393d78-8141-4fe8-a9e9-a8e1d775ff47',
  '20363a9b-d379-4872-9e71-d1ec8990f332',
  '9c12f378-eb9e-4e05-9c38-00aefd1da693',
  'de610412-aee6-46e3-9759-375b81e73496',
  '550cbd1d-a4db-415a-879f-fde291fbd0bc',
  '2c497cdc-ed65-4232-a3bb-30daf8f8085d',
  'fdb3fc0c-4fc5-4ad4-8b0c-b48159aea5f2',
  '16b15846-8bb6-486d-be3b-cbc5ea49f277',
  '95cd4bba-a3cf-4a09-8c11-d43d1f637026',
  '9048d99f-145c-4350-8a2c-8adcb67b3f88',
  'c7227e3b-1cb6-4a1a-9dc5-12012ea75a58',
  '4d679a6c-0141-4c89-b637-1ae251a71e46',
  '56314d18-ffb9-4e0c-b309-1f4e8ae0bfab',
  '46b9e7fc-a130-4c2b-8590-7c0142efe8ef',
  '0caad64d-69c5-4f52-83b8-7d17461191db',
  'f848d2ed-4d87-4039-acd1-78ad88945c80',
  '1b4bd57f-52b6-49e2-9a13-f07c6c7f2a9f',
  'b1a4e9a7-21f7-47c4-b5c3-ae22b054f144',
  '0f1e4d96-d410-44fb-be2b-98d24bd08de6',
  'e8ccdf4c-c05e-4a4e-9dbe-c51fd2c0b965',
  'd0139cb3-a609-4e0f-950e-6e3b96aff444',
  'e298b4b5-7887-419c-914d-cf3dc3617d49',
  'c00a69c5-8169-49c7-9ceb-f79bc53b0905',
  '69fc3266-0968-40db-8880-c3300556e502',
  '5d533bc1-86bd-473e-b7c0-fba71f36c6c8',
  '2c71401f-908b-415b-bd85-118f601d9172',
  'b43ebcab-405a-4c63-a570-5a485399d1d7',
  'f3adf777-9fd7-497b-8ae0-e229231999f8',
  '18ef3003-6279-468f-a5cd-d168871a7e7a',
  'ebf49926-f060-4e04-b57f-2b85e688d37a',
  '40fd996e-4da4-4e02-bd07-ca855ee86585',
  '0311016a-5628-46f4-a9df-4b5b319afb0e',
  '0828be13-92f2-4aed-9da0-e871b66b4abf',
  '6da55a17-6a12-4391-9460-150c8d5f9e62',
  '7b478788-9fd5-4a30-b9c6-88409aa29a7e',
  '4942890f-4ba8-4f7e-a39d-3d8538010ff8',
  '26bfcf1c-a778-477f-92f8-17bcb360f23d',
  'e2545fcd-9060-407a-8df5-9803bc7b77d0',
  '96bcd91c-78f9-40b6-b7e2-11d8e11fb343',
  '552f1efc-c035-4b7b-802f-7cc32c731d77',
  'feab3448-1976-4e76-846d-4588615a6634',
  '3cb7dda4-9510-44c7-8509-d4dd27f565b4',
  '11ef5872-cc00-4d5a-822a-35f5d487f974',
  'c7a3bc07-7f5c-41e4-a88c-a6e3bf9a9453',
  '8ebe21cd-85e1-4f31-9437-96f2b9d7fc1c',
  '6b580612-d381-4225-9ecc-2eabba0b0897',
  '04564799-c5cc-4962-9bfd-8c6fde5f4020',
  '06d6d07b-3a8a-4d00-98d4-dccd6d958e55',
  '589b501a-bf0a-474a-860f-21bdf67dfbfb',
  '5157a335-1217-4783-9744-a29bfaa67ade',
  '377f2a01-e696-4ad7-bf9b-3c2471ed015c',
  '4c1a0f7c-f2dd-49dd-9923-57fd0b95088c',
  'aa26ef48-b473-43e6-ad0e-defa11df126d',
  'f0ca46e3-1194-4204-8865-387dbfb3da3e',
  'd52d0c28-7b66-4286-b3f6-488f7b4509d9',
  'fbd02086-13ba-4bd4-9240-856acee664b4',
  '7aa4355d-6294-491b-98db-e0c93d349dd4',
  '7790ef99-c1ed-410b-96dd-9ed3852e869f',
  '25c4362d-159d-4732-8a17-602cddc64961',
  'd9f2b354-40f5-40b4-9700-d0bf2d80262b',
  '0f088283-24e5-493e-abc8-3a4b568b80b9',
  '03c451ed-d7b0-49f9-af3a-f488b7aa2b3e',
  '6768eea4-c769-4b50-9e4e-0c689ccf1689',
  '9821517a-c9c6-477a-8010-9a6039e0cd76',
  '217ff03b-60a4-4cc4-8f8a-008331733b97',
  '3dc4958b-95dd-4f9f-8ff7-3fc5106950a0',
  '5a1f0053-b332-482e-91eb-83a73444b822',
  'd22df6fc-da6f-4994-89ce-4553dc0f65f2',
  '39946b4b-df7d-460b-bb4e-84e3c488c755',
  'c47bfbd5-0732-4505-bfaa-613f317923ce',
  'b9ddf0ba-8ab8-4340-85a9-f92921ebebd0',
  '90c2940e-bcf4-4b59-a77d-8c3087b04e22',
  '4d976e57-12b6-4085-b47c-84f501253b9c',
  'f2aa53ed-eb39-4f65-8443-d3af0e66d275',
  'caaa25f3-7fec-4461-ae66-98848e9c3c9e',
  '3e66e1df-03df-49c7-ad1c-574ad80e7591',
  '06b662a1-ff3f-4d91-94ed-27f46abdc39a',
  'cab6604b-9db5-44d6-a884-e99566dfaf26',
  '82dbea5a-e85a-42f9-a130-72784b593afe',
  'b92038ff-4fe6-4a00-8a18-7fb3f161fd4d',
  'd9187c0d-df0d-43a7-b485-be3ffa10f3eb',
  'b84f3317-da55-44ac-8822-6c7011257f21',
  '1f9cf866-25c6-4106-9d05-dfcd89cbc4ad',
  'b93d80cd-0ac6-4d78-81f1-d6a10adee82f',
  'a035b305-56ed-4d7b-9061-3987eccdf7f0',
  'ebdaadfa-082c-4dd2-ad29-9025b431e181',
  'acadee82-15f1-4166-9429-55dbb49953b5',
  '5a1743a2-e672-4749-adf9-1ee74a12f20c',
  '0d00864d-3cf8-41fc-9953-6f6a100115a3',
  '9cc590df-dc2c-4df7-bafa-8db48c1c5571',
  '3449ca54-8d74-4d37-9a9f-c369f1bc29b9',
  'a9328f6f-476b-464d-873c-8828dcf5d6b1',
  '4315fcda-cf8a-487b-b63d-85f263ba6ae4',
  '98f9a6c2-df94-43f4-9a18-b6fa90348aaa',
  '3d46e28e-617a-4d80-b390-6f18a6426e04',
};

/// Nouveaux exercices intégrés (migration v12 → v13, D30).
List<ExercisesCompanion> get builtInExercisesAddedInV13 => [
  for (final e in _builtIns)
    if (_addedInV13.contains(e.id))
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
