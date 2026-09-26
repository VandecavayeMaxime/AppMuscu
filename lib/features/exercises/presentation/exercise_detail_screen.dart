import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../workout/data/workout_repository.dart';
import '../../workout/domain/best_set.dart';
import '../../workout/domain/set_numbering.dart';
import '../../workout/presentation/set_format.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise_enums.dart';
import 'exercise_providers.dart';

/// Temps de repos proposés en secondes ; 0 = minuteur désactivé (RT-01).
const _restChoices = [0, 30, 45, 60, 90, 120, 150, 180, 240, 300];

/// Fiche d'un exercice : onglets « À propos » et « Historique » (EX-07).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(exerciseProvider(exerciseId))
        .when(
          skipLoadingOnReload: true,
          data: (exercise) => exercise == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.error_outline,
                    title: 'Exercice introuvable',
                  ),
                )
              : _ExerciseDetail(exercise),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) => Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.error_outline,
              title: 'Erreur',
              message: '$error',
            ),
          ),
        );
  }
}

enum _MenuAction { edit, delete }

class _ExerciseDetail extends ConsumerWidget {
  const _ExerciseDetail(this.exercise);

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exercise.name),
          actions: [
            // Modifier / supprimer : exercices perso uniquement (EX-05).
            if (exercise.isCustom)
              PopupMenuButton<_MenuAction>(
                tooltip: "Plus d'options",
                onSelected: (action) {
                  switch (action) {
                    case _MenuAction.edit:
                      context.go('/exercices/${exercise.id}/modifier');
                    case _MenuAction.delete:
                      _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _MenuAction.edit,
                    child: Text('Modifier'),
                  ),
                  PopupMenuItem(
                    value: _MenuAction.delete,
                    child: Text('Supprimer'),
                  ),
                ],
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À propos'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_AboutTab(exercise), _HistoryTab(exercise)],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer « ${exercise.name} » ?'),
        content: const Text(
          'Il disparaîtra de la bibliothèque, mais restera visible dans '
          "les séances et les modèles qui l'utilisent.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(exerciseRepositoryProvider).archiveCustom(exercise.id);
    if (context.mounted) context.go('/exercices');
  }
}

// ─── Onglet « À propos » ─────────────────────────────────────────────────────

class _AboutTab extends ConsumerWidget {
  const _AboutTab(this.exercise);

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final instructions = exercise.instructions ?? '';

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Image générique, en attendant les illustrations des mouvements.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 72,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Groupe musculaire'),
          trailing: Text(exercise.bodyPart.label),
        ),
        ListTile(
          title: const Text('Catégorie'),
          trailing: Text(exercise.equipment.label),
        ),
        const _SectionTitle('Instructions'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            instructions.isEmpty ? 'Aucune instruction.' : instructions,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        const _SectionTitle('Préférences'),
        if (exercise.trackingType == TrackingType.weightReps)
          ListTile(
            title: const Text('Unité'),
            trailing: SegmentedButton<WeightUnit>(
              showSelectedIcon: false,
              segments: [
                for (final unit in WeightUnit.values)
                  ButtonSegment(value: unit, label: Text(unit.label)),
              ],
              selected: {exercise.weightUnit},
              onSelectionChanged: (selection) => _savePreferences(
                ref,
                weightUnit: selection.single,
                defaultRestSeconds: exercise.defaultRestSeconds,
              ),
            ),
          ),
        ListTile(
          title: const Text('Minuteur de repos'),
          trailing: Text(_restLabel(exercise.defaultRestSeconds)),
          onTap: () => _chooseRest(context, ref),
        ),
      ],
    );
  }

  Future<void> _savePreferences(
    WidgetRef ref, {
    required WeightUnit weightUnit,
    required int? defaultRestSeconds,
  }) {
    return ref
        .read(exerciseRepositoryProvider)
        .updatePreferences(
          exercise.id,
          weightUnit: weightUnit,
          defaultRestSeconds: defaultRestSeconds,
        );
  }

  Future<void> _chooseRest(BuildContext context, WidgetRef ref) async {
    // Enveloppé dans un record pour distinguer « Réglage global » (null)
    // de « feuille fermée sans choix » (résultat null).
    final choice = await showModalBottomSheet<({int? seconds})>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final seconds in <int?>[null, ..._restChoices])
              ListTile(
                title: Text(_restLabel(seconds)),
                trailing: seconds == exercise.defaultRestSeconds
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, (seconds: seconds)),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    await _savePreferences(
      ref,
      weightUnit: exercise.weightUnit,
      defaultRestSeconds: choice.seconds,
    );
  }
}

String _restLabel(int? seconds) => switch (seconds) {
  null => 'Réglage global',
  0 => 'Désactivé',
  _ => formatDuration(seconds),
};

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

// ─── Onglet « Historique » ───────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab(this.exercise);

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(exerciseHistoryProvider(exercise.id))
        .when(
          skipLoadingOnReload: true,
          data: (sessions) => sessions.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: "Pas encore d'historique",
                  message: 'Tes séances avec cet exercice apparaîtront ici.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) => _SessionCard(
                    session: sessions[index],
                    exercise: exercise,
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: "Impossible de charger l'historique",
            message: '$error',
          ),
        );
  }
}

/// Un bloc de l'historique : nom de la séance, date, séries (★ = meilleure).
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.exercise});

  final ExerciseSession session;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = setLabels([for (final set in session.sets) set.setType]);
    final best = bestSetIndex(session.sets, exercise.trackingType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.workoutName, style: theme.textTheme.titleMedium),
            Text(
              MaterialLocalizations.of(context).formatFullDate(session.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final (index, set) in session.sets.indexed)
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
                    Expanded(
                      child: Text(
                        formatSetValue(
                          set,
                          exercise.trackingType,
                          exercise.weightUnit,
                        ),
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }
}
