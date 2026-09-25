// Registry central de las 63 gráficas de Graphic.
//
// Una sola fuente de verdad para: número, nombre, clasificación auditada
// (36 / 18 / 9), origen de datos, construcción y builder.
//
//   getGraphicChart(n)   → especificación del caso n (1..63)
//   graphicChartRegistry → lista completa (debe tener 63 elementos)

import 'package:flutter/widgets.dart';

import 'charts/graphic_axes_style_charts.dart';
import 'charts/graphic_bar_charts.dart';
import 'charts/graphic_financial_stat_charts.dart';
import 'charts/graphic_interactive_charts.dart';
import 'charts/graphic_line_area_charts.dart';
import 'charts/graphic_polar_charts.dart';
import 'charts/graphic_scatter_charts.dart';
import 'common/graphic_common.dart';
import 'data/graphic_dataset.dart';

typedef GraphicChartBuilder = Widget Function(GraphicDataset data);

class GraphicChartSpec {
  const GraphicChartSpec({
    required this.number,
    required this.name,
    required this.classification,
    required this.construction,
    required this.builder,
    GraphicDataOrigin? origin,
    GraphicDataOrigin Function(GraphicDataset)? originOf,
  })  : _origin = origin,
        _originOf = originOf,
        assert(origin != null || originOf != null);

  final int number;
  final String name;
  final GraphicClassification classification;
  final String construction;
  final GraphicChartBuilder builder;

  final GraphicDataOrigin? _origin;
  final GraphicDataOrigin Function(GraphicDataset)? _originOf;

  /// Origen de datos. Para 41-44 depende de si existe Media.trends.
  GraphicDataOrigin originFor(GraphicDataset d) => _originOf?.call(d) ?? _origin!;
}

const _n = GraphicClassification.nativo;
const _v = GraphicClassification.variante;
const _c = GraphicClassification.composicion;
const _dir = GraphicDataOrigin.directo;
const _der = GraphicDataOrigin.derivado;
const _nd = GraphicDataOrigin.noDisponible;

GraphicDataOrigin _trendsOrigin(GraphicDataset d) => d.hasTrends ? _der : _nd;

