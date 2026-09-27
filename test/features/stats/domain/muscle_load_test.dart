import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/stats/domain/muscle_load.dart';
import 'package:flutter_test/flutter_test.dart';

CountedSet _set(BodyPart main, [List<BodyPart> secondary = const []]) =>
    (main: main, secondary: secondary);

void main() {
  group('muscleLoad (RG-17)', () {
    test('1 par série pour le muscle principal', () {
      final load = muscleLoad([_set(BodyPart.chest), _set(BodyPart.chest)]);
      expect(load, {BodyPart.chest: 2});
    });

    test('½ par muscle secondaire', () {
      final load = muscleLoad([
        _set(BodyPart.chest, [BodyPart.triceps, BodyPart.shoulders]),
      ]);
      expect(load, {
        BodyPart.chest: 1,
        BodyPart.triceps: 0.5,
        BodyPart.shoulders: 0.5,
      });
    });

    test('cumule plusieurs séries sur les mêmes muscles', () {
      final load = muscleLoad([
        _set(BodyPart.lats, [BodyPart.biceps]),
        _set(BodyPart.chest, [BodyPart.biceps]),
      ]);
      expect(load[BodyPart.biceps], 1);
    });

    test('aucune série : carte vide', () {
      expect(muscleLoad(const []), isEmpty);
    });
  });

  group('muscleZoneProgress (SA-04, RG-18)', () {
    // Repère des pectoraux : bas = 6, haut = 20.
    test('0 série : toujours 0 (gris), quel que soit le repère', () {
      expect(muscleZoneProgress(BodyPart.chest, 0), 0);
    });

    test('sous le repère bas : entre 0 et 1', () {
      expect(muscleZoneProgress(BodyPart.chest, 3), 0.5);
      expect(muscleZoneProgress(BodyPart.chest, 6), 1);
    });

    test('entre bas et haut : entre 1 et 2', () {
      expect(muscleZoneProgress(BodyPart.chest, 13), 1.5);
      expect(muscleZoneProgress(BodyPart.chest, 20), 2);
    });

    test('au-delà du repère haut : entre 2 et 3, plafonné', () {
      expect(muscleZoneProgress(BodyPart.chest, 25), 2.5);
      expect(muscleZoneProgress(BodyPart.chest, 30), 3);
      expect(muscleZoneProgress(BodyPart.chest, 100), 3); // plafond
    });

    test('chaque muscle suivi a son propre repère', () {
      expect(muscleVolumeLandmarks.keys.toSet(), muscleMapBodyParts.toSet());
    });
  });

  group('rankedMuscles (SA-05)', () {
    test('du plus au moins travaillé', () {
      final ranked = rankedMuscles({
        BodyPart.abs: 3,
        BodyPart.chest: 10,
        BodyPart.lats: 6,
      });
      expect(ranked.map((e) => e.key), [
        BodyPart.chest,
        BodyPart.lats,
        BodyPart.abs,
      ]);
    });

    test('égalité : ordre de BodyPart (celui de la bibliothèque)', () {
      final ranked = rankedMuscles({BodyPart.triceps: 4, BodyPart.chest: 4});
      expect(ranked.map((e) => e.key), [BodyPart.chest, BodyPart.triceps]);
    });
  });
}
