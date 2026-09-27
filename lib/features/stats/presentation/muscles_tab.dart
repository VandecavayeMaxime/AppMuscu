import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_title.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../data/stats_repository.dart';
import '../domain/muscle_load.dart';
import '../domain/weekly_sessions.dart';
import 'body_silhouette.dart';
import 'stats_providers.dart';

/// Sous-onglet « Muscles » (SA-04, SA-05) : deux silhouettes colorées selon
/// les séries validées de la semaine affichée, puis la liste des muscles
/// travaillés. Une semaine à la fois (lundi à dimanche) : le but est de
/// vérifier si chaque muscle a été assez travaillé *cette semaine-là*, pas
/// de comparer des périodes de longueurs différentes.
class MusclesTab extends ConsumerStatefulWidget {
  const MusclesTab({super.key});

  @override
  ConsumerState<MusclesTab> createState() => _MusclesTabState();
}

class _MusclesTabState extends ConsumerState<MusclesTab>
    with SingleTickerProviderStateMixin {
  late DateTime _weekStart = startOfWeek(clock.now());

  /// Muscle mis en avant par un toucher, sur la silhouette ou la liste.
  BodyPart? _highlighted;

  /// Décalage horizontal (en pixels) de la silhouette pendant un glissement
  /// (SA-04) : suit le doigt dès le premier geste, puis s'anime jusqu'à 0
  /// (on reste sur la semaine) ou ± la largeur (on change de semaine).
  double _dragExtent = 0;

  late final AnimationController _dragController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _toggleHighlight(BodyPart part) =>
      setState(() => _highlighted = _highlighted == part ? null : part);

  bool get _isCurrentWeek => _weekStart == startOfWeek(clock.now());

  void _changeWeek(int deltaWeeks) => setState(() {
    final next = DateTime(
      _weekStart.year,
      _weekStart.month,
      _weekStart.day + 7 * deltaWeeks,
    );
    // Jamais de semaine future, même en glissant vite plusieurs fois.
    final current = startOfWeek(clock.now());
    _weekStart = next.isAfter(current) ? current : next;
    _highlighted = null;
  });

  /// Suit le doigt dès le début du geste (pas seulement une fois relâché) :
  /// vers la droite pour prévisualiser la semaine précédente, vers la
  /// gauche pour la suivante (jamais au-delà de la semaine en cours).
  void _onDragUpdate(DragUpdateDetails details) => setState(() {
    _dragExtent += details.delta.dx;
    if (_isCurrentWeek) _dragExtent = _dragExtent.clamp(0, double.infinity);
  });

  Future<void> _onDragEnd(DragEndDetails details, double width) async {
    final velocity = details.primaryVelocity ?? 0;
    final threshold = width / 3;
    var weekDelta = 0;
    if (_dragExtent > threshold || velocity > 700) {
      weekDelta = -1;
    } else if (!_isCurrentWeek &&
        (_dragExtent < -threshold || velocity < -700)) {
      weekDelta = 1;
    }
    final target = weekDelta == 0 ? 0.0 : width * -weekDelta;
    await _animateDragTo(target);
    if (weekDelta != 0) _changeWeek(weekDelta);
    setState(() => _dragExtent = 0);
  }

  /// Termine le geste par une petite animation, que la semaine change ou
  /// que la silhouette revienne simplement à sa place.
  Future<void> _animateDragTo(double target) async {
    final tween = Tween<double>(begin: _dragExtent, end: target);
    _dragController.value = 0;
    void listener() =>
        setState(() => _dragExtent = tween.evaluate(_dragController));
    _dragController.addListener(listener);
    try {
      await _dragController.forward();
    } finally {
      _dragController.removeListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(muscleUsageProvider)
        .when(
          skipLoadingOnReload: true,
          data: _content,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de charger les statistiques',
            message: '$error',
          ),
        );
  }

  Map<BodyPart, double> _loadForWeek(List<MuscleUsage> usage, DateTime week) {
    final weekEnd = DateTime(week.year, week.month, week.day + 7);
    final counted = [
      for (final u in usage)
        if (!u.workoutStartedAt.isBefore(week) &&
            u.workoutStartedAt.isBefore(weekEnd))
          (main: u.main, secondary: u.secondary),
    ];
    return muscleLoad(counted);
  }

  Widget _silhouettes(Map<BodyPart, double> load) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _SilhouetteColumn(
          label: 'Face',
          view: BodyView.front,
          load: load,
          highlighted: _highlighted,
          onTap: _toggleHighlight,
        ),
      ),
      Expanded(
        child: _SilhouetteColumn(
          label: 'Dos',
          view: BodyView.back,
          load: load,
          highlighted: _highlighted,
          onTap: _toggleHighlight,
        ),
      ),
    ],
  );

  Widget _content(List<MuscleUsage> usage) {
    if (usage.isEmpty) {
      return const EmptyState(
        icon: Icons.accessibility_new,
        title: 'Pas encore de statistiques',
        message:
            'Elles apparaîtront après ta première séance avec des séries '
            'validées.',
      );
    }

    final load = _loadForWeek(usage, _weekStart);
    final isCurrentWeek = _isCurrentWeek;
    final ranked = rankedMuscles(load);
    final previousWeek = DateTime(
      _weekStart.year,
      _weekStart.month,
      _weekStart.day - 7,
    );
    final previousLoad = _loadForWeek(usage, previousWeek);
    final nextWeek = DateTime(
      _weekStart.year,
      _weekStart.month,
      _weekStart.day + 7,
    );
    final nextLoad = isCurrentWeek ? null : _loadForWeek(usage, nextWeek);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _WeekHeader(
          weekStart: _weekStart,
          showThisWeekButton: !isCurrentWeek,
          onThisWeek: () => setState(() {
            _weekStart = startOfWeek(clock.now());
            _highlighted = null;
          }),
        ),
        const SizedBox(height: 12),
        // Glisser ici change de semaine (SA-04) : pas besoin de flèches. La
        // silhouette suit le doigt dès le début du geste (pas seulement une
        // fois relâché), comme un carrousel de pages.
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: (details) => _onDragEnd(details, width),
              child: ClipRect(
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(_dragExtent - width, 0),
                      child: SizedBox(
                        width: width,
                        child: _silhouettes(previousLoad),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(_dragExtent, 0),
                      child: SizedBox(
                        key: const ValueKey('current-week-silhouettes'),
                        width: width,
                        child: _silhouettes(load),
                      ),
                    ),
                    if (nextLoad != null)
                      Transform.translate(
                        offset: Offset(_dragExtent + width, 0),
                        child: SizedBox(
                          width: width,
                          child: _silhouettes(nextLoad),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        const _Legend(),
        SectionTitle('Séries de la semaine'),
        if (load.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Aucune série validée cette semaine-là.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final entry in ranked)
            _MuscleRow(
              part: entry.key,
              value: entry.value,
              fraction: entry.value / ranked.first.value,
              highlighted: _highlighted == entry.key,
              onTap: () => _toggleHighlight(entry.key),
            ),
      ],
    );
  }
}

