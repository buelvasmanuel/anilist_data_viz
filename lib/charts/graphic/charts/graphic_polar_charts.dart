// Gráficas circulares y polares: #7, #8, #9, #53, #54, #56.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import '../data/graphic_view_models.dart';
import '../shapes/graphic_custom_shapes.dart';
import 'graphic_chart_helpers.dart';

/// Pie / doughnut base: IntervalMark + Proportion + StackModifier en polar 1D.
Widget _pie(List<GCategory> data, {double innerRadius = 0, GradientEncode? gradient, ElevationEncode? elevation}) {
  return withLegend(
    Chart(
      data: data,
      variables: categoryVars(),
      transforms: [Proportion(variable: 'y', as: 'percent')],
      marks: [
        IntervalMark(
          position: Varset('percent') / Varset('x'),
          color: gradient == null ? ColorEncode(variable: 'x', values: graphicPalette) : null,
          gradient: gradient,
          elevation: elevation,
          label: LabelEncode(
            encoder: (t) => Label(
              '${((t['percent'] as num) * 100).toStringAsFixed(0)}%',
              LabelStyle(textStyle: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
          modifiers: [StackModifier()],
        ),
      ],
      coord: PolarCoord(transposed: true, dimCount: 1, startRadius: innerRadius),
    ),
    [for (final c in data) c.label],
  );
}

/// #7 Pie — NATIVO — DERIVADO (conteo por formato).
Widget g07Pie(GraphicDataset d) =>
    guard(d.countByFormat.length >= 2, () => _pie(d.countByFormat));

/// #8 Doughnut — NATIVO — DERIVADO (conteo por estado).
Widget g08Doughnut(GraphicDataset d) =>
    guard(d.countByStatus.length >= 2, () => _pie(d.countByStatus, innerRadius: 0.5));

/// #9 Radial Bar — NATIVO — DIRECTO (score de top-5 títulos).
Widget g09RadialBar(GraphicDataset d) => guard(
      d.topByScore.isNotEmpty,
      () => Chart<GAnime>(
        data: d.topByScore.take(5).toList(),
        variables: {
          'title': Variable<GAnime, String>(accessor: (a) => a.title),
          'score': Variable<GAnime, num>(
            accessor: (a) => a.score ?? 0,
            scale: LinearScale(min: 0, max: 100),
          ),
        },
        marks: [
          IntervalMark(
            position: Varset('title') * Varset('score'),
            color: ColorEncode(variable: 'title', values: graphicPalette),
            shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(6)))),
          ),
        ],
        coord: PolarCoord(transposed: true, startRadius: 0.2),
        selections: tapSelection(),
        tooltip: TooltipGuide(),
      ),
    );

/// #53 Shaded Doughnut — VARIANTE — DERIVADO.
/// Gradiente de barrido por categoría + sombra de elevación.
Widget g53ShadedDoughnut(GraphicDataset d) => guard(
      d.countByFormat.length >= 2,
      () => _pie(
        d.countByFormat,
        innerRadius: 0.5,
        gradient: GradientEncode(
          variable: 'x',
          values: [
            for (final c in graphicPalette)
              SweepGradient(colors: [c.withAlpha(110), c]),
          ],
        ),
        elevation: ElevationEncode(value: 4),
      ),
    );

/// #54 Semi-Doughnut Progress — VARIANTE — DIRECTO (averageScore del #1 por popularidad).
///
/// Patrón del ejemplo oficial "Gauge / Progress Indicator": dos tuplas sobre
/// el mismo anillo (pista al 100 % y valor), con arco de π a 2π.
Widget g54SemiDoughnutProgress(GraphicDataset d) {
  final top = d.topByPopularity.where((a) => a.score != null).toList();
  return guard(top.isNotEmpty, () {
    final anime = top.first;
    return Stack(
      children: [
        Chart(
          data: [const GCategory('track', 100), GCategory('value', anime.score!)],
          variables: categoryVars(yScale: LinearScale(min: 0, max: 100)),
          marks: [
            IntervalMark(
              position: Varset('x') * Varset('y'),
              color: ColorEncode(variable: 'x', values: [Colors.grey.shade300, Colors.indigo]),
              shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(8)))),
            ),
          ],
          coord: PolarCoord(
            transposed: true,
            startAngle: math.pi,
            endAngle: 2 * math.pi,
            startRadius: 0.8,
            endRadius: 0.8,
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${anime.score}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(anime.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
          ]),
        ),
      ],
    );
  });
}

/// #56 Exploding Radial Bar — COMPOSICIÓN — DIRECTO.
///
/// Graphic no tiene `explode`. Se compone con:
/// - PointSelection (Graphic) → updater de elevación en el tuple seleccionado;
/// - ExplodedRectShape (Shape propio) → desplaza hacia fuera los sectores con
///   elevación > 0.
Widget g56ExplodingRadialBar(GraphicDataset d) => guard(
      d.topByScore.isNotEmpty,
      () => Chart<GAnime>(
        data: d.topByScore.take(5).toList(),
        variables: {
          'title': Variable<GAnime, String>(accessor: (a) => a.title),
          'score': Variable<GAnime, num>(
            accessor: (a) => a.score ?? 0,
            scale: LinearScale(min: 0, max: 100),
          ),
        },
        selections: {'tap': PointSelection(on: {GestureType.tap})},
        marks: [
          IntervalMark(
            position: Varset('title') * Varset('score'),
            shape: ShapeEncode(value: ExplodedRectShape(explodeOffset: 12)),
            color: ColorEncode(
              variable: 'title',
              values: graphicPalette,
              updaters: {
                'tap': {false: (c) => c.withAlpha(90)},
              },
            ),
            elevation: ElevationEncode(
              value: 0,
              updaters: {
                'tap': {true: (_) => 6},
              },
            ),
          ),
        ],
        coord: PolarCoord(transposed: true, startRadius: 0.2),
      ),
    );
