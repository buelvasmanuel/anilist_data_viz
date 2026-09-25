// Barras y columnas: #2, #3, #14, #15, #16, #17, #18, #21, #22, #25, #28, #30.

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import '../data/graphic_view_models.dart';
import 'graphic_chart_helpers.dart';

/// Variables para top-N de títulos: 'title' y la métrica elegida.
Map<String, Variable<GAnime, dynamic>> _titleVars(
  String metric,
  num Function(GAnime) value, {
  LinearScale? scale,
}) =>
    {
      'title': Variable<GAnime, String>(accessor: (a) => a.title),
      metric: Variable<GAnime, num>(accessor: value, scale: scale ?? LinearScale(min: 0)),
    };

/// #2 Columna Vertical — NATIVO — DIRECTO (popularity top-10).
Widget g02Column(GraphicDataset d) => guard(
      d.topByPopularity.isNotEmpty,
      () => Chart(
        data: d.topByPopularity,
        variables: _titleVars('popularity', (a) => a.popularity),
        marks: [
          IntervalMark(
            position: Varset('title') * Varset('popularity'),
            shape: ShapeEncode(
              value: RectShape(borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            ),
          ),
        ],
        axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
        selections: tapSelection(),
        tooltip: TooltipGuide(),
      ),
    );

/// #3 Barra Horizontal — NATIVO — DIRECTO (score top-10).
Widget g03HorizontalBar(GraphicDataset d) => guard(
      d.topByScore.isNotEmpty,
      () => Chart(
        data: d.topByScore,
        variables: _titleVars('score', (a) => a.score ?? 0, scale: LinearScale(min: 0, max: 100)),
        marks: [IntervalMark(position: Varset('title') * Varset('score'))],
        coord: RectCoord(transposed: true),
        axes: [Defaults.verticalAxis, Defaults.horizontalAxis],
      ),
    );

/// #14 Pyramid — NATIVO — DERIVADO (conteo por formato, ordenado).
Widget g14Pyramid(GraphicDataset d) => guard(
      d.countByFormat.length >= 2,
      () => Chart(
        data: d.countByFormat, // ya viene ordenado de mayor a menor
        variables: categoryVars(),
        marks: [
          IntervalMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: FunnelShape(pyramid: true)),
            color: ColorEncode(variable: 'x', values: graphicPalette),
            label: LabelEncode(encoder: (t) => Label('${t['x']} (${t['y']})')),
            modifiers: [SymmetricModifier()],
          ),
        ],
        coord: RectCoord(transposed: true, verticalRange: [1, 0]),
      ),
    );

/// #15 Funnel — NATIVO — DERIVADO (conteo por estado, ordenado).
Widget g15Funnel(GraphicDataset d) => guard(
      d.countByStatus.length >= 2,
      () => Chart(
        data: d.countByStatus,
        variables: categoryVars(),
        marks: [
          IntervalMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: FunnelShape()),
            color: ColorEncode(variable: 'x', values: graphicPalette),
            label: LabelEncode(encoder: (t) => Label('${t['x']} (${t['y']})')),
            modifiers: [SymmetricModifier()],
          ),
        ],
        coord: RectCoord(transposed: true, verticalRange: [1, 0]),
      ),
    );

/// #16 Histogram — VARIANTE — DERIVADO (bins de 10 puntos de averageScore).
/// Los bins se calculan en GraphicTransformations.histogramBins.
Widget g16Histogram(GraphicDataset d) => guard(
      d.scoreBins.any((b) => b.value > 0),
      () => Chart(
        data: d.scoreBins,
        variables: categoryVars(),
        marks: [
          IntervalMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: RectShape(histogram: true)),
            color: ColorEncode(value: Defaults.primaryColor.withAlpha(200)),
          ),
        ],
        axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
      ),
    );

/// #17 Stacked Column — NATIVO — DERIVADO (año × formato).
Widget g17StackedColumn(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          marks: [
            IntervalMark(
              position: Varset('x') * Varset('value') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          axes: standardAxes,
          selections: {'tap': PointSelection(variable: 'x')},
          tooltip: TooltipGuide(multiTuples: true, variables: ['series', 'value']),
        ),
        d.formats,
      ),
    );

