import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/relative_date_format.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../rest_timer/presentation/rest_timer_providers.dart';
import '../../workout/data/workout_repository.dart';
import '../../workout/presentation/workout_providers.dart';
import '../data/template_repository.dart';
import '../domain/template_preview.dart';
import 'template_providers.dart';

/// Section « Modèles » de l'onglet Séance (TP-02) : une carte par modèle,
/// et un bouton pour en créer un.
class TemplateSection extends ConsumerWidget {
  const TemplateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templateListProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Modèles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nouveau'),
              onPressed: () => context.push('/seance/modeles/nouveau'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...switch (templates) {
          null => const <Widget>[], // chargement
          [] => const [
            EmptyState(
              icon: Icons.list_alt,
              title: 'Aucun modèle',
              message:
                  'Un modèle retient tes exercices et tes séries pour '
                  'démarrer une séance en deux gestes.',
            ),
          ],
          final templates => [
            for (final details in templates)
              _TemplateCard(details, key: ValueKey(details.template.id)),
          ],
        },
      ],
    );
  }
}

/// « Jamais utilisé », « Hier », « Il y a 3 jours »…
String _lastUsedLabel(TemplateDetails details) {
  final lastUsed = details.lastUsedAt;
  return lastUsed == null
      ? 'Jamais utilisé'
      : formatRelativeDay(lastUsed, clock.now());
}

enum _TemplateAction { edit, duplicate, delete }

/// Carte d'un modèle : nom, aperçu des exercices, dernière utilisation.
/// La toucher ouvre l'aperçu ; le menu ⋯ permet de le modifier, le
/// dupliquer ou le supprimer.
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard(this.details, {super.key});

  final TemplateDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _preview(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      details.template.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<_TemplateAction>(
                    tooltip: 'Options du modèle',
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (action) => _onAction(context, ref, action),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _TemplateAction.edit,
                        child: Text('Modifier'),
                      ),
                      PopupMenuItem(
                        value: _TemplateAction.duplicate,
                        child: Text('Dupliquer'),
                      ),
                      PopupMenuItem(
                        value: _TemplateAction.delete,
                        child: Text('Supprimer'),
                      ),
                    ],
                  ),
                ],
              ),
              for (final line in templatePreview(details))
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    line,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _lastUsedLabel(details),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _preview(BuildContext context, WidgetRef ref) async {
    final start = await showModalBottomSheet<bool>(
      context: context,
      // Par-dessus la barre des onglets, et non en dessous.
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _TemplatePreview(details),
    );
    if (start == true && context.mounted) {
      await _startWorkout(context, ref, details.template);
    }
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _TemplateAction action,
  ) async {
    final repository = ref.read(templateRepositoryProvider);
    final template = details.template;
    switch (action) {
      case _TemplateAction.edit:
        await context.push('/seance/modeles/${template.id}');
      case _TemplateAction.duplicate:
        await repository.duplicateTemplate(template.id);
      case _TemplateAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: 'Supprimer « ${template.name} » ?',
          message: 'Les séances déjà faites avec ce modèle sont conservées.',
          confirm: 'Supprimer',
        );
        if (confirmed) await repository.deleteTemplate(template.id);
    }
  }
}

/// Aperçu d'un modèle, en bas de l'écran : ses exercices et le bouton
/// « Démarrer la séance ». Renvoie `true` si on veut démarrer.
class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview(this.details);

  final TemplateDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(details.template.name, style: theme.textTheme.headlineSmall),
            Text(
              _lastUsedLabel(details),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final item in details.exercises)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${item.sets.length} ×',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          Expanded(child: Text(item.exercise.name)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer la séance'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ActiveWorkoutChoice { resume, discard }

/// Démarre une séance depuis le modèle (TP-05). S'il y a déjà une séance en
/// cours, propose de la reprendre ou de l'abandonner (WO-02).
Future<void> _startWorkout(
  BuildContext context,
  WidgetRef ref,
  Template template,
) async {
  final repository = ref.read(workoutRepositoryProvider);
  final active = ref.read(activeWorkoutProvider).value;

  if (active != null) {
    final choice = await showDialog<_ActiveWorkoutChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Une séance est déjà en cours'),
        content: Text("« ${active.name} » n'est pas terminée."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _ActiveWorkoutChoice.discard),
            child: const Text("L'abandonner et démarrer"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _ActiveWorkoutChoice.resume),
            child: const Text('Reprendre la séance en cours'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    if (choice == _ActiveWorkoutChoice.resume) {
      await context.push('/seance-en-cours');
      return;
    }
    await ref.read(restTimerControllerProvider).stop();
    await repository.discardWorkout(active.id);
  }

  await repository.startWorkout(template.id);
  if (context.mounted) await context.push('/seance-en-cours');
}
