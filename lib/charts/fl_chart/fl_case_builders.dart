// Los 63 casos maestros dibujados con FL Chart 1.2.0.
//
// Se reutilizan las seis familias de FL Chart (LineChart, BarChart, PieChart,
// ScatterChart, CandlestickChart; RadarChart no lo pide ningún caso) y los
// wrappers de esta carpeta. Lo que FL Chart no trae se construye como
// VARIANTE, COMPOSICIÓN o ADAPTACIÓN, y así se declara en cada caso.

import 'dart:math' as math;

import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/common/live_case_hosts.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_view_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'fl_bar_charts.dart';
import 'fl_gauge_charts.dart';
import 'fl_line_charts.dart';
import 'fl_multi_bar_charts.dart';
import 'fl_pie_charts.dart';

const _n = ImplementationStrategy.nativo;
const _v = ImplementationStrategy.variante;
const _c = ImplementationStrategy.composicion;
const _a = ImplementationStrategy.adaptacion;

CaseImpl _impl(int n, ImplementationStrategy s, String api, CaseBuilder b, {String? note}) =>
    CaseImpl(strategy: s, origin: sharedCaseOrigins[n]!, api: api, builder: b, note: note);

/// Los 63 casos de FL Chart.
final Map<int, CaseImpl> flChartCases = {
  1: _impl(1, _n, 'LineChart', (_, d) => _lineChart([_line(_spots(d.g.scoreByYear), casePalette[0])], xLabels: _labels(d.g.scoreByYear))),
  2: _impl(2, _n, 'BarChart (BasicBarChart)', (_, d) => BasicBarChart(data: toCategories(_topPopularity(d)), categoryLabelSize: 9, showGrid: true, valueFormatter: (v) => _numShort(v.toDouble()))),
  3: _impl(3, _v, 'BarChart + rotationQuarterTurns', (_, d) => BasicBarChart(data: toCategories(_topScore(d)), isHorizontal: true, barWidth: 10, showGrid: true)),
  4: _impl(4, _v, 'LineChart + isCurved', (_, d) => _lineChart([_line(_spots(d.g.scoreByYear), casePalette[0], curved: true)], xLabels: _labels(d.g.scoreByYear))),
  5: _impl(5, _v, 'LineChart + belowBarData', (_, d) => _lineChart([_line(_spots(d.g.countByYear), casePalette[2], area: true)], xLabels: _labels(d.g.countByYear), minY: 0)),
  6: _impl(6, _v, 'LineChart + isCurved + belowBarData', (_, d) => _lineChart([_line(_spots(d.g.countByYear), casePalette[2], area: true, curved: true)], xLabels: _labels(d.g.countByYear), minY: 0)),
  7: _impl(7, _n, 'PieChart (BasicPieChart)', (_, d) => BasicPieChart(data: toCategories(d.g.countByFormat))),
  8: _impl(8, _v, 'PieChart + centerSpaceRadius', (_, d) => BasicPieChart(data: toCategories(d.g.countByStatus), isDonut: true)),
  9: _impl(9, _c, 'PieChart concéntricos en Stack', (_, d) => _RadialBars(items: _topScoreRaw(d, 5))),
  10: _impl(10, _n, 'ScatterChart', (_, d) => _scatter(d, (_) => FlDotCirclePainter(radius: 3.5, color: casePalette[0]))),
  11: _impl(11, _v, 'ScatterChart + radio por punto', (_, d) {
        final maxEp = d.g.titles.map((a) => a.episodes ?? 0).fold<int>(1, math.max);
        return _scatter(d, (a) => FlDotCirclePainter(radius: 3 + 12 * math.sqrt((a.episodes ?? 0) / maxEp), color: casePalette[4].withAlpha(150)),
            where: (a) => a.episodes != null);
      }, note: 'Solo entran obras con episodes (AniList no lo informa para manga).'),
  12: _impl(12, _v, 'LineChartBarData(isStepLineChart)', (_, d) => _lineChart([_line(_spots(d.g.cumulativeByYear), casePalette[3], step: true)], xLabels: _labels(d.g.cumulativeByYear), minY: 0)),
  13: _impl(13, _v, 'isStepLineChart + belowBarData', (_, d) => _lineChart([_line(_spots(d.g.cumulativeByYear), casePalette[3], step: true, area: true)], xLabels: _labels(d.g.cumulativeByYear), minY: 0)),
  14: _impl(14, _a, 'BarChart horizontal con rangos simétricos (fromY/toY)', (_, d) {
        final items = [...d.g.countByFormat]..sort((a, b) => a.value.compareTo(b.value));
        return _centeredBars(items);
      }, note: 'FL Chart no tiene Pyramid: se dibuja con barras centradas (la más corta arriba).'),
  15: _impl(15, _a, 'BarChart horizontal con rangos simétricos (fromY/toY)', (_, d) => _centeredBars(d.g.countByStatus),
      note: 'FL Chart no tiene Funnel: se dibuja con barras centradas (la más ancha arriba).'),
  16: _impl(16, _v, 'BarChart sobre bins externos (groupsSpace 0)', (_, d) => BasicBarChart(data: toCategories(d.g.scoreBins), groupsSpace: 0, barWidth: 26, showBorder: true, categoryLabelSize: 8)),
  17: _impl(17, _v, 'BarChartRodStackItem (MultiSeriesBarChart)', (_, d) => MultiSeriesBarChart(seriesList: toCategorySeries(d.g.yearFormatSeries), isStacked: true, barWidth: 16)),
  18: _impl(18, _v, 'BarChartRodStackItem + rotationQuarterTurns', (_, d) => MultiSeriesBarChart(seriesList: toCategorySeries(d.g.genreStatusSeries), isStacked: true, isHorizontal: true, barWidth: 14)),
  19: _impl(19, _v, 'LineChart + betweenBarsData sobre acumulados', (_, d) => _stackedLines(d.g.yearFormatSeries, area: true)),
  20: _impl(20, _v, 'LineChart con series acumuladas', (_, d) => _stackedLines(d.g.yearFormatSeries)),
  21: _impl(21, _v, 'BarChartRodStackItem con valores normalizados', (_, d) => MultiSeriesBarChart(seriesList: toCategorySeries(toPercent(d.g.yearFormatSeries)), isStacked: true, barWidth: 16)),
  22: _impl(22, _v, 'BarChartRodStackItem normalizado + rotationQuarterTurns', (_, d) => MultiSeriesBarChart(seriesList: toCategorySeries(toPercent(d.g.genreStatusSeries)), isStacked: true, isHorizontal: true, barWidth: 14)),
  23: _impl(23, _v, 'betweenBarsData con acumulados normalizados', (_, d) => _stackedLines(toPercent(d.g.yearFormatSeries), area: true, maxY: 100)),
  24: _impl(24, _v, 'LineChart con acumulados normalizados', (_, d) => _stackedLines(toPercent(d.g.yearFormatSeries), maxY: 100)),
  25: _impl(25, _v, 'BarChartRodData(fromY, toY)', (_, d) => _rangeBars(d.g.airingRanges)),
  26: _impl(26, _v, 'betweenBarsData entre dos líneas', (_, d) => _rangeArea(d.g.scoreRangeByYear)),
  27: _impl(27, _v, 'betweenBarsData + isCurved', (_, d) => _rangeArea(d.g.scoreRangeByYear, curved: true)),
  28: _impl(28, _v, 'BarChartRodData(fromY, toY) con acumulados', (_, d) => _waterfall(d.g.waterfallSteps)),
  29: _impl(29, _v, 'LineChart + FlDotData', (_, d) => _lineChart([_line(_spots(d.g.scoreByYear), casePalette[0], dots: true)], xLabels: _labels(d.g.scoreByYear))),
  30: _impl(30, _v, 'BarChart con negativos (BasicBarChart bySign)', (_, d) => BasicBarChart(
        data: toCategories(d.g.genreDeviation), isHorizontal: true, barWidth: 12, colorMode: BarColorMode.bySign,
        baselineY: 0, showBaselineLine: true, showGrid: true)),
  31: _impl(31, _v, 'LineChart sin títulos, cuadrícula ni borde', (_, d) => BasicLineChart(points: toXY(d.g.countByYear), showTitles: false, showGrid: false, showBorder: false)),
  32: _impl(32, _a, 'CandlestickChart (CandlestickSpot)', (_, d) => withTrends(d, () => _candles(d.g.trendOhlc)), note: ohlcNote),
  33: _impl(33, _a, 'LineChart: segmentos high-low + ticks open/close', (_, d) => withTrends(d, () => _hloc(d.g.trendOhlc)), note: hlocNote),
  34: _impl(34, _a, 'LineChart: cajas y bigotes con segmentos', (_, d) => _boxPlot(d.g.boxByFormat),
      note: 'FL Chart no tiene Box Plot: caja y bigotes dibujados con segmentos de LineChart.'),
  35: _impl(35, _n, 'BarChartRodData.toYErrorRange + errorIndicatorData', (_, d) => _errorBars(d.g.errorByGenre)),
  36: _impl(36, _c, 'BarChart + LineChart superpuestos en Stack', (_, d) => _combined(d)),
  37: _impl(37, _c, 'Dos LineChart en Stack (eje izquierdo y derecho)', (_, d) => _dualAxis(d)),
  38: _impl(38, _n, 'LineChart + FlTransformationConfig (zoom/pan horizontal)', (_, d) => _panZoom(d),
      note: 'Pellizca o usa la rueda + arrastre sobre el gráfico.'),
  39: _impl(39, _c, 'LineTouchData.touchCallback + ExtraLinesData', (_, d) => _Crosshair(items: d.g.scoreByYear)),
  40: _impl(40, _v, 'LineTouchData con tooltip multiserie', (_, d) => _trackball(d.g.yearFormatSeries)),
  41: _impl(41, _v, 'LineChart: serie + SMA', (_, d) => withTrends(d, () => _sma(d)), note: trendsIndicatorNote),
  42: _impl(42, _v, 'LineChart + betweenBarsData (bandas)', (_, d) => withTrends(d, () => _bollinger(d.g.bollingerPoints)), note: trendsIndicatorNote),
  43: _impl(43, _v, 'LineChart + HorizontalRangeAnnotation', (_, d) => withTrends(d, () => _rsi(d.g.rsiPoints)), note: trendsIndicatorNote),
  44: _impl(44, _c, 'LineChart: MACD, señal e histograma como segmentos', (_, d) => withTrends(d, () => _macd(d.g.macdPoints)), note: trendsIndicatorNote),
  45: _impl(45, _v, 'LineChart: puntos + recta de regresión', (_, d) => _trend(d.g.regression)),
  46: _impl(46, _n, 'RangeAnnotations + ExtraLinesData', (_, d) => _plotBands(d)),
  47: _impl(47, _c, 'BarChart + widget Flutter posicionado en Stack', (_, d) => _widgetAnnotation(d)),
  48: _impl(48, _v, 'LineChartBarData.gradient con cortes duros', (_, d) => _multiColored(d)),
  49: _impl(49, _n, 'BarChartRodData.gradient', (_, d) => BasicBarChart(
        data: toCategories(_topScore(d)), barGradient: const LinearGradient(colors: [Color(0xFF7E57C2), Color(0xFF26C6DA)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        categoryLabelSize: 9, minY: 0, maxY: 100)),
  50: _impl(50, _v, 'Eje X por índice + getTitlesWidget (sin huecos)', (_, d) => _gapless(d),
      note: 'Eje sin huecos (gapless). FL Chart no dibuja la marca de ruptura de eje.'),
  51: _impl(51, _v, 'log10 externo + etiquetas 10^n', (_, d) => _logBars(d)),
  52: _impl(52, _c, 'BarChart + ScrollController + paginación AniList', (_, d) => LazyLoadingHost(
        chartBuilder: (items) => _plainBars([for (final m in items) GCategory(shortLabel(m.title, 8), m.popularity ?? 0)], color: casePalette[5]))),
  53: _impl(53, _n, 'PieChartSectionData.gradient', (_, d) => _shadedDonut(d.g.countByFormat)),
  54: _impl(54, _c, 'PieChart + ClipRect/OverflowBox + Stack (SemiCircleGauge)', (_, d) {
        final top = d.g.topByPopularity.first;
        return SemiCircleGauge(value: (top.score ?? 0).toDouble(), valueLabel: '${top.score ?? '–'}', caption: shortLabel(top.title, 28));
      }),
  55: _impl(55, _c, 'RangeSlider + LineChart resumen + BarChart filtrado', (_, d) => _RangeFilter(items: d.g.countByYear)),
  56: _impl(56, _c, 'PieChart concéntricos + selección con estado', (_, d) => _RadialBars(items: _topScoreRaw(d, 5), explodable: true)),
  57: _impl(57, _v, 'BarChart ±1 sin ejes', (_, d) => _winLoss(d.g.winLossByYear)),
  58: _impl(58, _v, 'LineChart + FlDotData.checkToShowDot (mín./máx.)', (_, d) => _sparkMinMax(d.g.countByYear)),
  59: _impl(59, _n, 'ScatterSpot.dotPainter (círculo, cuadrado, cruz)', (_, d) => _multiShape(d)),
  60: _impl(60, _c, 'BarTouchData.touchCallback + Card en Stack', (_, d) => _WidgetTooltip(items: d.g.topByPopularity)),
  61: _impl(61, _c, 'AnimationController + Interval por barra', (_, d) => _Staggered(items: d.g.topByPopularity)),
  62: _impl(62, _v, 'Valores negados + rightTitles/topTitles', (_, d) => _invertedOpposed(d)),
  63: _impl(63, _c, 'Timer → GraphQL → ChangeNotifier → LineChart', (_, d) => LiveStreamingHost(
        chartBuilder: (samples) => _lineChart(
              [_line([for (var i = 0; i < samples.length; i++) FlSpot(i.toDouble(), samples[i].totalPopularity.toDouble())], casePalette[1], dots: true)],
              xLabels: [for (final s in samples) liveLabel(s)],
            ))),
};

// ---------------------------------------------------------------------------
// Datos
// ---------------------------------------------------------------------------

List<GCategory> _topPopularity(CaseData d) =>
    [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 10), a.popularity)];