final List<GraphicChartSpec> graphicChartRegistry = [
  // ------------------------------- BÁSICOS 1-31 -------------------------------
  GraphicChartSpec(number: 1, name: 'Línea Simple', classification: _n, origin: _der,
      construction: 'LineMark', builder: g01LineSimple),
  GraphicChartSpec(number: 2, name: 'Columna Vertical', classification: _n, origin: _dir,
      construction: 'IntervalMark + RectShape', builder: g02Column),
  GraphicChartSpec(number: 3, name: 'Barra Horizontal', classification: _n, origin: _dir,
      construction: 'IntervalMark + RectCoord(transposed)', builder: g03HorizontalBar),
  GraphicChartSpec(number: 4, name: 'Línea Curva / Spline', classification: _n, origin: _der,
      construction: 'LineMark + BasicLineShape(smooth)', builder: g04Spline),
  GraphicChartSpec(number: 5, name: 'Área', classification: _n, origin: _der,
      construction: 'AreaMark (+ LineMark borde)', builder: g05Area),
  GraphicChartSpec(number: 6, name: 'Spline Area', classification: _n, origin: _der,
      construction: 'AreaMark + BasicAreaShape(smooth)', builder: g06SplineArea),
  GraphicChartSpec(number: 7, name: 'Pie', classification: _n, origin: _der,
      construction: 'IntervalMark + Proportion + StackModifier + PolarCoord(transposed, dimCount 1)',
      builder: g07Pie),
  GraphicChartSpec(number: 8, name: 'Doughnut', classification: _n, origin: _der,
      construction: 'Pie + PolarCoord(startRadius)', builder: g08Doughnut),
  GraphicChartSpec(number: 9, name: 'Radial Bar', classification: _n, origin: _dir,
      construction: 'IntervalMark + PolarCoord(transposed)', builder: g09RadialBar),
  GraphicChartSpec(number: 10, name: 'Scatter', classification: _n, origin: _dir,
      construction: 'PointMark', builder: g10Scatter),
  GraphicChartSpec(number: 11, name: 'Bubble', classification: _n, origin: _dir,
      construction: 'PointMark + SizeEncode(variable)', builder: g11Bubble),
  GraphicChartSpec(number: 12, name: 'Step Line', classification: _n, origin: _der,
      construction: 'LineMark + BasicLineShape(stepped)', builder: g12StepLine),
  GraphicChartSpec(number: 13, name: 'Step Area', classification: _n, origin: _der,
      construction: 'AreaMark + BasicAreaShape(stepped)', builder: g13StepArea),
  GraphicChartSpec(number: 14, name: 'Pyramid', classification: _n, origin: _der,
      construction: 'IntervalMark + FunnelShape(pyramid) + SymmetricModifier', builder: g14Pyramid),
  GraphicChartSpec(number: 15, name: 'Funnel', classification: _n, origin: _der,
      construction: 'IntervalMark + FunnelShape + SymmetricModifier', builder: g15Funnel),
  GraphicChartSpec(number: 16, name: 'Histogram', classification: _v, origin: _der,
      construction: 'Bins externos + IntervalMark + RectShape(histogram)', builder: g16Histogram),
  GraphicChartSpec(number: 17, name: 'Stacked Column', classification: _n, origin: _der,
      construction: 'IntervalMark + StackModifier', builder: g17StackedColumn),
  GraphicChartSpec(number: 18, name: 'Stacked Bar', classification: _n, origin: _der,
      construction: 'IntervalMark + StackModifier + transposed', builder: g18StackedBar),
  GraphicChartSpec(number: 19, name: 'Stacked Area', classification: _n, origin: _der,
      construction: 'AreaMark + StackModifier', builder: g19StackedArea),
  GraphicChartSpec(number: 20, name: 'Stacked Line', classification: _n, origin: _der,
      construction: 'LineMark + StackModifier', builder: g20StackedLine),
  GraphicChartSpec(number: 21, name: '100% Stacked Column', classification: _n, origin: _der,
      construction: 'Proportion(nest) + StackModifier + IntervalMark', builder: g21Stacked100Column),
  GraphicChartSpec(number: 22, name: '100% Stacked Bar', classification: _n, origin: _der,
      construction: 'Proportion(nest) + StackModifier + transposed', builder: g22Stacked100Bar),
  GraphicChartSpec(number: 23, name: '100% Stacked Area', classification: _n, origin: _der,
      construction: 'Proportion(nest) + StackModifier + AreaMark', builder: g23Stacked100Area),
  GraphicChartSpec(number: 24, name: '100% Stacked Line', classification: _n, origin: _der,
      construction: 'Proportion(nest) + StackModifier + LineMark', builder: g24Stacked100Line),
  GraphicChartSpec(number: 25, name: 'Range Column', classification: _n, origin: _dir,
      construction: 'IntervalMark [start, end]', builder: g25RangeColumn),
  GraphicChartSpec(number: 26, name: 'Range Area', classification: _n, origin: _der,
      construction: 'AreaMark [start, end]', builder: g26RangeArea),
  GraphicChartSpec(number: 27, name: 'Spline Range Area', classification: _n, origin: _der,
      construction: 'AreaMark [start, end] + BasicAreaShape(smooth)', builder: g27SplineRangeArea),
  GraphicChartSpec(number: 28, name: 'Waterfall', classification: _v, origin: _der,
      construction: 'Acumulados externos + IntervalMark [from, to]', builder: g28Waterfall),
  GraphicChartSpec(number: 29, name: 'Line with markers', classification: _n, origin: _der,
      construction: 'LineMark + PointMark', builder: g29LineWithMarkers),
  GraphicChartSpec(number: 30, name: 'Diverging Bar', classification: _v, origin: _der,
      construction: 'Desviación externa + IntervalMark + transposed + LineAnnotation', builder: g30DivergingBar),
  GraphicChartSpec(number: 31, name: 'Sparkline Line', classification: _v, origin: _der,
      construction: 'LineMark sin ejes ni padding', builder: g31SparklineLine),

  // ------------------------------ AVANZADOS 32-63 ------------------------------
  GraphicChartSpec(number: 32, name: 'Candlestick', classification: _n, origin: _nd,
      construction: 'CustomMark + CandlestickShape', builder: g32Candlestick),
  GraphicChartSpec(number: 33, name: 'HLOC', classification: _c, origin: _nd,
      construction: 'CustomMark + HlocShape (Shape propio)', builder: g33Hloc),
  GraphicChartSpec(number: 34, name: 'Box and Whisker', classification: _c, origin: _der,
      construction: 'Cuartiles externos + CustomMark + BoxPlotShape (Shape propio)', builder: g34BoxPlot),
  GraphicChartSpec(number: 35, name: 'Error Bars', classification: _c, origin: _der,
      construction: 'Media ± σ externas + CustomMark + ErrorBarShape (Shape propio)', builder: g35ErrorBars),
  GraphicChartSpec(number: 36, name: 'Combined Column + Line', classification: _n, origin: _der,
      construction: 'IntervalMark + LineMark en un Chart', builder: g36CombinedColumnLine),
  GraphicChartSpec(number: 37, name: 'Dual Y Axis', classification: _n, origin: _dir,
      construction: 'AxisGuide(variable, position: 1, flip)', builder: g37DualYAxis),
  GraphicChartSpec(number: 38, name: 'Pan & Zoom', classification: _n, origin: _dir,
      construction: 'RectCoord(horizontalRangeUpdater: Defaults.horizontalRangeEvent)', builder: g38PanZoom),
  GraphicChartSpec(number: 39, name: 'Crosshair', classification: _n, origin: _dir,
      construction: 'PointSelection + CrosshairGuide', builder: g39Crosshair),
  GraphicChartSpec(number: 40, name: 'Trackball', classification: _v, origin: _der,
      construction: 'PointSelection(dim x) + TooltipGuide(multiTuples) + CrosshairGuide + updaters',
      builder: g40Trackball),
  GraphicChartSpec(number: 41, name: 'SMA', classification: _v, originOf: _trendsOrigin,
      construction: 'SMA externa + LineMark por serie', builder: g41Sma),
  GraphicChartSpec(number: 42, name: 'Bollinger Bands', classification: _v, originOf: _trendsOrigin,
      construction: 'Bandas externas + AreaMark [lower, upper] + LineMark', builder: g42Bollinger),
  GraphicChartSpec(number: 43, name: 'RSI', classification: _v, originOf: _trendsOrigin,
      construction: 'RSI externo + LineMark + RegionAnnotation + gestureStream compartido',
      builder: (d) => G43Rsi(d)),
  GraphicChartSpec(number: 44, name: 'MACD', classification: _v, originOf: _trendsOrigin,
      construction: 'MACD externo + IntervalMark + LineMark', builder: g44Macd),
  GraphicChartSpec(number: 45, name: 'Trendline Regression', classification: _v, origin: _der,
      construction: 'Regresión externa + PointMark + LineMark', builder: g45Trendline),
  GraphicChartSpec(number: 46, name: 'Plot Bands / Strip Lines', classification: _n, origin: _dir,
      construction: 'RegionAnnotation + LineAnnotation + TagAnnotation', builder: g46PlotBands),
  GraphicChartSpec(number: 47, name: 'Cartesian Widget Annotations', classification: _c, origin: _dir,
      construction: 'TagAnnotation (canvas) + Stack/Positioned con widget Flutter', builder: g47WidgetAnnotations),
  GraphicChartSpec(number: 48, name: 'Multi-colored Line', classification: _v, origin: _der,
      construction: 'LineMark + GradientEncode con cortes duros', builder: g48MultiColoredLine),
  GraphicChartSpec(number: 49, name: 'Palette Gradient Series', classification: _n, origin: _dir,
      construction: 'IntervalMark + GradientEncode', builder: g49PaletteGradient),
  GraphicChartSpec(number: 50, name: 'Break / Gapless DateTime Axis', classification: _v, origin: _dir,
      construction: 'TimeScale vs OrdinalScale (sin axis break)', builder: g50GaplessAxis),
  GraphicChartSpec(number: 51, name: 'Logarithmic Scale', classification: _v, origin: _dir,
      construction: 'log10 en Variable + LinearScale(ticks, formatter)', builder: g51LogScale),
  GraphicChartSpec(number: 52, name: 'Infinite Scrolling / Lazy Loading', classification: _c, origin: _dir,
      construction: 'EventUpdater propio + carga de páginas + nueva lista', builder: (d) => G52InfiniteScroll(d)),
  GraphicChartSpec(number: 53, name: 'Shaded Doughnut', classification: _v, origin: _der,
      construction: 'Doughnut + GradientEncode(SweepGradient) + ElevationEncode', builder: g53ShadedDoughnut),
  GraphicChartSpec(number: 54, name: 'Semi-Doughnut Progress', classification: _v, origin: _dir,
      construction: 'IntervalMark + PolarCoord(startAngle π, endAngle 2π)', builder: g54SemiDoughnutProgress),
  GraphicChartSpec(number: 55, name: 'Range Selection Data Filter', classification: _c, origin: _dir,
      construction: 'IntervalSelection + selectionStream + estado Flutter + filtrado',
      builder: (d) => G55RangeSelectionFilter(d)),
  GraphicChartSpec(number: 56, name: 'Exploding Radial Bar', classification: _c, origin: _dir,
      construction: 'PointSelection + ElevationEncode.updaters + ExplodedRectShape (Shape propio)',
      builder: g56ExplodingRadialBar),
  GraphicChartSpec(number: 57, name: 'Sparkline Win-Loss', classification: _v, origin: _der,
      construction: '±1 externo + IntervalMark sin ejes', builder: g57SparklineWinLoss),
  GraphicChartSpec(number: 58, name: 'Sparkline Area with Min/Max', classification: _v, origin: _der,
      construction: 'AreaMark + PointMark(SizeEncode encoder en extremos)', builder: g58SparklineMinMax),
  GraphicChartSpec(number: 59, name: 'Multi-shape Categorical Scatter', classification: _n, origin: _dir,
      construction: 'PointMark + ShapeEncode(variable)', builder: g59MultiShapeScatter),
  GraphicChartSpec(number: 60, name: 'Fully Customized Widget Tooltip', classification: _c, origin: _dir,
      construction: 'selectionStream + gestureStream + Card en Stack', builder: (d) => G60WidgetTooltip(d)),
  GraphicChartSpec(number: 61, name: 'Staggered Animation', classification: _c, origin: _dir,
      construction: 'Mark.transition con curvas Interval por marca + recreación por Key',
      builder: (d) => G61StaggeredAnimation(d)),
  GraphicChartSpec(number: 62, name: 'Inverted / Opposed Axis', classification: _v, origin: _dir,
      construction: 'RectCoord(verticalRange: [1, 0]) + AxisGuide(position: 1, flip)',
      builder: g62InvertedOpposedAxis),
  GraphicChartSpec(number: 63, name: 'Real-time Streaming', classification: _n, origin: _der,
      construction: 'Chart.changeDataStream + ChangeDataEvent + Mark.transition',
      builder: (d) => G63RealTimeStreaming(d)),
];

/// Especificación del caso [number] (1..63).
GraphicChartSpec getGraphicChart(int number) {
  assert(graphicChartRegistry.length == 63, 'El registry debe tener 63 casos');
  return graphicChartRegistry.firstWhere(
    (s) => s.number == number,
    orElse: () => throw ArgumentError.value(number, 'number', 'Debe estar entre 1 y 63'),
  );
}