/// En-tête de la semaine affichée (SA-04) : le changement de semaine se fait
/// en glissant sur la silhouette juste en dessous, d'où l'absence de flèches
/// ici ; un raccourci reste utile pour revenir directement à la semaine en
/// cours après avoir glissé plusieurs fois.
class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekStart,
    required this.showThisWeekButton,
    required this.onThisWeek,
  });

  final DateTime weekStart;
  final bool showThisWeekButton;
  final VoidCallback onThisWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          formatWeekRange(weekStart),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        if (showThisWeekButton)
          TextButton(
            onPressed: onThisWeek,
            child: const Text('Revenir à cette semaine'),
          ),
      ],
    );
  }
}

/// Légende des 3 repères (SA-04) : insuffisant, correct à optimal, élevé.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          item(lightRed, 'Insuffisant'),
          item(mediumRed, 'Correct'),
          item(darkRed, 'Élevé'),
        ],
      ),
    );
  }
}

class _SilhouetteColumn extends StatelessWidget {
  const _SilhouetteColumn({
    required this.label,
    required this.view,
    required this.load,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final BodyView view;
  final Map<BodyPart, double> load;
  final BodyPart? highlighted;
  final ValueChanged<BodyPart> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          BodySilhouette(
            view: view,
            load: load,
            highlighted: highlighted,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

/// Une ligne de muscle (SA-05) : nom, nombre de séries et une barre
/// proportionnelle en fond, teintée selon le même repère que la silhouette.
class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.part,
    required this.value,
    required this.fraction,
    required this.highlighted,
    required this.onTap,
  });

  final BodyPart part;
  final double value;
  final double fraction;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = muscleColor(context, part, value);
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0, 1),
              child: ColoredBox(
                color: fill.withValues(alpha: highlighted ? 0.55 : 0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text(part.label)),
                Text(formatNumber(value)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
