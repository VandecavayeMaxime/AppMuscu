import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/duration_format.dart';
import '../../../core/utils/weight_format.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../../templates/data/template_repository.dart';
import '../../templates/domain/template_changes.dart';
import '../../templates/presentation/template_providers.dart';
import '../domain/best_set.dart';
import '../domain/exercise_comparison.dart';
import '../domain/set_numbering.dart';
import '../domain/workout_details.dart';
import '../domain/workout_summary.dart';
import 'set_format.dart';
import 'workout_providers.dart';

/// Résumé affiché à la fin d'une séance (WO-18) : chiffres clés, puis chaque
/// exercice avec ses séries et sa comparaison avec la dernière fois. Il
/// propose aussi de mettre à jour le modèle d'origine (TP-07).
class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(workoutDetailsProvider(workoutId)).value;
    if (details == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final workout = details.workout;
    final summary = WorkoutSummary.of(details);
    String time(DateTime date) => localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
      alwaysUse24HourFormat: true,
    );
    final secondaryStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Séance terminée'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Icon(Icons.emoji_events, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            workout.name,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            localizations.formatFullDate(workout.startedAt),
            style: secondaryStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            '${time(workout.startedAt)} → ${time(workout.endedAt ?? workout.startedAt)}',
            style: secondaryStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _UpdateTemplateCard(details),
          const SizedBox(height: 8),
          Row(
            children: [
              _Stat('Durée', formatDuration(summary.duration.inSeconds)),
              _Stat('Exercices', '${summary.exerciseCount}'),
            ],
          ),
          Row(
            children: [
              _Stat('Séries', '${summary.setCount}'),
              _Stat('Volume', '${formatVolume(summary.volumeKg)} kg'),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in details.exercises)
            _ExerciseSummaryCard(item: item, startedAt: workout.startedAt),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => context.go('/seance'),
            child: const Text('OK'),
          ),
        ),
      ),
    );
  }
}

/// « La séance diffère du modèle » + bouton de mise à jour (TP-07). Rien si
/// la séance ne vient pas d'un modèle ou s'y conforme.
class _UpdateTemplateCard extends ConsumerWidget {
  const _UpdateTemplateCard(this.details);

  final WorkoutDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateId = details.workout.templateId;
    // Le modèle d'origine ; `null` s'il a été supprimé entre-temps.
    final template = templateId == null
        ? null
        : ref.watch(templateProvider(templateId)).value;
    if (template == null || !workoutDiffersFromTemplate(details, template)) {
      return const SizedBox.shrink();
    }
    final name = template.template.name;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('La séance diffère du modèle « $name ».'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(templateRepositoryProvider)
                      .updateFromWorkout(template.template.id, details);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Modèle « $name » mis à jour')),
                  );
                },
                child: const Text('Mettre à jour le modèle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un exercice du résumé : ses séries (★ = meilleure), puis l'évolution
/// depuis la dernière fois.
class _ExerciseSummaryCard extends ConsumerWidget {
  const _ExerciseSummaryCard({required this.item, required this.startedAt});

  final WorkoutExerciseDetails item;
  final DateTime startedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exercise = item.exercise;
    final type = exercise.trackingType;
    final unit = exercise.weightUnit;
    final sets = [
      for (final set in item.sets)
        if (set.completedAt != null) set,
    ];
    final labels = setLabels([for (final set in sets) set.setType]);
    final best = bestSetIndex(sets, type);
    final previous = ref
        .watch(
          previousSetsBeforeProvider((
            exerciseId: exercise.id,
            startedBefore: startedAt,
          )),
        )
        .value;
    final comparison = previous == null
        ? null
        : compareWithPrevious(sets, previous, type);
    final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final (index, set) in sets.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        labels[index],
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Text(formatSetValue(set, type, unit))),
                    if (index == best)
                      Icon(
                        Icons.star,
                        size: 18,
                        color: theme.colorScheme.primary,
                        semanticLabel: 'Meilleure série',
                      ),
                  ],
                ),
              ),
            const Divider(height: 24),
            if (previous == null)
              const SizedBox.shrink() // chargement
            else if (comparison == null)
              Text('Première fois avec cet exercice', style: secondaryStyle)
            else ...[
              _ComparisonRow(
                label: _totalLabel(type),
                value: _formatTotal(comparison.total, type),
                trend: comparison.totalTrend,
                delta: _formatDelta(comparison.totalDelta, type),
              ),
              _ComparisonRow(
                label: 'Meilleure série',
                value: formatSetValue(comparison.best, type, unit),
                trend: comparison.bestTrend,
              ),
              Text(
                'Dernière fois : '
                '${formatSetValue(comparison.previousBest, type, unit)}',
                style: secondaryStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _totalLabel(TrackingType type) => switch (type) {
  TrackingType.weightReps => 'Volume',
  TrackingType.reps => 'Reps au total',
  TrackingType.duration => 'Durée totale',
};

String _formatTotal(double total, TrackingType type) => switch (type) {
  TrackingType.weightReps => '${formatVolume(total)} kg',
  TrackingType.reps => '${total.round()} reps',
  TrackingType.duration => formatDuration(total.round()),
};

/// Écart avec la dernière fois : « +95 kg », « −3 reps », « = ».
String _formatDelta(double delta, TrackingType type) {
  if (trendOf(delta, 0) == Trend.same) return '=';
  final sign = delta > 0 ? '+' : '−';
  return '$sign${_formatTotal(delta.abs(), type)}';
}

/// « Volume   1 615 kg   ▲ +95 kg »
class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.trend,
    this.delta,
  });

  final String label;
  final String value;
  final Trend trend;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, meaning) = switch (trend) {
      Trend.up => (Icons.arrow_upward, theme.colorScheme.primary, 'En hausse'),
      Trend.down => (
        Icons.arrow_downward,
        theme.colorScheme.error,
        'En baisse',
      ),
      Trend.same => (
        Icons.drag_handle,
        theme.colorScheme.onSurfaceVariant,
        'Stable',
      ),
    };
    final delta = this.delta;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: color, semanticLabel: meaning),
          if (delta != null) ...[
            const SizedBox(width: 2),
            Text(
              delta,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}
