// Los 63 casos maestros dibujados con d_chart 3.0.0.
//
// d_chart solo ofrece barras, líneas, dispersión, pie y combinados (con
// dominio Ordinal, Numérico o de Tiempo). Todo lo demás se construye con esos
// componentes: rangos con `measureOffset`, velas y cajas superponiendo dos o
// tres DChartBarO con el mismo viewport, anillos radiales con DChartPieO
// concéntricos, etc. Cada caso declara si es NATIVO, VARIANTE, COMPOSICIÓN o
// ADAPTACIÓN; no se afirma que d_chart tenga widgets que no existen.

import 'dart:math' as math;

import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/common/live_case_hosts.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_view_models.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';

const _n = ImplementationStrategy.nativo;
const _v = ImplementationStrategy.variante;
const _c = ImplementationStrategy.composicion;
const _a = ImplementationStrategy.adaptacion;

CaseImpl _impl(int n, ImplementationStrategy s, String api, CaseBuilder b, {String? note}) =>
    CaseImpl(strategy: s, origin: sharedCaseOrigins[n]!, api: api, builder: b, note: note);

/// Los 63 casos de d_chart.
final Map<int, CaseImpl> dChartCases = {
  1: _impl(1, _n, 'DChartLineN + NumericGroup', (_, d) => _line([_yearGroup('Score medio', d.g.scoreByYear)], zeroBound: false)),
  2: _impl(2, _n, 'DChartBarO (arrangeVertically: false)', (_, d) => _bars([_og('popularity', _topPopularity(d))], rotation: 45)),
  3: _impl(3, _n, 'DChartBarO (arrangeVertically: true)', (_, d) => _bars([_og('score', _topScore(d, 10))], horizontal: true)),
  4: _impl(4, _a, 'DChartLineN sobre puntos interpolados (Catmull-Rom)', (_, d) => _line([
        _numGroup('Curva', _catmull(_yearPoints(d.g.scoreByYear))),
        _numGroup('Datos', _yearPoints(d.g.scoreByYear)),
      ], points: true, pointsOnlyFor: 'Datos', zeroBound: false),
      note: 'd_chart no suaviza líneas: la curva interpola (Catmull-Rom) los puntos reales, que se marcan encima.'),
  5: _impl(5, _v, 'DChartLineN + includeArea', (_, d) => _line([_yearGroup('Obras', d.g.countByYear)], area: true)),
  6: _impl(6, _a, 'DChartLineN + includeArea sobre puntos interpolados', (_, d) => _line([_numGroup('Obras', _catmull(_yearPoints(d.g.countByYear)))], area: true),
      note: 'Curva por interpolación Catmull-Rom de los conteos reales por año.'),
  7: _impl(7, _n, 'DChartPieO', (_, d) => _pie(d.g.countByFormat)),
  8: _impl(8, _n, 'DChartPieO + ConfigSeriesPieO(arcWidth)', (_, d) => _pie(d.g.countByStatus, arcWidth: 34)),
  9: _impl(9, _c, 'DChartPieO concéntricos en Stack', (_, d) => _DcRadial(items: _topScore(d, 5))),
  10: _impl(10, _n, 'DChartScatterN', (_, d) => _scatter(d)),
  11: _impl(11, _v, 'DChartScatterN + radiusPx por punto', (_, d) {
        final maxEp = d.g.titles.map((a) => a.episodes ?? 0).fold<int>(1, math.max);
        return _scatter(d, where: (a) => a.episodes != null, radius: (a) => 3 + 12 * math.sqrt((a.episodes ?? 0) / maxEp));
      }, note: 'Tamaño = episodes (anime) o chapters (manga).'),
  12: _impl(12, _v, 'DChartLineN con puntos duplicados en escalón', (_, d) => _line([_numGroup('Acumulado', _steps(_yearPoints(d.g.cumulativeByYear)))])),
  13: _impl(13, _v, 'DChartLineN escalonado + includeArea', (_, d) => _line([_numGroup('Acumulado', _steps(_yearPoints(d.g.cumulativeByYear)))], area: true)),
  14: _impl(14, _a, 'DChartBarO horizontal + measureOffset (barras centradas)', (_, d) {
        final items = [...d.g.countByFormat]..sort((a, b) => a.value.compareTo(b.value));
        return _centered(items);
      }, note: 'd_chart no tiene Pyramid: barras centradas con measureOffset.'),
  15: _impl(15, _a, 'DChartBarO horizontal + measureOffset (barras centradas)', (_, d) => _centered(d.g.countByStatus),
      note: 'd_chart no tiene Funnel: barras centradas con measureOffset.'),
  16: _impl(16, _v, 'DChartBarO sobre bins externos', (_, d) => _bars([_og('Obras', d.g.scoreBins)], rotation: 45)),
  17: _impl(17, _n, 'DChartBarO + BarGroupingType.stacked', (_, d) => _bars(_seriesGroups(d.g.yearFormatSeries), stacked: true, legend: true)),
  18: _impl(18, _n, 'BarGroupingType.stacked + arrangeVertically', (_, d) => _bars(_seriesGroups(d.g.genreStatusSeries), stacked: true, horizontal: true, legend: true)),
  19: _impl(19, _n, 'DChartLineN + ConfigSeriesLineN(stacked, includeArea)', (_, d) => _line(_seriesYearGroups(d.g.yearFormatSeries), area: true, stacked: true, legend: true)),
  20: _impl(20, _n, 'DChartLineN + ConfigSeriesLineN(stacked)', (_, d) => _line(_seriesYearGroups(d.g.yearFormatSeries), stacked: true, points: true, legend: true)),
  21: _impl(21, _v, 'stacked sobre valores normalizados a 100 %', (_, d) => _bars(_seriesGroups(toPercent(d.g.yearFormatSeries)), stacked: true, legend: true, max: 100)),
  22: _impl(22, _v, 'stacked + arrangeVertically sobre valores normalizados', (_, d) => _bars(_seriesGroups(toPercent(d.g.genreStatusSeries)), stacked: true, horizontal: true, legend: true, max: 100)),
  23: _impl(23, _v, 'stacked + includeArea sobre valores normalizados', (_, d) => _line(_seriesYearGroups(toPercent(d.g.yearFormatSeries)), area: true, stacked: true, legend: true)),
  24: _impl(24, _v, 'stacked sobre valores normalizados', (_, d) => _line(_seriesYearGroups(toPercent(d.g.yearFormatSeries)), stacked: true, points: true, legend: true)),
  25: _impl(25, _v, 'DChartBarO + measureOffset (inicio de la barra)', (_, d) => _rangeBars(d.g.airingRanges)),
  26: _impl(26, _v, 'DChartLineN apilado: base transparente + banda', (_, d) => _rangeArea(_yearRanges(d.g.scoreRangeByYear))),
  27: _impl(27, _a, 'Banda apilada sobre puntos interpolados', (_, d) {
        final r = _yearRanges(d.g.scoreRangeByYear);
        return _rangeArea((low: _catmull(r.low), high: _catmull(r.high)));
      }, note: 'Bordes suavizados por interpolación Catmull-Rom de los mínimos y máximos reales.'),
  28: _impl(28, _v, 'DChartBarO + measureOffset (cascada)', (_, d) => _waterfall(d.g.waterfallSteps)),
  29: _impl(29, _n, 'ConfigSeriesLineN(includePoints)', (_, d) => _line([_yearGroup('Score medio', d.g.scoreByYear)], points: true, zeroBound: false)),
  30: _impl(30, _n, 'DChartBarO con medidas negativas + customColor', (_, d) => _bars([_og('desviación', d.g.genreDeviation)],
      horizontal: true, color: (c, _) => c.value >= 0 ? casePalette[2] : casePalette[1])),
  31: _impl(31, _v, 'DChartLineN con ejes noRenderSpec', (_, d) => _line([_yearGroup('Obras', d.g.countByYear)], hideAxes: true, area: true)),
  32: _impl(32, _a, 'Dos DChartBarO superpuestos (mecha y cuerpo) con measureOffset', (_, d) => withTrends(d, () => _candles(d.g.trendOhlc)), note: ohlcNote),
  33: _impl(33, _a, 'DChartComboO: barra high-low (measureOffset) + marcadores open/close', (_, d) => withTrends(d, () => _hloc(d.g.trendOhlc)), note: hlocNote),
  34: _impl(34, _c, 'Tres DChartBarO superpuestos (bigote, caja, mediana)', (_, d) => _boxPlot(d.g.boxByFormat),
      note: 'd_chart no tiene Box Plot: se superponen tres DChartBarO con el mismo viewport.'),
  35: _impl(35, _c, 'Dos DChartBarO superpuestos (media y rango ±σ)', (_, d) => _errorBars(d.g.errorByGenre)),
  36: _impl(36, _n, 'DChartComboO (bar + line) + secondaryMeasureAxis', (_, d) => _combo(
        [_og('Obras', d.g.countByYear), _og('Score medio', d.g.scoreByYear)],
        render: (g) => g.id == 'Obras' ? RenderType.bar : RenderType.line,
        secondary: (g) => g.id == 'Score medio',
      )),
  37: _impl(37, _n, 'DChartComboO (dos líneas) + secondaryMeasureAxis', (_, d) => _combo(
        [
          _og('popularity', _topPopularity(d)),
          _og('averageScore', [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 8), a.score ?? 0)]),
        ],
        render: (_) => RenderType.line,
        secondary: (g) => g.id == 'averageScore',
        rotation: 45,
      )),
  38: _impl(38, _n, 'DChartBarO(allowSliding) + OrdinalViewport', (_, d) {
        final items = [...d.g.datedTitles]..sort((a, b) => a.date.compareTo(b.date));
        final data = [for (var i = 0; i < items.length; i++) GCategory('${items[i].date.year}·$i', items[i].value)];
        return _bars([_og('popularity', data)], rotation: 60, sliding: true, viewport: data.isEmpty ? null : OrdinalViewport(startingDomain: data.first.label, dataSize: 12));
      }, note: 'Arrastra o pellizca horizontalmente (SlidingViewport + PanAndZoomBehavior).'),
  39: _impl(39, _c, 'DChartLineN + onChangedListener + grupos de guía', (_, d) => _DcCrosshair(items: _yearPoints(d.g.scoreByYear))),
  40: _impl(40, _c, 'DChartLineN multiserie + onChangedListener + panel', (_, d) => _DcTrackball(points: d.g.yearFormatSeries)),
  41: _impl(41, _v, 'DChartLineT + TimeGroup (serie y SMA)', (_, d) => withTrends(d, () => _timeLines([
        _tg('Variación diaria', [for (final p in d.g.trendSma) if (p.series == 'Variación diaria') GCategory(p.x, p.value)]),
        _tg('SMA 7', [for (final p in d.g.trendSma) if (p.series != 'Variación diaria') GCategory(p.x, p.value)]),
      ])), note: trendsIndicatorNote),
  42: _impl(42, _v, 'DChartLineT con banda media ± 2σ', (_, d) => withTrends(d, () {
        final p = d.g.bollingerPoints;
        return _timeLines([
          _tg('Inferior', [for (final b in p) GCategory(b.label, b.lower)]),
          _tg('Media 20', [for (final b in p) GCategory(b.label, b.mid)]),
          _tg('Superior', [for (final b in p) GCategory(b.label, b.upper)]),
          _tg('Variación diaria', [for (final b in p) GCategory(b.label, b.value)]),
        ], dashed: {'Inferior', 'Superior'});
      }), note: trendsIndicatorNote),
  43: _impl(43, _v, 'DChartLineT + líneas de referencia 70/30', (_, d) => withTrends(d, () {
        final r = d.g.rsiPoints;
        return _timeLines([
          _tg('RSI 14', r),
          _tg('70', [for (final c in r) GCategory(c.label, 70)]),
          _tg('30', [for (final c in r) GCategory(c.label, 30)]),
        ], dashed: {'70', '30'}, min: 0, max: 100);
      }), note: trendsIndicatorNote),
  44: _impl(44, _v, 'DChartComboT (histograma bar + MACD y señal line)', (_, d) => withTrends(d, () => _macd(d.g.macdPoints)), note: trendsIndicatorNote),
  45: _impl(45, _v, 'DChartComboN (scatterPlot + line de regresión)', (_, d) => _trend(d.g.regression)),
  46: _impl(46, _v, 'DChartComboO: barras + líneas de referencia (strip lines)', (_, d) {
        final items = [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 8), a.score ?? 0)];
        return _combo(
          [
            _og('score', items),
            _og('Umbral 80', [for (final c in items) GCategory(c.label, 80)]),
            _og('Media', [for (final c in items) GCategory(c.label, d.g.globalMeanScore)]),
            _og('Umbral 60', [for (final c in items) GCategory(c.label, 60)]),
          ],
          render: (g) => g.id == 'score' ? RenderType.bar : RenderType.line,
          rotation: 45,
          max: 100,
        );
      }, note: 'd_chart no sombrea regiones: las bandas se marcan con sus líneas límite (80 y 60) y la media.'),
  47: _impl(47, _c, 'DChartBarO + widget Flutter posicionado en Stack', (_, d) => _widgetAnnotation(d)),
  48: _impl(48, _n, 'ConfigSeriesLineN.customColor por punto', (_, d) => _line(
        [_yearGroup('Score medio', d.g.scoreByYear)],
        points: true,
        zeroBound: false,
        pointColor: (y) => y >= d.g.globalMeanScore ? casePalette[2] : casePalette[1],
      )),
  49: _impl(49, _n, 'ConfigSeriesBarO.fillGradient', (_, d) => _bars([_og('score', _topScore(d, 10))], rotation: 45, max: 100,
      gradient: const LinearGradient(colors: [Color(0xFF26C6DA), Color(0xFF7E57C2)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
  50: _impl(50, _v, 'DChartComboO: dominio ordinal de años (sin huecos)', (_, d) => _gapless(d.g.countByYear),
      note: 'Eje sin huecos (gapless). d_chart no dibuja la marca de ruptura de eje.'),
  51: _impl(51, _v, 'log10 externo + MeasureAxis.tickLabelFormatter', (_, d) => _bars(
        [_og('log10(popularity)', [for (final a in spreadByPopularity(d.g)) GCategory(shortLabel(a.title, 8), math.log(math.max(1, a.popularity)) / math.ln10)])],
        rotation: 45,
        format: (v) => v == null ? '' : '10^${v.toStringAsFixed(1)}',
      )),
  52: _impl(52, _c, 'DChartBarO + ScrollController + paginación AniList', (_, d) => LazyLoadingHost(
        chartBuilder: (items) => _bars([_og('popularity', [for (final m in items) GCategory('${shortLabel(m.title, 6)}·${m.id}', m.popularity ?? 0)])], rotation: 60))),
  53: _impl(53, _n, 'DChartPieO + ConfigSeriesPieO.fillGradient', (_, d) => _pie(d.g.countByFormat, arcWidth: 40, shaded: true)),
  54: _impl(54, _v, 'DChartPieO(startAngle π, arcLength π) + Stack', (_, d) => _semiDonut(d)),
  55: _impl(55, _c, 'RangeSlider (Flutter) + DChartBarO filtrado', (_, d) => _DcRangeFilter(items: d.g.countByYear)),
  56: _impl(56, _c, 'DChartPieO concéntricos + selección con estado', (_, d) => _DcRadial(items: _topScore(d, 5), explodable: true)),
  57: _impl(57, _v, 'DChartBarO ±1 sin ejes', (_, d) => _bars([_og('win-loss', d.g.winLossByYear)], hideAxes: true,
      color: (c, _) => c.value >= 0 ? casePalette[2] : casePalette[1])),
  58: _impl(58, _v, 'DChartLineN + includeArea + radiusPx solo en mín./máx.', (_, d) => _sparkMinMax(d.g.countByYear)),
  59: _impl(59, _c, 'Un DChartScatterN por formato (symbolRender) superpuestos', (_, d) => _multiShape(d),
      note: 'symbolRender es único por gráfico: se superpone un DChartScatterN por formato con el mismo viewport.'),
  60: _impl(60, _c, 'DChartBarO.onChangedListener + Card en Stack', (_, d) => _DcWidgetTooltip(items: d.g.topByPopularity)),
  61: _impl(61, _c, 'AnimationController + Interval por barra', (_, d) => _DcStaggered(items: _topPopularity(d))),
  62: _impl(62, _n, 'DChartLineN(flipVerticalAxis) — ranking invertido, eje X arriba', (_, d) {
        final ranked = d.g.rankedTitles.take(10).toList();
        if (ranked.length < 2) return const TechnicalIssue('AniList no devolvió rankings para esta muestra.');
        return DChartLineN(
          flipVerticalAxis: true,
          groupList: [_numGroup('ranking', [for (var i = 0; i < ranked.length; i++) (i.toDouble(), ranked[i].rank!.toDouble())])],
          domainAxis: DomainAxisN(
            labelStyle: _lbl,
            tickLabelFormatter: (v) {
              final i = v?.round() ?? -1;
              return i >= 0 && i < ranked.length && v == i ? shortLabel(ranked[i].title, 6) : '';
            },
          ),
          measureAxis: _measure(zeroBound: false, format: (v) => v == null ? '' : '#${v.round()}'),
          configSeriesLine: ConfigSeriesLineN(includePoints: true, customColor: (g, d, i) => casePalette[4]),
        );
      }),
  63: _impl(63, _c, 'Timer → GraphQL → ChangeNotifier → DChartLineN', (_, d) => LiveStreamingHost(
        chartBuilder: (samples) {
          final values = [for (final s in samples) s.totalPopularity];
          final lo = values.reduce(math.min), hi = values.reduce(math.max);
          return _line(
            [_numGroup('popularity total', [for (var i = 0; i < samples.length; i++) (i.toDouble(), samples[i].totalPopularity.toDouble())])],
            points: true,
            min: lo - 50,
            max: hi + 50,
          );
        })),
};

// ---------------------------------------------------------------------------
// Datos
// ---------------------------------------------------------------------------

List<GCategory> _topPopularity(CaseData d) =>
    [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 10), a.popularity)];

List<GCategory> _topScore(CaseData d, int n) =>
    [for (final a in d.g.topByScore.take(n)) GCategory(shortLabel(a.title, 12), a.score ?? 0)];

typedef _Pt = (double, double);

List<_Pt> _yearPoints(List<GCategory> items) => [
      for (var i = 0; i < items.length; i++) ((num.tryParse(items[i].label) ?? i).toDouble(), items[i].value.toDouble()),
    ];

({List<_Pt> low, List<_Pt> high}) _yearRanges(List<GRange> r) => (
      low: [for (var i = 0; i < r.length; i++) ((num.tryParse(r[i].x) ?? i).toDouble(), r[i].low.toDouble())],
      high: [for (var i = 0; i < r.length; i++) ((num.tryParse(r[i].x) ?? i).toDouble(), r[i].high.toDouble())],
    );

/// Interpolación Catmull-Rom uniforme entre puntos reales (no añade datos:
/// solo dibuja la curva que pasa por ellos).
List<_Pt> _catmull(List<_Pt> p, {int steps = 8}) {
  if (p.length < 3) return p;
  final out = <_Pt>[];
  for (var i = 0; i < p.length - 1; i++) {
    final p0 = p[i == 0 ? 0 : i - 1], p1 = p[i], p2 = p[i + 1], p3 = p[i + 2 < p.length ? i + 2 : i + 1];
    for (var s = 0; s < steps; s++) {
      final t = s / steps, t2 = t * t, t3 = t2 * t;
      double c(double a, double b, double c, double d) =>
          0.5 * (2 * b + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (-a + 3 * b - 3 * c + d) * t3);
      out.add((c(p0.$1, p1.$1, p2.$1, p3.$1), c(p0.$2, p1.$2, p2.$2, p3.$2)));
    }
  }
  out.add(p.last);
  return out;
}

/// Escalón: cada valor se mantiene hasta el siguiente x.
List<_Pt> _steps(List<_Pt> p) => [
      for (var i = 0; i < p.length; i++) ...[
        if (i > 0) (p[i].$1, p[i - 1].$2),
        p[i],
      ],
    ];

// ---------------------------------------------------------------------------
// Grupos y ejes
// ---------------------------------------------------------------------------

const _lbl = LabelStyle(color: Color(0xFF9E9E9E), fontSize: 9);
const _grid = LineStyle(color: Color(0x33999999));

/// Grupo ordinal. Las etiquetas repetidas (p. ej. dos títulos que se
/// abrevian igual) se numeran: un dominio ordinal duplicado rompe las líneas.
OrdinalGroup _og(String id, List<GCategory> items) {
  final seen = <String, int>{};
  return OrdinalGroup(id: id, data: [
    for (var i = 0; i < items.length; i++) OrdinalData(domain: _unique(items[i].label, seen), measure: items[i].value, others: i),
  ]);
}

String _unique(String label, Map<String, int> seen) {
  final n = seen[label] = (seen[label] ?? 0) + 1;
  return n == 1 ? label : '$label ($n)';
}

NumericGroup _numGroup(String id, List<_Pt> pts) =>
    NumericGroup(id: id, data: [for (final p in pts) NumericData(domain: p.$1, measure: p.$2)]);

NumericGroup _yearGroup(String id, List<GCategory> items) => _numGroup(id, _yearPoints(items));

TimeGroup _tg(String id, List<GCategory> items) => TimeGroup(
      id: id,
      data: [for (final c in items) if (DateTime.tryParse(c.label) != null) TimeData(domain: DateTime.parse(c.label), measure: c.value)],
    );

List<OrdinalGroup> _seriesGroups(List<GSeriesPoint> points) {
  final by = <String, List<GCategory>>{};
  for (final p in points) {
    (by[p.series] ??= []).add(GCategory(p.x, p.value));
  }
  return [for (final e in by.entries) _og(e.key, e.value)];
}

List<NumericGroup> _seriesYearGroups(List<GSeriesPoint> points) {
  final by = <String, List<GCategory>>{};
  for (final p in points) {
    (by[p.series] ??= []).add(GCategory(p.x, p.value));
  }
  return [for (final e in by.entries) _yearGroup(e.key, e.value)];
}

MeasureAxis _measure({double? min, double? max, bool hide = false, String Function(num?)? format, bool zeroBound = true}) => MeasureAxis(
      labelStyle: _lbl,
      gridlineStyle: _grid,
      noRenderSpec: hide,
      viewport: min == null || max == null ? null : NumericViewport(min: min, max: max),
      numericTickProvider: zeroBound ? null : const NumericTickProvider(zeroBound: false),
      tickLabelFormatter: format,
    );

/// Eje X numérico sin partir de 0 (los años empiezan en ~2015, no en 0).
DomainAxisN _domainN({bool hide = false}) => DomainAxisN(
      labelStyle: _lbl,
      noRenderSpec: hide,
      numericTickProvider: const NumericTickProvider(zeroBound: false),
      tickLabelFormatter: (v) => v == null ? '' : (v == v.roundToDouble() ? v.toStringAsFixed(0) : ''),
    );

DomainAxisO _domainO({int rotation = 0, bool hide = false, OrdinalViewport? viewport}) =>
    DomainAxisO(labelStyle: _lbl, labelRotation: rotation, noRenderSpec: hide, viewport: viewport);

Widget _withLegend(Widget chart, List<String> labels) => Column(children: [
      Expanded(child: chart),
      SimpleLegend(labels: labels, colors: casePalette),
    ]);

Color _seriesColor(String id, List<String> ids) => casePalette[math.max(0, ids.indexOf(id)) % casePalette.length];

// ---------------------------------------------------------------------------
// Constructores reutilizados
// ---------------------------------------------------------------------------

Widget _bars(
  List<OrdinalGroup> groups, {
  bool horizontal = false,
  bool stacked = false,
  bool legend = false,
  bool hideAxes = false,
  bool sliding = false,
  int rotation = 0,
  double? min,
  double? max,
  OrdinalViewport? viewport,
  Color Function(GCategory c, int index)? color,
  Gradient? gradient,
  String Function(num?)? format,
  num Function(int index)? offset,
  int? maxBarWidthPx,
}) {
  final ids = [for (final g in groups) g.id];
  final chart = DChartBarO(
    groupList: groups,
    arrangeVertically: horizontal,
    allowSliding: sliding,
    domainAxis: _domainO(rotation: horizontal ? 0 : rotation, hide: hideAxes, viewport: viewport),
    measureAxis: _measure(min: min ?? (max == null ? null : 0), max: max, hide: hideAxes, format: format),
    configSeriesBar: ConfigSeriesBarO(
      barGroupingType: stacked ? BarGroupingType.stacked : BarGroupingType.grouped,
      maxBarWidthPx: maxBarWidthPx,
      customColor: (g, d, i) => color != null ? color(GCategory(d.domain, d.measure ?? 0), d.others as int? ?? i ?? 0) : _seriesColor(g.id, ids),
      fillGradient: gradient == null ? null : (g, d, i) => gradient,
      fillPatternBase: gradient == null ? FillPattern.solid : FillPattern.gradient,
      measureOffset: offset == null ? null : (g, d, i) => offset(d.others as int? ?? i ?? 0),
    ),
  );
  return legend ? _withLegend(chart, ids) : chart;
}

Widget _line(
  List<NumericGroup> groups, {
  bool area = false,
  bool points = false,
  bool stacked = false,
  bool legend = false,
  bool hideAxes = false,
  bool zeroBound = true,
  String? pointsOnlyFor,
  double? min,
  double? max,
  Color Function(num y)? pointColor,
}) {
  final ids = [for (final g in groups) g.id];
  final chart = DChartLineN(
    groupList: groups,
    domainAxis: _domainN(hide: hideAxes),
    measureAxis: _measure(min: min, max: max, hide: hideAxes, zeroBound: zeroBound),
    configSeriesLine: ConfigSeriesLineN(
      includeArea: area,
      includePoints: points,
      stacked: stacked,
      areaOpacity: 0.35,
      strokeWidthPx: (g, d, i) => g.id == pointsOnlyFor ? 0 : 2.5,
      pointRadius: (g, d, i) => pointsOnlyFor == null || g.id == pointsOnlyFor ? 4 : 0,
      customColor: (g, d, i) => pointColor != null ? pointColor(d.measure ?? 0) : _seriesColor(g.id, ids),
    ),
  );
  return legend ? _withLegend(chart, ids) : chart;
}

Widget _combo(
  List<OrdinalGroup> groups, {
  required RenderType Function(OrdinalGroup g) render,
  bool Function(OrdinalGroup g)? secondary,
  int rotation = 0,
  double? max,
}) {
  final ids = [for (final g in groups) g.id];
  return _withLegend(
    DChartComboO(
      groupList: groups,
      renderType: render,
      domainAxis: _domainO(rotation: rotation),
      measureAxis: _measure(min: max == null ? null : 0, max: max),
      secondaryMeasureAxis: _measure(),
      useSecondaryMeasureAxis: secondary,
      configSeriesBar: ConfigSeriesBarO(customColor: (g, d, i) => _seriesColor(g.id, ids)),
      configSeriesLine: ConfigSeriesLineO(
        includePoints: true,
        customColor: (g, d, i) => _seriesColor(g.id, ids),
        dashPattern: (g, d, i) => g.id.startsWith('Umbral') ? [4, 4] : null,
      ),
    ),
    ids,
  );
}

Widget _timeLines(List<TimeGroup> groups, {Set<String> dashed = const {}, double? min, double? max}) {
  final ids = [for (final g in groups) g.id];
  return _withLegend(
    DChartLineT(
      groupList: groups,
      domainAxis: DomainAxisT(labelStyle: _lbl),
      measureAxis: _measure(min: min, max: max, zeroBound: false),
      configSeriesLine: ConfigSeriesLineT(
        customColor: (g, d, i) => _seriesColor(g.id, ids),
        dashPattern: (g, d, i) => dashed.contains(g.id) ? [4, 4] : null,
        strokeWidthPx: (g, d, i) => dashed.contains(g.id) ? 1 : 2,
      ),
    ),
    ids,
  );
}

Widget _pie(List<GCategory> items, {int? arcWidth, bool shaded = false}) => _withLegend(
      DChartPieO(
        data: [for (final c in items) OrdinalData(domain: c.label, measure: c.value)],
        configSeriesPie: ConfigSeriesPieO(
          arcWidth: arcWidth,
          showLabel: true,
          customColor: (g, d, i) => casePalette[(i ?? 0) % casePalette.length],
          fillGradient: shaded
              ? (g, d, i) {
                  final base = casePalette[(i ?? 0) % casePalette.length];
                  return LinearGradient(colors: [base, Color.lerp(base, Colors.black, 0.55)!]);
                }
              : null,
        ),
      ),
      [for (final c in items) c.label],
    );

Widget _scatter(CaseData d, {bool Function(GAnime a)? where, double Function(GAnime a)? radius}) {
  final items = [for (final a in scoredTitles(d.g)) if (where == null || where(a)) a];
  return DChartScatterN(
    groupList: [
      NumericGroup(id: 'obras', data: [
        for (final a in items) NumericData(domain: a.popularity, measure: a.score!, others: a),
      ]),
    ],
    domainAxis: DomainAxisN(labelStyle: _lbl, tickLabelFormatter: (v) => v == null ? '' : '${(v / 1000).round()}k'),
    measureAxis: _measure(zeroBound: false),
    configSeriesScatter: ConfigSeriesScatterN(
      customColor: (g, dt, i) => casePalette[radius == null ? 0 : 4].withAlpha(radius == null ? 255 : 150),
      pointRadius: radius == null ? null : (g, dt, i) => radius(dt.others as GAnime),
    ),
  );
}

Widget _multiShape(CaseData d) {
  final formats = d.g.formats;
  final items = [for (final a in scoredTitles(d.g)) if (formats.contains(a.format)) a];
  if (items.isEmpty) return const TechnicalIssue('Sin obras puntuadas en la muestra.');
  final xs = items.map((a) => a.popularity.toDouble());
  final ys = items.map((a) => a.score!.toDouble());
  final xMin = xs.reduce(math.min), xMax = xs.reduce(math.max), yMin = ys.reduce(math.min), yMax = ys.reduce(math.max);
  const shapes = [SymbolRenderCircle(), SymbolRenderRect(), SymbolRenderTriangle(), SymbolRenderRoundedRect(isSolid: false)];
  return _withLegend(
    Stack(children: [
      for (var i = 0; i < formats.length; i++)
        Positioned.fill(
          child: DChartScatterN(
            groupList: [
              NumericGroup(id: formats[i], data: [
                for (final a in items)
                  if (a.format == formats[i]) NumericData(domain: a.popularity, measure: a.score!),
              ]),
            ],
            domainAxis: DomainAxisN(
              labelStyle: _lbl,
              viewport: NumericViewport(min: xMin, max: xMax),
              tickLabelFormatter: (v) => v == null ? '' : '${(v / 1000).round()}k',
            ),
            measureAxis: _measure(min: yMin - 2, max: yMax + 2),
            configSeriesScatter: ConfigSeriesScatterN(
              symbolRender: shapes[i % shapes.length],
              customColor: (g, dt, j) => casePalette[i],
              pointRadius: (g, dt, j) => 5,
            ),
          ),
        ),
    ]),
    [for (var i = 0; i < formats.length; i++) '${formats[i]} (${['●', '■', '▲', '□'][i % 4]})'],
  );
}

Widget _centered(List<GCategory> items) {
  final max = items.isEmpty ? 1.0 : items.map((c) => c.value.toDouble()).reduce(math.max);
  return _withLegend(
    DChartBarO(
      groupList: [_og('obras', items)],
      arrangeVertically: true,
      domainAxis: _domainO(),
      measureAxis: _measure(min: 0, max: max, hide: true),
      configSeriesBar: ConfigSeriesBarO(
        measureOffset: (g, d, i) => (max - (d.measure ?? 0)) / 2,
        customColor: (g, d, i) => casePalette[(i ?? 0) % casePalette.length],
      ),
    ),
    [for (final c in items) '${c.label}: ${c.value}'],
  );
}

Widget _rangeBars(List<GRange> ranges) {
  if (ranges.isEmpty) return const TechnicalIssue('La muestra no tiene obras con fecha de inicio y fin.');
  final lo = ranges.map((r) => r.low.toDouble()).reduce(math.min);
  final hi = ranges.map((r) => r.high.toDouble()).reduce(math.max);
  final data = [for (final r in ranges) GCategory(shortLabel(r.x, 8), r.high - r.low + 0.3)];
  return _bars(
    [_og('emisión', data)],
    rotation: 45,
    min: lo - 1,
    max: hi + 1,
    offset: (i) => ranges[i].low,
    format: (v) => v == null ? '' : v.toStringAsFixed(0),
  );
}

Widget _rangeArea(({List<_Pt> low, List<_Pt> high}) r) {
  final band = [for (var i = 0; i < r.low.length; i++) (r.low[i].$1, r.high[i].$2 - r.low[i].$2)];
  return DChartLineN(
    groupList: [_numGroup('mínimo', r.low), _numGroup('banda', band)],
    domainAxis: _domainN(),
    measureAxis: _measure(),
    configSeriesLine: ConfigSeriesLineN(
      stacked: true,
      includeArea: true,
      areaOpacity: 0.4,
      customColor: (g, d, i) => casePalette[0],
      areaColor: (g, d, i) => g.id == 'mínimo' ? Colors.transparent : casePalette[0],
    ),
  );
}

Widget _waterfall(List<GWaterfallStep> steps) {
  final data = [for (final s in steps) GCategory(s.label, (s.to - s.from).abs())];
  return _bars(
    [_og('cascada', data)],
    rotation: 45,
    min: 0,
    max: steps.isEmpty ? 1 : steps.map((s) => math.max(s.from, s.to).toDouble()).reduce(math.max) * 1.05,
    offset: (i) => math.min(steps[i].from, steps[i].to),
    color: (c, i) {
      final s = steps[i];
      return s.isTotal ? casePalette[9] : (s.to >= s.from ? casePalette[2] : casePalette[1]);
    },
  );
}

/// Dos o más DChartBarO superpuestos que comparten dominio y viewport.
Widget _layers(List<Widget Function(bool top)> layers) => Stack(children: [
      for (var i = 0; i < layers.length; i++) Positioned.fill(child: layers[i](i == layers.length - 1)),
    ]);

Widget _rangeLayer(List<GCategory> domain, List<num> from, List<num> to, double min, double max, int width, Color Function(int i) color) =>
    DChartBarO(
      groupList: [
        OrdinalGroup(id: 'r$width', data: [
          for (var i = 0; i < domain.length; i++) OrdinalData(domain: domain[i].label, measure: (to[i] - from[i]).abs(), others: i),
        ]),
      ],
      domainAxis: _domainO(),
      measureAxis: _measure(min: min, max: max),
      configSeriesBar: ConfigSeriesBarO(
        maxBarWidthPx: width,
        measureOffset: (g, d, i) => math.min(from[d.others as int], to[d.others as int]),
        customColor: (g, d, i) => color(d.others as int),
      ),
    );

Widget _candles(List<GOhlc> c) {
  final domain = [for (final k in c) GCategory(k.label.substring(5), 0)];
  final lo = c.map((k) => k.low.toDouble()).reduce(math.min), hi = c.map((k) => k.high.toDouble()).reduce(math.max);
  final pad = (hi - lo) * 0.05 + 1;
  Color col(int i) => c[i].close >= c[i].open ? casePalette[2] : casePalette[1];
  return _layers([
    (_) => _rangeLayer(domain, [for (final k in c) k.low], [for (final k in c) k.high], lo - pad, hi + pad, 2, col),
    (_) => _rangeLayer(domain, [for (final k in c) k.open], [for (final k in c) k.close == k.open ? k.close + pad / 20 : k.close], lo - pad, hi + pad, 12, col),
  ]);
}

Widget _hloc(List<GOhlc> c) {
  final labels = [for (final k in c) k.label.substring(5)];
  final lo = c.map((k) => k.low.toDouble()).reduce(math.min), hi = c.map((k) => k.high.toDouble()).reduce(math.max);
  final pad = (hi - lo) * 0.05 + 1;
  return _withLegend(
    DChartComboO(
      groupList: [
        OrdinalGroup(id: 'high-low', data: [for (var i = 0; i < c.length; i++) OrdinalData(domain: labels[i], measure: c[i].high - c[i].low, others: i)]),
        OrdinalGroup(id: 'open', data: [for (var i = 0; i < c.length; i++) OrdinalData(domain: labels[i], measure: c[i].open)]),
        OrdinalGroup(id: 'close', data: [for (var i = 0; i < c.length; i++) OrdinalData(domain: labels[i], measure: c[i].close)]),
      ],
      renderType: (g) => g.id == 'high-low' ? RenderType.bar : RenderType.scatterPlot,
      domainAxis: _domainO(),
      measureAxis: _measure(min: lo - pad, max: hi + pad),
      configSeriesBar: ConfigSeriesBarO(
        maxBarWidthPx: 2,
        measureOffset: (g, d, i) => c[d.others as int].low,
        customColor: (g, d, i) => Colors.grey,
      ),
      configSeriesScatter: ConfigSeriesScatterO(
        symbolRender: const SymbolRenderRect(),
        pointRadius: (g, d, i) => 4,
        customColor: (g, d, i) => g.id == 'open' ? casePalette[3] : casePalette[0],
      ),
    ),
    const ['high-low', 'open', 'close'],
  );
}

Widget _boxPlot(List<GBoxStat> b) {
  if (b.isEmpty) return const TechnicalIssue('No hay formatos con al menos 2 obras puntuadas.');
  final domain = [for (final s in b) GCategory(s.label, 0)];
  Color col(int i) => casePalette[i % casePalette.length];
  return _layers([
    (_) => _rangeLayer(domain, [for (final s in b) s.min], [for (final s in b) s.max], 0, 100, 2, (_) => Colors.grey),
    (_) => _rangeLayer(domain, [for (final s in b) s.q1], [for (final s in b) s.q3], 0, 100, 26, col),
    (_) => _rangeLayer(domain, [for (final s in b) s.median - 0.4], [for (final s in b) s.median + 0.4], 0, 100, 26, (_) => Colors.black87),
  ]);
}

Widget _errorBars(List<GErrorStat> e) {
  if (e.isEmpty) return const TechnicalIssue('No hay géneros con al menos 2 obras puntuadas.');
  final domain = [for (final s in e) GCategory(s.label, 0)];
  return _layers([
    (_) => _rangeLayer(domain, [for (final _ in e) 0], [for (final s in e) s.mean], 0, 100, 22, (i) => casePalette[i % casePalette.length].withAlpha(150)),
    (_) => _rangeLayer(domain, [for (final s in e) s.low], [for (final s in e) s.high], 0, 100, 2, (_) => const Color(0xFFFFB74D)),
  ]);
}

Widget _macd(List<GMacdPoint> p) => _withLegend(
      DChartComboT(
        groupList: [
          TimeGroup(id: 'Histograma', data: [for (final m in p) TimeData(domain: DateTime.parse(m.label), measure: m.histogram)]),
          TimeGroup(id: 'MACD', data: [for (final m in p) TimeData(domain: DateTime.parse(m.label), measure: m.macd)]),
          TimeGroup(id: 'Señal', data: [for (final m in p) TimeData(domain: DateTime.parse(m.label), measure: m.signal)]),
        ],
        renderType: (g) => g.id == 'Histograma' ? RenderType.bar : RenderType.line,
        domainAxis: DomainAxisT(labelStyle: _lbl),
        measureAxis: _measure(zeroBound: false),
        configSeriesBar: ConfigSeriesBarT(customColor: (g, d, i) => (d.measure ?? 0) >= 0 ? casePalette[2] : casePalette[1]),
        configSeriesLine: ConfigSeriesLineT(customColor: (g, d, i) => g.id == 'MACD' ? casePalette[0] : casePalette[3]),
      ),
      const ['Histograma', 'MACD', 'Señal'],
    );

Widget _trend(List<GRegressionPoint> p) {
  final sorted = [...p]..sort((a, b) => a.x.compareTo(b.x));
  return _withLegend(
    DChartComboN(
      groupList: [
        NumericGroup(id: 'obras', data: [for (final r in sorted) NumericData(domain: r.x, measure: r.y)]),
        NumericGroup(id: 'regresión', data: [for (final r in sorted) NumericData(domain: r.x, measure: r.fitted)]),
      ],
      renderType: (g) => g.id == 'regresión' ? RenderType.line : RenderType.scatterPlot,
      domainAxis: DomainAxisN(labelStyle: _lbl, tickLabelFormatter: (v) => v == null ? '' : '${(v / 1000).round()}k'),
      measureAxis: _measure(zeroBound: false),
      configSeriesLine: ConfigSeriesLineN(customColor: (g, d, i) => casePalette[1]),
      configSeriesScatter: ConfigSeriesScatterN(customColor: (g, d, i) => casePalette[0], pointRadius: (g, d, i) => 3),
    ),
    const ['obras', 'regresión'],
  );
}

Widget _gapless(List<GCategory> items) {
  final years = [for (final c in items) int.tryParse(c.label) ?? 0];
  var gaps = 0;
  for (var i = 1; i < years.length; i++) {
    gaps += math.max(0, years[i] - years[i - 1] - 1);
  }
  return Column(children: [
    Text('Dominio ordinal: $gaps años sin obras en el rango no ocupan espacio.', style: const TextStyle(fontSize: 11)),
    Expanded(
      child: DChartComboO(
        groupList: [_og('obras', items)],
        renderType: (_) => RenderType.line,
        domainAxis: _domainO(),
        measureAxis: _measure(),
        configSeriesLine: ConfigSeriesLineO(includePoints: true, customColor: (g, d, i) => casePalette[5]),
      ),
    ),
  ]);
}

Widget _semiDonut(CaseData d) {
  final top = d.g.topByPopularity.first;
  final score = (top.score ?? 0).toDouble();
  return LayoutBuilder(builder: (context, box) {
    final size = math.min(box.maxWidth, box.maxHeight * 2);
    return Center(
      child: SizedBox(
        width: size,
        height: size / 2,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: size,
            maxHeight: size,
            child: Stack(alignment: Alignment.center, children: [
              DChartPieO(
                data: [OrdinalData(domain: 'score', measure: score), OrdinalData(domain: 'resto', measure: 100 - score)],
                configSeriesPie: ConfigSeriesPieO(
                  startAngle: math.pi,
                  arcLength: math.pi,
                  arcWidth: (size * 0.12).round(),
                  customColor: (g, dt, i) => i == 0 ? casePalette[0] : Colors.grey.withAlpha(60),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: size * 0.1),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${top.score ?? '–'}', style: Theme.of(context).textTheme.headlineSmall),
                  Text(shortLabel(top.title, 28), style: const TextStyle(fontSize: 10)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  });
}

Widget _sparkMinMax(List<GCategory> items) {
  final values = [for (final c in items) c.value];
  final minV = values.reduce((a, b) => a < b ? a : b), maxV = values.reduce((a, b) => a > b ? a : b);
  return Column(children: [
    Expanded(
      child: DChartLineN(
        groupList: [_yearGroup('obras', items)],
        domainAxis: _domainN(hide: true),
        measureAxis: _measure(hide: true),
        configSeriesLine: ConfigSeriesLineN(
          includeArea: true,
          includePoints: true,
          areaOpacity: 0.3,
          customColor: (g, d, i) => casePalette[0],
          pointRadius: (g, d, i) => d.measure == minV || d.measure == maxV ? 5 : 0,
          pointColor: (g, d, i) => d.measure == maxV ? casePalette[2] : casePalette[1],
        ),
      ),
    ),
    Text('mín. $minV · máx. $maxV obras por año', style: const TextStyle(fontSize: 10)),
  ]);
}

Widget _widgetAnnotation(CaseData d) {
  final items = _topPopularity(d);
  final maxIndex = items.indexWhere((c) => c.value == items.map((e) => e.value).reduce(math.max));
  return LayoutBuilder(builder: (context, box) {
    final x = 40 + (maxIndex + 0.5) * (box.maxWidth - 50) / items.length;
    return Stack(children: [
      Positioned.fill(child: _bars([_og('popularity', items)], rotation: 45, max: items[maxIndex].value * 1.3)),
      Positioned(
        left: (x - 60).clamp(0, box.maxWidth - 120),
        top: 0,
        width: 120,
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text('Máximo: ${d.g.topByPopularity[maxIndex].title}', style: const TextStyle(fontSize: 9), textAlign: TextAlign.center, maxLines: 2),
          ),
        ),
      ),
    ]);
  });
}

// ---------------------------------------------------------------------------
// Composiciones con estado
// ---------------------------------------------------------------------------

class _DcRadial extends StatefulWidget {
  const _DcRadial({required this.items, this.explodable = false});
  final List<GCategory> items;
  final bool explodable;

  @override
  State<_DcRadial> createState() => _DcRadialState();
}

class _DcRadialState extends State<_DcRadial> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
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
                    child: Padding(
                      padding: EdgeInsets.all(i * ring),
                      child: DChartPieO(
                        data: [
                          OrdinalData(domain: items[i].label, measure: items[i].value),
                          OrdinalData(domain: 'resto', measure: 100 - items[i].value),
                        ],
                        configSeriesPie: ConfigSeriesPieO(
                          arcWidth: (ring * (_selected == i ? 0.95 : 0.7)).round(),
                          customColor: (g, d, j) => j == 0
                              ? casePalette[i].withAlpha(_selected == null || _selected == i ? 255 : 70)
                              : Colors.grey.withAlpha(40),
                        ),
                      ),
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

class _DcCrosshair extends StatefulWidget {
  const _DcCrosshair({required this.items});
  final List<_Pt> items;

  @override
  State<_DcCrosshair> createState() => _DcCrosshairState();
}

class _DcCrosshairState extends State<_DcCrosshair> {
  _Pt? _sel;

  @override
  Widget build(BuildContext context) {
    final p = widget.items;
    if (p.length < 2) return const TechnicalIssue('Pocos años en la muestra.');
    final xs = p.map((e) => e.$1), ys = p.map((e) => e.$2);
    final xMin = xs.reduce(math.min), xMax = xs.reduce(math.max), yMin = ys.reduce(math.min), yMax = ys.reduce(math.max);
    final s = _sel;
    return Column(children: [
      Text(s == null ? 'Toca un punto de la línea' : '${s.$1.toStringAsFixed(0)}: ${s.$2.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
      Expanded(
        child: DChartLineN(
          defaultInteractions: true,
          onChangedListener: (NumericData d) {
            if (d.others == 'dato') setState(() => _sel = (d.domain.toDouble(), (d.measure ?? 0).toDouble()));
          },
          groupList: [
            NumericGroup(id: 'score', data: [for (final e in p) NumericData(domain: e.$1, measure: e.$2, others: 'dato')]),
            if (s != null) _numGroup('h', [(xMin, s.$2), (xMax, s.$2)]),
            if (s != null) _numGroup('v', [(s.$1, yMin), (s.$1, yMax)]),
          ],
          domainAxis: _domainN(),
          measureAxis: _measure(zeroBound: false),
          configSeriesLine: ConfigSeriesLineN(
            includePoints: true,
            customColor: (g, d, i) => g.id == 'score' ? casePalette[0] : Colors.grey,
            dashPattern: (g, d, i) => g.id == 'score' ? null : [4, 4],
            pointRadius: (g, d, i) => g.id == 'score' ? 4 : 0,
            strokeWidthPx: (g, d, i) => g.id == 'score' ? 2.5 : 1,
          ),
        ),
      ),
    ]);
  }
}

class _DcTrackball extends StatefulWidget {
  const _DcTrackball({required this.points});
  final List<GSeriesPoint> points;

  @override
  State<_DcTrackball> createState() => _DcTrackballState();
}

class _DcTrackballState extends State<_DcTrackball> {
  String? _x;

  @override
  Widget build(BuildContext context) {
    final groups = _seriesYearGroups(widget.points);
    final ids = [for (final g in groups) g.id];
    final at = _x == null ? const <GSeriesPoint>[] : [for (final p in widget.points) if (p.x == _x) p];
    return Column(children: [
      Text(
        _x == null ? 'Toca un punto: se muestran todas las series en ese año' : '$_x · ${[for (final p in at) '${p.series}: ${p.value}'].join(' · ')}',
        style: const TextStyle(fontSize: 11),
      ),
      Expanded(
        child: DChartLineN(
          defaultInteractions: true,
          onChangedListener: (NumericData d) => setState(() => _x = d.domain.toStringAsFixed(0)),
          groupList: groups,
          domainAxis: _domainN(),
          measureAxis: _measure(),
          configSeriesLine: ConfigSeriesLineN(includePoints: true, customColor: (g, d, i) => _seriesColor(g.id, ids)),
        ),
      ),
      SimpleLegend(labels: ids, colors: casePalette),
    ]);
  }
}

class _DcRangeFilter extends StatefulWidget {
  const _DcRangeFilter({required this.items});
  final List<GCategory> items;

  @override
  State<_DcRangeFilter> createState() => _DcRangeFilterState();
}

class _DcRangeFilterState extends State<_DcRangeFilter> {
  late RangeValues _range = RangeValues(0, math.max(0, widget.items.length - 1).toDouble());

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.length < 2) return const TechnicalIssue('Pocos años en la muestra para filtrar.');
    final from = _range.start.round(), to = _range.end.round();
    return Column(children: [
      SizedBox(height: 50, child: _line([_yearGroup('obras', items)], area: true, hideAxes: true)),
      RangeSlider(
        values: _range,
        min: 0,
        max: (items.length - 1).toDouble(),
        divisions: items.length - 1,
        labels: RangeLabels(items[from].label, items[to].label),
        onChanged: (r) => setState(() => _range = r),
      ),
      Expanded(child: _bars([_og('obras', items.sublist(from, to + 1))])),
    ]);
  }
}

class _DcWidgetTooltip extends StatefulWidget {
  const _DcWidgetTooltip({required this.items});
  final List<GAnime> items;

  @override
  State<_DcWidgetTooltip> createState() => _DcWidgetTooltipState();
}

class _DcWidgetTooltipState extends State<_DcWidgetTooltip> {
  GAnime? _sel;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final a = _sel;
    return Stack(children: [
      Positioned.fill(
        child: DChartBarO(
          defaultInteractions: true,
          onChangedListener: (OrdinalData d) => setState(() => _sel = d.others as GAnime?),
          groupList: [
            OrdinalGroup(id: 'popularity', data: [
              for (final t in items) OrdinalData(domain: shortLabel(t.title, 8), measure: t.popularity, others: t),
            ]),
          ],
          domainAxis: _domainO(rotation: 45),
          measureAxis: _measure(),
          configSeriesBar: ConfigSeriesBarO(customColor: (g, d, i) => d.others == _sel ? casePalette[3] : casePalette[0]),
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
                    if (a.episodes != null) Text('episodios/capítulos: ${a.episodes}', style: const TextStyle(fontSize: 10)),
                  ]),
          ),
        ),
      ),
    ]);
  }
}

class _DcStaggered extends StatefulWidget {
  const _DcStaggered({required this.items});
  final List<GCategory> items;

  @override
  State<_DcStaggered> createState() => _DcStaggeredState();
}

class _DcStaggeredState extends State<_DcStaggered> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final maxY = items.map((c) => c.value.toDouble()).fold<double>(1, math.max);
    return Column(children: [
      Expanded(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _bars(
            [
              _og('popularity', [
                for (var i = 0; i < items.length; i++)
                  GCategory(
                    items[i].label,
                    items[i].value *
                        Curves.easeOut.transform(Interval(i / (items.length + 4), (i + 5) / (items.length + 4)).transform(_controller.value)),
                  ),
              ]),
            ],
            rotation: 45,
            max: maxY,
            color: (c, i) => casePalette[i % casePalette.length],
          ),
        ),
      ),
      TextButton(onPressed: () => _controller.forward(from: 0), child: const Text('Repetir animación')),
    ]);
  }
}