List<GCategory> _topScore(CaseData d) => _topScoreRaw(d, 10);

List<GCategory> _topScoreRaw(CaseData d, int n) =>
    [for (final a in d.g.topByScore.take(n)) GCategory(shortLabel(a.title, 12), a.score ?? 0)];

List<FlSpot> _spots(List<GCategory> items) =>
    [for (var i = 0; i < items.length; i++) FlSpot(i.toDouble(), items[i].value.toDouble())];

List<String> _labels(List<GCategory> items) => [for (final c in items) c.label];

String _numShort(double v) {
  final a = v.abs();
  if (a >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (a >= 10000) return '${(v / 1000).toStringAsFixed(0)}k';
  if (a >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

// ---------------------------------------------------------------------------
// Piezas de FL Chart reutilizadas por varios casos
// ---------------------------------------------------------------------------

const _ts = TextStyle(fontSize: 9);

AxisTitles _none() => const AxisTitles(sideTitles: SideTitles(showTitles: false));

/// Eje con espacio reservado pero sin texto (para alinear gráficos en Stack).
AxisTitles _blank(double reserved) =>
    AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: reserved, getTitlesWidget: (_, _) => const SizedBox.shrink()));

AxisTitles _axis(String Function(double v) fn, {double reserved = 34, double? interval}) => AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: reserved,
        interval: interval,
        getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, space: 4, child: Text(fn(v), style: _ts)),
      ),
    );

