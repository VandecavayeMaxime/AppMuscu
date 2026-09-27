import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/exercise_enums.dart';
import 'exercise_providers.dart';

/// Onglet « Exercices » : bibliothèque, recherche et filtres (EX-02, EX-03).
///
/// Le même écran sert de sélecteur d'exercices (WO-04), pour la séance et
/// pour les modèles : ainsi, les deux évoluent ensemble.
class ExercisesScreen extends ConsumerStatefulWidget {
  /// L'onglet Exercices : toucher un exercice ouvre sa fiche.
  const ExercisesScreen({super.key}) : pickerOwnerPath = null;

  /// Le sélecteur, ouvert par-dessus l'écran situé à [ownerPath] (séance en
  /// cours ou éditeur de modèle). Toucher un nom ouvre la fiche, la case à
  /// cocher sélectionne l'exercice ; « Ajouter » renvoie les identifiants
  /// choisis, dans l'ordre de sélection. Un exercice créé depuis le
  /// sélecteur est sélectionné d'office.
  const ExercisesScreen.picker({super.key, required String ownerPath})
    : pickerOwnerPath = ownerPath;

  /// Chemin de l'écran qui a ouvert le sélecteur ; `null` pour l'onglet.
  final String? pickerOwnerPath;

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  late final _searchController = TextEditingController(
    text: ref.read(exerciseFilterProvider(_mode)).search,
  );

  /// Sélection en cours (sélecteur uniquement), dans l'ordre des coches.
  final _selected = <String>[];

  String? get _ownerPath => widget.pickerOwnerPath;
  ExerciseListMode get _mode =>
      _ownerPath == null ? ExerciseListMode.library : ExerciseListMode.picker;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(exerciseFilterProvider(_mode));
    final filterNotifier = ref.read(exerciseFilterProvider(_mode).notifier);
    final exercises = ref.watch(exerciseListProvider(_mode));
    final ownerPath = _ownerPath;

    return Scaffold(
      appBar: ownerPath == null
          ? AppBar(title: const Text('Exercices'))
          : AppBar(
              title: const Text('Ajouter des exercices'),
              actions: [
                TextButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => context.pop(_selected),
                  child: Text(
                    _selected.isEmpty
                        ? 'Ajouter'
                        : 'Ajouter (${_selected.length})',
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouvel exercice',
        onPressed: _createExercise,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Rechercher un exercice',
              leading: const Icon(Icons.search),
              trailing: [
                if (filter.search.isNotEmpty)
                  IconButton(
                    tooltip: 'Effacer la recherche',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      filterNotifier.search('');
                    },
                  ),
              ],
              onChanged: filterNotifier.search,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 8,
              children: [
                _FilterChip<BodyPart>(
                  label: 'Groupe musculaire',
                  selected: filter.bodyPart,
                  values: BodyPart.values,
                  labelOf: (value) => value.label,
                  onChanged: filterNotifier.filterBodyPart,
                ),
                _FilterChip<Equipment>(
                  label: 'Équipement',
                  selected: filter.equipment,
                  values: Equipment.values,
                  labelOf: (value) => value.label,
                  onChanged: filterNotifier.filterEquipment,
                ),
              ],
            ),
          ),
          Expanded(
            // Un AsyncValue a trois états : données, chargement, erreur.
            // skipLoadingOnReload : pendant une nouvelle recherche, on garde
            // la liste précédente affichée plutôt qu'un indicateur de chargement.
            child: exercises.when(
              skipLoadingOnReload: true,
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'Aucun exercice trouvé',
                      message: 'Essaie un autre nom ou retire les filtres.',
                    )
                  // Barre verticale toujours visible : la bibliothèque est
                  // grande (83 exercices), pour voir où on en est.
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 88,
                        ), // place du bouton +
                        itemCount: list.length,
                        itemBuilder: (context, index) => _tile(list[index]),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Impossible de charger les exercices',
                message: '$error',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Exercise exercise) {
    final ownerPath = _ownerPath;
    return ListTile(
      leading: CircleAvatar(
        child: Text(exercise.name.characters.first.toUpperCase()),
      ),
      title: Text(exercise.name),
      subtitle: Text(
        '${exercise.bodyPart.label} · ${exercise.equipment.label}',
      ),
      onTap: () => ownerPath == null
          ? context.go('/exercices/${exercise.id}')
          : context.push('$ownerPath/exercice/${exercise.id}'),
      trailing: ownerPath == null
          ? null
          : Checkbox(
              value: _selected.contains(exercise.id),
              onChanged: (checked) => setState(() {
                checked == true
                    ? _selected.add(exercise.id)
                    : _selected.remove(exercise.id);
              }),
            ),
    );
  }

  Future<void> _createExercise() async {
    final ownerPath = _ownerPath;
    if (ownerPath == null) {
      context.go('/exercices/nouveau');
      return;
    }
    final id = await context.push<String>('$ownerPath/nouvel-exercice');
    if (id != null && mounted) setState(() => _selected.add(id));
  }
}

/// Puce de filtre. Sans filtre : affiche [label] et ouvre la liste des choix.
/// Avec un filtre : affiche la valeur choisie, avec une croix pour le retirer.
class _FilterChip<T> extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T? selected;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = this.selected;
    if (selected == null) {
      return ActionChip(
        avatar: const Icon(Icons.filter_list),
        label: Text(label),
        onPressed: () => _choose(context),
      );
    }
    return InputChip(
      label: Text(labelOf(selected)),
      selected: true,
      onPressed: () => _choose(context),
      onDeleted: () => onChanged(null),
      deleteButtonTooltipMessage: 'Retirer le filtre',
    );
  }

  Future<void> _choose(BuildContext context) async {
    final choice = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final value in values)
              ListTile(
                title: Text(labelOf(value)),
                trailing: value == selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (choice != null) onChanged(choice);
  }
}
