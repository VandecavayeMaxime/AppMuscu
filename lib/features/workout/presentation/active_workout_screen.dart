import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/reorder_list.dart';
import '../../../core/widgets/swipe_delete_background.dart';
import '../../../core/widgets/text_input_dialog.dart';
import '../../exercises/presentation/exercise_note.dart';
import '../../rest_timer/presentation/rest_countdown.dart';
import '../../rest_timer/presentation/rest_line.dart';
import '../../rest_timer/presentation/rest_timer_providers.dart';
import '../data/workout_repository.dart';
import '../domain/set_numbering.dart';
import '../domain/set_rules.dart';
import 'elapsed_time.dart';
import 'set_row.dart';
import 'workout_providers.dart';

/// Choix face à des séries remplies mais pas validées en terminant (WO-17).
enum _ReadySetsChoice { complete, discard, abandon }

/// Écran « Séance en cours » (docs/SPEC.md §5.2), en plein écran.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  /// Mode « réorganiser » (WO-15) : ordre affiché pendant le glisser-déposer
  /// (lignes de workout_exercises), sans attendre que la base confirme.
  /// `null` = affichage normal.
  List<String>? _order;

  /// Ligne de repos du minuteur (RT-08) : pour savoir si elle est visible et
  /// pouvoir y revenir.
  final _runningLineKey = GlobalKey();
  final _scrollViewKey = GlobalKey();

  /// Faux quand la ligne du repos en cours est sortie de l'écran : le
  /// compteur compact s'affiche alors dans l'en-tête.
  bool _runningLineVisible = true;
  bool _initialScrollDone = false;

  @override
  Widget build(BuildContext context) {
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
    final timer = ref.watch(restTimerProvider).value;
    final theme = Theme.of(context);

    // Une fois l'écran dessiné : la ligne du repos en cours est-elle visible ?
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRunningLine());
    // En rouvrant la séance pendant un repos, on arrive sur sa ligne (RT-08).
    if (details != null && !_initialScrollDone) {
      _initialScrollDone = true;
      if (timer != null && timer.isRunning(clock.now())) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _revealRunningLine(animate: false),
        );
      }
    }

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
          // Compteur compact quand la ligne du repos est hors de l'écran ;
          // le toucher y ramène (RT-08).
          if (!_runningLineVisible)
            RestCountdown(onTap: () => _revealRunningLine(animate: true)),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
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
          : _order != null
          ? _reorderList(details)
          // Tout l'écran est construit d'un coup (une séance ne compte que
          // quelques dizaines de séries) : la ligne du repos en cours existe
          // donc même hors de l'écran, et on peut y revenir.
          : NotificationListener<ScrollNotification>(
              onNotification: (_) {
                _checkRunningLine();
                return false;
              },
              child: SingleChildScrollView(
                key: _scrollViewKey,
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in details.exercises)
                      _ExerciseSection(
                        item,
                        key: ValueKey(item.entry.id),
                        runningSetId: timer?.setId,
                        runningLineKey: _runningLineKey,
                        onReorder: details.exercises.length < 2
                            ? null
                            : () => _startReorder(details),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter des exercices'),
                        onPressed: () =>
                            _addExercises(context, ref, workout.id),
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
              ),
            ),
    );
  }

  /// Met à jour [_runningLineVisible] : la ligne du repos en cours est-elle
  /// (au moins en partie) dans la zone visible de la liste ?
  void _checkRunningLine() {
    if (!mounted) return;
    final line = _runningLineKey.currentContext?.findRenderObject();
    final view = _scrollViewKey.currentContext?.findRenderObject();
    var visible = true; // pas de ligne de repos : rien à signaler
    if (line is RenderBox &&
        view is RenderBox &&
        line.attached &&
        line.hasSize &&
        view.hasSize) {
      final top = line.localToGlobal(Offset.zero).dy;
      final viewTop = view.localToGlobal(Offset.zero).dy;
      visible =
          top + line.size.height > viewTop && top < viewTop + view.size.height;
    }
    if (visible != _runningLineVisible) {
      setState(() => _runningLineVisible = visible);
    }
  }

  /// Fait défiler la liste jusqu'à la ligne du repos en cours (RT-08).
  void _revealRunningLine({required bool animate}) {
    final line = _runningLineKey.currentContext;
    if (line == null) return;
    Scrollable.ensureVisible(
      line,
      alignment: 0.3,
      duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
    );
  }

  void _startReorder(WorkoutDetails details) {
    FocusScope.of(context).unfocus();
    setState(
      () => _order = [for (final item in details.exercises) item.entry.id],
    );
  }

  Widget _reorderList(WorkoutDetails details) {
    final byId = {for (final item in details.exercises) item.entry.id: item};
    final order = [
      for (final id in _order!)
        if (byId.containsKey(id)) id,
    ];
    return ReorderList(
      items: [
        for (final id in order)
          (key: ValueKey(id), name: byId[id]!.exercise.name),
      ],
      onMove: (from, to) {
        order.insert(to, order.removeAt(from));
        setState(() => _order = order);
        ref
            .read(workoutRepositoryProvider)
            .reorderExercises(details.workout.id, order);
      },
      onDone: () => setState(() => _order = null),
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
      final abandon = await showConfirmDialog(
        context,
        title: 'Aucune série validée',
        message:
            'Valide au moins une série pour terminer la séance, '
            'ou abandonne-la.',
        cancel: 'Continuer la séance',
        confirm: 'Abandonner',
      );
      if (!abandon || !context.mounted) return;
      await ref.read(restTimerControllerProvider).stop();
      await repository.discardWorkout(workoutId);
      if (context.mounted) _leave(context);
      return;
    }

    final bool validateReadySets;
    if (ready > 0) {
      final choice = await showDialog<_ReadySetsChoice>(
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
            // Jeter les séries remplies mais pas validées n'a de sens que
            // s'il reste des séries déjà validées (RG-08) ; sinon il n'y
            // aurait plus rien à enregistrer, donc plutôt abandonner (sans
            // rien sauvegarder) que terminer une séance vide.
            if (completed > 0)
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, _ReadySetsChoice.discard),
                child: const Text('Jeter'),
              )
            else
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, _ReadySetsChoice.abandon),
                child: const Text('Abandonner'),
              ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _ReadySetsChoice.complete),
              child: const Text('Compléter'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      if (choice == _ReadySetsChoice.abandon) {
        await ref.read(restTimerControllerProvider).stop();
        await repository.discardWorkout(workoutId);
        if (context.mounted) _leave(context);
        return;
      }
      validateReadySets = choice == _ReadySetsChoice.complete;
    } else {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Terminer la séance ?',
        cancel: 'Continuer',
        confirm: 'Terminer',
      );
      if (!confirmed) return;
      validateReadySets = false;
    }

    // Terminer la séance arrête le minuteur de repos (RT-04).
    await ref.read(restTimerControllerProvider).stop();
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
    final confirmed = await showConfirmDialog(
      context,
      title: 'Annuler la séance ?',
      message: 'La séance et toutes ses séries seront supprimées.',
      cancel: 'Continuer la séance',
      confirm: 'Supprimer',
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(restTimerControllerProvider).stop();
    await ref.read(workoutRepositoryProvider).discardWorkout(workoutId);
    if (context.mounted) _leave(context);
  }
}

