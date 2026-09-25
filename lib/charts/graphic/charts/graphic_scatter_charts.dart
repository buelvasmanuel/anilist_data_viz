// Dispersión: #10, #11, #45, #59.

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import '../data/graphic_view_models.dart';
import 'graphic_chart_helpers.dart';

Map<String, Variable<GAnime, dynamic>> _scatterVars() => {
      'title': Variable<GAnime, String>(accessor: (a) => a.title),
      'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity),
      'score': Variable<GAnime, num>(
        accessor: (a) => a.score ?? 0,
        scale: LinearScale(min: 0, max: 100),
      ),
      'episodes': Variable<GAnime, num>(accessor: (a) => a.episodes ?? 0),
      'format': Variable<GAnime, String>(accessor: (a) => a.format),
    };

List<GAnime> _scored(GraphicDataset d) => [for (final a in d.titles) if (a.score != null) a];

/// #10 Scatter — NATIVO — DIRECTO (popularity × score).
Widget g10Scatter(GraphicDataset d) {
  final data = _scored(d);
  return guard(
    data.length >= 3,
    () => Chart(
      data: data,
      variables: _scatterVars(),
      marks: [
        PointMark(
          position: Varset('popularity') * Varset('score'),
          size: SizeEncode(value: 6),
          color: ColorEncode(value: Defaults.primaryColor.withAlpha(170)),
        ),
      ],
      axes: standardAxes,
      selections: tapSelection(),
      tooltip: TooltipGuide(variables: ['title', 'popularity', 'score']),
    ),
  );
}

/// #11 Bubble — NATIVO — DIRECTO (X = popularity, Y = score, tamaño = episodes).
/// Bubble = X, Y y tamaño; no es una tercera dimensión matemática.
Widget g11Bubble(GraphicDataset d) {
  final data = [for (final a in _scored(d)) if (a.episodes != null) a];
  return guard(
    data.length >= 3,
    () => Chart(
      data: data,
      variables: _scatterVars(),
      marks: [
        PointMark(
          position: Varset('popularity') * Varset('score'),
          size: SizeEncode(variable: 'episodes', values: [5, 30]),
          color: ColorEncode(value: Defaults.primaryColor.withAlpha(120)),
        ),
      ],
      axes: standardAxes,
      selections: tapSelection(),
      tooltip: TooltipGuide(variables: ['title', 'episodes', 'score']),
    ),
  );
}

/// #45 Trendline Regression — VARIANTE — DERIVADO (mínimos cuadrados score ~ popularity).
/// La recta se calcula en GraphicTransformations.linearRegression.
Widget g45Trendline(GraphicDataset d) {
  final pts = d.regression;
  return guard(pts.length >= 3, () {
    final y = sharedScale([for (final p in pts) ...[p.y, p.fitted]]); // misma escala Y
    return Chart<GRegressionPoint>(
      data: pts,
      variables: {
        'x': Variable<GRegressionPoint, num>(accessor: (p) => p.x),
        'y': Variable<GRegressionPoint, num>(accessor: (p) => p.y, scale: y),
        'fitted': Variable<GRegressionPoint, num>(accessor: (p) => p.fitted, scale: y),
      },
      marks: [
        PointMark(position: Varset('x') * Varset('y'), size: SizeEncode(value: 5)),
        LineMark(
          position: Varset('x') * Varset('fitted'),
          color: ColorEncode(value: Colors.red),
          size: SizeEncode(value: 2),
        ),
      ],
      axes: standardAxes,
    );
  });
}

/// #59 Multi-shape Categorical Scatter — NATIVO — DIRECTO (forma según formato).
/// Graphic trae 2 formas (círculo, cuadrado) × relleno/hueco = 4 variantes.
Widget g59MultiShapeScatter(GraphicDataset d) {
  final formats = d.formats.take(4).toList();
  final data = [for (final a in _scored(d)) if (formats.contains(a.format)) a];
  return guard(
    data.length >= 3,
    () => withLegend(
      Chart(
        data: data,
        variables: {
          ..._scatterVars(),
          'format': Variable<GAnime, String>(
            accessor: (a) => a.format,
            scale: OrdinalScale(values: formats),
          ),
        },
        marks: [
          PointMark(
            position: Varset('popularity') * Varset('score'),
            shape: ShapeEncode(
              variable: 'format',
              values: [
                CircleShape(),
                SquareShape(),
                CircleShape(hollow: true, strokeWidth: 2),
                SquareShape(hollow: true, strokeWidth: 2),
              ].take(formats.length).toList(),
            ),
            color: ColorEncode(variable: 'format', values: graphicPalette),
            size: SizeEncode(value: 9),
          ),
        ],
        axes: standardAxes,
      ),
      formats,
    ),
  );
}
