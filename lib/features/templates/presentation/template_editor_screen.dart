import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/input_parsing.dart';
import '../../../core/utils/weight_format.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../rest_timer/domain/rest_timer.dart';
import '../../rest_timer/presentation/rest_line.dart';
import '../../settings/data/settings_repository.dart';
import '../../workout/presentation/exercise_reorder_list.dart';
import '../../workout/presentation/set_row.dart';
import '../data/template_repository.dart';

/// Création (TP-01) ou modification (TP-03) d'un modèle.
///
/// Même présentation que la séance en cours, sans « Précédent » ni case de
/// validation. Tout se passe dans un brouillon en mémoire, enregistré d'un
/// bloc par « Enregistrer » ; quitter sans enregistrer demande confirmation.
class TemplateEditorScreen extends ConsumerStatefulWidget {
  const TemplateEditorScreen({super.key, this.templateId});

  /// Modèle à modifier ; `null` pour en créer un.
  final String? templateId;

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  final _name = TextEditingController();

  /// `null` tant que le modèle à modifier n'est pas chargé.
  TemplateDraft? _draft;
  bool _notFound = false;

  /// Des modifications n'ont pas été enregistrées.
  bool _dirty = false;
  bool _saving = false;
  String? _nameError;

  /// Mode « réorganiser » : exercices réduits, à faire glisser.
  bool _reordering = false;

  bool get _isNew => widget.templateId == null;

  /// Chemin de cet écran, pour ouvrir le sélecteur et les fiches par-dessus.
  String get _path => _isNew
      ? '/seance/modeles/nouveau'
      : '/seance/modeles/${widget.templateId}';

  @override
  void initState() {
    super.initState();
    if (_isNew) {
      _draft = TemplateDraft();
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final details = await ref
        .read(templateRepositoryProvider)
        .getTemplate(widget.templateId!);
    if (!mounted) return;
    setState(() {
      if (details == null) {
        _notFound = true;
      } else {
        _draft = TemplateDraft.fromDetails(details);
        _name.text = details.template.name;
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Une valeur a changé (saisie) : rien à redessiner ici.
  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  /// La structure change (exercices, séries, repos) : on redessine.
  void _edit(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;

    // PopScope intercepte le retour (flèche, geste ou bouton Android) tant
    // qu'il reste des modifications non enregistrées.
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showConfirmDialog(
          context,
          title: 'Abandonner les modifications ?',
          cancel: 'Continuer',
          confirm: 'Abandonner',
        );
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'Nouveau modèle' : 'Modifier le modèle'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: draft == null || _saving ? null : _save,
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
        body: draft == null
            ? _notFound
                  ? const EmptyState(
                      icon: Icons.list_alt,
                      title: 'Modèle introuvable',
                    )
                  : const Center(child: CircularProgressIndicator())
            : _reordering
            ? ExerciseReorderList(
                items: [
                  for (final item in draft.exercises)
                    (key: ObjectKey(item), name: item.exercise.name),
                ],
                onMove: (from, to) => _edit(() => draft.moveExercise(from, to)),
                onDone: () => setState(() => _reordering = false),
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      controller: _name,
                      autofocus: _isNew,
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.titleLarge,
                      decoration: InputDecoration(
                        labelText: 'Nom du modèle',
                        errorText: _nameError,
                      ),
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                        _markDirty();
                      },
                    ),
                  ),
                  for (final (index, item) in draft.exercises.indexed)
                    _DraftExerciseSection(
                      key: ObjectKey(item),
                      item: item,
                      path: _path,
                      onValueChanged: _markDirty,
                      onEdit: _edit,
                      onReorder: draft.exercises.length < 2
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              setState(() => _reordering = true);
                            },
                      onRemove: () =>
                          _edit(() => draft.exercises.removeAt(index)),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter des exercices'),
                      onPressed: _addExercises,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _addExercises() async {
    final exerciseIds = await context.push<List<String>>('$_path/ajouter');
    if (exerciseIds == null || exerciseIds.isEmpty) return;
    final repository = ref.read(exerciseRepositoryProvider);
    final exercises = [
      for (final id in exerciseIds) await repository.findById(id),
    ];
    if (!mounted) return;
    _edit(() {
      for (final exercise in exercises.nonNulls) {
        _draft!.exercises.add(DraftExercise(exercise));
      }
    });
  }

  Future<void> _save() async {
    final draft = _draft!;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Donne un nom au modèle');
      return;
    }
    if (draft.exercises.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Ajoute au moins un exercice')),
        );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    draft.name = name;
    await ref
        .read(templateRepositoryProvider)
        .saveTemplate(draft, templateId: widget.templateId);
    // `pop` ferme l'écran même si PopScope bloque le retour.
    if (mounted) context.pop();
  }
}

enum _ExerciseAction { reorder, remove }

/// Un exercice du modèle : titre et menu, tableau des séries prévues avec
/// leur temps de repos, « + Ajouter une série ».
class _DraftExerciseSection extends ConsumerWidget {
  const _DraftExerciseSection({
    super.key,
    required this.item,
    required this.path,
    required this.onValueChanged,
    required this.onEdit,
    required this.onReorder,
    required this.onRemove,
  });

  final DraftExercise item;
  final String path;
  final VoidCallback onValueChanged;
  final void Function(VoidCallback change) onEdit;

  /// Passe en mode « réorganiser » ; `null` s'il n'y a qu'un exercice.
  final VoidCallback? onReorder;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exercise = item.exercise;
    final globalRest =
        ref.watch(defaultRestSecondsProvider).value ??
        SettingsRepository.fallbackRestSeconds;
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              // Comme pendant la séance : toucher le nom ouvre la fiche, un
              // appui long réduit les exercices pour les réordonner.
              child: InkWell(
                onTap: () => context.push('$path/exercice/${exercise.id}'),
                onLongPress: onReorder,
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
              onSelected: (action) => switch (action) {
                _ExerciseAction.reorder => onReorder?.call(),
                _ExerciseAction.remove => onRemove(),
              },
              itemBuilder: (context) => [
                if (onReorder != null)
                  const PopupMenuItem(
                    value: _ExerciseAction.reorder,
                    child: Text('Réorganiser'),
                  ),
                const PopupMenuItem(
                  value: _ExerciseAction.remove,
                  child: Text('Retirer du modèle'),
                ),
              ],
            ),
          ],
        ),
        SetColumns(
          label: Text('Série', style: headerStyle),
          inputs: [
            for (final title in inputTitles(exercise))
              Text(title, style: headerStyle, textAlign: TextAlign.center),
          ],
        ),
        for (final (index, set) in item.sets.indexed)
          // Balayer vers la gauche supprime la série, sauf la dernière :
          // un exercice du modèle a toujours au moins une série.
          Dismissible(
            key: ObjectKey(set),
            direction: item.sets.length > 1
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: const SwipeDeleteBackground(),
            onDismissed: (_) => onEdit(() => item.sets.remove(set)),
            child: Column(
              children: [
                _DraftSetRow(
                  set: set,
                  number: index + 1,
                  exercise: exercise,
                  onChanged: onValueChanged,
                ),
                _DraftRestLine(
                  set: set,
                  item: item,
                  globalRest: globalRest,
                  onEdit: onEdit,
                ),
              ],
            ),
          ),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une série'),
            onPressed: () => onEdit(item.addSet),
          ),
        ),
      ],
    );
  }
}

