import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../templates/presentation/template_list.dart';
import 'elapsed_time.dart';
import 'workout_providers.dart';

/// Onglet « Séance » : reprendre la séance en cours, et les modèles, d'où
/// démarre toute séance (WO-01).
class WorkoutHomeScreen extends ConsumerWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Séance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Une seule séance en cours à la fois (WO-02) : on propose de la
          // reprendre.
          if (workout != null) ...[
            Text(
              'Séance en cours',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(workout.name, overflow: TextOverflow.ellipsis),
                subtitle: ElapsedTime(workout.startedAt),
                onTap: () => context.push('/seance-en-cours'),
                trailing: FilledButton(
                  onPressed: () => context.push('/seance-en-cours'),
                  child: const Text('Reprendre'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          const TemplateSection(),
        ],
      ),
    );
  }
}
