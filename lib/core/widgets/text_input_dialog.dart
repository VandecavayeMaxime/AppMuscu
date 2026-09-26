import 'package:material_ui/material_ui.dart';

/// Boîte de dialogue avec un champ texte. Renvoie le texte saisi, ou `null`
/// si elle est annulée.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hint,
  int maxLines = 1,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextInputDialog(
      title: title,
      initialValue: initialValue,
      hint: hint,
      maxLines: maxLines,
    ),
  );
}

// Widget à état : c'est lui qui crée et libère le contrôleur du champ. Le
// libérer juste après `showDialog` planterait pendant l'animation de fermeture.
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.initialValue,
    required this.hint,
    required this.maxLines,
  });

  final String title;
  final String initialValue;
  final String? hint;
  final int maxLines;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: widget.maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
