import 'package:app_muscu/core/database/app_database.dart';
import 'package:app_muscu/features/workout/domain/set_rules.dart';
import 'package:app_muscu/features/workout/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSet _set({
  double? kg,
  int? reps,
  int? seconds,
  double? plannedKg,
  int? plannedReps,
  int? plannedSeconds,
}) => WorkoutSet(
  id: 'id',
  workoutExerciseId: 'we',
  position: 0,
  setType: SetType.normal,
  weightKg: kg,
  reps: reps,
  durationSeconds: seconds,
  plannedWeightKg: plannedKg,
  plannedReps: plannedReps,
  plannedDurationSeconds: plannedSeconds,
);

void main() {
  group('placeholdersOf (RG-11)', () {
    final previous = _set(kg: 80, reps: 8, seconds: 45);

    test('valeur prévue par le modèle, sinon « Précédent »', () {
      final set = _set(plannedKg: 85, plannedSeconds: 60);

      final placeholders = placeholdersOf(set, previous);

      expect(placeholders.weightKg, 85); // modèle
      expect(placeholders.reps, 8); // pas prévu → Précédent
      expect(placeholders.durationSeconds, 60);
    });

    test('ni modèle ni « Précédent » : pas de placeholder', () {
      final placeholders = placeholdersOf(_set(), null);
      expect(placeholders.weightKg, isNull);
      expect(placeholders.reps, isNull);
      expect(placeholders.durationSeconds, isNull);
    });
  });

  group('placeholdersOfAll (WO-10)', () {
    test("une série ajoutée sans équivalent la dernière fois reprend celle "
        "d'avant dans la séance, même si elle n'est encore que préremplie", () {
      // 4 séries de la séance en cours, aucune encore saisie ; seules les
      // 3 premières ont un équivalent la dernière fois (« Précédent »).
      final sets = [_set(), _set(), _set(), _set()];
      final previous = [_set(reps: 8), _set(reps: 9), _set(reps: 5)];

      final placeholders = placeholdersOfAll(sets, previous);

      expect(placeholders.map((p) => p.reps), [8, 9, 5, 5]);
    });

    test('la chaîne suit la vraie valeur dès qu\'une série en a une, pas son '
        'propre placeholder', () {
      final sets = [_set(reps: 8), _set(), _set(reps: 12), _set()];

      final placeholders = placeholdersOfAll(sets, const []);

      // set[2] a déjà 12 en vrai : peu importe le placeholder qu'on lui
      // calcule (ignoré à l'affichage, une vraie valeur prime toujours),
      // mais set[3] doit repartir de 12, pas de la chaîne d'avant (8).
      expect(placeholders.map((p) => p.reps), [null, 8, 8, 12]);
    });
  });
}
