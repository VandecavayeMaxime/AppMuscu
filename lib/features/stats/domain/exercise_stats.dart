// Statistiques d'un exercice (EX-12 à EX-15), calculées à partir de son
// historique : la liste des séances de l'onglet « Historique » (EX-10).

import 'dart:math';

import '../../../core/database/app_database.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../../workout/domain/best_set.dart';
import '../../workout/domain/set_type.dart';
import '../../workout/domain/workout_details.dart';
import 'chart_point.dart';

/// Écart en dessous duquel deux valeurs sont égales (arrondis des décimales).
const _tolerance = 1e-9;

/// Séries qui comptent : validées (l'historique ne contient qu'elles) et pas
/// d'échauffement (types de série retirés, D12, mais d'anciennes séries
/// peuvent en être).
Iterable<WorkoutSet> _counted(List<WorkoutSet> sets) =>
    sets.where((set) => set.setType != SetType.warmup);

double _kg(WorkoutSet set) => set.weightKg ?? 0;
int _reps(WorkoutSet set) => set.reps ?? 0;
int _seconds(WorkoutSet set) => set.durationSeconds ?? 0;

/// Séances de la plus ancienne à la plus récente (l'historique est dans
/// l'ordre inverse).
Iterable<ExerciseSession> _chronological(List<ExerciseSession> sessions) =>
    sessions.reversed;

// ─── Courbe d'évolution (EX-12) ──────────────────────────────────────────────

/// Valeur suivie par la courbe, selon le type de suivi.
enum ExerciseMetric {
  oneRepMax('1RM estimé'),
  maxWeight('Poids max'),
  volume('Volume'),
  maxReps('Reps max'),
  totalReps('Reps totales'),
  maxDuration('Durée max'),
  totalDuration('Durée totale');

  const ExerciseMetric(this.label);

  final String label;

  /// Valeurs proposées pour un type de suivi, la première par défaut.
  static List<ExerciseMetric> of(TrackingType trackingType) =>
      switch (trackingType) {
        TrackingType.weightReps => const [
          oneRepMax,
          maxWeight,
          volume,
          maxReps,
          totalReps,
        ],
        TrackingType.reps => const [maxReps, totalReps],
        TrackingType.duration => const [maxDuration, totalDuration],
      };

  /// Valeur de la séance : kg (poids et volume), reps ou secondes.
  double valueOf(List<WorkoutSet> sets) {
    final counted = _counted(sets);
    double best(double Function(WorkoutSet) value) =>
        counted.map(value).fold(0, max);
    double sum(double Function(WorkoutSet) value) =>
        counted.map(value).fold(0, (a, b) => a + b);

    return switch (this) {
      oneRepMax => best((s) => estimatedOneRepMax(_kg(s), _reps(s))),
      maxWeight => best((s) => _reps(s) > 0 ? _kg(s) : 0),
      volume => sum((s) => _kg(s) * _reps(s)),
      maxReps => best((s) => _reps(s).toDouble()),
      totalReps => sum((s) => _reps(s).toDouble()),
      maxDuration => best((s) => _seconds(s).toDouble()),
      totalDuration => sum((s) => _seconds(s).toDouble()),
    };
  }
}

/// Un point par séance, dans l'ordre chronologique (EX-12). Les séances où
/// la valeur est nulle (que des séries à 0) sont ignorées.
List<ChartPoint> metricHistory(
  List<ExerciseSession> sessions,
  ExerciseMetric metric,
) => [
  for (final session in _chronological(sessions))
    if (metric.valueOf(session.sets) case final value when value > 0)
      ChartPoint(session.date, value),
];

// ─── Records (EX-13) ─────────────────────────────────────────────────────────

enum RecordKind {
  oneRepMax('1RM estimé'),
  maxWeight('Poids max'),
  bestSetVolume('Meilleure série'),
  sessionVolume('Meilleur volume'),
  maxReps('Reps max en une série'),
  sessionReps('Reps max en une séance'),
  maxDuration("Durée max d'une série"),
  sessionDuration('Durée max en une séance');

  const RecordKind(this.label);

  final String label;
}

/// Un record : sa valeur (kg, reps ou secondes), sa date et, s'il vient
/// d'une seule série, cette série.
class ExerciseRecord {
  const ExerciseRecord(this.kind, this.value, this.date, [this.set]);

  final RecordKind kind;
  final double value;
  final DateTime date;
  final WorkoutSet? set;
}

