import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

/// Temps de repos global (ST-01), mis à jour en direct.
final defaultRestSecondsProvider = StreamProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).watchDefaultRestSeconds(),
);

/// Réglages de l'app, rangés en clé → valeur dans la table settings.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _defaultRestKey = 'default_rest_seconds';

  /// Temps de repos global tant qu'il n'a pas été réglé (RG-09) : 2:00.
  static const fallbackRestSeconds = 120;

  Stream<int> watchDefaultRestSeconds() =>
      _watch(_defaultRestKey)
          .map((value) => int.tryParse(value ?? '') ?? fallbackRestSeconds);

  Future<void> setDefaultRestSeconds(int seconds) =>
      _set(_defaultRestKey, '$seconds');

  Stream<String?> _watch(String key) =>
      (_db.select(_db.settings)..where((s) => s.key.equals(key)))
          .map((row) => row.value)
          .watchSingleOrNull();

  Future<void> _set(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}