/// Etiqueta de posición entera [labels][i]; vacío entre enteros o fuera de rango.
String Function(double) _at(List<String> labels, {int every = 1}) => (v) {
      final i = v.round();
      if ((v - i).abs() > 0.01 || i < 0 || i >= labels.length || i % every != 0) return '';
      return labels[i];
    };

int _every(int count, {int max = 6}) => count <= max ? 1 : (count / max).ceil();

FlTitlesData _titles({AxisTitles? left, AxisTitles? bottom, AxisTitles? right, AxisTitles? top}) => FlTitlesData(
      leftTitles: left ?? _none(),
      bottomTitles: bottom ?? _none(),
      rightTitles: right ?? _none(),
      topTitles: top ?? _none(),
    );

LineChartBarData _line(
  List<FlSpot> spots,
  Color color, {
  bool curved = false,
  bool step = false,
  bool area = false,
  bool dots = false,
  double width = 2.5,
}) =>
    LineChartBarData(
      spots: spots,
      color: color,
      barWidth: width,
      isCurved: curved,
      preventCurveOverShooting: true,
      isStepLineChart: step,
      dotData: FlDotData(show: dots),
      belowBarData: BarAreaData(show: area, color: color.withAlpha(60)),
    );

LineChartBarData _segment(double x1, double y1, double x2, double y2, Color color, {double width = 2}) =>
    LineChartBarData(
      spots: [FlSpot(x1, y1), FlSpot(x2, y2)],
      color: color,
      barWidth: width,
      dotData: const FlDotData(show: false),
    );

Widget _lineChart(
  List<LineChartBarData> bars, {
  List<String>? xLabels,
  List<BetweenBarsData> between = const [],
  ExtraLinesData? extra,
  RangeAnnotations? ranges,
  double? minX,
  double? maxX,
  double? minY,
  double? maxY,
  bool touch = true,
  String Function(double)? yFormat,
  FlTransformationConfig transformation = const FlTransformationConfig(),
}) =>
    LineChart(
      LineChartData(
        lineBarsData: bars,
        betweenBarsData: between,
        extraLinesData: extra ?? const ExtraLinesData(),
        rangeAnnotations: ranges ?? const RangeAnnotations(),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(enabled: touch),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(
          left: _axis(yFormat ?? _numShort, reserved: 38),
          bottom: xLabels == null ? null : _axis(_at(xLabels, every: _every(xLabels.length)), reserved: 22, interval: 1),
        ),
      ),
      transformationConfig: transformation,
    );

BarChartGroupData _group(int x, List<BarChartRodData> rods) => BarChartGroupData(x: x, barRods: rods);

Widget _barChart(
  List<BarChartGroupData> groups, {
  List<String>? labels,
  double? minY,
  double? maxY,
  int rotation = 0,
  bool showLeft = true,
  ExtraLinesData? extra,
  RangeAnnotations? ranges,
  BarTouchData? touch,
  String Function(double)? yFormat,
}) =>
    BarChart(
      BarChartData(
        barGroups: groups,
        alignment: BarChartAlignment.spaceAround,
        minY: minY,
        maxY: maxY,
        rotationQuarterTurns: rotation,
        extraLinesData: extra ?? const ExtraLinesData(),
        rangeAnnotations: ranges ?? const RangeAnnotations(),
        barTouchData: touch ?? BarTouchData(enabled: true),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(
          left: showLeft ? _axis(yFormat ?? _numShort, reserved: 38) : null,
          bottom: labels == null ? null : _axis(_at(labels, every: _every(labels.length, max: 10)), reserved: 22),
        ),
      ),
    );

Widget _plainBars(List<GCategory> items, {Color? color}) => _barChart(
      [
        for (var i = 0; i < items.length; i++)
          _group(i, [BarChartRodData(toY: items[i].value.toDouble(), color: color ?? casePalette[0], width: 14)]),
      ],
      labels: _labels(items),
      minY: 0,
    );