/// Une série prévue : numéro et champs de saisie, tous facultatifs.
class _DraftSetRow extends StatefulWidget {
  const _DraftSetRow({
    required this.set,
    required this.number,
    required this.exercise,
    required this.onChanged,
  });

  final DraftSet set;
  final int number;
  final Exercise exercise;
  final VoidCallback onChanged;

  @override
  State<_DraftSetRow> createState() => _DraftSetRowState();
}

class _DraftSetRowState extends State<_DraftSetRow> {
  DraftSet get _set => widget.set;
  late final _unit = widget.exercise.weightUnit;

  late final _weight = TextEditingController(
    text: _set.weightKg == null ? '' : formatWeight(_set.weightKg!, _unit),
  );
  late final _reps = TextEditingController(text: _set.reps?.toString() ?? '');
  late final _duration = TextEditingController(
    text: _set.durationSeconds == null
        ? ''
        : formatDuration(_set.durationSeconds!),
  );

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SetColumns(
        label: Text(
          '${widget.number}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        inputs: [
          for (final field in setFieldsOf(widget.exercise.trackingType))
            switch (field) {
              SetField.weight => SetInputField(
                field: field,
                controller: _weight,
                onChanged: (text) {
                  final value = parseDecimal(text);
                  _set.weightKg = value == null ? null : _unit.toKg(value);
                  widget.onChanged();
                },
              ),
              SetField.reps => SetInputField(
                field: field,
                controller: _reps,
                onChanged: (text) {
                  _set.reps = parseInteger(text);
                  widget.onChanged();
                },
              ),
              SetField.duration => SetInputField(
                field: field,
                controller: _duration,
                onChanged: (text) {
                  _set.durationSeconds = parseDuration(text);
                  widget.onChanged();
                },
              ),
            },
        ],
      ),
    );
  }
}

/// Temps de repos prévu après une série ; le toucher permet de le changer.
class _DraftRestLine extends StatelessWidget {
  const _DraftRestLine({
    required this.set,
    required this.item,
    required this.globalRest,
    required this.onEdit,
  });

  final DraftSet set;
  final DraftExercise item;
  final int globalRest;
  final void Function(VoidCallback change) onEdit;

  @override
  Widget build(BuildContext context) {
    final exerciseRest = item.exercise.defaultRestSeconds;
    final seconds = effectiveRestSeconds(
      setRest: set.restSeconds,
      exerciseRest: exerciseRest,
      globalRest: globalRest,
    );

    return InkWell(
      onTap: () async {
        final choice = await showRestPicker(
          context,
          current: set.restSeconds,
          defaultSeconds: exerciseRest ?? globalRest,
        );
        if (choice == null) return;
        onEdit(() {
          if (choice.allSets) {
            item.setRestForAll(choice.seconds);
          } else {
            set.restSeconds = choice.seconds;
          }
        });
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: PlainRestLine(
          label: seconds == 0 ? 'Sans repos' : formatDuration(seconds),
          done: false,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
