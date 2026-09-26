import 'package:drift/drift.dart';

import '../../../features/exercises/domain/exercise_enums.dart';
import '../../utils/text_normalizer.dart';
import '../app_database.dart';

/// Les 10 exercices livrés avec l'app (docs/SPEC.md §5.1, EX-01).
///
/// Les identifiants sont fixes : une future version pourra corriger ou
/// compléter ces exercices sans créer de doublons.
final builtInExercises = [
  _builtIn(
    '509d3ccf-bf4e-411b-a5db-2d2e491f586c',
    'Développé couché (barre)',
    Equipment.barbell,
    BodyPart.chest,
    TrackingType.weightReps,
  ),
  _builtIn(
    'c152f391-b038-44f6-b8df-cfef1d1a789d',
    'Squat (barre)',
    Equipment.barbell,
    BodyPart.quads,
    TrackingType.weightReps,
  ),
  _builtIn(
    '7c098dc4-7640-4b19-9dda-14dd6f4cb30a',
    'Soulevé de terre (barre)',
    Equipment.barbell,
    BodyPart.back,
    TrackingType.weightReps,
  ),
  _builtIn(
    '3b49eab5-f756-427e-8ee6-62ab6d6114bb',
    'Développé militaire (barre)',
    Equipment.barbell,
    BodyPart.shoulders,
    TrackingType.weightReps,
  ),
  _builtIn(
    '8087a454-a438-4c79-be98-f6670785da3e',
    'Rowing (barre)',
    Equipment.barbell,
    BodyPart.back,
    TrackingType.weightReps,
  ),
  _builtIn(
    '5bc61b55-5623-4618-a35e-f8dc3469c2ab',
    'Presse à cuisses',
    Equipment.machine,
    BodyPart.quads,
    TrackingType.weightReps,
  ),
  _builtIn(
    'eba26f67-c29f-44b6-99c6-0de4a0f8538c',
    'Curl biceps (haltères)',
    Equipment.dumbbell,
    BodyPart.biceps,
    TrackingType.weightReps,
  ),
  _builtIn(
    'd5702b62-5375-434d-a0bb-f2c807c0b16a',
    'Extension triceps (poulie)',
    Equipment.cable,
    BodyPart.triceps,
    TrackingType.weightReps,
  ),
  _builtIn(
    'd160b037-2046-44ac-ba37-97784a8cade2',
    'Tractions',
    Equipment.bodyweight,
    BodyPart.back,
    TrackingType.reps,
  ),
  _builtIn(
    'a6a15280-2533-4e58-9161-ba084762cae2',
    'Gainage (planche)',
    Equipment.bodyweight,
    BodyPart.abs,
    TrackingType.duration,
  ),
];

ExercisesCompanion _builtIn(
  String id,
  String name,
  Equipment equipment,
  BodyPart bodyPart,
  TrackingType trackingType,
) {
  return ExercisesCompanion.insert(
    id: Value(id),
    name: name,
    nameNormalized: normalizeForSearch(name),
    equipment: equipment,
    bodyPart: bodyPart,
    trackingType: trackingType,
  );
}
