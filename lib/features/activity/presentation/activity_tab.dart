import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/platform/health_data.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../stats/domain/chart_point.dart';
import '../../stats/domain/stats_period.dart';
import '../../stats/presentation/line_chart.dart';
import '../domain/activity_summary.dart';
import 'activity_providers.dart';

/// Périodes de la courbe (comme la fiche exercice et l'onglet Corps).
const _periods = [StatsPeriod.month1, StatsPeriod.months3, StatsPeriod.year1];

/// Sous-onglet « Activité » de Stats (D36, D37) : pas, distance, calories et
/// sommeil, lus sur le téléphone (Health Connect ou Apple Santé) plutôt que
/// saisis à la main, contrairement au reste de l'app — d'où l'écran
/// d'autorisation : sans elle, il n'y a vraiment rien à montrer
/// (contrairement à Corps et Muscles, D33, où une mesure/série juste pas
/// encore saisie n'empêche pas d'afficher le reste).
class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  var _metric = ActivityMetric.steps;
  var _period = StatsPeriod.months3;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(activityPermissionProvider)
        .when(
          skipLoadingOnReload: true,
          data: (granted) => granted == true ? _content() : _askPermission(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de vérifier les autorisations',
            message: '$error',
          ),
        );
  }

  Widget _askPermission() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Expanded(
        child: EmptyState(
          icon: Icons.directions_walk,
          title: 'Accès à tes données de santé',
          message:
              'Autorise l\'accès pour voir tes pas, ta distance, tes '
              'calories et ton sommeil, lus depuis Health Connect ou '
              'Apple Santé.',
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FilledButton(
          onPressed: () async {
            await ref.read(healthDataProvider).requestPermission();
            ref.invalidate(activityPermissionProvider);
          },
          child: const Text("Autoriser l'accès"),
        ),
      ),
    ],
  );

  Widget _content() {
    return ref
        .watch(activityHistoryProvider)
        .when(
          skipLoadingOnReload: true,
          data: _chart,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de charger tes données',
            message: '$error',
          ),
        );
  }

  Widget _chart(List<ActivitySummary> summaries) {
    final theme = Theme.of(context);
    final start = _period.start(clock.now());
    final chartPoints = [
      for (final summary in summaries)
        if (_metric.valueOf(summary) case final value?)
          if (start == null || !summary.date.isBefore(start))
            ChartPoint(summary.date, value),
    ];
    final latest = chartPoints.isEmpty ? null : chartPoints.last.value;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              for (final metric in ActivityMetric.values)
                ChoiceChip(
                  label: Text(metric.label),
                  selected: metric == _metric,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _metric = metric),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            latest == null
                ? 'Aucune donnée sur cette période.'
                : _format(latest),
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        if (chartPoints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LineChart(points: chartPoints, axisLabel: _axisLabel),
          ),
        const SizedBox(height: 8),
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
      ],
    );
  }

  String _axisLabel(double value) => switch (_metric) {
    ActivityMetric.steps || ActivityMetric.calories => formatNumber(value),
    ActivityMetric.distance => formatNumber(value / 1000),
    ActivityMetric.sleep => formatMinutes(Duration(minutes: value.round())),
  };

  String _format(double value) => switch (_metric) {
    ActivityMetric.steps => '${formatNumber(value)} pas',
    ActivityMetric.distance => '${formatNumber(value / 1000)} km',
    ActivityMetric.calories => '${formatNumber(value)} kcal',
    ActivityMetric.sleep => formatMinutes(Duration(minutes: value.round())),
  };
}
