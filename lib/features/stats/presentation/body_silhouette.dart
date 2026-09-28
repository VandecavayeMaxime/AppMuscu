import 'package:material_ui/material_ui.dart';
import 'package:path_parsing/path_parsing.dart';

import '../../exercises/domain/exercise_enums.dart';
import '../domain/muscle_load.dart';
import 'body_paths_data.dart';

/// Face ou dos, pour choisir le bon jeu de tracés (SA-04).
enum BodyView { front, back }

/// Repère de dessin, commun aux deux vues (voir body_paths_data.dart).
const bodyWidth = 724.0;
const bodyHeight = 1448.0;

/// Convertit un tracé SVG (`d="M10 10L90 90…"`) en `Path` Flutter, en
/// suivant les commandes une à une (`path_parsing` ramène tout, y compris
/// les arcs et les courbes quadratiques, à des segments droits et des
/// courbes cubiques, ce que `Path` sait déjà tracer).
class _FlutterPathProxy extends PathProxy {
  _FlutterPathProxy(this.path);

  final Path path;

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

Path _parse(String svgPathData) {
  final path = Path();
  writeSvgPathDataToPath(svgPathData, _FlutterPathProxy(path));
  return path;
}

/// Un seul `Path` (toutes ses pièces réunies) par tracé fourni.
Path _combine(List<String> svgPaths) {
  final combined = Path();
  for (final data in svgPaths) {
    combined.addPath(_parse(data), Offset.zero);
  }
  return combined;
}

/// Dans le SVG d'origine, la vue de dos occupe le même repère que la face,
/// décalé de [bodyWidth] vers la droite (un seul document pour les deux
/// vues) : on le ramène ici à 0..[bodyWidth], comme la face.
Path _combineBack(List<String> svgPaths) =>
    _combine(svgPaths).shift(const Offset(-bodyWidth, 0));

/// Tracés calculés une seule fois (au premier accès), tant que l'app tourne.
final Map<BodyPart, Path> _frontMuscles = {
  for (final MapEntry(key: part, value: paths) in frontBodyPaths.entries)
    part: _combine(paths),
};
final Map<BodyPart, Path> _backMuscles = {
  for (final MapEntry(key: part, value: paths) in backBodyPaths.entries)
    part: _combineBack(paths),
  ..._trapeziusBackSplit(),
};

/// Scinde le tracé (dos) du trapèze en haut / milieu-bas (D29) : la source
/// n'a qu'un seul tracé pour tout le trapèze, donc on le découpe ici en 2
/// par un simple recadrage horizontal, plutôt que de redessiner à la main.
Map<BodyPart, Path> _trapeziusBackSplit() {
  final whole = _combineBack(trapeziusBackPaths);
  final bounds = whole.getBounds();
  // Le haut du trapèze (nuque, épaules) est plus petit que le milieu/bas
  // (entre les omoplates) : la limite est placée à 38 % de la hauteur.
  final splitY = bounds.top + bounds.height * 0.38;
  Path clip(double top, double bottom) => Path.combine(
    PathOperation.intersect,
    whole,
    Path()..addRect(Rect.fromLTRB(bounds.left, top, bounds.right, bottom)),
  );
  return {
    BodyPart.trapeziusUpper: clip(bounds.top, splitY),
    BodyPart.trapeziusLower: clip(splitY, bounds.bottom),
  };
}

final Path _frontNeutral = _combine(frontNeutralPaths);
final Path _backNeutral = _combineBack(backNeutralPaths);

Map<BodyPart, Path> _musclesOf(BodyView view) =>
    view == BodyView.front ? _frontMuscles : _backMuscles;

Path _neutralOf(BodyView view) =>
    view == BodyView.front ? _frontNeutral : _backNeutral;

/// Le muscle touché par [point] (dans le repère 0..[bodyWidth] ×
/// 0..[bodyHeight]) sur la silhouette [view], ou `null` hors de toute zone
/// suivie (tête, mains, pieds, espace entre deux muscles…).
BodyPart? bodyPartAt(BodyView view, Offset point) {
  for (final MapEntry(key: part, value: path) in _musclesOf(view).entries) {
    if (path.contains(point)) return part;
  }
  return null;
}

/// Repère (0..[bodyWidth] × 0..[bodyHeight]) du tracé de [part] sur la vue
/// [view], ou `null` s'il n'y en a pas (ex. les fessiers en vue de face).
/// Sert à placer une étiquette à hauteur d'un muscle sans deviner sa
/// position à la main (carte du corps, SA-07).
Rect? boundsOf(BodyView view, BodyPart part) =>
    _musclesOf(view)[part]?.getBounds();

/// Bleu (bas), vert (optimal) et orange (élevé) : 3 couleurs franches, sans
/// dégradé, au-delà du gris neutre (pas travaillé) (SA-04). L'orange plutôt
/// qu'un rouge pour « élevé » : un volume au-dessus du repère haut n'est pas
/// forcément un problème, contrairement à ce que suggérerait un rouge franc.
const lowColor = Color(0xFF60A5FA);
const optimalColor = Color(0xFF16A34A);
const highColor = Color(0xFFF97316);

/// Couleur d'un muscle selon ses séries de la semaine (SA-04) : gris (pas
/// travaillé), puis une des 3 couleurs franches selon la zone où on tombe
/// (`muscleZoneProgress`, RG-23), pour qu'on distingue vite bas / optimal /
/// élevé.
Color muscleColor(BuildContext context, BodyPart part, double sets) {
  final neutral = Theme.of(context).colorScheme.surfaceContainerHighest;
  final t = muscleZoneProgress(part, sets);
  if (t <= 0) return neutral;
  if (t <= 1) return lowColor;
  if (t <= 2) return optimalColor;
  return highColor;
}

/// Une silhouette (face ou dos, adaptée de react-native-body-highlighter,
/// MIT, voir body_paths_data.dart), coloriée selon [load] (SA-04). Toucher
/// un muscle appelle [onTap], pour le mettre en avant dans la liste (SA-05).
class BodySilhouette extends StatelessWidget {
  const BodySilhouette({
    super.key,
    required this.view,
    required this.load,
    this.highlighted,
    this.onTap,
  });

