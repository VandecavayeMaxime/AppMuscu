import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../core/utils/date_format.dart';
import '../domain/chart_point.dart';

/// Courbe d'une valeur dans le temps (EX-12), dessinée à la main : axe des
/// valeurs à gauche, dates de début et de fin en bas, un point par valeur.
/// Toucher la courbe sélectionne le point le plus proche.
///
/// `CustomPaint` confie le dessin à un `CustomPainter`, qui reçoit un
/// `Canvas` (une feuille blanche) et y trace lignes, cercles et textes.
class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    required this.points,
    required this.axisLabel,
    this.selectedIndex,
    this.onSelect,
    this.height = 200,
  });

  /// Dans l'ordre chronologique, au moins un.
  final List<ChartPoint> points;

  /// Texte d'une graduation de l'axe des valeurs.
  final String Function(double value) axisLabel;

  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _ChartStyle(
      line: theme.colorScheme.primary,
      grid: theme.colorScheme.outlineVariant,
      background: theme.colorScheme.surface,
      label: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    return SizedBox(
      height: height,
      // `LayoutBuilder` donne la largeur disponible, nécessaire pour placer
      // les points avant de dessiner (et pour retrouver le point touché).
      child: LayoutBuilder(
        builder: (context, constraints) {
          final geometry = _Geometry(
            points,
            constraints.biggest,
            axisLabel,
            style.label,
          );
          final onSelect = this.onSelect;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: onSelect == null
                ? null
                : (details) =>
                      onSelect(geometry.nearest(details.localPosition.dx)),
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(geometry, style, selectedIndex),
            ),
          );
        },
      ),
    );
  }
}

class _ChartStyle {
  const _ChartStyle({
    required this.line,
    required this.grid,
    required this.background,
    required this.label,
  });

  final Color line;
  final Color grid;
  final Color background;
  final TextStyle label;
}

/// Position de chaque élément du graphique, calculée une fois pour le dessin
/// et pour le toucher.
class _Geometry {
  _Geometry(this.points, this.size, this.axisLabel, TextStyle labelStyle) {
    // Bornes de l'axe : un peu de marge autour des valeurs, puis arrondies
    // à des graduations « rondes » (1, 2, 2,5 ou 5 × une puissance de 10).
    final values = points.map((p) => p.value);
    final low = values.reduce(min);
    final high = values.reduce(max);
    final margin = high - low < 1e-9
        ? max(1.0, high.abs() * 0.05)
        : (high - low) * 0.1;
    step = _niceStep((high - low + 2 * margin) / 3);
    final bottom = ((low - margin) / step).floorToDouble() * step;
    // Pas de graduation négative pour des valeurs qui ne le sont jamais.
    minValue = low >= 0 ? max(0, bottom) : bottom;
    maxValue = ((high + margin) / step).ceilToDouble() * step;

    // La largeur de l'axe dépend du plus long texte de graduation.
    var widest = 0.0;
    for (final tick in ticks) {
      final painter = _text(axisLabel(tick), labelStyle);
      widest = max(widest, painter.width);
      painter.dispose();
    }
    plot = Rect.fromLTRB(
      widest + 8,
      8,
      size.width - 8,
      size.height - _bottomSpace,
    );
  }

  static const _bottomSpace = 20.0;

  /// Marge à gauche et à droite des points extrêmes.
  static const _inset = 8.0;

  final List<ChartPoint> points;
  final Size size;
  final String Function(double) axisLabel;
  late final double step;
  late final double minValue;
  late final double maxValue;
  late final Rect plot;

  List<double> get ticks => [
    for (var v = minValue; v <= maxValue + step / 1000; v += step) v,
  ];

  double x(DateTime date) {
    final first = points.first.date.millisecondsSinceEpoch;
    final span = points.last.date.millisecondsSinceEpoch - first;
    if (span == 0) return plot.center.dx;
    final t = (date.millisecondsSinceEpoch - first) / span;
    return plot.left + _inset + t * (plot.width - 2 * _inset);
  }

  double y(double value) =>
      plot.bottom - (value - minValue) / (maxValue - minValue) * plot.height;

  /// Position du point le plus proche horizontalement de [dx].
  int nearest(double dx) {
    var best = 0;
    for (var i = 1; i < points.length; i++) {
      if ((x(points[i].date) - dx).abs() < (x(points[best].date) - dx).abs()) {
        best = i;
      }
    }
    return best;
  }

  static double _niceStep(double raw) {
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final fraction = raw / magnitude;
    final nice = fraction <= 1
        ? 1.0
        : fraction <= 2
        ? 2.0
        : fraction <= 2.5
        ? 2.5
        : fraction <= 5
        ? 5.0
        : 10.0;
    return nice * magnitude;
  }
}

TextPainter _text(String text, TextStyle style) => TextPainter(
  text: TextSpan(text: text, style: style),
  textDirection: TextDirection.ltr,
)..layout();

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.geometry, this.style, this.selectedIndex);

  final _Geometry geometry;
  final _ChartStyle style;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final plot = g.plot;
    final points = g.points;

    // Graduations : une ligne fine et sa valeur à gauche.
    final gridPaint = Paint()
      ..color = style.grid
      ..strokeWidth = 1;
    for (final tick in g.ticks) {
      final y = g.y(tick);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final label = _text(g.axisLabel(tick), style.label);
      label.paint(
        canvas,
        Offset(plot.left - 8 - label.width, y - label.height / 2),
      );
      label.dispose();
    }

    // Dates de la première et de la dernière valeur, sous l'axe.
    final first = points.first.date;
    final last = points.last.date;
    final withYear = first.year != last.year;
    String date(DateTime d) =>
        withYear ? formatDayMonthYear(d) : formatDayMonth(d);
    final dateTop = plot.bottom + 4;
    final firstLabel = _text(date(first), style.label);
    if (points.length == 1) {
      firstLabel.paint(
        canvas,
        Offset(plot.center.dx - firstLabel.width / 2, dateTop),
      );
    } else {
      firstLabel.paint(canvas, Offset(plot.left, dateTop));
      final lastLabel = _text(date(last), style.label);
      lastLabel.paint(canvas, Offset(plot.right - lastLabel.width, dateTop));
      lastLabel.dispose();
    }
    firstLabel.dispose();

    // Point sélectionné : un trait vertical derrière la courbe.
    final selected = selectedIndex;
    if (selected != null) {
      final x = g.x(points[selected].date);
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        gridPaint..strokeWidth = 1.5,
      );
    }

    // La courbe, puis ses points.
    final offsets = [
      for (final point in points) Offset(g.x(point.date), g.y(point.value)),
    ];
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = style.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    final dotPaint = Paint()..color = style.line;
    for (final offset in offsets) {
      canvas.drawCircle(offset, 3.5, dotPaint);
    }
    if (selected != null) {
      canvas.drawCircle(
        offsets[selected],
        7,
        Paint()..color = style.background,
      );
      canvas.drawCircle(offsets[selected], 5.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.geometry.points != geometry.points ||
      old.geometry.size != geometry.size ||
      old.selectedIndex != selectedIndex ||
      old.style.line != style.line ||
      old.style.background != style.background;
}
