import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/duration_format.dart';
import '../../rest_timer/presentation/rest_line.dart';
import '../data/settings_repository.dart';
import '../domain/app_theme.dart';

/// Onglet « Réglages » (ST-01 à ST-04). Chaque changement est enregistré
/// tout de suite.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(settingsRepositoryProvider);
    final restSeconds =
        ref.watch(defaultRestSecondsProvider).value ??
        SettingsRepository.fallbackRestSeconds;
    final sound = ref.watch(restSoundProvider).value ?? true;
    final vibration = ref.watch(restVibrationProvider).value ?? true;
    final keepScreenOn = ref.watch(keepScreenOnProvider).value ?? false;
    final theme = ref.watch(appThemeProvider).value ?? AppTheme.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          const _SectionTitle('Minuteur de repos'),
          ListTile(
            title: const Text('Temps de repos par défaut'),
            subtitle: const Text(
              'Pour les exercices sans temps de repos propre',
            ),
            trailing: Text(
              restSeconds == 0 ? 'Sans repos' : formatDuration(restSeconds),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              final seconds = await showDefaultRestPicker(
                context,
                current: restSeconds,
              );
              if (seconds != null) {
                await repository.setDefaultRestSeconds(seconds);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Son'),
            subtitle: const Text('À la fin du repos'),
            value: sound,
            onChanged: repository.setRestSound,
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('À la fin du repos'),
            value: vibration,
            onChanged: repository.setRestVibration,
          ),
          const _SectionTitle('Séance'),
          SwitchListTile(
            title: const Text("Garder l'écran allumé"),
            subtitle: const Text("Tant qu'une séance est en cours"),
            value: keepScreenOn,
            onChanged: repository.setKeepScreenOn,
          ),
          const _SectionTitle('Apparence'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SegmentedButton<AppTheme>(
              segments: [
                for (final value in AppTheme.values)
                  ButtonSegment(value: value, label: Text(value.label)),
              ],
              selected: {theme},
              onSelectionChanged: (selection) =>
                  repository.setTheme(selection.single),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
