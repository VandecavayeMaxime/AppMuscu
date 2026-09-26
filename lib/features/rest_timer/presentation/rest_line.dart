import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/clock_tick.dart';
import '../../../core/utils/duration_format.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../settings/data/settings_repository.dart';
import '../../workout/data/workout_repository.dart';
import '../../workout/presentation/set_row.dart';
import '../domain/rest_timer.dart';
import 'rest_timer_providers.dart';

/// Temps de repos proposés, en secondes ; 0 = pas de minuteur (RT-01).
const restChoices = [0, 30, 45, 60, 90, 120, 150, 180, 240, 300];

/// Ligne de repos affichée sous une série (RT-03), dans l'un des trois états :
/// **prévu** (temps affiché discrètement), **en cours** (barre de progression
/// et temps restant), **terminé** (✓, surligné comme la série validée). La
/// toucher permet de changer le temps de repos (RT-07). Pas de bouton (RT-04).
class RestLine extends ConsumerWidget {
  const RestLine({super.key, required this.set, required this.exercise});

  final WorkoutSet set;
  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final globalRest =
        ref.watch(defaultRestSecondsProvider).value ??
        SettingsRepository.fallbackRestSeconds;
    final seconds = effectiveRestSeconds(
      setRest: set.restSeconds,
      exerciseRest: exercise.defaultRestSeconds,
      globalRest: globalRest,
    );
    final timer = ref.watch(restTimerProvider).value;
    final now = ref.watch(clockTickProvider).value ?? clock.now();
    final running =
        timer != null && timer.setId == set.id && timer.isRunning(now);
    // Terminé : la série est validée et son repos ne tourne plus.
    final done = set.completedAt != null && !running;

    return InkWell(
      onTap: () => _chooseRest(context, ref, globalRest),
      child: Ink(
        // Même fond que la série validée juste au-dessus.
        color: done ? completedSetColor(theme.colorScheme) : null,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: running
            ? _RunningBar(
                progress: timer.progress(now),
                remainingSeconds: timer.remainingSeconds(now),
              )
            : PlainRestLine(
                label: seconds == 0 ? 'Sans repos' : formatDuration(seconds),
                done: done,
                color: done
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }

  Future<void> _chooseRest(
    BuildContext context,
    WidgetRef ref,
    int globalRest,
  ) async {
    final choice = await showRestPicker(
      context,
      current: set.restSeconds,
      defaultSeconds: exercise.defaultRestSeconds ?? globalRest,
    );
    if (choice == null) return;
    final repository = ref.read(workoutRepositoryProvider);
    if (choice.allSets) {
      await repository.setExerciseRest(set.workoutExerciseId, choice.seconds);
    } else {
      await repository.setSetRest(set.id, choice.seconds);
    }
    await saveRestAsDefault(ref, exercise, choice);
  }
}

/// « ─────── 2:00 ─────── » (prévu) ou « ─────── ✓ 2:00 ─────── » (terminé).
class PlainRestLine extends StatelessWidget {
  const PlainRestLine({
    super.key,
    required this.label,
    required this.done,
    required this.color,
  });

  final String label;
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Divider(color: color.withValues(alpha: 0.4)));
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (done) Icon(Icons.check, size: 14, color: color),
              if (done) const SizedBox(width: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
        line,
      ],
    );
  }
}

/// Barre qui se remplit pendant le repos, avec le temps restant au milieu.
class _RunningBar extends StatelessWidget {
  const _RunningBar({required this.progress, required this.remainingSeconds});

  final double progress;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // L'heure n'est relue que toutes les 200 ms : entre deux lectures,
          // la barre glisse en continu jusqu'à sa nouvelle position.
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: tickInterval,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 22,
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          Text(
            formatDuration(remainingSeconds),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Temps choisi (`null` = par défaut, 0 = sans repos), pour une série ou
/// pour toutes celles de l'exercice, et éventuellement à enregistrer comme
/// temps par défaut de l'exercice (RT-09).
typedef RestChoice = ({int? seconds, bool allSets, bool saveAsDefault});

/// Feuille de choix du temps de repos (RT-07), partagée par la séance et
/// l'éditeur de modèle. Renvoie `null` si elle est fermée sans choix.
Future<RestChoice?> showRestPicker(
  BuildContext context, {
  required int? current,
  required int defaultSeconds,
}) {
  return showModalBottomSheet<RestChoice>(
    context: context,
    showDragHandle: true,
    builder: (context) =>
        _RestPicker(current: current, defaultSeconds: defaultSeconds),
  );
}

/// « Enregistrer comme défaut de l'exercice » (RT-09) : met aussi à jour la
/// bibliothèque, tout de suite.
Future<void> saveRestAsDefault(
  WidgetRef ref,
  Exercise exercise,
  RestChoice choice,
) async {
  final seconds = choice.seconds;
  if (!choice.saveAsDefault || seconds == null) return;
  await ref
      .read(exerciseRepositoryProvider)
      .updateDefaultRest(exercise.id, seconds);
}

/// Même feuille pour le temps de repos global des réglages (ST-01) : ni
/// « Par défaut » ni « Appliquer à toutes les séries ». Renvoie le temps
/// choisi, ou `null` si elle est fermée sans choix.
Future<int?> showDefaultRestPicker(
  BuildContext context, {
  required int current,
}) async {
  final choice = await showModalBottomSheet<RestChoice>(
    context: context,
    showDragHandle: true,
    builder: (context) => _RestPicker(current: current),
  );
  return choice?.seconds;
}

/// Choix du temps de repos d'une série, ou de toutes celles de l'exercice.
class _RestPicker extends StatefulWidget {
  const _RestPicker({required this.current, this.defaultSeconds});

  /// Valeur actuelle (pour une série, `null` = par défaut).
  final int? current;

  /// Valeur par défaut qui s'appliquera si on choisit « Par défaut » (RG-09).
  /// `null` pour le réglage global : pas de choix « Par défaut », ni de case
  /// « Appliquer à toutes les séries ».
  final int? defaultSeconds;

  @override
  State<_RestPicker> createState() => _RestPickerState();
}

class _RestPickerState extends State<_RestPicker> {
  bool _allSets = false;
  bool _saveAsDefault = false;

  @override
  Widget build(BuildContext context) {
    final defaultSeconds = widget.defaultSeconds;
    final forSet = defaultSeconds != null;
    String label(int? seconds) => switch (seconds) {
      null => 'Par défaut (${formatDuration(defaultSeconds ?? 0)})',
      0 => 'Sans repos',
      _ => formatDuration(seconds),
    };

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Temps de repos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (forSet) ...[
            CheckboxListTile(
              value: _allSets,
              title: const Text("Appliquer à toutes les séries de l'exercice"),
              onChanged: (value) => setState(() => _allSets = value ?? false),
            ),
            CheckboxListTile(
              value: _saveAsDefault,
              title: const Text("Enregistrer comme défaut de l'exercice"),
              onChanged: (value) =>
                  setState(() => _saveAsDefault = value ?? false),
            ),
            const Divider(),
          ],
          // « Par défaut » n'a pas de sens si on enregistre un nouveau défaut.
          for (final seconds in <int?>[
            if (forSet && !_saveAsDefault) null,
            ...restChoices,
          ])
            ListTile(
              title: Text(label(seconds)),
              trailing: seconds == widget.current
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, (
                seconds: seconds,
                allSets: _allSets,
                saveAsDefault: _saveAsDefault,
              )),
            ),
        ],
      ),
    );
  }
}
