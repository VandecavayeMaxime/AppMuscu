import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/template_repository.dart';

/// Les modèles de l'onglet Séance, mis à jour en direct (TP-02).
final templateListProvider = StreamProvider.autoDispose<List<TemplateDetails>>(
  (ref) => ref.watch(templateRepositoryProvider).watchTemplates(),
);

/// Un modèle, ou `null` s'il a été supprimé.
final templateProvider = StreamProvider.autoDispose
    .family<TemplateDetails?, String>(
      (ref, templateId) =>
          ref.watch(templateRepositoryProvider).watchTemplate(templateId),
    );
