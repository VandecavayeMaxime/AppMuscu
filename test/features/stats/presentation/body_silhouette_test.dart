import 'package:app_muscu/features/exercises/domain/exercise_enums.dart';
import 'package:app_muscu/features/stats/presentation/body_silhouette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Un point par muscle, au centre de son premier tracé (calculé par
  // `Path.getBounds()` : voir la remarque sur body_paths_data.dart dans
  // ARCHITECTURE.md si ces tracés changent un jour).
  group('bodyPartAt (SA-04, SA-05, D20)', () {
    test('face', () {
      expect(
        bodyPartAt(BodyView.front, const Offset(305, 377)),
        BodyPart.chest,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(305, 296)),
        BodyPart.trapezius,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(235, 348)),
        BodyPart.shoulders,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(202, 448)),
        BodyPart.biceps,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(153, 591)),
        BodyPart.forearms,
      );
      expect(bodyPartAt(BodyView.front, const Offset(336, 508)), BodyPart.abs);
      expect(
        bodyPartAt(BodyView.front, const Offset(453, 431)),
        BodyPart.obliques,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(275, 803)),
        BodyPart.quads,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(313, 714)),
        BodyPart.adductors,
      );
      expect(
        bodyPartAt(BodyView.front, const Offset(278, 1088)),
        BodyPart.calves,
      );
    });

    test('dos : trapèzes, dorsaux, lombaires, fessiers, ischios et triceps '
        'remplacent poitrine et abdos (D20)', () {
      expect(
        bodyPartAt(BodyView.back, const Offset(317, 385)),
        BodyPart.trapezius,
      );
      expect(bodyPartAt(BodyView.back, const Offset(270, 362)), BodyPart.lats);
      expect(
        bodyPartAt(BodyView.back, const Offset(276, 598)),
        BodyPart.lowerBack,
      );
      expect(
        bodyPartAt(BodyView.back, const Offset(212, 417)),
        BodyPart.triceps,
      );
      expect(
        bodyPartAt(BodyView.back, const Offset(290, 641)),
        BodyPart.glutes,
      );
      expect(
        bodyPartAt(BodyView.back, const Offset(248, 829)),
        BodyPart.hamstrings,
      );
      expect(
        bodyPartAt(BodyView.back, const Offset(332.2, 822.6)),
        BodyPart.adductors,
      );
      // Même zone sur les deux vues (mêmes deltoïdes, RG-17).
      expect(
        bodyPartAt(BodyView.back, const Offset(224, 354)),
        BodyPart.shoulders,
      );
      expect(
        bodyPartAt(BodyView.back, const Offset(263, 1062)),
        BodyPart.calves,
      );
    });

    test('hors de toute zone suivie : tête, espace entre les muscles', () {
      // Loin de tout tracé.
      expect(bodyPartAt(BodyView.front, const Offset(10, 10)), isNull);
      expect(bodyPartAt(BodyView.front, const Offset(-100, 500)), isNull);
    });
  });
}
