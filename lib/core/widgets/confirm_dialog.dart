import 'package:material_ui/material_ui.dart';

/// Boîte de dialogue de confirmation à deux boutons. Renvoie `true` si
/// l'utilisateur choisit [confirm], `false` s'il annule ou la ferme.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String cancel = 'Annuler',
  required String confirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
