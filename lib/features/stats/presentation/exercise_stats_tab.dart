import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/relative_date_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_title.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../../exercises/presentation/exercise_providers.dart';
import '../../workout/domain/workout_details.dart';
import '../../workout/presentation/set_format.dart';
import '../domain/chart_point.dart';
import '../domain/exercise_stats.dart';
import '../domain/stats_period.dart';
import 'line_chart.dart';

/// Périodes de la courbe (EX-12).
const _periods = [StatsPeriod.months3, StatsPeriod.year1, StatsPeriod.all];

/// Onglet « Statistiques » de la fiche exercice (EX-12 à EX-15) : courbe,
/// records, records par nombre de reps et fréquence. Tout est calculé à
/// partir de l'historique de l'exercice (EX-10).
class ExerciseStatsTab extends ConsumerStatefulWidget {
  const ExerciseStatsTab(this.exercise, {super.key});

  final Exercise exercise;

  @override
  ConsumerState<ExerciseStatsTab> createState() => _ExerciseStatsTabState();
}

class _ExerciseStatsTabState extends ConsumerState<ExerciseStatsTab> {
  /// Valeur suivie ; `null` = la première proposée pour le type de suivi.
  ExerciseMetric? _metric;
  var _period = StatsPeriod.year1;

  /// Point touché ; `null` = le dernier.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(exerciseHistoryProvider(widget.exercise.id))
        .when(
          skipLoadingOnReload: true,
          data: (sessions) => sessions.isEmpty
              ? const EmptyState(
                  icon: Icons.insights,
                  title: 'Pas encore de statistiques',
                  message:
                      'Elles apparaîtront après ta première séance avec cet '
                      'exercice.',
                )
              : _content(context, sessions),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de charger les statistiques',
            message: '$error',
          ),
        );
  }

  Widget _content(BuildContext context, List<ExerciseSession> sessions) {
    final theme = Theme.of(context);
    final exercise = widget.exercise;
    final unit = exercise.weightUnit;
    final now = clock.now();

    final metrics = ExerciseMetric.of(exercise.trackingType);
    final metric = metrics.contains(_metric) ? _metric! : metrics.first;
    final format = _MetricFormat.of(metric, unit);
    final start = _period.start(now);
    final points = [
      for (final point in metricHistory(sessions, metric))
        if (start == null || !point.date.isBefore(start))
          ChartPoint(point.date, format.toDisplay(point.value)),
    ];
    final selected = points.isEmpty
        ? null
        : switch (_selected) {
            final index? when index < points.length => index,
            _ => points.length - 1,
          };
    final frequency = exerciseFrequency(sessions, now)!;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _Chips(
          values: metrics,
          selected: metric,
          label: (m) => m.label,
          onSelected: (m) => setState(() {
            _metric = m;
            _selected = null;
          }),
        ),
        const SizedBox(height: 12),
        // Valeur et date du point sélectionné.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            selected == null
                ? ''
                : '${format.value(points[selected].value)} · '
                      '${formatDayMonthYear(points[selected].date)}',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: points.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Aucune séance sur cette période.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : LineChart(
                  points: points,
                  axisLabel: format.axis,
                  selectedIndex: selected,
                  onSelect: (index) => setState(() => _selected = index),
                ),
        ),
        const SizedBox(height: 8),
        _Chips(
          values: _periods,
          selected: _period,
          label: (p) => p.label,
          onSelected: (p) => setState(() {
            _period = p;
            _selected = null;
          }),
        ),
        const SectionTitle('Records'),
        for (final record in exerciseRecords(sessions, exercise.trackingType))
          _RecordTile(record, exercise),
        if (exercise.trackingType == TrackingType.weightReps) ...[
          const SectionTitle('Records par nombre de reps'),
          _RepRecordsTable(repRecords(sessions), unit),
        ],
        const SectionTitle('Fréquence'),
        ListTile(
          title: const Text('Séances'),
          trailing: Text('${frequency.sessions}'),
        ),
        ListTile(
          title: const Text('Par semaine'),
          trailing: Text('${formatNumber(frequency.perWeek)} en moyenne'),
        ),
        ListTile(
          title: const Text('Dernière fois'),
          trailing: Text(formatRelativeDay(frequency.last, now)),
        ),
      ],
    );
  }
}