// ---------------------------------------------------------------------------
// Casos
// ---------------------------------------------------------------------------

Widget _scatter(CaseData d, FlDotPainter Function(GAnime a) painter, {bool Function(GAnime a)? where}) {
  final items = [for (final a in scoredTitles(d.g)) if (where == null || where(a)) a];
  return ScatterChart(
    ScatterChartData(
      scatterSpots: [
        for (final a in items) ScatterSpot(a.popularity.toDouble(), a.score!.toDouble(), dotPainter: painter(a)),
      ],
      titlesData: _titles(left: _axis(_numShort), bottom: _axis(_numShort, reserved: 22)),
      gridData: const FlGridData(),
      borderData: FlBorderData(show: false),
    ),
  );
}

Widget _multiShape(CaseData d) {
  final formats = d.g.formats;
  FlDotPainter painter(GAnime a) {
    final i = formats.indexOf(a.format);
    final color = casePalette[(i < 0 ? formats.length : i) % casePalette.length];
    return switch (i % 3) {
      0 => FlDotCirclePainter(radius: 4, color: color),
      1 => FlDotSquarePainter(size: 8, color: color, strokeWidth: 0),
      _ => FlDotCrossPainter(size: 9, color: color, width: 2),
    };
  }

  return Column(children: [
    Expanded(child: _scatter(d, painter, where: (a) => formats.contains(a.format))),
    SimpleLegend(labels: [for (var i = 0; i < formats.length; i++) '${formats[i]} (${['●', '■', '✕'][i % 3]})'], colors: casePalette),
  ]);
}

Widget _centeredBars(List<GCategory> items) {
  final max = items.isEmpty ? 1.0 : items.map((c) => c.value.toDouble()).reduce(math.max);
  return Column(children: [
    Expanded(
      child: _barChart(
        [
          for (var i = 0; i < items.length; i++)
            _group(i, [
              BarChartRodData(
                fromY: -items[i].value / 2,
                toY: items[i].value / 2,
                width: 22,
                color: casePalette[i % casePalette.length],
                borderRadius: BorderRadius.zero,
              ),
            ]),
        ],
        rotation: 1,
        minY: -max / 2,
        maxY: max / 2,
        showLeft: false,
      ),
    ),
    SimpleLegend(labels: [for (final c in items) '${c.label}: ${c.value}'], colors: casePalette),
  ]);
}

Widget _stackedLines(List<GSeriesPoint> points, {bool area = false, double? maxY}) {
  final cumulative = toStackedCumulative(points);
  final series = <String, List<GSeriesPoint>>{};
  for (final p in cumulative) {
    (series[p.series] ??= []).add(p);
  }
  final names = series.keys.toList();
  final xs = [for (final p in series.values.first) p.x];
  final bars = [
    for (var s = 0; s < names.length; s++)
      _line(
        [for (var i = 0; i < series[names[s]]!.length; i++) FlSpot(i.toDouble(), series[names[s]]![i].value.toDouble())],
        casePalette[s],
        area: area && s == 0,
      ),
  ];
  return Column(children: [
    Expanded(
      child: _lineChart(
        bars,
        xLabels: xs,
        minY: 0,
        maxY: maxY,
        between: area
            ? [for (var s = 1; s < names.length; s++) BetweenBarsData(fromIndex: s - 1, toIndex: s, color: casePalette[s].withAlpha(90))]
            : const [],
      ),
    ),
    SimpleLegend(labels: names, colors: casePalette),
  ]);
}

Widget _rangeBars(List<GRange> ranges) {
  if (ranges.isEmpty) return const TechnicalIssue('La muestra no tiene obras con fecha de inicio y fin.');
  final lo = ranges.map((r) => r.low.toDouble()).reduce(math.min);
  final hi = ranges.map((r) => r.high.toDouble()).reduce(math.max);
  return _barChart(
    [
      for (var i = 0; i < ranges.length; i++)
        _group(i, [
          BarChartRodData(fromY: ranges[i].low.toDouble(), toY: ranges[i].high.toDouble() + 0.3, width: 12, color: casePalette[i % casePalette.length]),
        ]),
    ],
    labels: [for (final r in ranges) shortLabel(r.x, 8)],
    minY: lo - 1,
    maxY: hi + 1,
    yFormat: (v) => v.toStringAsFixed(0),
  );
}

Widget _rangeArea(List<GRange> ranges, {bool curved = false}) => _lineChart(
      [
        _line([for (var i = 0; i < ranges.length; i++) FlSpot(i.toDouble(), ranges[i].low.toDouble())], casePalette[0], curved: curved),
        _line([for (var i = 0; i < ranges.length; i++) FlSpot(i.toDouble(), ranges[i].high.toDouble())], casePalette[1], curved: curved),
      ],
      xLabels: [for (final r in ranges) r.x],
      between: [BetweenBarsData(fromIndex: 0, toIndex: 1, color: casePalette[0].withAlpha(70))],
    );

Widget _waterfall(List<GWaterfallStep> steps) => _barChart(
      [
        for (var i = 0; i < steps.length; i++)
          _group(i, [
            BarChartRodData(
              fromY: steps[i].from.toDouble(),
              toY: steps[i].to.toDouble(),
              width: 16,
              borderRadius: BorderRadius.zero,
              color: steps[i].isTotal
                  ? casePalette[9]
                  : (steps[i].to >= steps[i].from ? casePalette[2] : casePalette[1]),
            ),
          ]),
      ],
      labels: [for (final s in steps) s.label],
      minY: 0,
    );

