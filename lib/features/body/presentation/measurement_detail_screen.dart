import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/input_parsing.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/text_input_dialog.dart';
import '../../stats/domain/chart_point.dart';
import '../../stats/domain/stats_period.dart';
import '../../../core/widgets/swipe_delete_background.dart';
import '../../stats/presentation/line_chart.dart';
import '../data/body_repository.dart';
import '../domain/body_measurement_field.dart';
import '../domain/body_measurement_stats.dart';
import 'body_providers.dart';

const _periods = [
  StatsPeriod.month1,
  StatsPeriod.months3,
  StatsPeriod.year1,
  StatsPeriod.all,
];

/// Page d'une mesure (SA-08) : courbe en grand avec sa période, puis toutes
/// ses valeurs de la plus récente à la plus ancienne. Toucher une valeur la
/// modifie ; la balayer vers la gauche la supprime.
class MeasurementDetailScreen extends ConsumerStatefulWidget {
  const MeasurementDetailScreen({super.key, required this.field});

  final BodyMeasurementField field;

  @override
  ConsumerState<MeasurementDetailScreen> createState() =>
      _MeasurementDetailScreenState();
}

class _MeasurementDetailScreenState
    extends ConsumerState<MeasurementDetailScreen> {
  var _period = StatsPeriod.months3;

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    return Scaffold(
      appBar: AppBar(title: Text(field.label)),
      body: ref
          .watch(bodyMeasurementsProvider)
          .when(
            skipLoadingOnReload: true,
            data: (rows) {
              final entries = [
                for (final row in rows)
                  if (field.valueOf(row) != null) row,
              ];
              return entries.isEmpty
                  ? const EmptyState(
                      icon: Icons.show_chart,
                      title: 'Pas encore de mesure',
                    )
                  : _content(entries);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Impossible de charger les mesures',
              message: '$error',
            ),
          ),
    );
  }

  Widget _content(List<BodyMeasurement> entries) {
    final field = widget.field;
    final points = pointsOf(entries, field);
    final start = _period.start(clock.now());
    final chartPoints = [
      for (final point in points)
        if (start == null || !point.date.isBefore(start)) point,
    ];
    final mostRecentFirst = entries.reversed.toList();

    return ListView(
      children: [
        if (chartPoints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: LineChart(
              points: [
                for (final p in chartPoints) ChartPoint(p.date, p.value),
              ],
              axisLabel: formatNumber,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              for (final period in _periods)
                ChoiceChip(
                  label: Text(period.label),
                  selected: period == _period,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _period = period),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final row in mostRecentFirst) _valueTile(row),
      ],
    );
  }

  Widget _valueTile(BodyMeasurement row) {
    final field = widget.field;
    final value = field.valueOf(row)!;
    return Dismissible(
      key: ValueKey(row.id),
      direction: DismissDirection.endToStart,
      background: const SwipeDeleteBackground(),
      onDismissed: (_) =>
          ref.read(bodyRepositoryProvider).clearValue(row.id, field),
      child: ListTile(
        title: Text('${formatNumber(value)} ${field.unit}'),
        subtitle: Text(formatDayMonthYear(row.measuredAt)),
        onTap: () => _edit(row, value),
      ),
    );
  }

  Future<void> _edit(BodyMeasurement row, double value) async {
    final field = widget.field;
    final text = await showTextInputDialog(
      context,
      title: field.label,
      initialValue: formatNumber(value),
      hint: '${field.min.round()} à ${field.max.round()} ${field.unit}',
    );
    if (text == null) return;
    final parsed = parseDecimal(text);
    if (parsed == null || !field.accepts(parsed)) return;
    await ref.read(bodyRepositoryProvider).updateValue(row.id, field, parsed);
  }
}
