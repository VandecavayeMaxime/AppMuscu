import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/body_repository.dart';

/// Toutes les mesures, de la plus ancienne à la plus récente (SA-07, SA-08).
final bodyMeasurementsProvider =
    StreamProvider.autoDispose<List<BodyMeasurement>>(
      (ref) => ref.watch(bodyRepositoryProvider).watchAll(),
    );
