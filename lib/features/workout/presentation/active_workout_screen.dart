import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/text_input_dialog.dart';
import '../data/workout_repository.dart';
import '../domain/set_numbering.dart';
import '../domain/set_rules.dart';
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
        // Toucher le nom permet de le changer (WO-01).
        title: InkWell(
          onTap: () => _rename(context, ref, workout),
          child: Column(
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
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: details == null
                  ? null
                  : () => _finish(context, ref, details),
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
                for (final item in details.exercises)
                  _ExerciseSection(item, key: ValueKey(item.entry.id)),
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

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final name = await showTextInputDialog(
      context,
      title: 'Nom de la séance',
      initialValue: workout.name,
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(workoutRepositoryProvider).renameWorkout(workout.id, name);
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

  /// Terminer la séance (WO-17), puis afficher le résumé (WO-18).
  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetails details,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workoutId = details.workout.id;

    var completed = 0;
    var ready = 0; // remplies mais pas validées
    for (final item in details.exercises) {
      for (final set in item.sets) {
        if (set.completedAt != null) {
          completed++;
        } else if (isSetReady(set, item.exercise.trackingType)) {
          ready++;
        }
      }
    }

    // Rien à enregistrer : on propose d'abandonner la séance (RG-08).
    if (completed == 0 && ready == 0) {
      final abandon = await _confirm(
        context,
        title: 'Aucune série validée',
        message:
            'Valide au moins une série pour terminer la séance, '
            'ou abandonne-la.',
        cancel: 'Continuer la séance',
        confirm: 'Abandonner',
      );
      if (!abandon || !context.mounted) return;
      await repository.discardWorkout(workoutId);
      if (context.mounted) _leave(context);
      return;
    }

    final bool validateReadySets;
    if (ready > 0) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Séries inachevées'),
          content: Text(
            ready == 1
                ? '1 série est remplie mais pas validée.'
                : '$ready séries sont remplies mais pas validées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            // Jeter n'a de sens que s'il reste des séries validées (RG-08).
            if (completed > 0)
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Jeter'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Compléter'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      validateReadySets = choice;
    } else {
      final confirmed = await _confirm(
        context,
        title: 'Terminer la séance ?',
        cancel: 'Continuer',
        confirm: 'Terminer',
      );
      if (!confirmed) return;
      validateReadySets = false;
    }

    await repository.finishWorkout(
      workoutId,
      validateReadySets: validateReadySets,
    );
    if (context.mounted) context.pushReplacement('/resume/$workoutId');
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
}

/// Retour aux onglets ; une séance en cours le reste (WO-21).
void _leave(BuildContext context) {
  context.canPop() ? context.pop() : context.go('/seance');
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  String? message,
  required String cancel,
  required String confirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
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

enum _ExerciseAction { note, remove }

/// Un exercice de la séance : titre et menu, note, tableau des séries,
/// « + Ajouter une série ».
class _ExerciseSection extends ConsumerStatefulWidget {
  const _ExerciseSection(this.item, {super.key});

  final WorkoutExerciseDetails item;

  @override
  ConsumerState<_ExerciseSection> createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends ConsumerState<_ExerciseSection> {
  /// Séries balayées : masquées tout de suite, sans attendre que la base
  /// confirme leur suppression (le widget Dismissible l'exige).
  final _dismissed = <String>{};

  WorkoutExerciseDetails get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = item.exercise;
    final note = item.entry.notes;
    final sets = [
      for (final set in item.sets)
        if (!_dismissed.contains(set.id)) set,
    ];
    final previous =
        ref.watch(previousSetsProvider(exercise.id)).value ?? const [];
    final labels = setLabels([for (final set in sets) set.setType]);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              // Toucher le nom ouvre la fiche de l'exercice (WO-22).
              child: InkWell(
                onTap: () =>
                    context.push('/seance-en-cours/exercice/${exercise.id}'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
                  child: Text(
                    exercise.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            PopupMenuButton<_ExerciseAction>(
              tooltip: "Options de l'exercice",
              icon: const Icon(Icons.more_horiz),
              onSelected: _onAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _ExerciseAction.note,
                  child: Text(
                    note == null ? 'Ajouter une note' : 'Modifier la note',
                  ),
                ),
                const PopupMenuItem(
                  value: _ExerciseAction.remove,
                  child: Text('Retirer de la séance'),
                ),
              ],
            ),
          ],
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              note,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
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
        for (final (index, set) in sets.indexed)
          // Balayer vers la gauche supprime la série (WO-11).
          Dismissible(
            key: ValueKey('dismiss-${set.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: theme.colorScheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            onDismissed: (_) {
              setState(() => _dismissed.add(set.id));
              ref.read(workoutRepositoryProvider).deleteSet(set.id);
            },
            child: SetRow(
              key: ValueKey(set.id),
              set: set,
              label: labels[index],
              exercise: exercise,
              previous: index < previous.length ? previous[index] : null,
            ),
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

  Future<void> _onAction(_ExerciseAction action) async {
    final repository = ref.read(workoutRepositoryProvider);
    switch (action) {
      case _ExerciseAction.note:
        final note = await showTextInputDialog(
          context,
          title: 'Note',
          initialValue: item.entry.notes ?? '',
          hint: 'Réglage de la machine, sensations…',
          maxLines: 4,
        );
        if (note != null) {
          await repository.updateExerciseNote(item.entry.id, note);
        }
      case _ExerciseAction.remove:
        final confirmed = await _confirm(
          context,
          title: 'Retirer « ${item.exercise.name} » ?',
          message: 'Ses séries seront supprimées de la séance.',
          cancel: 'Annuler',
          confirm: 'Retirer',
        );
        if (confirmed) await repository.removeExercise(item.entry.id);
    }
  }
}