Widget _candles(List<GOhlc> candles) => CandlestickChart(
      CandlestickChartData(
        candlestickSpots: [
          for (var i = 0; i < candles.length; i++)
            CandlestickSpot(
              x: i.toDouble(),
              open: candles[i].open.toDouble(),
              high: candles[i].high.toDouble(),
              low: candles[i].low.toDouble(),
              close: candles[i].close.toDouble(),
            ),
        ],
        minX: -0.7,
        maxX: candles.length - 0.3,
        titlesData: _titles(
          left: _axis(_numShort, reserved: 38),
          bottom: _axis(_at([for (final c in candles) c.label.substring(5)], every: _every(candles.length)), reserved: 22, interval: 1),
        ),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );

Widget _hloc(List<GOhlc> candles) => _lineChart(
      [
        for (var i = 0; i < candles.length; i++) ...[
          _segment(i.toDouble(), candles[i].low.toDouble(), i.toDouble(), candles[i].high.toDouble(),
              candles[i].close >= candles[i].open ? casePalette[2] : casePalette[1]),
          _segment(i - 0.3, candles[i].open.toDouble(), i.toDouble(), candles[i].open.toDouble(),
              candles[i].close >= candles[i].open ? casePalette[2] : casePalette[1]),
          _segment(i.toDouble(), candles[i].close.toDouble(), i + 0.3, candles[i].close.toDouble(),
              candles[i].close >= candles[i].open ? casePalette[2] : casePalette[1]),
        ],
      ],
      xLabels: [for (final c in candles) c.label.substring(5)],
      minX: -0.7,
      maxX: candles.length - 0.3,
      touch: false,
    );

Widget _boxPlot(List<GBoxStat> boxes) {
  if (boxes.isEmpty) return const TechnicalIssue('No hay formatos con al menos 2 obras puntuadas.');
  const w = 0.25;
  return _lineChart(
    [
      for (var i = 0; i < boxes.length; i++) ...[
        _segment(i.toDouble(), boxes[i].min.toDouble(), i.toDouble(), boxes[i].q1.toDouble(), casePalette[i]),
        _segment(i.toDouble(), boxes[i].q3.toDouble(), i.toDouble(), boxes[i].max.toDouble(), casePalette[i]),
        _segment(i - w / 2, boxes[i].min.toDouble(), i + w / 2, boxes[i].min.toDouble(), casePalette[i]),
        _segment(i - w / 2, boxes[i].max.toDouble(), i + w / 2, boxes[i].max.toDouble(), casePalette[i]),
        _segment(i - w, boxes[i].q1.toDouble(), i + w, boxes[i].q1.toDouble(), casePalette[i]),
        _segment(i - w, boxes[i].q3.toDouble(), i + w, boxes[i].q3.toDouble(), casePalette[i]),
        _segment(i - w, boxes[i].q1.toDouble(), i - w, boxes[i].q3.toDouble(), casePalette[i]),
        _segment(i + w, boxes[i].q1.toDouble(), i + w, boxes[i].q3.toDouble(), casePalette[i]),
        _segment(i - w, boxes[i].median.toDouble(), i + w, boxes[i].median.toDouble(), casePalette[i], width: 4),
      ],
    ],
    xLabels: [for (final b in boxes) b.label],
    minX: -0.6,
    maxX: boxes.length - 0.4,
    touch: false,
  );
}

Widget _errorBars(List<GErrorStat> stats) => BarChart(
      BarChartData(
        barGroups: [
          for (var i = 0; i < stats.length; i++)
            _group(i, [
              BarChartRodData(
                toY: stats[i].mean.toDouble(),
                width: 18,
                color: casePalette[i % casePalette.length].withAlpha(170),
                toYErrorRange: FlErrorRange(
                  lowerBy: (stats[i].mean - stats[i].low).toDouble(),
                  upperBy: (stats[i].high - stats[i].mean).toDouble(),
                ),
              ),
            ]),
        ],
        minY: 0,
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(left: _axis(_numShort), bottom: _axis(_at([for (final s in stats) s.label]), reserved: 22)),
      ),
    );

Widget _combined(CaseData d) {
  final counts = d.g.countByYear;
  final scores = {for (final c in d.g.scoreByYear) c.label: c.value};
  final labels = _labels(counts);
  return Column(children: [
    Expanded(
      child: Stack(children: [
        BarChart(
          BarChartData(
            barGroups: [
              for (var i = 0; i < counts.length; i++)
                _group(i, [BarChartRodData(toY: counts[i].value.toDouble(), width: 14, color: casePalette[0].withAlpha(170))]),
            ],
            alignment: BarChartAlignment.spaceAround,
            minY: 0,
            barTouchData: BarTouchData(enabled: false),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              left: _axis(_numShort, reserved: 34),
              bottom: _axis(_at(labels, every: _every(labels.length)), reserved: 22),
              right: _blank(34),
            ),
          ),
        ),
        LineChart(
          LineChartData(
            minX: -0.5,
            maxX: counts.length - 0.5,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              _line([
                for (var i = 0; i < counts.length; i++)
                  if (scores[counts[i].label] != null) FlSpot(i.toDouble(), scores[counts[i].label]!.toDouble()),
              ], casePalette[1], dots: true),
            ],
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: _titles(left: _blank(34), bottom: _blank(22), right: _axis(_numShort, reserved: 34)),
          ),
        ),
      ]),
    ),
    SimpleLegend(labels: const ['Obras (eje izq.)', 'Score medio (eje der.)'], colors: [casePalette[0], casePalette[1]]),
  ]);
}

