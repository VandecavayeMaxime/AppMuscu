import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/input_parsing.dart';
import '../../../core/utils/weight_format.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../../rest_timer/domain/rest_timer.dart';
import '../../rest_timer/presentation/rest_timer_providers.dart';
import '../../settings/data/settings_repository.dart';
import '../data/workout_repository.dart';

/// Fond d'une série validée (WO-08), repris par sa ligne de repos une fois
/// le repos terminé : les deux forment un seul bloc coloré.
Color completedSetColor(ColorScheme colors) =>
    colors.primaryContainer.withValues(alpha: 0.6);

/// Colonnes du tableau des séries (WO-05), partagées par l'en-tête et les
/// lignes pour qu'elles restent alignées.
class SetColumns extends StatelessWidget {
  const SetColumns({
    super.key,
    required this.label,
    required this.previous,
    required this.inputs,
    required this.check,
  });

  final Widget label;
  final Widget previous;
  final List<Widget> inputs;
  final Widget check;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 44, child: Center(child: label)),
        Expanded(flex: 3, child: previous),
        for (final input in inputs)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: input,
            ),
          ),
        SizedBox(width: 56, child: Center(child: check)),
      ],
    );
  }
}

/// Titres des colonnes de saisie selon le type de suivi.
List<String> inputTitles(Exercise exercise) => switch (exercise.trackingType) {
  TrackingType.weightReps => [exercise.weightUnit.label, 'Reps'],
  TrackingType.reps => ['Reps'],
  TrackingType.duration => ['Durée'],
};

