import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/seed/exercise_media.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/settings_button.dart';
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
          ? AppBar(
              title: const Text('Exercices'),
              actions: const [SettingsButton()],
            )
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _FilterButton(mode: _mode),
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
    final imageAsset = builtInExerciseMedia[exercise.id]?.imageAsset;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imageAsset == null ? null : AssetImage(imageAsset),
        child: imageAsset != null
            ? null
            : Text(exercise.name.characters.first.toUpperCase()),
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

/// Un seul bouton pour les deux filtres (groupe musculaire, équipement),
/// plutôt qu'une puce par catégorie : ouvre une feuille avec les deux à la
/// fois, comme Strong. Son compte de filtres actifs se coche; une croix les
/// retire tous.
class _FilterButton extends ConsumerWidget {
  const _FilterButton({required this.mode});

  final ExerciseListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(exerciseFilterProvider(mode));
    final count = filter.bodyParts.length + filter.equipment.length;
    if (count == 0) {
      return ActionChip(
        avatar: const Icon(Icons.filter_list),
        label: const Text('Filtres'),
        onPressed: () => _openFilters(context),
      );
    }
    return InputChip(
      avatar: const Icon(Icons.filter_list),
      label: Text('Filtres ($count)'),
      selected: true,
      onPressed: () => _openFilters(context),
      onDeleted: () =>
          ref.read(exerciseFilterProvider(mode).notifier).clearFilters(),
      deleteButtonTooltipMessage: 'Retirer tous les filtres',
    );
  }

  void _openFilters(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => _FilterSheet(mode: mode),
  );
}

/// Les deux catégories de filtres l'une sous l'autre, chacune en puces à
/// cocher (plusieurs valeurs possibles à la fois, comme Strong) plutôt
/// qu'une liste à choix unique.
class _FilterSheet extends ConsumerWidget {
  const _FilterSheet({required this.mode});

  final ExerciseListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(exerciseFilterProvider(mode));
    final notifier = ref.read(exerciseFilterProvider(mode).notifier);
    final theme = Theme.of(context);
    final hasFilters =
        filter.bodyParts.isNotEmpty || filter.equipment.isNotEmpty;

    // Compact (densité, espacements et puces réduits) pour que tout tienne
    // sans défiler, même avec les 19 groupes musculaires et les 8
    // équipements : l'idéal est de tout voir d'un coup.
    Widget section(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(spacing: 4, runSpacing: 4, children: chips),
        ],
      ),
    );

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtres', style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: hasFilters ? notifier.clearFilters : null,
                child: const Text('Tout effacer'),
              ),
            ],
          ),
          section('Groupe musculaire', [
            for (final part in BodyPart.values)
              FilterChip(
                visualDensity: VisualDensity.compact,
                label: Text(part.label),
                selected: filter.bodyParts.contains(part),
                onSelected: (_) => notifier.toggleBodyPart(part),
              ),
          ]),
          section('Équipement', [
            for (final value in Equipment.values)
              FilterChip(
                visualDensity: VisualDensity.compact,
                label: Text(value.label),
                selected: filter.equipment.contains(value),
                onSelected: (_) => notifier.toggleEquipment(value),
              ),
          ]),
        ],
      ),
    );
  }
}
