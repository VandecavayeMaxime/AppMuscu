import 'package:drift/drift.dart' show Selectable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/app_theme.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

/// Temps de repos global (ST-01), mis à jour en direct.
final defaultRestSecondsProvider = StreamProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).watchDefaultRestSeconds(),
);

/// Son et vibration de fin de repos (ST-02).
final restSoundProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchRestSound(),
);
final restVibrationProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchRestVibration(),
);

/// Garder l'écran allumé pendant une séance (ST-04).
final keepScreenOnProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchKeepScreenOn(),
);

/// Thème choisi (ST-03).
final appThemeProvider = StreamProvider<AppTheme>(
  (ref) => ref.watch(settingsRepositoryProvider).watchTheme(),
);

/// Réglages de l'app, rangés en clé → valeur dans la table settings. Une
/// clé absente = valeur par défaut.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _defaultRestKey = 'default_rest_seconds';
  static const _restSoundKey = 'rest_sound';
  static const _restVibrationKey = 'rest_vibration';
  static const _keepScreenOnKey = 'keep_screen_on';
  static const _themeKey = 'theme';

  /// Temps de repos global tant qu'il n'a pas été réglé (RG-09) : 2:00.
  static const fallbackRestSeconds = 120;

  // ─── Temps de repos par défaut (ST-01) ─────────────────────────────────────

  Stream<int> watchDefaultRestSeconds() =>
      _watch(_defaultRestKey)
          .map((value) => int.tryParse(value ?? '') ?? fallbackRestSeconds);

  Future<void> setDefaultRestSeconds(int seconds) =>
      _set(_defaultRestKey, '$seconds');

  // ─── Fin du repos : son et vibration (ST-02) ───────────────────────────────

  Stream<bool> watchRestSound() => _watchBool(_restSoundKey, orElse: true);
  Future<void> setRestSound(bool on) => _setBool(_restSoundKey, on);

  Stream<bool> watchRestVibration() =>
      _watchBool(_restVibrationKey, orElse: true);
  Future<void> setRestVibration(bool on) => _setBool(_restVibrationKey, on);

  /// Son et vibration en une lecture, au moment de programmer la
  /// notification de fin de repos.
  Future<({bool sound, bool vibration})> readRestAlert() async => (
    sound: await _readBool(_restSoundKey, orElse: true),
    vibration: await _readBool(_restVibrationKey, orElse: true),
  );

  // ─── Écran allumé pendant une séance (ST-04) ───────────────────────────────

  Stream<bool> watchKeepScreenOn() =>
      _watchBool(_keepScreenOnKey, orElse: false);
  Future<void> setKeepScreenOn(bool on) => _setBool(_keepScreenOnKey, on);

  // ─── Thème (ST-03) ─────────────────────────────────────────────────────────

  Stream<AppTheme> watchTheme() => _watch(_themeKey)
      .map((value) => AppTheme.values.asNameMap()[value] ?? AppTheme.system);

  Future<void> setTheme(AppTheme theme) => _set(_themeKey, theme.name);

  // ─── Lecture et écriture d'une clé ─────────────────────────────────────────

  Selectable<String> _query(String key) => (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).map((row) => row.value);

  Stream<String?> _watch(String key) => _query(key).watchSingleOrNull();

  Future<void> _set(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Stream<bool> _watchBool(String key, {required bool orElse}) =>
      _watch(key).map((value) => value == null ? orElse : value == '1');

  Future<bool> _readBool(String key, {required bool orElse}) async {
    final value = await _query(key).getSingleOrNull();
    return value == null ? orElse : value == '1';
  }

  Future<void> _setBool(String key, bool on) => _set(key, on ? '1' : '0');
}