/// Une ligne du tableau : numéro, Précédent, champs de saisie, bouton ✓.
///
/// Chaque saisie est enregistrée en base immédiatement (WO-21).
class SetRow extends ConsumerStatefulWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.label,
    required this.exercise,
    this.previous,
  });

  final WorkoutSet set;

  /// Libellé de la colonne « Série » : 1, 2, W… (RG-02).
  final String label;
  final Exercise exercise;

  /// Série de même rang lors de la dernière séance (RG-03), s'il y en a une.
  final WorkoutSet? previous;

  @override
  ConsumerState<SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<SetRow> {
  final _weight = TextEditingController();
  final _reps = TextEditingController();
  final _duration = TextEditingController();
  final _weightFocus = FocusNode();
  final _repsFocus = FocusNode();
  final _durationFocus = FocusNode();

  WeightUnit get _unit => widget.exercise.weightUnit;
  WorkoutRepository get _repository => ref.read(workoutRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _syncFields();
  }

  @override
  void didUpdateWidget(SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFields();
  }

  @override
  void dispose() {
    for (final controller in [_weight, _reps, _duration]) {
      controller.dispose();
    }
    for (final focus in [_weightFocus, _repsFocus, _durationFocus]) {
      focus.dispose();
    }
    super.dispose();
  }

  /// Recopie les valeurs de la base dans les champs… sauf dans celui en cours
  /// de saisie : sinon le texte changerait sous les doigts de l'utilisateur.
  void _syncFields() {
    final set = widget.set;
    void sync(TextEditingController controller, FocusNode focus, String text) {
      if (!focus.hasFocus && controller.text != text) controller.text = text;
    }

    sync(
      _weight,
      _weightFocus,
      set.weightKg == null ? '' : formatWeight(set.weightKg!, _unit),
    );
    sync(_reps, _repsFocus, set.reps?.toString() ?? '');
    sync(
      _duration,
      _durationFocus,
      set.durationSeconds == null ? '' : formatDuration(set.durationSeconds!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = widget.set.completedAt != null;
    final previous = widget.previous;

    return Container(
      color: completed ? completedSetColor(theme.colorScheme) : null,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SetColumns(
        label: Text(widget.label, style: theme.textTheme.labelLarge),
        previous: InkWell(
          onTap: previous == null ? null : _copyPrevious,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              previous == null ? '—' : _previousText(previous),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        inputs: [
          if (widget.exercise.trackingType == TrackingType.weightReps)
            _input(
              controller: _weight,
              focus: _weightFocus,
              hint: previous?.weightKg == null
                  ? null
                  : formatWeight(previous!.weightKg!, _unit),
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              allowed: RegExp('[0-9.,]'),
              onChanged: (text) {
                final value = parseDecimal(text);
                _repository.updateSet(
                  widget.set.id,
                  weightKg: Value(value == null ? null : _unit.toKg(value)),
                );
              },
            ),
          if (widget.exercise.trackingType != TrackingType.duration)
            _input(
              controller: _reps,
              focus: _repsFocus,
              hint: previous?.reps?.toString(),
              keyboard: TextInputType.number,
              allowed: RegExp('[0-9]'),
              onChanged: (text) => _repository.updateSet(
                widget.set.id,
                reps: Value(parseInteger(text)),
              ),
            ),
          if (widget.exercise.trackingType == TrackingType.duration)
            _input(
              controller: _duration,
              focus: _durationFocus,
              hint: previous?.durationSeconds == null
                  ? null
                  : formatDuration(previous!.durationSeconds!),
              keyboard: TextInputType.datetime,
              allowed: RegExp('[0-9:]'),
              onChanged: (text) => _repository.updateSet(
                widget.set.id,
                durationSeconds: Value(parseDuration(text)),
              ),
            ),
        ],
        check: IconButton(
          tooltip: completed ? 'Annuler la validation' : 'Valider la série',
          onPressed: _toggleCompleted,
          style: IconButton.styleFrom(
            backgroundColor: completed
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            foregroundColor: completed
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
          icon: const Icon(Icons.check),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required FocusNode focus,
    required String? hint,
    required TextInputType keyboard,
    required RegExp allowed,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focus,
      keyboardType: keyboard,
      inputFormatters: [FilteringTextInputFormatter.allow(allowed)],
      textAlign: TextAlign.center,
      onChanged: onChanged,
      decoration: InputDecoration(
        // Placeholder grisé : valeur reprise si on valide sans saisir (RG-11).
        hintText: hint,
        isDense: true,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _previousText(WorkoutSet previous) {
    return switch (widget.exercise.trackingType) {
      TrackingType.weightReps =>
        '${formatWeight(previous.weightKg ?? 0, _unit)} × ${previous.reps ?? 0}',
      TrackingType.reps => '${previous.reps ?? 0}',
      TrackingType.duration => formatDuration(previous.durationSeconds ?? 0),
    };
  }

  /// Taper sur « Précédent » recopie ses valeurs dans la série (WO-06).
  void _copyPrevious() {
    final previous = widget.previous!;
    FocusScope.of(context).unfocus();
    _repository.updateSet(
      widget.set.id,
      weightKg: Value(previous.weightKg),
      reps: Value(previous.reps),
      durationSeconds: Value(previous.durationSeconds),
    );
  }

  /// Valide (WO-08) ou dévalide (WO-09) la série.
  Future<void> _toggleCompleted() async {
    FocusScope.of(context).unfocus();
    if (widget.set.completedAt != null) {
      await _repository.uncompleteSet(widget.set.id);
      await ref.read(restTimerControllerProvider).stopIfFor([widget.set.id]);
      return;
    }

    // Champ vide → valeur du placeholder (RG-11).
    final previous = widget.previous;
    final typedWeight = parseDecimal(_weight.text);
    final weightKg = typedWeight != null
        ? _unit.toKg(typedWeight)
        : previous?.weightKg;
    final reps = parseInteger(_reps.text) ?? previous?.reps;
    final duration = parseDuration(_duration.text) ?? previous?.durationSeconds;

    final trackingType = widget.exercise.trackingType;
    final missing = switch (trackingType) {
      TrackingType.weightReps when weightKg == null || reps == null =>
        'Saisis le poids et les reps',
      TrackingType.reps when reps == null => 'Saisis les reps',
      TrackingType.duration when duration == null => 'Saisis la durée',
      _ => null,
    };
    if (missing != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(missing)));
      return;
    }

    // Le repos démarre AVANT que la série soit marquée validée : sinon la
    // ligne de repos s'afficherait un instant comme « terminée » (série
    // validée, mais pas encore de minuteur) avant de passer « en cours ».
    final globalRest =
        ref.read(defaultRestSecondsProvider).value ??
        SettingsRepository.fallbackRestSeconds;
    await ref
        .read(restTimerControllerProvider)
        .start(
          setId: widget.set.id,
          seconds: effectiveRestSeconds(
            setRest: widget.set.restSeconds,
            exerciseRest: widget.exercise.defaultRestSeconds,
            globalRest: globalRest,
          ),
          nextExercise: widget.exercise.name,
        );

    await _repository.completeSet(
      widget.set.id,
      weightKg: trackingType == TrackingType.weightReps ? weightKg : null,
      reps: trackingType == TrackingType.duration ? null : reps,
      durationSeconds: trackingType == TrackingType.duration ? duration : null,
    );
  }
}