/// Retour aux onglets ; une séance en cours le reste (WO-21).
void _leave(BuildContext context) {
  context.canPop() ? context.pop() : context.go('/seance');
}

enum _ExerciseAction { note, reorder, remove }

/// Un exercice de la séance : titre et menu, note, tableau des séries,
/// « + Ajouter une série ».
class _ExerciseSection extends ConsumerStatefulWidget {
  const _ExerciseSection(
    this.item, {
    super.key,
    required this.runningSetId,
    required this.runningLineKey,
    this.onReorder,
  });

  final WorkoutExerciseDetails item;

  /// Série dont le repos est en cours : sa ligne de repos reçoit
  /// [runningLineKey] (RT-08).
  final String? runningSetId;
  final GlobalKey runningLineKey;

  /// Passe en mode « réorganiser » ; `null` s'il n'y a qu'un exercice.
  final VoidCallback? onReorder;

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
    final sets = [
      for (final set in item.sets)
        if (!_dismissed.contains(set.id)) set,
    ];
    final previous =
        ref.watch(previousSetsProvider(exercise.id)).value ?? const [];
    final placeholders = placeholdersOfAll(sets, previous);
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
              // Toucher le nom ouvre la fiche de l'exercice (WO-22) ; un
              // appui long réduit les exercices pour les réordonner (WO-15).
              child: InkWell(
                onTap: () =>
                    context.push('/seance-en-cours/exercice/${exercise.id}'),
                onLongPress: widget.onReorder,
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
                  child: Text(exerciseNoteAction(exercise)),
                ),
                if (widget.onReorder != null)
                  const PopupMenuItem(
                    value: _ExerciseAction.reorder,
                    child: Text('Réorganiser'),
                  ),
                const PopupMenuItem(
                  value: _ExerciseAction.remove,
                  child: Text('Retirer de la séance'),
                ),
              ],
            ),
          ],
        ),
        // Note de l'exercice, la même partout (EX-11).
        ExerciseNoteText(exercise),
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
            background: const SwipeDeleteBackground(),
            onDismissed: (_) {
              setState(() => _dismissed.add(set.id));
              ref.read(restTimerControllerProvider).stopIfFor([set.id]);
              ref.read(workoutRepositoryProvider).deleteSet(set.id);
            },
            // La série et, juste en dessous, sa ligne de repos (RT-03).
            child: Column(
              children: [
                SetRow(
                  key: ValueKey(set.id),
                  set: set,
                  label: labels[index],
                  exercise: exercise,
                  previous: index < previous.length ? previous[index] : null,
                  placeholders: placeholders[index],
                ),
                RestLine(
                  key: set.id == widget.runningSetId
                      ? widget.runningLineKey
                      : null,
                  set: set,
                  exercise: exercise,
                ),
              ],
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
        await editExerciseNote(context, ref, item.exercise);
      case _ExerciseAction.reorder:
        widget.onReorder?.call();
      case _ExerciseAction.remove:
        final confirmed = await showConfirmDialog(
          context,
          title: 'Retirer « ${item.exercise.name} » ?',
          message: 'Ses séries seront supprimées de la séance.',
          cancel: 'Annuler',
          confirm: 'Retirer',
        );
        if (!confirmed) return;
        await ref
            .read(restTimerControllerProvider)
            .stopIfFor(item.sets.map((set) => set.id));
        await repository.removeExercise(item.entry.id);
    }
  }
}
