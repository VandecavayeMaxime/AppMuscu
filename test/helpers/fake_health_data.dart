import 'package:app_muscu/core/platform/health_data.dart';
import 'package:app_muscu/features/activity/domain/activity_summary.dart';

/// Fausses données de santé : n'appelle aucun paquet natif, note seulement
/// les appels et renvoie ce que le test a préparé.
class FakeHealthData implements HealthData {
  /// `null` = jamais demandée (état de départ). Change quand le test
  /// touche `requestPermission` ou pose directement cette valeur.
  bool? permission;

  int permissionRequests = 0;

  /// Historique renvoyé par [history], quelle que soit la période demandée.
  List<ActivitySummary> summaries = [];

  @override
  Future<bool?> hasPermission() async => permission;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    permission = true;
    return true;
  }

  @override
  Future<List<ActivitySummary>> history(DateTime start, DateTime end) async =>
      summaries;
}
