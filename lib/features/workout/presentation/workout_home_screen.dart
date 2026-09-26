import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/empty_state.dart';
import '../data/workout_repository.dart';
import 'elapsed_time.dart';
import 'workout_providers.dart';

/// Onglet « Séance » : démarrer ou reprendre une séance, liste des modèles (M5).
class WorkoutHomeScreen extends ConsumerWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final workout = activeWorkout.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Séance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeWorkout.isLoading)
            const SizedBox.shrink()
          // Une seule séance en cours à la fois (WO-02) : on propose de la
          // reprendre au lieu d'en démarrer une autre.
          else if (workout != null) ...[
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
          ] else
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer une séance vide'),
              onPressed: () async {
                await ref.read(workoutRepositoryProvider).startWorkout();
                if (context.mounted) context.push('/seance-en-cours');
              },
            ),
          const SizedBox(height: 32),
          const EmptyState(
            icon: Icons.list_alt,
            title: "Aucun modèle pour l'instant",
            message: 'Les modèles de séance arrivent au jalon M5.',
          ),
        ],
      ),
    );
  }
}
