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
/// D31 — toujours affichée, même sans aucune mesure encore saisie, D33),
/// puis le poids seul (chiffre centré, D43), masse grasse et masse
/// musculaire (en lignes), puis le graphique — celui du poids par défaut,
/// ou celui du champ qu'on vient de toucher (un tour sur la silhouette, le
/// poids, masse grasse ou masse musculaire, D31/D44/D45). Il n'y a plus de
/// page séparée par mesure (D45, SA-08 retiré) : tout passe par ce
/// graphique commun, y compris pour le poids, un choix lissé/brut (D41)
/// s'ajoutant au-dessus de sa courbe.
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

  /// Courbe du poids lissée (moyenne sur 7 jours, RG-20) ou valeurs brutes
  /// (D41). Sans effet sur les autres champs, jamais lissés.
  var _smoothWeight = true;

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
    final weightPoints = pointsOf(rows, BodyMeasurementField.weight);
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
        // Juste sous la silhouette (D43) : seul le chiffre et l'unité,
        // centrés — pas de nom ni d'écart, contrairement aux lignes
        // ci-dessous. Toucher sélectionne le poids pour le graphique commun
        // (comme un tour sur la silhouette, D44) plutôt que d'ouvrir une
        // autre page (revenir à ça serait revenir au comportement de D31,
        // retiré en D40).
        if (weightPoints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            // `Center` autour de l'`InkWell`, pas l'inverse : sinon
            // l'`InkWell` prend toute la largeur de la ligne (celle que
            // `Center` lui laisse) et la surbrillance couvre bien plus que
            // le chiffre.
            child: Center(
              child: InkWell(
                onTap: () => setState(
                  () => _selectedField = BodyMeasurementField.weight,
                ),
                child: Text(
                  '${formatNumber(weightPoints.last.value)} '
                  '${BodyMeasurementField.weight.unit}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        if (fatPoints.isNotEmpty)
          _SummaryRow(
            field: BodyMeasurementField.bodyFat,
            points: fatPoints,
            useThirtyDayReference: true,
            onTap: (f) => setState(() => _selectedField = f),
          ),
        if (muscleMassPoints.isNotEmpty)
          _SummaryRow(
            field: BodyMeasurementField.muscleMass,
            points: muscleMassPoints,
            useThirtyDayReference: true,
            onTap: (f) => setState(() => _selectedField = f),
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

  /// Le graphique du champ affiché (le poids par défaut, ou le champ qu'on
  /// vient de toucher, D31/D45) : titre, dernière valeur, écart, courbe et
  /// période. Pas tapotable (D40) : il n'y a plus de page séparée à ouvrir
  /// (D45).
  Widget _fieldSection(List<BodyMeasurement> rows, BodyMeasurementField field) {
    final theme = Theme.of(context);
    final points = pointsOf(rows, field);
    final isCircumference = BodyMeasurementField.circumferences.contains(field);
    final delta = measurementDelta(
      points,
      useThirtyDayReference: !isCircumference,
    );
    final start = _period.start(clock.now());
    final isWeight = field == BodyMeasurementField.weight;
    // Le lissage (RG-20) ne concerne que le poids : les tours et la
    // composition du corps sont saisis trop rarement pour ça. Choix laissé
    // à l'utilisateur pour le poids (D41) : le chiffre affiché au-dessus et
    // l'écart (RG-21) restent, eux, toujours calculés sur les valeurs
    // brutes, lissées ou pas.
    final smoothed = isWeight && _smoothWeight
        ? smoothedWeight(points)
        : [for (final p in points) ChartPoint(p.date, p.value)];
    final chartPoints = [
      for (final point in smoothed)
        if (start == null || !point.date.isBefore(start)) point,
    ];

    return Padding(
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
          if (isWeight)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Lissé (7 j)')),
                  ButtonSegment(value: false, label: Text('Brut')),
                ],
                selected: {_smoothWeight},
                onSelectionChanged: (selection) =>
                    setState(() => _smoothWeight = selection.first),
              ),
            ),
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
    );
  }
}

/// Dernière valeur et écart d'un champ (masse grasse, masse musculaire).
/// Toucher sélectionne ce champ pour le graphique commun (D45), comme un
/// tour sur la silhouette ou le chiffre du poids.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.field,
    required this.points,
    required this.useThirtyDayReference,
    required this.onTap,
  });

  final BodyMeasurementField field;
  final List<MeasurementPoint> points;
  final bool useThirtyDayReference;
  final ValueChanged<BodyMeasurementField> onTap;

  @override
  Widget build(BuildContext context) {
    final delta = measurementDelta(
      points,
      useThirtyDayReference: useThirtyDayReference,
    );
    return ListTile(
      onTap: () => onTap(field),
      title: Text(field.label),
      trailing: ConstrainedBox(
        // Sans cette borne, une référence longue (« depuis le 1 sept. »,
        // D42) peut forcer `Column` à prendre toute la largeur de la
        // ligne — `ListTile` le refuse (voir sa propre vérification).
        constraints: const BoxConstraints(maxWidth: 140),
        child: Column(
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
