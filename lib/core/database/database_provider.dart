import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// La base de données, unique pour toute l'app. Les tests la remplacent par
/// une base en mémoire (`appDatabaseProvider.overrideWithValue(...)`).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
