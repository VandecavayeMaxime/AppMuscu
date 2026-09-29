import 'package:material_ui/material_ui.dart';

import '../../../core/utils/weight_format.dart';
import '../../exercises/domain/exercise_enums.dart';
import '../../stats/presentation/body_silhouette.dart';
import '../domain/body_measurement_field.dart';
import '../domain/body_measurement_stats.dart';

/// Position (fraction de la hauteur du corps, 0 en haut) et côté de
/// l'étiquette de chaque tour, tirés des tracés de la carte des muscles
/// (SA-04) plutôt que devinés à la main : la hauteur d'un muscle sur la
/// silhouette est déjà connue de `body_silhouette.dart`.
Map<BodyMeasurementField, (double heightFraction, bool onLeft)>
_circumferenceAnchors() {
  Rect? bounds(BodyPart part) => boundsOf(BodyView.front, part);
  double centerOf(BodyPart part) => bounds(part)!.center.dy / bodyHeight;

  final chest = bounds(BodyPart.chest)!;
  final trapezius = bounds(BodyPart.trapeziusUpper)!;
  final abs = bounds(BodyPart.abs)!;
  final quads = bounds(BodyPart.quads)!;

  // Entre le bas des abdos et le haut des quadriceps : pas de tracé
  // « hanches » à part en vue de face (les fessiers sont au dos, RG-17).
  final hipsFraction = (abs.bottom + quads.top) / 2 / bodyHeight;
  final thighTopFraction = quads.top / bodyHeight;

  return {
    // Un peu au-dessus des trapèzes/de la poitrine : pas de tracé « cou ».
    BodyMeasurementField.neck: (
      (trapezius.top.clamp(0, chest.top) - 30) / bodyHeight,
      true,
    ),
    BodyMeasurementField.chest: (centerOf(BodyPart.chest), true),
    BodyMeasurementField.arm: (centerOf(BodyPart.biceps), false),
    BodyMeasurementField.forearm: (centerOf(BodyPart.forearms), false),
    BodyMeasurementField.waist: (centerOf(BodyPart.abs), true),
    BodyMeasurementField.hips: (hipsFraction, true),
    // Un peu plus bas que les hanches, sans tracé dédié non plus (au dos).
    BodyMeasurementField.glutes: ((hipsFraction + thighTopFraction) / 2, false),
    BodyMeasurementField.thigh: (centerOf(BodyPart.quads), true),
    BodyMeasurementField.calf: (centerOf(BodyPart.calves), false),
  };
}

/// Les tours qui ont un tracé musculaire dédié (donc une zone tactile
/// directement sur le dessin) : cou, hanches et fesses n'en ont pas (voir
/// `_circumferenceAnchors`), seule leur étiquette reste tactile pour eux.
const _bodyPartOf = {
  BodyMeasurementField.chest: BodyPart.chest,
  BodyMeasurementField.arm: BodyPart.biceps,
  BodyMeasurementField.forearm: BodyPart.forearms,
  BodyMeasurementField.waist: BodyPart.abs,
  BodyMeasurementField.thigh: BodyPart.quads,
  BodyMeasurementField.calf: BodyPart.calves,
};

/// Une silhouette neutre (aucun muscle coloré), annotée des 9 tours, chacun à
/// hauteur de sa partie du corps (SA-07). Remplace la silhouette d'origine,
/// jugée moins lisible qu'une liste simple pour les autres mesures (D26) —
/// seuls les tours en profitent, avec la silhouette déjà dessinée pour la
/// carte des muscles. Toucher directement le dessin marche aussi pour les
/// tours qui ont un tracé musculaire (D31). Les 9 étiquettes sont toujours là,
/// même sans valeur encore saisie (D33) : sinon la silhouette semblerait
/// incomplète plutôt que de montrer ce qui reste à ajouter.
class AnnotatedBodySilhouette extends StatelessWidget {
  const AnnotatedBodySilhouette({
    super.key,
    required this.values,
    required this.deltas,
    required this.selected,
    required this.onTap,
  });

  /// Dernière valeur de chaque tour déjà saisi ; absent = pas encore saisi.
  final Map<BodyMeasurementField, double> values;
  final Map<BodyMeasurementField, MeasurementDelta?> deltas;

  /// Le tour actuellement affiché dans le graphique, s'il y en a un (D31).
  final BodyMeasurementField? selected;

  /// Toucher une étiquette ou une zone du dessin avec une valeur sélectionne
  /// ce tour (D31) ; les tours sans valeur ne font rien, faute d'historique à
  /// afficher.
  final ValueChanged<BodyMeasurementField> onTap;

