import 'package:app_muscu/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Base SQLite neuve, en mémoire : chaque test part de zéro, avec les
/// 10 exercices de base.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Identifiants fixes de deux exercices de base (voir built_in_exercises.dart).
const benchPressId = '509d3ccf-bf4e-411b-a5db-2d2e491f586c';
const squatId = 'c152f391-b038-44f6-b8df-cfef1d1a789d';