/// Les records de tout l'historique, selon le type de suivi (EX-13). En cas
/// d'égalité, la première fois compte.
List<ExerciseRecord> exerciseRecords(
  List<ExerciseSession> sessions,
  TrackingType trackingType,
) {
  final records = <RecordKind, ExerciseRecord>{};
  void consider(
    RecordKind kind,
    double value,
    DateTime date, [
    WorkoutSet? set,
  ]) {
    final current = records[kind];
    if (value > (current?.value ?? 0) + _tolerance) {
      records[kind] = ExerciseRecord(kind, value, date, set);
    }
  }

  for (final session in _chronological(sessions)) {
    final date = session.date;
    for (final set in _counted(session.sets)) {
      switch (trackingType) {
        case TrackingType.weightReps:
          consider(
            RecordKind.oneRepMax,
            estimatedOneRepMax(_kg(set), _reps(set)),
            date,
            set,
          );
          if (_reps(set) > 0) {
            consider(RecordKind.maxWeight, _kg(set), date, set);
          }
          consider(RecordKind.bestSetVolume, _kg(set) * _reps(set), date, set);
        case TrackingType.reps:
          consider(RecordKind.maxReps, _reps(set).toDouble(), date, set);
        case TrackingType.duration:
          consider(RecordKind.maxDuration, _seconds(set).toDouble(), date, set);
      }
    }
    switch (trackingType) {
      case TrackingType.weightReps:
        consider(
          RecordKind.sessionVolume,
          ExerciseMetric.volume.valueOf(session.sets),
          date,
        );
      case TrackingType.reps:
        consider(
          RecordKind.sessionReps,
          ExerciseMetric.totalReps.valueOf(session.sets),
          date,
        );
      case TrackingType.duration:
        consider(
          RecordKind.sessionDuration,
          ExerciseMetric.totalDuration.valueOf(session.sets),
          date,
        );
    }
  }
  // Dans l'ordre de l'énumération, c'est-à-dire l'ordre d'affichage. Le `?`
  // devant un élément l'omet s'il est null (pas de record de ce type).
  return [for (final kind in RecordKind.values) ?records[kind]];
}

// ─── Records par nombre de reps (EX-14) ──────────────────────────────────────

/// Le meilleur poids soulevé en exactement [reps] reps, et sa date.
class RepRecord {
  const RepRecord(this.reps, this.weightKg, this.date);

  final int reps;
  final double weightKg;
  final DateTime date;
}

/// Records par nombre de reps (RG-18), du plus petit nombre de reps au plus
/// grand. Une ligne n'est gardée que si son poids dépasse celui de toutes
/// les lignes à plus de reps : 100 kg × 5 rend inutile « 95 kg × 3 ».
List<RepRecord> repRecords(List<ExerciseSession> sessions) {
  final best = <int, RepRecord>{};
  for (final session in _chronological(sessions)) {
    for (final set in _counted(session.sets)) {
      final (kg, reps) = (_kg(set), _reps(set));
      if (kg <= 0 || reps <= 0) continue;
      if (kg > (best[reps]?.weightKg ?? 0) + _tolerance) {
        best[reps] = RepRecord(reps, kg, session.date);
      }
    }
  }

  final kept = <RepRecord>[];
  var heaviest = 0.0;
  for (final reps in best.keys.toList()..sort((a, b) => b.compareTo(a))) {
    final record = best[reps]!;
    if (record.weightKg > heaviest + _tolerance) {
      kept.add(record);
      heaviest = record.weightKg;
    }
  }
  return kept.reversed.toList();
}

// ─── Fréquence (EX-15) ───────────────────────────────────────────────────────

class ExerciseFrequency {
  const ExerciseFrequency({
    required this.sessions,
    required this.perWeek,
    required this.last,
  });

  /// Nombre de séances avec l'exercice.
  final int sessions;

  /// Moyenne par semaine depuis la première séance (RG-19).
  final double perWeek;

  /// Date de la dernière séance.
  final DateTime last;
}

/// Fréquence de l'exercice (EX-15), `null` s'il n'a jamais été fait.
ExerciseFrequency? exerciseFrequency(
  List<ExerciseSession> sessions,
  DateTime now,
) {
  if (sessions.isEmpty) return null;
  final days = now.difference(sessions.last.date).inHours / 24;
  final weeks = max(1.0, days / 7);
  return ExerciseFrequency(
    sessions: sessions.length,
    perWeek: (sessions.length / weeks * 10).round() / 10,
    last: sessions.first.date,
  );
}
