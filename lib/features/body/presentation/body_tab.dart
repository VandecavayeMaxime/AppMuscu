import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../stats/domain/chart_point.dart';
import '../../stats/domain/stats_period.dart';
import '../../stats/presentation/line_chart.dart';
import '../domain/body_measurement_field.dart';
import '../domain/body_measurement_stats.dart';
import 'annotated_silhouette.dart';
import 'body_providers.dart';

/// Périodes de la courbe du poids (SA-07).
const _periods = [StatsPeriod.month1, StatsPeriod.months3, StatsPeriod.year1];

/// Sous-onglet « Corps » (SA-07) : les tours d'abord (silhouette agrandie,
/// tactile directement sur le dessin pour ceux qui ont un tracé musculaire,
/// D31 — toujours affichée, même sans aucune mesure encore saisie, D33), puis
/// masse grasse et masse musculaire, puis le graphique — celui du poids par
/// défaut, ou celui du tour qu'on vient de toucher. Toucher le graphique
/// ouvre sa page (SA-08).
class BodyTab extends ConsumerStatefulWidget {
  const BodyTab({super.key});

  @override
  ConsumerState<BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<BodyTab> {
  var _period = StatsPeriod.months3;

  /// Le champ affiché dans le graphique (D31) ; `null` = pas encore touché,
  /// donc le poids par défaut (ou le premier champ qui a une valeur).
  BodyMeasurementField? _selectedField;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(bodyMeasurementsProvider)
        .when(
          skipLoadingOnReload: true,
          data: _content,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de charger les mesures',
            message: '$error',
          ),
        );
  }

  Widget _content(List<BodyMeasurement> rows) {
    final fatPoints = pointsOf(rows, BodyMeasurementField.bodyFat);
    final muscleMassPoints = pointsOf(rows, BodyMeasurementField.muscleMass);
    final circumferenceValues = _circumferenceValues(rows);
    final field = _effectiveField(rows, circumferenceValues);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnnotatedBodySilhouette(
            values: circumferenceValues,
            deltas: {
              for (final f in BodyMeasurementField.circumferences)
                if (pointsOf(rows, f) case final points when points.isNotEmpty)
                  f: measurementDelta(points, useThirtyDayReference: false),
            },
            selected: field,
            onTap: (f) => setState(() => _selectedField = f),
          ),
        ),
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
        if (field != null)
          _fieldSection(rows, field)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Ajoute ton poids ou tes tours pour suivre leur évolution.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
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

  /// Le tour qu'on vient de toucher s'il a encore une valeur, sinon le poids,
  /// sinon le premier champ qui en a une (D31).
  BodyMeasurementField? _effectiveField(
    List<BodyMeasurement> rows,
    Map<BodyMeasurementField, double> circumferenceValues,
  ) {
    final selected = _selectedField;
    if (selected != null && pointsOf(rows, selected).isNotEmpty) {
      return selected;
    }
    for (final f in [
      BodyMeasurementField.weight,
      BodyMeasurementField.bodyFat,
      BodyMeasurementField.muscleMass,
      ...BodyMeasurementField.circumferences,
    ]) {
      if (pointsOf(rows, f).isNotEmpty) return f;
    }
    return null;
  }

  /// Dernière valeur de chaque tour déjà saisi (SA-07).
  Map<BodyMeasurementField, double> _circumferenceValues(
    List<BodyMeasurement> rows,
  ) => {
    for (final field in BodyMeasurementField.circumferences)
      if (pointsOf(rows, field) case final points when points.isNotEmpty)
        field: points.last.value,
  };

  /// Le graphique du champ affiché (le poids par défaut, ou le tour qu'on
  /// vient de toucher, D31) : titre, dernière valeur, écart, courbe et
  /// période. Toucher ouvre sa page (SA-08), comme les autres mesures.
  Widget _fieldSection(List<BodyMeasurement> rows, BodyMeasurementField field) {
    final theme = Theme.of(context);
    final points = pointsOf(rows, field);
    final isCircumference = BodyMeasurementField.circumferences.contains(field);
    final delta = measurementDelta(
      points,
      useThirtyDayReference: !isCircumference,
    );
    final start = _period.start(clock.now());
    // Le lissage (RG-20) ne concerne que le poids : les tours et la
    // composition du corps sont saisis trop rarement pour ça.
    final smoothed = field == BodyMeasurementField.weight
        ? smoothedWeight(points)
        : [for (final p in points) ChartPoint(p.date, p.value)];
    final chartPoints = [
      for (final point in smoothed)
        if (start == null || !point.date.isBefore(start)) point,
    ];

    return InkWell(
      onTap: () => context.push('/stats/mesure/${field.name}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(field.label, style: theme.textTheme.titleMedium),
                Text(
                  '${formatNumber(points.last.value)} ${field.unit}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            if (delta != null) _DeltaText(delta, field.unit),
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