  @override
  Widget build(BuildContext context) {
    final anchors = _circumferenceAnchors();
    final left = <MapEntry<BodyMeasurementField, double>>[];
    final right = <MapEntry<BodyMeasurementField, double>>[];
    for (final field in BodyMeasurementField.circumferences) {
      final (heightFraction, onLeft) = anchors[field]!;
      (onLeft ? left : right).add(MapEntry(field, heightFraction));
    }

    // Assez large pour « Avant-bras » seul (sans valeur encore saisie, D33),
    // le plus long des 9 noms de tour.
    const sideWidth = 132.0;
    // Hauteur de la ligne principale (nom + valeur + trait) : fixe, pour que
    // son centre tombe pile sur la hauteur anatomique calculée, l'écart (une
    // ligne de plus, facultative) ne faisant que s'ajouter en dessous sans
    // décaler cet alignement.
    const lineHeight = 18.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // La silhouette garde son rapport largeur/hauteur (bodyWidth /
        // bodyHeight) : sa hauteur réelle dépend de la largeur qui lui
        // reste une fois les 2 colonnes d'étiquettes retirées. Calculée ici
        // plutôt qu'avec un `AspectRatio` autour de toute la ligne (essayé
        // puis abandonné : imbriqué avec celui de `BodySilhouette`, il ne
        // donnait plus la vraie hauteur du dessin, et les étiquettes ne
        // tombaient plus en face de leur muscle).
        final silhouetteWidth = (constraints.maxWidth - sideWidth * 2).clamp(
          0.0,
          double.infinity,
        );
        final height = silhouetteWidth * bodyHeight / bodyWidth;

        Widget side(List<MapEntry<BodyMeasurementField, double>> entries) =>
            SizedBox(
              width: sideWidth,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final MapEntry(key: field, value: fraction) in entries)
                    Positioned(
                      top: fraction * height - lineHeight / 2,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: values.containsKey(field)
                            ? () => onTap(field)
                            : null,
                        child: _CircumferenceLabel(
                          field: field,
                          value: values[field],
                          delta: deltas[field],
                          leaderOnRight: entries == left,
                          lineHeight: lineHeight,
                          selected: field == selected,
                        ),
                      ),
                    ),
                ],
              ),
            );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            side(left),
            SizedBox(
              width: silhouetteWidth,
              height: height,
              child: BodySilhouette(
                view: BodyView.front,
                load: const {},
                highlighted: _bodyPartOf[selected],
                onTap: (part) {
                  for (final MapEntry(key: field, value: bodyPart)
                      in _bodyPartOf.entries) {
                    if (bodyPart == part && values.containsKey(field)) {
                      onTap(field);
                      return;
                    }
                  }
                },
              ),
            ),
            side(right),
          ],
        );
      },
    );
  }
}

/// Nom, valeur et trait de rappel sur une seule ligne de hauteur fixe
/// ([lineHeight]), centrée sur la hauteur anatomique calculée ; l'écart
/// (RG-21), facultatif, s'ajoute juste en dessous sans décaler cet
/// alignement.
class _CircumferenceLabel extends StatelessWidget {
  const _CircumferenceLabel({
    required this.field,
    required this.value,
    required this.delta,
    required this.leaderOnRight,
    required this.lineHeight,
    required this.selected,
  });

  final BodyMeasurementField field;

  /// `null` si ce tour n'a encore aucune valeur saisie (D33).
  final double? value;
  final MeasurementDelta? delta;
  final bool leaderOnRight;
  final double lineHeight;

  /// `true` si c'est le tour actuellement affiché dans le graphique (D31).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    final label = Text(
      value == null ? field.label : '${field.label} ${formatNumber(value)}',
      style: theme.textTheme.labelMedium?.copyWith(
        color: value == null
            ? theme.colorScheme.onSurfaceVariant
            : selected
            ? theme.colorScheme.primary
            : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
      textAlign: leaderOnRight ? TextAlign.right : TextAlign.left,
    );
    final leader = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ),
    );
    final delta = this.delta;

    return Column(
      crossAxisAlignment: leaderOnRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: lineHeight,
          child: Row(
            children: leaderOnRight ? [label, leader] : [leader, label],
          ),
        ),
        if (delta != null)
          Text(
            switch (delta.trend) {
              MeasurementTrend.up => '▲ ${formatNumber(delta.value.abs())}',
              MeasurementTrend.down => '▼ ${formatNumber(delta.value.abs())}',
              MeasurementTrend.equal => '=',
            },
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