/// #18 Stacked Bar — NATIVO — DERIVADO (género × estado).
Widget g18StackedBar(GraphicDataset d) => guard(
      d.genreStatusSeries.isNotEmpty,
      () => withLegend(
        Chart(
          data: d.genreStatusSeries,
          variables: seriesVars(),
          marks: [
            IntervalMark(
              position: Varset('x') * Varset('value') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          coord: RectCoord(transposed: true),
          axes: [Defaults.verticalAxis, Defaults.horizontalAxis],
        ),
        seriesNames(d.genreStatusSeries),
      ),
    );

/// #21 100% Stacked Column — NATIVO — DERIVADO.
/// `Proportion` es un transform propio de Graphic (cuenta como NATIVO).
Widget g21Stacked100Column(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          transforms: [Proportion(variable: 'value', nest: Varset('x'), as: 'percent')],
          marks: [
            IntervalMark(
              position: Varset('x') * Varset('percent') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          axes: standardAxes,
        ),
        d.formats,
      ),
    );

/// #22 100% Stacked Bar — NATIVO — DERIVADO.
Widget g22Stacked100Bar(GraphicDataset d) => guard(
      d.genreStatusSeries.isNotEmpty,
      () => withLegend(
        Chart(
          data: d.genreStatusSeries,
          variables: seriesVars(),
          transforms: [Proportion(variable: 'value', nest: Varset('x'), as: 'percent')],
          marks: [
            IntervalMark(
              position: Varset('x') * Varset('percent') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          coord: RectCoord(transposed: true),
          axes: [Defaults.verticalAxis, Defaults.horizontalAxis],
        ),
        seriesNames(d.genreStatusSeries),
      ),
    );

/// #25 Range Column — NATIVO — DIRECTO (año de startDate–endDate).
Widget g25RangeColumn(GraphicDataset d) => guard(
      d.airingRanges.isNotEmpty,
      () => Chart(
        data: d.airingRanges,
        variables: rangeVars(d.airingRanges),
        marks: [
          IntervalMark(
            position: Varset('x') * (Varset('low') + Varset('high')),
            shape: ShapeEncode(value: RectShape(borderRadius: BorderRadius.circular(3))),
          ),
        ],
        coord: RectCoord(transposed: true),
        axes: [Defaults.verticalAxis, Defaults.horizontalAxis],
      ),
    );

/// #28 Waterfall — VARIANTE — DERIVADO (variación de títulos año a año).
/// Los acumulados se calculan en GraphicTransformations.waterfall.
Widget g28Waterfall(GraphicDataset d) {
  final steps = d.waterfallSteps;
  return guard(steps.length >= 3, () {
    final s = sharedScale([for (final p in steps) ...[p.from, p.to]]);
    return Chart<GWaterfallStep>(
      data: steps,
      variables: {
        'label': Variable<GWaterfallStep, String>(accessor: (p) => p.label),
        'from': Variable<GWaterfallStep, num>(accessor: (p) => p.from, scale: s),
        'to': Variable<GWaterfallStep, num>(accessor: (p) => p.to, scale: s),
        'total': Variable<GWaterfallStep, String>(accessor: (p) => p.isTotal ? 'si' : 'no'),
      },
      marks: [
        IntervalMark(
          position: Varset('label') * (Varset('from') + Varset('to')),
          color: ColorEncode(
            encoder: (t) => t['total'] == 'si'
                ? Colors.blueGrey
                : ((t['to'] as num) >= (t['from'] as num) ? Colors.green : Colors.red),
          ),
        ),
      ],
      axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
    );
  });
}

/// #30 Diverging Bar — VARIANTE — DERIVADO (score medio del género − media global).
Widget g30DivergingBar(GraphicDataset d) {
  final data = d.genreDeviation;
  return guard(data.isNotEmpty, () {
    final maxAbs = data.map((c) => c.value.abs()).reduce((a, b) => a > b ? a : b);
    final bound = maxAbs == 0 ? 1 : maxAbs.ceil();
    return Chart(
      data: data,
      variables: categoryVars(yScale: LinearScale(min: -bound, max: bound)),
      marks: [
        IntervalMark(
          position: Varset('x') * Varset('y'),
          color: ColorEncode(encoder: (t) => (t['y'] as num) >= 0 ? Colors.green : Colors.red),
        ),
      ],
      coord: RectCoord(transposed: true),
      annotations: [LineAnnotation(dim: Dim.y, value: 0)],
      axes: [Defaults.verticalAxis, Defaults.horizontalAxis],
    );
  });
}