  final BodyView view;

  /// Séries de la semaine par muscle (RG-17) ; absent = jamais travaillé.
  final Map<BodyPart, double> load;

  /// Muscle actuellement mis en avant (bordure), s'il y en a un.
  final BodyPart? highlighted;

  final ValueChanged<BodyPart>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTap = this.onTap;

    return AspectRatio(
      aspectRatio: bodyWidth / bodyHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / bodyWidth;

          Widget painted = CustomPaint(
            size: constraints.biggest,
            painter: _BodyPainter(
              muscles: _musclesOf(view),
              neutralPath: _neutralOf(view),
              highlighted: highlighted,
              neutral: theme.colorScheme.surfaceContainerHighest,
              highlightColor: theme.colorScheme.primary,
              muscleColor: (part) =>
                  muscleColor(context, part, load[part] ?? 0),
            ),
          );
          if (onTap == null) return painted;

          return GestureDetector(
            onTapUp: (details) {
              final part = bodyPartAt(view, details.localPosition / scale);
              if (part != null) onTap(part);
            },
            child: painted,
          );
        },
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.muscles,
    required this.neutralPath,
    required this.highlighted,
    required this.neutral,
    required this.highlightColor,
    required this.muscleColor,
  });

  final Map<BodyPart, Path> muscles;
  final Path neutralPath;
  final BodyPart? highlighted;
  final Color neutral;
  final Color highlightColor;
  final Color Function(BodyPart part) muscleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / bodyWidth;
    canvas.save();
    canvas.scale(scale);

    canvas.drawPath(neutralPath, Paint()..color = neutral);

    for (final MapEntry(key: part, value: path) in muscles.entries) {
      canvas.drawPath(path, Paint()..color = muscleColor(part));
      if (part == highlighted) {
        canvas.drawPath(
          path,
          Paint()
            ..color = highlightColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5 / scale,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BodyPainter oldDelegate) =>
      oldDelegate.muscles != muscles ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.neutral != neutral ||
      oldDelegate.highlightColor != highlightColor;
}