Widget _dualAxis(CaseData d) {
  final top = d.g.topByPopularity;
  LineChartData data(List<FlSpot> spots, Color color, {required bool leftAxis}) => LineChartData(
        minX: 0,
        maxX: (top.length - 1).toDouble(),
        lineBarsData: [_line(spots, color, dots: true)],
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(show: leftAxis, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(
          left: leftAxis ? _axis(_numShort, reserved: 38) : _blank(38),
          right: leftAxis ? _blank(34) : _axis(_numShort, reserved: 34),
          bottom: leftAxis ? _axis(_at([for (final a in top) shortLabel(a.title, 6)], every: 2), reserved: 22, interval: 1) : _blank(22),
        ),
      );
  return Column(children: [
    Expanded(
      child: Stack(children: [
        LineChart(data([for (var i = 0; i < top.length; i++) FlSpot(i.toDouble(), top[i].popularity.toDouble())], casePalette[0], leftAxis: true)),
        LineChart(data([
          for (var i = 0; i < top.length; i++)
            if (top[i].score != null) FlSpot(i.toDouble(), top[i].score!.toDouble()),
        ], casePalette[1], leftAxis: false)),
      ]),
    ),
    SimpleLegend(labels: const ['popularity (eje izq.)', 'averageScore (eje der.)'], colors: [casePalette[0], casePalette[1]]),
  ]);
}

Widget _panZoom(CaseData d) {
  final items = [...d.g.datedTitles]..sort((a, b) => a.date.compareTo(b.date));
  return _lineChart(
    [_line([for (var i = 0; i < items.length; i++) FlSpot(i.toDouble(), items[i].value.toDouble())], casePalette[5], dots: true, width: 1.5)],
    xLabels: [for (final t in items) '${t.date.year}'],
    transformation: const FlTransformationConfig(scaleAxis: FlScaleAxis.horizontal, maxScale: 10),
  );
}

class _Crosshair extends StatefulWidget {
  const _Crosshair({required this.items});
  final List<GCategory> items;

  @override
  State<_Crosshair> createState() => _CrosshairState();
}

class _CrosshairState extends State<_Crosshair> {
  FlSpot? _spot;

  @override
  Widget build(BuildContext context) {
    final spots = _spots(widget.items);
    final color = Theme.of(context).colorScheme.outline;
    return Column(children: [
      Text(_spot == null ? 'Toca o pasa el ratón sobre la línea' : '${widget.items[_spot!.x.round()].label}: ${_spot!.y.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 11)),
      Expanded(
        child: LineChart(
          LineChartData(
            lineBarsData: [_line(spots, casePalette[0], dots: true)],
            extraLinesData: ExtraLinesData(
              horizontalLines: [if (_spot != null) HorizontalLine(y: _spot!.y, color: color, strokeWidth: 1, dashArray: [4, 4])],
              verticalLines: [if (_spot != null) VerticalLine(x: _spot!.x, color: color, strokeWidth: 1, dashArray: [4, 4])],
            ),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: false,
              touchCallback: (event, response) {
                final s = response?.lineBarSpots;
                setState(() => _spot = (s == null || s.isEmpty || !event.isInterestedForInteractions) ? null : FlSpot(s.first.x, s.first.y));
              },
            ),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: _titles(left: _axis(_numShort, reserved: 38), bottom: _axis(_at(_labels(widget.items), every: 2), reserved: 22, interval: 1)),
          ),
        ),
      ),
    ]);
  }
}

Widget _trackball(List<GSeriesPoint> points) {
  final series = toXYSeries(points);
  final labels = <String>[for (final p in series.first.data) p.label ?? ''];
  return Column(children: [
    Expanded(
      child: LineChart(
        LineChartData(
          lineBarsData: [
            for (var s = 0; s < series.length; s++)
              _line([for (var i = 0; i < series[s].data.length; i++) FlSpot(i.toDouble(), series[s].data[i].y.toDouble())], casePalette[s], dots: true),
          ],
          lineTouchData: LineTouchData(
            touchSpotThreshold: 40,
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes) TouchedSpotIndicatorData(FlLine(color: Colors.grey, strokeWidth: 1), const FlDotData()),
            ],
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final s in spots) LineTooltipItem('${series[s.barIndex].seriesName}: ${s.y.toStringAsFixed(0)}', TextStyle(color: casePalette[s.barIndex], fontSize: 10)),
              ],
            ),
          ),
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: _titles(left: _axis(_numShort), bottom: _axis(_at(labels, every: 2), reserved: 22, interval: 1)),
        ),
      ),
    ),
    SimpleLegend(labels: [for (final s in series) s.seriesName], colors: casePalette),
  ]);
}

List<String> _dateLabels(List<String> labels) => [for (final l in labels) l.length >= 10 ? l.substring(5) : l];

Widget _sma(CaseData d) {
  final values = [for (final p in d.g.trendSma) if (p.series == 'Variación diaria') p];
  final sma = [for (final p in d.g.trendSma) if (p.series != 'Variación diaria') p];
  return Column(children: [
    Expanded(
      child: _lineChart(
        [
          _line([for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i].value.toDouble())], casePalette[9], width: 1.5),
          _line([for (var i = 0; i < sma.length; i++) FlSpot(i.toDouble(), sma[i].value.toDouble())], casePalette[3]),
        ],
        xLabels: _dateLabels([for (final p in values) p.x]),
      ),
    ),
    SimpleLegend(labels: const ['Variación diaria', 'SMA 7'], colors: [casePalette[9], casePalette[3]]),
  ]);
}

Widget _bollinger(List<GBollingerPoint> pts) => _lineChart(
      [
        _line([for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].lower.toDouble())], casePalette[0].withAlpha(120), width: 1),
        _line([for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].upper.toDouble())], casePalette[0].withAlpha(120), width: 1),
        _line([for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].mid.toDouble())], casePalette[0]),
        _line([for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].value.toDouble())], casePalette[9], width: 1.5),
      ],
      xLabels: _dateLabels([for (final p in pts) p.label]),
      between: [BetweenBarsData(fromIndex: 0, toIndex: 1, color: casePalette[0].withAlpha(40))],
    );

Widget _rsi(List<GCategory> pts) => _lineChart(
      [_line(_spots(pts), casePalette[4], width: 1.8)],
      xLabels: _dateLabels(_labels(pts)),
      minY: 0,
      maxY: 100,
      ranges: RangeAnnotations(horizontalRangeAnnotations: [
        HorizontalRangeAnnotation(y1: 70, y2: 100, color: Colors.red.withAlpha(30)),
        HorizontalRangeAnnotation(y1: 0, y2: 30, color: Colors.green.withAlpha(30)),
      ]),
    );

Widget _macd(List<GMacdPoint> pts) => Column(children: [
      Expanded(
        child: _lineChart(
          [
            _line([for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].macd.toDouble())], casePalette[0], width: 1.8),
            _line([for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].signal.toDouble())], casePalette[3], width: 1.8),
            for (var i = 0; i < pts.length; i++)
              _segment(i.toDouble(), 0, i.toDouble(), pts[i].histogram.toDouble(), pts[i].histogram >= 0 ? casePalette[2] : casePalette[1], width: 3),
          ],
          xLabels: _dateLabels([for (final p in pts) p.label]),
          touch: false,
        ),
      ),
      SimpleLegend(labels: const ['MACD', 'Señal', 'Histograma'], colors: [casePalette[0], casePalette[3], casePalette[2]]),
    ]);

Widget _trend(List<GRegressionPoint> pts) {
  final sorted = [...pts]..sort((a, b) => a.x.compareTo(b.x));
  return _lineChart([
    LineChartBarData(
      spots: [for (final p in sorted) FlSpot(p.x.toDouble(), p.y.toDouble())],
      barWidth: 0,
      color: Colors.transparent,
      dotData: FlDotData(getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 3, color: casePalette[0], strokeWidth: 0)),
    ),
    _line([for (final p in sorted) FlSpot(p.x.toDouble(), p.fitted.toDouble())], casePalette[1]),
  ]);
}

Widget _plotBands(CaseData d) {
  final items = [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 8), a.score ?? 0)];
  return _barChart(
    [for (var i = 0; i < items.length; i++) _group(i, [BarChartRodData(toY: items[i].value.toDouble(), width: 14, color: casePalette[0])])],
    labels: _labels(items),
    minY: 0,
    maxY: 100,
    ranges: RangeAnnotations(horizontalRangeAnnotations: [
      HorizontalRangeAnnotation(y1: 80, y2: 100, color: Colors.green.withAlpha(40)),
      HorizontalRangeAnnotation(y1: 0, y2: 60, color: Colors.red.withAlpha(25)),
    ]),
    extra: ExtraLinesData(horizontalLines: [
      HorizontalLine(y: d.g.globalMeanScore, color: casePalette[3], strokeWidth: 2, dashArray: [6, 4]),
    ]),
  );
}