/// Affichage d'une valeur de la courbe : conversion dans l'unité de
/// l'exercice, texte complet et graduation de l'axe.
class _MetricFormat {
  const _MetricFormat({
    required this.toDisplay,
    required this.value,
    required this.axis,
  });

  factory _MetricFormat.of(ExerciseMetric metric, WeightUnit unit) =>
      switch (metric) {
        ExerciseMetric.oneRepMax || ExerciseMetric.maxWeight => _MetricFormat(
          toDisplay: unit.fromKg,
          value: (v) => '${formatNumber(v)} ${unit.label}',
          axis: formatNumber,
        ),
        // Le volume reste en kg, quelle que soit l'unité (RG-01).
        ExerciseMetric.volume => _MetricFormat(
          toDisplay: (kg) => kg,
          value: (v) => '${formatVolume(v)} kg',
          axis: formatVolume,
        ),
        ExerciseMetric.maxReps || ExerciseMetric.totalReps => _MetricFormat(
          toDisplay: (reps) => reps,
          value: (v) => '${v.round()} reps',
          axis: formatNumber,
        ),
        ExerciseMetric.maxDuration ||
        ExerciseMetric.totalDuration => _MetricFormat(
          toDisplay: (seconds) => seconds,
          value: (v) => formatDuration(v.round()),
          axis: (v) => formatDuration(v.round()),
        ),
      };

  final double Function(double) toDisplay;
  final String Function(double) value;
  final String Function(double) axis;
}

/// Une rangée de choix exclusifs (valeur suivie, période).
class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          for (final value in values)
            ChoiceChip(
              label: Text(label(value)),
              selected: value == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(value),
            ),
        ],
      ),
    );
  }
}

/// Un record (EX-13) : libellé, valeur et date (avec la série quand elle
/// éclaire la valeur).
class _RecordTile extends StatelessWidget {
  const _RecordTile(this.record, this.exercise);

  final ExerciseRecord record;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final unit = exercise.weightUnit;
    final set = record.set;
    String weight(double kg) => '${formatWeight(kg, unit)} ${unit.label}';
    String setValue(WorkoutSet set) =>
        formatSetValue(set, exercise.trackingType, unit);

    final value = switch (record.kind) {
      RecordKind.oneRepMax || RecordKind.maxWeight => weight(record.value),
      RecordKind.bestSetVolume => setValue(set!),
      RecordKind.sessionVolume => '${formatVolume(record.value)} kg',
      RecordKind.maxReps ||
      RecordKind.sessionReps => '${record.value.round()} reps',
      RecordKind.maxDuration ||
      RecordKind.sessionDuration => formatDuration(record.value.round()),
    };
    final date = formatDayMonthYear(record.date);
    final detail = switch (record.kind) {
      RecordKind.oneRepMax ||
      RecordKind.maxWeight => '${setValue(set!)} · $date',
      _ => date,
    };

    return ListTile(
      title: Text(record.kind.label),
      subtitle: Text(detail),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Records par nombre de reps (EX-14) : reps, poids, date.
class _RepRecordsTable extends StatelessWidget {
  const _RepRecordsTable(this.records, this.unit);

  final List<RepRecord> records;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    Widget cell(String text, [TextStyle? style]) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: style),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(64),
          1: FlexColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            children: [
              cell('Reps', header),
              cell('Poids', header),
              cell('Date', header),
            ],
          ),
          for (final record in records)
            TableRow(
              children: [
                cell('${record.reps}'),
                cell('${formatWeight(record.weightKg, unit)} ${unit.label}'),
                cell(formatDayMonthYear(record.date)),
              ],
            ),
        ],
      ),
    );
  }
}
