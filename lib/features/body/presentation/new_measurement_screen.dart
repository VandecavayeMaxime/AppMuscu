import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/input_parsing.dart';
import '../../../core/utils/weight_format.dart';
import '../data/body_repository.dart';
import '../domain/body_measurement_field.dart';

/// « + Mesure » (SA-06) : un formulaire daté du jour (modifiable), tous les
/// champs facultatifs mais il en faut au moins un (RG-22). Chaque champ
/// affiche en grisé sa dernière valeur, qui n'est enregistrée que si on la
/// retape : au départ, les champs sont vides.
class NewMeasurementScreen extends ConsumerStatefulWidget {
  const NewMeasurementScreen({super.key});

  @override
  ConsumerState<NewMeasurementScreen> createState() =>
      _NewMeasurementScreenState();
}

class _NewMeasurementScreenState extends ConsumerState<NewMeasurementScreen> {
  late DateTime _date;
  final _controllers = {
    for (final field in BodyMeasurementField.values)
      field: TextEditingController(),
  };
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = clock.now();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: clock.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final values = <BodyMeasurementField, double>{};
    for (final MapEntry(key: field, value: controller)
        in _controllers.entries) {
      final text = controller.text.trim();
      if (text.isEmpty) continue;
      final value = parseDecimal(text);
      if (value == null || !field.accepts(value)) {
        setState(
          () => _error =
              '${field.label} : entre ${formatNumber(field.min)} et '
              '${formatNumber(field.max)} ${field.unit}.',
        );
        return;
      }
      values[field] = value;
    }

    if (values.isEmpty) {
      setState(() => _error = 'Saisis au moins une valeur.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });
    await ref.read(bodyRepositoryProvider).addMeasurementValues(_date, values);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final latest = ref.watch(_latestValuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle mesure'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            trailing: Text(formatDayMonthYear(_date)),
            onTap: _pickDate,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          _field(BodyMeasurementField.weight, latest),
          _field(BodyMeasurementField.bodyFat, latest),
          _field(BodyMeasurementField.muscleMass, latest),
          const SizedBox(height: 16),
          Text('Tours (cm)', style: Theme.of(context).textTheme.titleSmall),
          for (final field in BodyMeasurementField.circumferences)
            _field(field, latest),
          const SizedBox(height: 16),
          Text(
            'Valeurs grisées = dernière mesure ; seuls les champs remplis '
            'comptent.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    BodyMeasurementField field,
    AsyncValue<Map<BodyMeasurementField, double>> latest,
  ) {
    final hintValue = latest.value?[field];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _controllers[field],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: '${field.label} (${field.unit})',
          hintText: hintValue == null ? null : formatNumber(hintValue),
        ),
      ),
    );
  }
}

final _latestValuesProvider =
    FutureProvider.autoDispose<Map<BodyMeasurementField, double>>(
      (ref) => ref.watch(bodyRepositoryProvider).latestValues(),
    );