Widget _widgetAnnotation(CaseData d) {
  final items = _topPopularity(d);
  final maxIndex = items.indexWhere((c) => c.value == items.map((e) => e.value).reduce(math.max));
  final maxY = items[maxIndex].value * 1.25;
  const left = 38.0, bottom = 22.0;
  return LayoutBuilder(builder: (context, box) {
    final plotW = box.maxWidth - left;
    final x = left + (maxIndex + 0.5) * plotW / items.length;
    final y = (1 - items[maxIndex].value / maxY) * (box.maxHeight - bottom);
    return Stack(children: [
      _barChart(
        [for (var i = 0; i < items.length; i++) _group(i, [BarChartRodData(toY: items[i].value.toDouble(), width: 14, color: casePalette[0])])],
        labels: _labels(items),
        minY: 0,
        maxY: maxY.toDouble(),
        touch: BarTouchData(enabled: false),
      ),
      Positioned(
        left: (x - 60).clamp(0, box.maxWidth - 120),
        top: (y - 44).clamp(0, box.maxHeight),
        width: 120,
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text('Máximo: ${d.g.topByPopularity[maxIndex].title}\n${_numShort(items[maxIndex].value.toDouble())} usuarios',
                style: const TextStyle(fontSize: 9), textAlign: TextAlign.center, maxLines: 3),
          ),
        ),
      ),
    ]);
  });
}

Widget _multiColored(CaseData d) {
  final items = d.g.scoreByYear;
  final mean = d.g.globalMeanScore;
  final colors = <Color>[];
  final stops = <double>[];
  for (var i = 1; i < items.length; i++) {
    final c = items[i].value >= mean ? casePalette[2] : casePalette[1];
    colors.addAll([c, c]);
    stops.addAll([(i - 1) / (items.length - 1), i / (items.length - 1)]);
  }
  return _lineChart(
    [
      LineChartBarData(
        spots: _spots(items),
        barWidth: 3,
        gradient: colors.length < 2 ? null : LinearGradient(colors: colors, stops: stops),
        color: colors.length < 2 ? casePalette[0] : null,
        dotData: const FlDotData(),
      ),
    ],
    xLabels: _labels(items),
    extra: ExtraLinesData(horizontalLines: [HorizontalLine(y: mean, color: Colors.grey, dashArray: [4, 4], strokeWidth: 1)]),
  );
}

Widget _gapless(CaseData d) {
  final items = d.g.countByYear;
  final years = [for (final c in items) int.tryParse(c.label) ?? 0];
  var gaps = 0;
  for (var i = 1; i < years.length; i++) {
    gaps += math.max(0, years[i] - years[i - 1] - 1);
  }
  return Column(children: [
    Text('Eje ordinal: $gaps años sin obras en el rango no ocupan espacio.', style: const TextStyle(fontSize: 11)),
    Expanded(child: _lineChart([_line(_spots(items), casePalette[5], dots: true)], xLabels: _labels(items), minY: 0)),
  ]);
}

Widget _logBars(CaseData d) {
  final items = spreadByPopularity(d.g);
  return _barChart(
    [
      for (var i = 0; i < items.length; i++)
        _group(i, [BarChartRodData(toY: math.log(math.max(1, items[i].popularity)) / math.ln10, width: 12, color: casePalette[4])]),
    ],
    labels: [for (final a in items) shortLabel(a.title, 6)],
    minY: 0,
    yFormat: (v) => v == v.roundToDouble() ? '10^${v.toStringAsFixed(0)}' : '',
  );
}

Widget _shadedDonut(List<GCategory> items) {
  final total = items.fold<num>(0, (a, c) => a + c.value);
  return Column(children: [
    Expanded(
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          sections: [
            for (var i = 0; i < items.length; i++)
              PieChartSectionData(
                value: items[i].value.toDouble(),
                radius: 46,
                title: items[i].value / total >= 0.05 ? '${(items[i].value * 100 / total).toStringAsFixed(0)}%' : '',
                titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                gradient: LinearGradient(
                  colors: [casePalette[i % casePalette.length], Color.lerp(casePalette[i % casePalette.length], Colors.black, 0.55)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
          ],
        ),
      ),
    ),
    SimpleLegend(labels: _labels(items), colors: casePalette),
  ]);
}

Widget _winLoss(List<GCategory> items) => _barChart(
      [
        for (var i = 0; i < items.length; i++)
          _group(i, [
            BarChartRodData(
              toY: items[i].value.toDouble(),
              width: 14,
              borderRadius: BorderRadius.zero,
              color: items[i].value >= 0 ? casePalette[2] : casePalette[1],
            ),
          ]),
      ],
      minY: -1.2,
      maxY: 1.2,
      showLeft: false,
      touch: BarTouchData(enabled: false),
      extra: ExtraLinesData(horizontalLines: [HorizontalLine(y: 0, color: Colors.grey, strokeWidth: 1)]),
    );

Widget _sparkMinMax(List<GCategory> items) {
  final values = [for (final c in items) c.value];
  final minI = values.indexOf(values.reduce((a, b) => a < b ? a : b));
  final maxI = values.indexOf(values.reduce((a, b) => a > b ? a : b));
  return Column(children: [
    Expanded(
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _spots(items),
              color: casePalette[0],
              barWidth: 2,
              belowBarData: BarAreaData(show: true, color: casePalette[0].withAlpha(50)),
              dotData: FlDotData(
                checkToShowDot: (spot, _) => spot.x.round() == minI || spot.x.round() == maxI,
                getDotPainter: (spot, _, _, _) =>
                    FlDotCirclePainter(radius: 5, color: spot.x.round() == maxI ? casePalette[2] : casePalette[1], strokeWidth: 0),
              ),
            ),
          ],
          titlesData: _titles(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    ),
    Text('mín. ${items[minI].label}: ${items[minI].value} · máx. ${items[maxI].label}: ${items[maxI].value}', style: const TextStyle(fontSize: 10)),
  ]);
}

Widget _invertedOpposed(CaseData d) {
  final ranked = d.g.rankedTitles.take(10).toList();
  if (ranked.length < 2) return const TechnicalIssue('AniList no devolvió rankings para esta muestra.');
  return _lineChartInverted(ranked);
}

