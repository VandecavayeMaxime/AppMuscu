import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/empty_state.dart';
import '../data/workout_repository.dart';
import '../domain/set_numbering.dart';
import 'elapsed_time.dart';
import 'set_row.dart';
import 'workout_providers.dart';

/// Écran « Séance en cours » (docs/SPEC.md §5.2), en plein écran.
class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutProvider).value;
    if (workout == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.fitness_center,
          title: 'Aucune séance en cours',
        ),
      );
    }

    final details = ref.watch(workoutDetailsProvider(workout.id)).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Réduire',
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => _leave(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workout.name),
            ElapsedTime(
              workout.startedAt,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: () => _finish(context, ref, workout.id),
              child: const Text('Terminer'),
            ),
          ),
        ],
      ),
      body: details == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                for (final item in details.exercises) _ExerciseSection(item),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter des exercices'),
                    onPressed: () => _addExercises(context, ref, workout.id),
                  ),
                ),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: () => _discard(context, ref, workout.id),
                    child: const Text('Annuler la séance'),
                  ),
                ),
              ],
            ),
    );
  }

  /// Retour aux onglets ; la séance reste en cours (WO-21).
  void _leave(BuildContext context) {
    context.canPop() ? context.pop() : context.go('/seance');
  }

  Future<void> _addExercises(
    BuildContext context,
    WidgetRef ref,
    String workoutId,
  ) async {
    final exerciseIds = await context.push<List<String>>(
      '/seance-en-cours/ajouter',
    );
    if (exerciseIds == null || exerciseIds.isEmpty) return;
    await ref
        .read(workoutRepositoryProvider)
        .addExercises(workoutId, exerciseIds);
  }

  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    String workoutId,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Terminer la séance ?',
      message: 'Les séries non validées seront supprimées.',
      cancel: 'Continuer',
      confirm: 'Terminer',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(workoutRepositoryProvider).finishWorkout(workoutId);
      if (context.mounted) _leave(context);
    } on NoCompletedSetException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Valide au moins une série pour terminer, ou annule la séance.',
          ),
        ),
      );
    }
  }

  Future<void> _discard(
    BuildContext context,
    WidgetRef ref,
    String workoutId,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Annuler la séance ?',
      message: 'La séance et toutes ses séries seront supprimées.',
      cancel: 'Continuer la séance',
      confirm: 'Supprimer',
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(workoutRepositoryProvider).discardWorkout(workoutId);
    if (context.mounted) _leave(context);
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String cancel,
    required String confirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Un exercice de la séance : titre, tableau des séries, « + Ajouter une série ».
class _ExerciseSection extends ConsumerWidget {
  const _ExerciseSection(this.item);

  final WorkoutExerciseDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exercise = item.exercise;
    final previous =
        ref.watch(previousSetsProvider(exercise.id)).value ?? const [];
    final labels = setLabels([for (final set in item.sets) set.setType]);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toucher le nom ouvre la fiche de l'exercice (WO-22).
        InkWell(
          onTap: () => context.push('/seance-en-cours/exercice/${exercise.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              exercise.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        SetColumns(
          label: Text('Série', style: headerStyle),
          previous: Text(
            'Précédent',
            style: headerStyle,
            textAlign: TextAlign.center,
          ),
          inputs: [
            for (final title in inputTitles(exercise))
              Text(title, style: headerStyle, textAlign: TextAlign.center),
          ],
          check: Icon(Icons.check, size: 18, color: headerStyle?.color),
        ),
        for (final (index, set) in item.sets.indexed)
          SetRow(
            key: ValueKey(set.id),
            set: set,
            label: labels[index],
            exercise: exercise,
            previous: index < previous.length ? previous[index] : null,
          ),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une série'),
            onPressed: () =>
                ref.read(workoutRepositoryProvider).addSet(item.entry.id),
          ),
        ),
      ],
    );
  }
}
