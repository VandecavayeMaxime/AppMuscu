import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/rest_timer.dart';

final restTimerRepositoryProvider = Provider<RestTimerRepository>(
  (ref) => RestTimerRepository(ref.watch(appDatabaseProvider)),
);

/// État du minuteur de repos, enregistré dans la table settings pour survivre
/// à l'arrêt de l'app (RT-06).
class RestTimerRepository {
  RestTimerRepository(this._db);

  final AppDatabase _db;

  static const _setKey = 'rest_set_id';
  static const _endsAtKey = 'rest_ends_at';
  static const _totalKey = 'rest_total_seconds';
  static const _keys = [_setKey, _endsAtKey, _totalKey];

  /// Le minuteur enregistré (éventuellement déjà écoulé), ou `null`.
  Stream<RestTimer?> watch() => _query.watch().map(_toTimer);

  /// Comme [watch], en une seule lecture.
  Future<RestTimer?> read() async => _toTimer(await _query.get());

  SimpleSelectStatement<$SettingsTable, Setting> get _query =>
      _db.select(_db.settings)..where((s) => s.key.isIn(_keys));

  RestTimer? _toTimer(List<Setting> rows) {
    final values = {for (final row in rows) row.key: row.value};
    final setId = values[_setKey];
    final endsAt = int.tryParse(values[_endsAtKey] ?? '');
    final total = int.tryParse(values[_totalKey] ?? '');
    if (setId == null || endsAt == null || total == null) return null;
    return RestTimer(
      setId: setId,
      endsAt: DateTime.fromMillisecondsSinceEpoch(endsAt),
      totalSeconds: total,
    );
  }

  Future<void> save(RestTimer timer) {
    return _db.transaction(() async {
      final values = {
        _setKey: timer.setId,
        _endsAtKey: '${timer.endsAt.millisecondsSinceEpoch}',
        _totalKey: '${timer.totalSeconds}',
      };
      for (final MapEntry(:key, :value) in values.entries) {
        await _db
            .into(_db.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(key: key, value: value),
            );
      }
    });
  }

  Future<void> clear() =>
      (_db.delete(_db.settings)..where((s) => s.key.isIn(_keys))).go();
}
