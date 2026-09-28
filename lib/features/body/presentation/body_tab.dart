import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_title.dart';
import '../../stats/domain/stats_period.dart';
import '../../stats/presentation/line_chart.dart';
import '../domain/body_measurement_field.dart';
import '../domain/body_measurement_stats.dart';
import 'annotated_silhouette.dart';
import 'body_providers.dart';

/// Périodes de la courbe du poids (SA-07).
const _periods = [StatsPeriod.month1, StatsPeriod.months3, StatsPeriod.year1];

/// Sous-onglet « Corps » (SA-07) : poids (courbe lissée, RG-20), masse
/// grasse, masse musculaire, puis les tours, chacun avec son écart (RG-21).
/// Toucher une mesure ouvre sa page (SA-08).
class BodyTab extends ConsumerStatefulWidget {
  const BodyTab({super.key});

  @override
  ConsumerState<BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<BodyTab> {
  var _period = StatsPeriod.months3;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(bodyMeasurementsProvider)
        .when(
          skipLoadingOnReload: true,
          data: (rows) => rows.isEmpty ? _empty(context) : _content(rows),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de charger les mesures',
            message: '$error',
          ),
        );
  }

  Widget _empty(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Expanded(
        child: EmptyState(
          icon: Icons.monitor_weight_outlined,
          title: 'Pas encore de mesure',
          message: 'Ajoute ton poids ou tes tours pour suivre leur évolution.',
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Mesure'),
          onPressed: () => context.push('/stats/mesure/nouvelle'),
        ),
      ),
    ],
  );

  Widget _content(List<BodyMeasurement> rows) {
    final weightPoints = pointsOf(rows, BodyMeasurementField.weight);
    final fatPoints = pointsOf(rows, BodyMeasurementField.bodyFat);
    final muscleMassPoints = pointsOf(rows, BodyMeasurementField.muscleMass);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (weightPoints.isNotEmpty) _weightSection(weightPoints),
        if (fatPoints.isNotEmpty)
          _SummaryRow(
            field: BodyMeasurementField.bodyFat,
            points: fatPoints,
            useThirtyDayReference: true,
          ),
        if (muscleMassPoints.isNotEmpty)
          _SummaryRow(
            field: BodyMeasurementField.muscleMass,
            points: muscleMassPoints,
            useThirtyDayReference: true,
          ),
        if (_circumferenceValues(rows) case final values
            when values.isNotEmpty) ...[
          const SectionTitle('Tours'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnnotatedBodySilhouette(
              values: values,
              deltas: {
                for (final field in BodyMeasurementField.circumferences)
                  if (pointsOf(rows, field) case final points
                      when points.isNotEmpty)
                    field: measurementDelta(
                      points,
                      useThirtyDayReference: false,
                    ),
              },
              onTap: (field) => context.push('/stats/mesure/${field.name}'),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Mesure'),
              onPressed: () => context.push('/stats/mesure/nouvelle'),
            ),
          ),
        ),
      ],
    );
  }

  /// Dernière valeur de chaque tour déjà saisi (SA-07).
  Map<BodyMeasurementField, double> _circumferenceValues(
    List<BodyMeasurement> rows,
  ) => {
    for (final field in BodyMeasurementField.circumferences)
      if (pointsOf(rows, field) case final points when points.isNotEmpty)
        field: points.last.value,
  };

  Widget _weightSection(List<MeasurementPoint> points) {
    final theme = Theme.of(context);
    final smoothed = smoothedWeight(points);
    final delta = measurementDelta(points, useThirtyDayReference: true);
    final start = _period.start(clock.now());
    final chartPoints = [
      for (final point in smoothed)
        if (start == null || !point.date.isBefore(start)) point,
    ];

    return InkWell(
      onTap: () => context.push('/stats/mesure/weight'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Poids', style: theme.textTheme.titleMedium),
                Text(
                  '${formatNumber(points.last.value)} kg',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            if (delta != null) _DeltaText(delta, 'kg'),
            const SizedBox(height: 8),
            if (chartPoints.isNotEmpty)
              LineChart(points: chartPoints, axisLabel: formatNumber),
            const SizedBox(height: 8),
            Wrap(
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
          ],
        ),
      ),
    );
  }
}

/// Dernière valeur et écart d'un champ (masse grasse, masse musculaire, un
/// tour), tapotable pour ouvrir sa page (SA-08).
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.field,
    required this.points,
    required this.useThirtyDayReference,
  });

  final BodyMeasurementField field;
  final List<MeasurementPoint> points;
  final bool useThirtyDayReference;

  @override
  Widget build(BuildContext context) {
    final delta = measurementDelta(
      points,
      useThirtyDayReference: useThirtyDayReference,
    );
    return ListTile(
      onTap: () => context.push('/stats/mesure/${field.name}'),
      title: Text(field.label),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${formatNumber(points.last.value)} ${field.unit}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (delta != null) _DeltaText(delta, field.unit),
        ],
      ),
    );
  }
}

/// Écart formaté (RG-21) : ▲ / ▼ / = , la valeur, et sa référence.
class _DeltaText extends StatelessWidget {
  const _DeltaText(this.delta, this.unit);

  final MeasurementDelta delta;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final arrow = switch (delta.trend) {
      MeasurementTrend.up => '▲',
      MeasurementTrend.down => '▼',
      MeasurementTrend.equal => '=',
    };
    final reference = delta.referenceIsThirtyDaysAgo
        ? 'en 30 jours'
        : 'depuis le ${formatDayMonth(delta.referenceDate)}';
    return Text(
      '$arrow ${formatNumber(delta.value.abs())} $unit $reference',
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
