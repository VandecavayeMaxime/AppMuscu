import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/undo_snack_bar.dart';
import '../../workout/data/workout_repository.dart';
import '../domain/weekly_sessions.dart';
import 'session_colors.dart';
import 'stats_providers.dart';
import 'weekly_bar_chart.dart';

/// Sous-onglet « Séances » (SA-02, SA-03) : les séances par semaine, puis
/// celles de la semaine sélectionnée.
class SessionsTab extends ConsumerStatefulWidget {
  const SessionsTab({super.key});

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab> {
  /// Lundi de la semaine touchée ; `null` = la semaine en cours.
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templatesByColorProvider).value ?? const [];

    return ref
        .watch(finishedSessionsProvider)
        .when(
          skipLoadingOnReload: true,
          data: (sessions) {
            if (sessions.isEmpty) {
              return const EmptyState(
                icon: Icons.bar_chart,
                title: 'Pas encore de séance',
                message: 'Tes séances terminées apparaîtront ici, semaine par semaine.',
              );
            }
            final colors = SessionColors(
              templates,
              others: Theme.of(context).colorScheme.outline,
            );
            final weeks = groupByWeek(sessions, clock.now());
            final week = weeks.firstWhere(
              (w) => w.monday == _selected,
              orElse: () => weeks.last,
            );
            return _content(context, colors, weeks, week, sessions);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Impossible de charger les séances',
            message: '$error',
          ),
        );
  }

  /// Menu de l'appui long sur une séance, ouvert sous le doigt (WO-23).
  Future<void> _showSessionMenu(SessionEntry session, Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<_SessionAction>(
      context: context,
      position: RelativeRect.fromRect(
        position & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: _SessionAction.delete,
          child: Text('Supprimer la séance'),
        ),
      ],
    );
    if (action != _SessionAction.delete || !mounted) return;

    // Pas de confirmation : le message propose d'annuler.
    final repository = ref.read(workoutRepositoryProvider);
    await repository.deleteWorkout(session.id);
    if (!mounted) return;
    showUndoSnackBar(
      context,
      message: 'Séance supprimée',
      onUndo: () => repository.restoreWorkout(session.id),
    );
  }

  Widget _content(
    BuildContext context,
    SessionColors colors,
    List<WeekSessions> weeks,
    WeekSessions week,
    List<SessionEntry> sessions,
  ) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Séances par semaine',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: WeeklyBarChart(
            weeks: weeks,
            colorOf: colors.of,
            selected: week.monday,
            onSelect: (monday) => setState(() => _selected = monday),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              for (final entry in colors.legend(sessions))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(entry.color),
                    const SizedBox(width: 6),
                    Text(entry.label, style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        SectionTitle(formatWeekOf(week.monday)),
        if (week.sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Aucune séance cette semaine.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final session in week.sessions)
          // Appui long : petit menu pour supprimer la séance (WO-23).
          // `onLongPressStart` donne la position du doigt, où s'ouvre le menu.
          GestureDetector(
            onLongPressStart: (details) =>
                _showSessionMenu(session, details.globalPosition),
            child: ListTile(
              leading: _Dot(colors.of(session)),
              title: Text(session.name),
              subtitle: Text(
                '${formatWeekday(session.startedAt)} · '
                '${formatMinutes(session.duration)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              // Résumé de la séance, en lecture seule (SA-03).
              onTap: () => context.push('/stats/seance/${session.id}'),
            ),
          ),
      ],
    );
  }
}

enum _SessionAction { delete }

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
