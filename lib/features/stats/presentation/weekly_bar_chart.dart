import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../core/utils/date_format.dart';
import '../domain/weekly_sessions.dart';

/// Séances par semaine (SA-02) : une barre par semaine, qui empile un bloc
/// par séance, de la couleur de son modèle. Les 12 dernières semaines sont
/// visibles ; on glisse vers la gauche pour remonter le temps.
///
/// Ici, pas besoin de dessin sur mesure : chaque bloc est un simple
/// `Container` coloré, ce qui rend aussi chaque barre facile à toucher.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.weeks,
    required this.colorOf,
    required this.selected,
    required this.onSelect,
  });

  /// De la plus ancienne à la semaine en cours.
  final List<WeekSessions> weeks;
  final Color Function(SessionEntry session) colorOf;

  /// Lundi de la semaine sélectionnée.
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  static const visibleWeeks = 12;
  static const _barsHeight = 150.0;
  static const _labelsHeight = 20.0;
  static const _axisWidth = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    // Hauteur de l'axe, en séances : au moins 3 pour que les blocs ne
    // soient pas démesurés au début.
    final top = max(3, weeks.map((w) => w.sessions.length).fold(0, max));
    final unit = _barsHeight / top;
    final step = top <= 6 ? 1 : (top / 4).ceil();
    final ticks = [for (var k = step; k <= top; k += step) k];

    return SizedBox(
      height: _barsHeight + _labelsHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Axe vertical : nombre de séances.
          SizedBox(
            width: _axisWidth,
            height: _barsHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final k in ticks)
                  Positioned(
                    top: _barsHeight - k * unit - 7,
                    right: 6,
                    child: Text('$k', style: labelStyle),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slot = constraints.maxWidth / visibleWeeks;
                return Stack(
                  children: [
                    // Lignes horizontales derrière les barres (0 compris).
                    for (final k in [0, ...ticks])
                      Positioned(
                        top: _barsHeight - k * unit - 0.5,
                        left: 0,
                        right: 0,
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // Liste à l'envers : l'élément 0 (la semaine en cours)
                      // est à droite, et c'est lui qu'on voit d'abord.
                      reverse: true,
                      itemExtent: slot,
                      itemCount: weeks.length,
                      itemBuilder: (context, index) {
                        final week = weeks[weeks.length - 1 - index];
                        return _WeekBar(
                          key: ValueKey(week.monday),
                          week: week,
                          colorOf: colorOf,
                          unit: unit,
                          barWidth: slot * 0.5,
                          selected: week.monday == selected,
                          onTap: () => onSelect(week.monday),
                          labelStyle: labelStyle,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    super.key,
    required this.week,
    required this.colorOf,
    required this.unit,
    required this.barWidth,
    required this.selected,
    required this.onTap,
    required this.labelStyle,
  });

  final WeekSessions week;
  final Color Function(SessionEntry session) colorOf;

  /// Hauteur d'une séance.
  final double unit;
  final double barWidth;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final monday = week.monday;
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    // Le nom du mois s'affiche sous la semaine où il commence.
    final monthStarts = monday.day == 1 || sunday.month != monday.month;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: WeeklyBarChart._barsHeight,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
                  : null,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // La première séance de la semaine en bas de la pile.
                for (final session in week.sessions.reversed)
                  Container(
                    width: barWidth,
                    height: unit - 2,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: colorOf(session),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: WeeklyBarChart._labelsHeight,
            child: monthStarts
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, left: 2),
                    // Le texte peut dépasser de la barre, qui est étroite.
                    child: Text(
                      formatShortMonth(sunday),
                      style: labelStyle,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
