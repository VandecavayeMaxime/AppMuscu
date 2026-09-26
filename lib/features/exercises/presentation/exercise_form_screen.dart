import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise_enums.dart';
import 'exercise_providers.dart';

/// Création ([exerciseId] `null`) ou modification de la définition d'un
/// exercice perso (EX-04, EX-05). Les préférences se règlent dans la fiche.
class ExerciseFormScreen extends ConsumerWidget {
  const ExerciseFormScreen({super.key, this.exerciseId});

  final String? exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = exerciseId;
    if (id == null) return const _ExerciseForm();

    return ref
        .watch(exerciseProvider(id))
        .when(
          skipLoadingOnReload: true,
          data: (exercise) => exercise != null && exercise.isCustom
              ? _ExerciseForm(initial: exercise)
              : Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.error_outline,
                    title: 'Exercice introuvable',
                  ),
                ),
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

class _ExerciseForm extends ConsumerStatefulWidget {
  const _ExerciseForm({this.initial});

  /// Exercice à modifier ; `null` pour une création.
  final Exercise? initial;

  @override
  ConsumerState<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends ConsumerState<_ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.initial?.name,
  );
  late final _instructionsController = TextEditingController(
    text: widget.initial?.instructions,
  );
  late BodyPart? _bodyPart = widget.initial?.bodyPart;
  late Equipment? _equipment = widget.initial?.equipment;
  late TrackingType _trackingType =
      widget.initial?.trackingType ?? TrackingType.weightReps;

  /// Erreur venant de la base (nom déjà pris), affichée sous le champ Nom.
  String? _nameError;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Modifier l'exercice" : 'Nouvel exercice'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nom',
                errorText: _nameError,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Le nom est obligatoire'
                  : null,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BodyPart>(
              initialValue: _bodyPart,
              decoration: const InputDecoration(labelText: 'Groupe musculaire'),
              items: [
                for (final value in BodyPart.values)
                  DropdownMenuItem(value: value, child: Text(value.label)),
              ],
              onChanged: (value) => _bodyPart = value,
              validator: (value) =>
                  value == null ? 'Choisis un groupe musculaire' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Equipment>(
              initialValue: _equipment,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: [
                for (final value in Equipment.values)
                  DropdownMenuItem(value: value, child: Text(value.label)),
              ],
              onChanged: (value) => _equipment = value,
              validator: (value) =>
                  value == null ? 'Choisis une catégorie' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Type de suivi',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TrackingType>(
              showSelectedIcon: false,
              segments: [
                for (final value in TrackingType.values)
                  ButtonSegment(value: value, label: Text(value.label)),
              ],
              selected: {_trackingType},
              onSelectionChanged: (selection) =>
                  setState(() => _trackingType = selection.single),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _instructionsController,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Instructions (facultatif)',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repository = ref.read(exerciseRepositoryProvider);
    final text = _instructionsController.text.trim();
    final instructions = text.isEmpty ? null : text;
    try {
      if (_isEditing) {
        await repository.updateCustom(
          widget.initial!.id,
          name: _nameController.text,
          equipment: _equipment!,
          bodyPart: _bodyPart!,
          trackingType: _trackingType,
          instructions: instructions,
        );
        if (mounted) context.pop();
      } else {
        // Le nouvel identifiant est renvoyé à l'écran précédent : le
        // sélecteur d'exercices s'en sert pour le cocher.
        final created = await repository.createCustom(
          name: _nameController.text,
          equipment: _equipment!,
          bodyPart: _bodyPart!,
          trackingType: _trackingType,
          instructions: instructions,
        );
        if (mounted) context.pop(created.id);
      }
    } on DuplicateExerciseNameException {
      setState(() {
        _nameError = 'Un exercice porte déjà ce nom';
        _saving = false;
      });
    }
  }
}
