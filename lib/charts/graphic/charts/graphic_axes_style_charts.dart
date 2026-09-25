// Ejes, estilos y combinaciones: #36, #37, #46, #48, #49, #50, #51, #57, #58, #62.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import '../data/graphic_view_models.dart';
import 'graphic_chart_helpers.dart';

typedef _YearRow = ({String year, num count, num score});

List<_YearRow> _yearRows(GraphicDataset d) {
  final score = {for (final c in d.scoreByYear) c.label: c.value};
  return [
    for (final c in d.countByYear)
      if (score.containsKey(c.label)) (year: c.label, count: c.value, score: score[c.label]!),
  ];
}

/// #36 Combined Column + Line — NATIVO — DERIVADO (títulos por año + score medio).
/// Un único Chart con dos marks.
Widget g36CombinedColumnLine(GraphicDataset d) {
  final rows = _yearRows(d);
  return guard(
    rows.length >= 2,
    () => withLegend(
      Chart<_YearRow>(
        data: rows,
        variables: {
          'year': Variable<_YearRow, String>(accessor: (r) => r.year),
          'count': Variable<_YearRow, num>(accessor: (r) => r.count, scale: LinearScale(min: 0)),
          'score': Variable<_YearRow, num>(accessor: (r) => r.score, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [
          IntervalMark(position: Varset('year') * Varset('count'), color: ColorEncode(value: graphicPalette[0])),
          LineMark(position: Varset('year') * Varset('score'), color: ColorEncode(value: graphicPalette[1])),
          PointMark(position: Varset('year') * Varset('score'), color: ColorEncode(value: graphicPalette[1])),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis..variable = 'count'],
      ),
      ['Títulos', 'Score medio (0-100)'],
      colors: [graphicPalette[0], graphicPalette[1]],
    ),
  );
}

/// #37 Dual Y Axis — NATIVO — DIRECTO (popularity vs score, top-10).
/// Varios AxisGuide en la misma dimensión, cada uno ligado a su variable.
/// REVISAR VISUALMENTE: eje de score a la derecha y asociado a la línea.
Widget g37DualYAxis(GraphicDataset d) {
  final data = [for (final a in d.topByPopularity) if (a.score != null) a];
  return guard(
    data.length >= 2,
    () => Chart<GAnime>(
      data: data,
      variables: {
        'title': Variable<GAnime, String>(accessor: (a) => a.title),
        'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity, scale: LinearScale(min: 0)),
        'score': Variable<GAnime, num>(accessor: (a) => a.score!, scale: LinearScale(min: 0, max: 100)),
      },
      marks: [
        IntervalMark(position: Varset('title') * Varset('popularity'), color: ColorEncode(value: graphicPalette[0])),
        LineMark(position: Varset('title') * Varset('score'), color: ColorEncode(value: Colors.orange)),
        PointMark(position: Varset('title') * Varset('score'), color: ColorEncode(value: Colors.orange)),
      ],
      axes: [
        rotatedHorizontalAxis()..dim = Dim.x,
        Defaults.verticalAxis
          ..dim = Dim.y
          ..variable = 'popularity',
        AxisGuide(
          dim: Dim.y,
          variable: 'score',
          position: 1,
          flip: true,
          label: LabelStyle(
            textStyle: const TextStyle(fontSize: 10, color: Colors.orange),
            offset: const Offset(7.5, 0),
          ),
        ),
      ],
    ),
  );
}

/// #46 Plot Bands / Strip Lines — NATIVO — DIRECTO (score de los 10 más populares).
Widget g46PlotBands(GraphicDataset d) {
  final data = [for (final a in d.topByPopularity) if (a.score != null) a];
  return guard(
    data.length >= 2,
    () => Chart<GAnime>(
      data: data,
      variables: {
        'title': Variable<GAnime, String>(accessor: (a) => a.title),
        'score': Variable<GAnime, num>(accessor: (a) => a.score!, scale: LinearScale(min: 0, max: 100)),
      },
      marks: [IntervalMark(position: Varset('title') * Varset('score'))],
      annotations: [
        RegionAnnotation(dim: Dim.y, values: [75, 100], color: const Color(0x3300C853)),
        RegionAnnotation(dim: Dim.y, values: [0, 50], color: const Color(0x22D50000)),
        if (!d.globalMeanScore.isNaN)
          LineAnnotation(
            dim: Dim.y,
            value: d.globalMeanScore,
            style: PaintStyle(strokeColor: Colors.black54, strokeWidth: 1, dash: [4, 3]),
          ),
        TagAnnotation(label: Label('Zona excelente'), values: [data.first.title, 95]),
      ],
      axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
    ),
  );
}

/// #48 Multi-colored Line — VARIANTE — DERIVADO.
/// Una línea tiene UN estilo por grupo, así que el color por umbral se hace con
/// un gradiente de cortes duros. Los límites del gradiente = región del gráfico;
/// con la escala Y fija 0-100, el corte en la media global es 1 - media/100.
Widget g48MultiColoredLine(GraphicDataset d) => guard(
      d.scoreByYear.length >= 2 && !d.globalMeanScore.isNaN,
      () {
        final s = (1 - d.globalMeanScore / 100).clamp(0.0, 1.0).toDouble();
        return Chart(
          data: d.scoreByYear,
          variables: categoryVars(yScale: LinearScale(min: 0, max: 100)),
          marks: [
            LineMark(
              position: Varset('x') * Varset('y'),
              size: SizeEncode(value: 3),
              gradient: GradientEncode(
                value: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Colors.green, Colors.green, Colors.red, Colors.red],
                  stops: [0, s, s, 1],
                ),
              ),
            ),
          ],
          annotations: [
            LineAnnotation(dim: Dim.y, value: d.globalMeanScore,
                style: PaintStyle(strokeColor: Colors.black38, dash: [3, 3])),
          ],
          axes: standardAxes,
        );
      },
    );

