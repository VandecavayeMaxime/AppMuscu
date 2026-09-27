import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/stats_repository.dart';
import '../domain/weekly_sessions.dart';

/// Séances terminées, de la plus ancienne à la plus récente (SA-02).
final finishedSessionsProvider = StreamProvider.autoDispose<List<SessionEntry>>(
  (ref) => ref.watch(statsRepositoryProvider).watchFinishedSessions(),
);

/// Modèles dans l'ordre de leurs couleurs (RG-16).
final templatesByColorProvider = StreamProvider.autoDispose<List<Template>>(
  (ref) => ref.watch(statsRepositoryProvider).watchTemplatesByColor(),
);

/// Séries validées de tout l'historique, pour la carte des muscles (SA-04).
final muscleUsageProvider = StreamProvider.autoDispose<List<MuscleUsage>>(
  (ref) => ref.watch(statsRepositoryProvider).watchMuscleUsage(),
);