Widget _lineChartInverted(List<GAnime> ranked) => LineChart(
      LineChartData(
        lineBarsData: [
          _line([for (var i = 0; i < ranked.length; i++) FlSpot(i.toDouble(), -ranked[i].rank!.toDouble())], casePalette[4], dots: true),
        ],
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(
          right: _axis((v) => '#${(-v).toStringAsFixed(0)}', reserved: 38),
          top: _axis(_at([for (final a in ranked) shortLabel(a.title, 6)], every: 2), reserved: 22, interval: 1),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Composiciones con estado
// ---------------------------------------------------------------------------

/// Barras radiales: un anillo (PieChart) por elemento, apilados en un Stack.
class _RadialBars extends StatefulWidget {
  const _RadialBars({required this.items, this.explodable = false});
  final List<GCategory> items;
  final bool explodable;

  @override
  State<_RadialBars> createState() => _RadialBarsState();
}

class _RadialBarsState extends State<_RadialBars> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final track = Theme.of(context).colorScheme.outlineVariant.withAlpha(90);
    return Column(children: [
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final size = math.min(box.maxWidth, box.maxHeight);
          final ring = size / 2 / (items.length + 1.5);
          return Center(
            child: SizedBox.square(
              dimension: size,
              child: Stack(children: [
                for (var i = 0; i < items.length; i++)
                  Positioned.fill(
                    child: PieChart(
                      PieChartData(
                        startDegreeOffset: 270,
                        sectionsSpace: 0,
                        centerSpaceRadius: size / 2 - (i + 1) * ring,
                        pieTouchData: PieTouchData(enabled: false),
                        sections: [
                          PieChartSectionData(
                            value: items[i].value.toDouble(),
                            color: casePalette[i].withAlpha(_selected == null || _selected == i ? 255 : 70),
                            radius: ring * (_selected == i ? 1.0 : 0.72),
                            showTitle: false,
                          ),
                          PieChartSectionData(value: (100 - items[i].value).toDouble(), color: track, radius: ring * 0.72, showTitle: false),
                        ],
                      ),
                      duration: const Duration(milliseconds: 250),
                    ),
                  ),
              ]),
            ),
          );
        }),
      ),
      if (widget.explodable)
        Wrap(spacing: 4, children: [
          for (var i = 0; i < items.length; i++)
            ChoiceChip(
              label: Text('${items[i].label} ${items[i].value}', style: const TextStyle(fontSize: 9)),
              selected: _selected == i,
              onSelected: (s) => setState(() => _selected = s ? i : null),
            ),
        ])
      else
        SimpleLegend(labels: [for (final c in items) '${c.label} ${c.value}'], colors: casePalette),
    ]);
  }
}

class _RangeFilter extends StatefulWidget {
  const _RangeFilter({required this.items});
  final List<GCategory> items;

  @override
  State<_RangeFilter> createState() => _RangeFilterState();
}

class _RangeFilterState extends State<_RangeFilter> {
  late RangeValues _range = RangeValues(0, math.max(0, widget.items.length - 1).toDouble());

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.length < 2) return const TechnicalIssue('Pocos años en la muestra para filtrar.');
    final from = _range.start.round(), to = _range.end.round();
    final selected = items.sublist(from, to + 1);
    return Column(children: [
      SizedBox(
        height: 50,
        child: _lineChart(
          [_line(_spots(items), casePalette[9], area: true, width: 1.5)],
          touch: false,
          ranges: RangeAnnotations(verticalRangeAnnotations: [
            VerticalRangeAnnotation(x1: from.toDouble(), x2: to.toDouble(), color: casePalette[0].withAlpha(60)),
          ]),
        ),
      ),
      RangeSlider(
        values: _range,
        min: 0,
        max: (items.length - 1).toDouble(),
        divisions: items.length - 1,
        labels: RangeLabels(items[from].label, items[to].label),
        onChanged: (r) => setState(() => _range = r),
      ),
      Expanded(child: _plainBars(selected)),
    ]);
  }
}

class _WidgetTooltip extends StatefulWidget {
  const _WidgetTooltip({required this.items});
  final List<GAnime> items;

  @override
  State<_WidgetTooltip> createState() => _WidgetTooltipState();
}

class _WidgetTooltipState extends State<_WidgetTooltip> {
  int? _index;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final a = _index == null ? null : items[_index!];
    return Stack(children: [
      _barChart(
        [for (var i = 0; i < items.length; i++) _group(i, [BarChartRodData(toY: items[i].popularity.toDouble(), width: 14, color: casePalette[i == _index ? 3 : 0])])],
        labels: [for (final t in items) shortLabel(t.title, 6)],
        minY: 0,
        touch: BarTouchData(
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            final i = response?.spot?.touchedBarGroupIndex;
            if (event.isInterestedForInteractions && i != null && i != _index) setState(() => _index = i);
          },
        ),
      ),
      Positioned(
        right: 4,
        top: 0,
        width: 150,
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: a == null
                ? const Text('Toca una barra', style: TextStyle(fontSize: 10))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(a.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2),
                    Text('popularity: ${a.popularity}', style: const TextStyle(fontSize: 10)),
                    Text('score: ${a.score ?? '–'} · ${a.format}', style: const TextStyle(fontSize: 10)),
                    if (a.episodes != null) Text('episodios: ${a.episodes}', style: const TextStyle(fontSize: 10)),
                  ]),
          ),
        ),
      ),
    ]);
  }
}

class _Staggered extends StatefulWidget {
  const _Staggered({required this.items});
  final List<GAnime> items;

  @override
  State<_Staggered> createState() => _StaggeredState();
}

class _StaggeredState extends State<_Staggered> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final maxY = items.map((a) => a.popularity.toDouble()).fold<double>(1, math.max);
    return Column(children: [
      Expanded(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: _titles(left: _axis(_numShort, reserved: 38), bottom: _axis(_at([for (final a in items) shortLabel(a.title, 6)], every: 2), reserved: 22)),
              barGroups: [
                for (var i = 0; i < items.length; i++)
                  _group(i, [
                    BarChartRodData(
                      toY: items[i].popularity *
                          Curves.easeOutBack.transform(
                              Interval(i / (items.length + 4), (i + 5) / (items.length + 4)).transform(_controller.value).clamp(0.0, 1.0)),
                      width: 14,
                      color: casePalette[i % casePalette.length],
                    ),
                  ]),
              ],
            ),
            duration: Duration.zero,
          ),
        ),
      ),
      TextButton(onPressed: () => _controller.forward(from: 0), child: const Text('Repetir animación')),
    ]);
  }
}
