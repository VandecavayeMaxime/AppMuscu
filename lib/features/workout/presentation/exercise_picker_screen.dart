import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/widgets/empty_state.dart';
import '../../exercises/data/exercise_repository.dart';

/// Tous les exercices actifs de la bibliothèque.
final _allExercisesProvider = StreamProvider.autoDispose<List<Exercise>>(
  (ref) => ref.watch(exerciseRepositoryProvider).watchExercises(),
);

/// Sélecteur multiple d'exercices avec recherche (WO-04). Toucher un nom
/// ouvre la fiche de l'exercice ; la case à cocher le sélectionne. Renvoie la
/// liste des identifiants choisis, dans l'ordre de sélection.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final _selected = <String>[];
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(_allExercisesProvider).value ?? const [];
    // La bibliothèque est petite : on filtre directement en mémoire.
    final query = normalizeForSearch(_search);
    final visible = [
      for (final exercise in all)
        if (exercise.nameNormalized.contains(query)) exercise,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter des exercices'),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty ? null : () => context.pop(_selected),
            child: Text(
              _selected.isEmpty ? 'Ajouter' : 'Ajouter (${_selected.length})',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              hintText: 'Rechercher un exercice',
              leading: const Icon(Icons.search),
              onChanged: (text) => setState(() => _search = text),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Aucun exercice trouvé',
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final exercise = visible[index];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.bodyPart.label} · '
                          '${exercise.equipment.label}',
                        ),
                        // Le nom ouvre la fiche ; la case sélectionne.
                        onTap: () => context.push(
                          '/seance-en-cours/exercice/${exercise.id}',
                        ),
                        trailing: Checkbox(
                          value: _selected.contains(exercise.id),
                          onChanged: (checked) => setState(() {
                            checked == true
                                ? _selected.add(exercise.id)
                                : _selected.remove(exercise.id);
                          }),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
