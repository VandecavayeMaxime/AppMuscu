import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/text_input_dialog.dart';
import '../data/exercise_repository.dart';

/// Ajoute ou modifie la note personnelle d'un exercice (EX-11). Même boîte
/// de dialogue partout (séance, modèle, fiche) ; la note est enregistrée
/// tout de suite, sur l'exercice lui-même.
Future<void> editExerciseNote(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise,
) async {
  final note = await showTextInputDialog(
    context,
    title: 'Note',
    initialValue: exercise.note ?? '',
    hint: 'Réglage de la machine, sensations…',
    maxLines: 4,
  );
  if (note == null) return;
  await ref.read(exerciseRepositoryProvider).updateNote(exercise.id, note);
}

/// Libellé du menu ⋯ : « Ajouter une note » ou « Modifier la note ».
String exerciseNoteAction(Exercise exercise) =>
    exercise.note == null ? 'Ajouter une note' : 'Modifier la note';

/// La note sous le nom de l'exercice, en italique grisé (séance, modèle).
/// Rien si l'exercice n'a pas de note.
class ExerciseNoteText extends StatelessWidget {
  const ExerciseNoteText(this.exercise, {super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final note = exercise.note;
    if (note == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        note,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