/// #49 Palette Gradient Series — NATIVO — DIRECTO (score de los 10 mejor puntuados).
/// GradientEncode codifica el RELLENO de las barras con un gradiente vertical
/// por umbrales; los límites del gradiente son la región del gráfico, así que
/// el color de cada barra depende de la altura que alcanza.
Widget g49PaletteGradient(GraphicDataset d) => guard(
      d.topByScore.length >= 2,
      () => Chart<GAnime>(
        data: d.topByScore,
        variables: {
          'title': Variable<GAnime, String>(accessor: (a) => a.title),
          'score': Variable<GAnime, num>(accessor: (a) => a.score!, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [
          IntervalMark(
            position: Varset('title') * Varset('score'),
            gradient: GradientEncode(
              value: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green, Colors.yellow, Colors.red],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
        axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
      ),
    );

/// #50 Break / Gapless DateTime Axis — VARIANTE — DIRECTO (startDate.year de cada título).
/// Arriba: TimeScale (distancia temporal real: los años sin estrenos dejan huecos).
/// Abajo: OrdinalScale (orden temporal sin distancias: sin huecos).
/// Graphic NO tiene ruptura visual de eje (axis break).
Widget g50GaplessAxis(GraphicDataset d) {
  final data = [for (final a in d.topByPopularity) if (a.startYear != null) a]
    ..sort((a, b) => a.startYear!.compareTo(b.startYear!));
  return guard(data.length >= 2, () {
    String label(GAnime a) => '${a.startYear} · ${a.title.length > 12 ? '${a.title.substring(0, 12)}…' : a.title}';
    return Column(children: [
      const Text('TimeScale: distancia temporal real', style: TextStyle(fontSize: 11)),
      Expanded(
        child: Chart<GAnime>(
          data: data,
          variables: {
            'date': Variable<GAnime, DateTime>(
              accessor: (a) => DateTime(a.startYear!),
              scale: TimeScale(formatter: (t) => '${t.year}'),
            ),
            'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity, scale: LinearScale(min: 0)),
          },
          marks: [PointMark(position: Varset('date') * Varset('popularity'))],
          axes: standardAxes,
        ),
      ),
      const Text('OrdinalScale: orden temporal sin huecos', style: TextStyle(fontSize: 11)),
      Expanded(
        child: Chart<GAnime>(
          data: data,
          variables: {
            'label': Variable<GAnime, String>(
              accessor: label,
              scale: OrdinalScale(values: [for (final a in data) label(a)]),
            ),
            'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity, scale: LinearScale(min: 0)),
          },
          marks: [PointMark(position: Varset('label') * Varset('popularity'))],
          axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
        ),
      ),
    ]);
  });
}

/// #51 Logarithmic Scale — VARIANTE — DIRECTO (popularity).
/// Graphic NO tiene LogScale: transformación log10 + ticks y formatter propios.
Widget g51LogScale(GraphicDataset d) {
  final data = [for (final a in d.titles) if (a.popularity > 0) a]
    ..sort((a, b) => b.popularity.compareTo(a.popularity));
  final top = data.take(20).toList();
  return guard(top.length >= 3, () {
    num log10(num v) => math.log(v) / math.ln10;
    final lo = log10(top.last.popularity).floor();
    final hi = log10(top.first.popularity).ceil();
    return Chart<GAnime>(
      data: top,
      variables: {
        'title': Variable<GAnime, String>(accessor: (a) => a.title),
        'logPop': Variable<GAnime, num>(
          accessor: (a) => log10(a.popularity),
          scale: LinearScale(
            min: lo,
            max: hi == lo ? hi + 1 : hi,
            ticks: [for (var e = lo; e <= (hi == lo ? hi + 1 : hi); e++) e],
            formatter: (v) => math.pow(10, v).toStringAsFixed(0),
          ),
        ),
      },
      marks: [PointMark(position: Varset('title') * Varset('logPop'), size: SizeEncode(value: 7))],
      axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
      selections: tapSelection(),
      tooltip: TooltipGuide(variables: ['title']),
    );
  });
}

/// #57 Sparkline Win-Loss — VARIANTE — DERIVADO (score del año vs media global).
Widget g57SparklineWinLoss(GraphicDataset d) => guard(
      d.winLossByYear.length >= 2,
      () => Center(
        child: SizedBox(
          height: 36,
          width: 200,
          child: Chart(
            data: d.winLossByYear,
            padding: (_) => EdgeInsets.zero,
            variables: categoryVars(yScale: LinearScale(min: -1, max: 1)),
            marks: [
              IntervalMark(
                position: Varset('x') * Varset('y'),
                color: ColorEncode(
                  encoder: (t) => t['y'] == 0
                      ? Colors.grey
                      : ((t['y'] as num) > 0 ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );

/// #58 Sparkline Area with Min/Max — VARIANTE — DERIVADO.
Widget g58SparklineMinMax(GraphicDataset d) {
  final data = d.countByYear;
  return guard(data.length >= 2, () {
    final values = data.map((c) => c.value);
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    return Center(
      child: SizedBox(
        height: 56,
        width: 200,
        child: Chart(
          data: data,
          padding: (_) => const EdgeInsets.all(6),
          variables: categoryVars(),
          marks: [
            AreaMark(
              position: Varset('x') * Varset('y'),
              color: ColorEncode(value: Colors.blue.withAlpha(60)),
            ),
            PointMark(
              position: Varset('x') * Varset('y'),
              size: SizeEncode(
                encoder: (t) => (t['y'] == maxV || t['y'] == minV) ? 6.0 : 0.0,
              ),
              color: ColorEncode(encoder: (t) => t['y'] == maxV ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  });
}

/// #62 Inverted / Opposed Axis — VARIANTE — DIRECTO (rankings.rank).
/// Invertido: verticalRange [1, 0] (rank 1 arriba). Opuesto: eje X arriba.
/// REVISAR VISUALMENTE el lado del eje opuesto con el rango invertido.
Widget g62InvertedOpposedAxis(GraphicDataset d) => guard(
      d.rankedTitles.length >= 2,
      () => Chart<GAnime>(
        data: d.rankedTitles,
        variables: {
          'title': Variable<GAnime, String>(accessor: (a) => a.title),
          'rank': Variable<GAnime, num>(accessor: (a) => a.rank!, scale: LinearScale(min: 1)),
        },
        marks: [
          LineMark(position: Varset('title') * Varset('rank')),
          PointMark(position: Varset('title') * Varset('rank'), size: SizeEncode(value: 7)),
        ],
        coord: RectCoord(verticalRange: [1, 0]),
        axes: [
          AxisGuide(
            dim: Dim.x,
            position: 1,
            flip: true,
            line: Defaults.strokeStyle,
            label: LabelStyle(
              textStyle: const TextStyle(fontSize: 9, color: Color(0xFF808080)),
              offset: const Offset(0, -7.5),
              rotation: 0.5,
              align: Alignment.topRight,
            ),
          ),
          Defaults.verticalAxis..dim = Dim.y,
        ],
      ),
    );
