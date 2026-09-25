// Los 63 casos maestros dibujados con Syncfusion Flutter Charts 34.2.9.
//
// Casi todos usan una serie, indicador, behavior o anotación nativa de
// Syncfusion (SfCartesianChart, SfCircularChart, SfPyramidChart,
// SfFunnelChart y las sparklines). La composición con Flutter solo aparece
// donde el caso lo exige (#52, #55, #56, #63).

import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/common/live_case_hosts.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_view_models.dart';
import 'package:anilist_data_viz/presentation/state/anilist_live_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'syncfusion_gauge_charts.dart';

const _n = ImplementationStrategy.nativo;
const _v = ImplementationStrategy.variante;
const _c = ImplementationStrategy.composicion;
const _a = ImplementationStrategy.adaptacion;

CaseImpl _impl(int n, ImplementationStrategy s, String api, CaseBuilder b, {String? note}) =>
    CaseImpl(strategy: s, origin: sharedCaseOrigins[n]!, api: api, builder: b, note: note);

/// Los 63 casos de Syncfusion.
final Map<int, CaseImpl> syncfusionCases = {
  1: _impl(1, _n, 'SfCartesianChart + LineSeries', (_, d) => _cartesian([_lineSeries(d.g.scoreByYear)])),
  2: _impl(2, _n, 'ColumnSeries', (_, d) => _cartesian([
        ColumnSeries<GCategory, String>(dataSource: _topPopularity(d), xValueMapper: _x, yValueMapper: _y, color: casePalette[0]),
      ], labelRotation: -45)),
  3: _impl(3, _n, 'BarSeries', (_, d) => _cartesian([
        BarSeries<GCategory, String>(dataSource: _topScore(d, 10), xValueMapper: _x, yValueMapper: _y, color: casePalette[0]),
      ])),
  4: _impl(4, _n, 'SplineSeries', (_, d) => _cartesian([
        SplineSeries<GCategory, String>(dataSource: d.g.scoreByYear, xValueMapper: _x, yValueMapper: _y, color: casePalette[0], width: 2.5),
      ])),
  5: _impl(5, _n, 'AreaSeries', (_, d) => _cartesian([
        AreaSeries<GCategory, String>(dataSource: d.g.countByYear, xValueMapper: _x, yValueMapper: _y, color: casePalette[2].withAlpha(150)),
      ])),
  6: _impl(6, _n, 'SplineAreaSeries', (_, d) => _cartesian([
        SplineAreaSeries<GCategory, String>(dataSource: d.g.countByYear, xValueMapper: _x, yValueMapper: _y, color: casePalette[2].withAlpha(150)),
      ])),
  7: _impl(7, _n, 'SfCircularChart + PieSeries', (_, d) => _circular([
        PieSeries<GCategory, String>(dataSource: d.g.countByFormat, xValueMapper: _x, yValueMapper: _y, dataLabelSettings: _labelsOn),
      ])),
  8: _impl(8, _n, 'DoughnutSeries', (_, d) => _circular([
        DoughnutSeries<GCategory, String>(dataSource: d.g.countByStatus, xValueMapper: _x, yValueMapper: _y, dataLabelSettings: _labelsOn),
      ])),
  9: _impl(9, _n, 'RadialBarSeries', (_, d) => _circular([
        RadialBarSeries<GCategory, String>(
          dataSource: _topScore(d, 5), xValueMapper: _x, yValueMapper: _y, maximumValue: 100, gap: '6%',
          cornerStyle: CornerStyle.bothCurve, innerRadius: '25%',
        ),
      ], legend: LegendPosition.bottom)),
  10: _impl(10, _n, 'ScatterSeries', (_, d) => _numeric([
        ScatterSeries<GAnime, num>(
          dataSource: scoredTitles(d.g), xValueMapper: (a, _) => a.popularity, yValueMapper: (a, _) => a.score,
          color: casePalette[0], markerSettings: const MarkerSettings(height: 7, width: 7),
        ),
      ])),
  11: _impl(11, _n, 'BubbleSeries (sizeValueMapper)', (_, d) => _numeric([
        BubbleSeries<GAnime, num>(
          dataSource: [for (final a in scoredTitles(d.g)) if (a.episodes != null) a],
          xValueMapper: (a, _) => a.popularity, yValueMapper: (a, _) => a.score, sizeValueMapper: (a, _) => a.episodes,
          color: casePalette[4].withAlpha(140), minimumRadius: 2, maximumRadius: 14,
        ),
      ]), note: 'Tamaño = episodes (anime) o chapters (manga).'),
  12: _impl(12, _n, 'StepLineSeries', (_, d) => _cartesian([
        StepLineSeries<GCategory, String>(dataSource: d.g.cumulativeByYear, xValueMapper: _x, yValueMapper: _y, color: casePalette[3], width: 2.5),
      ])),
  13: _impl(13, _n, 'StepAreaSeries', (_, d) => _cartesian([
        StepAreaSeries<GCategory, String>(dataSource: d.g.cumulativeByYear, xValueMapper: _x, yValueMapper: _y, color: casePalette[3].withAlpha(150)),
      ])),
  14: _impl(14, _n, 'SfPyramidChart + PyramidSeries', (_, d) => SfPyramidChart(
        legend: const Legend(isVisible: true, position: LegendPosition.right),
        series: PyramidSeries<GCategory, String>(dataSource: d.g.countByFormat, xValueMapper: _x, yValueMapper: _y, dataLabelSettings: _labelsOn),
      )),
  15: _impl(15, _n, 'SfFunnelChart + FunnelSeries', (_, d) => SfFunnelChart(
        legend: const Legend(isVisible: true, position: LegendPosition.right),
        series: FunnelSeries<GCategory, String>(dataSource: d.g.countByStatus, xValueMapper: _x, yValueMapper: _y, dataLabelSettings: _labelsOn),
      )),
  16: _impl(16, _n, 'HistogramSeries (binInterval 10)', (_, d) => _numeric([
        HistogramSeries<GAnime, num>(
          dataSource: scoredTitles(d.g), yValueMapper: (a, _) => a.score, binInterval: 10,
          color: casePalette[0], borderWidth: 1, borderColor: Colors.white, showNormalDistributionCurve: true,
        ),
      ])),
  17: _impl(17, _n, 'StackedColumnSeries', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        StackedColumnSeries<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i]))),
  18: _impl(18, _n, 'StackedBarSeries', (_, d) => _multi(d.g.genreStatusSeries, (s, pts, i) =>
        StackedBarSeries<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i]))),
  19: _impl(19, _n, 'StackedAreaSeries', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        StackedAreaSeries<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i].withAlpha(190)))),
  20: _impl(20, _n, 'StackedLineSeries', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        StackedLineSeries<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i], markerSettings: const MarkerSettings(isVisible: true)))),
  21: _impl(21, _n, 'StackedColumn100Series', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        StackedColumn100Series<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i]))),
  22: _impl(22, _n, 'StackedBar100Series', (_, d) => _multi(d.g.genreStatusSeries, (s, pts, i) =>
        StackedBar100Series<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i]))),
  23: _impl(23, _n, 'StackedArea100Series', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        StackedArea100Series<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i].withAlpha(190)))),
  24: _impl(24, _n, 'StackedLine100Series', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        StackedLine100Series<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i], markerSettings: const MarkerSettings(isVisible: true)))),
  25: _impl(25, _n, 'RangeColumnSeries', (_, d) => _cartesian([
        RangeColumnSeries<GRange, String>(
          dataSource: d.g.airingRanges, xValueMapper: (r, _) => shortLabel(r.x, 10), lowValueMapper: (r, _) => r.low, highValueMapper: (r, _) => r.high + 0.3,
          color: casePalette[5],
        ),
      ], labelRotation: -45, yMin: _minRange(d.g.airingRanges))),
  26: _impl(26, _n, 'RangeAreaSeries', (_, d) => _cartesian([
        RangeAreaSeries<GRange, String>(
          dataSource: d.g.scoreRangeByYear, xValueMapper: (r, _) => r.x, lowValueMapper: (r, _) => r.low, highValueMapper: (r, _) => r.high,
          color: casePalette[0].withAlpha(120), borderColor: casePalette[0], borderWidth: 1,
        ),
      ])),
  27: _impl(27, _n, 'SplineRangeAreaSeries', (_, d) => _cartesian([
        SplineRangeAreaSeries<GRange, String>(
          dataSource: d.g.scoreRangeByYear, xValueMapper: (r, _) => r.x, lowValueMapper: (r, _) => r.low, highValueMapper: (r, _) => r.high,
          color: casePalette[0].withAlpha(120), borderColor: casePalette[0], borderWidth: 1,
        ),
      ])),
  28: _impl(28, _n, 'WaterfallSeries (totalSumPredicate)', (_, d) => _cartesian([
        WaterfallSeries<GWaterfallStep, String>(
          dataSource: d.g.waterfallSteps, xValueMapper: (s, _) => s.label,
          yValueMapper: (s, _) => s.isTotal ? s.to : s.to - s.from,
          totalSumPredicate: (s, _) => s.isTotal,
          color: casePalette[2], negativePointsColor: casePalette[1], totalSumColor: casePalette[9],
        ),
      ])),
  29: _impl(29, _n, 'LineSeries + MarkerSettings', (_, d) => _cartesian([_lineSeries(d.g.scoreByYear, markers: true)])),
  30: _impl(30, _n, 'BarSeries + pointColorMapper', (_, d) => _cartesian([
        BarSeries<GCategory, String>(
          dataSource: d.g.genreDeviation, xValueMapper: _x, yValueMapper: _y,
          pointColorMapper: (c, _) => c.value >= 0 ? casePalette[2] : casePalette[1],
        ),
      ])),
  31: _impl(31, _n, 'SfSparkLineChart', (_, d) => Center(
        child: SizedBox(height: 90, child: SfSparkLineChart(data: [for (final c in d.g.countByYear) c.value], color: casePalette[0], width: 2)),
      )),
  32: _impl(32, _a, 'CandleSeries', (_, d) => withTrends(d, () => _cartesian([
        CandleSeries<GOhlc, String>(
          dataSource: d.g.trendOhlc, xValueMapper: (c, _) => c.label.substring(5),
          openValueMapper: (c, _) => c.open, highValueMapper: (c, _) => c.high, lowValueMapper: (c, _) => c.low, closeValueMapper: (c, _) => c.close,
          enableSolidCandles: true,
        ),
      ], yMin: null)), note: ohlcNote),
  33: _impl(33, _a, 'HiloOpenCloseSeries', (_, d) => withTrends(d, () => _cartesian([
        HiloOpenCloseSeries<GOhlc, String>(
          dataSource: d.g.trendOhlc, xValueMapper: (c, _) => c.label.substring(5),
          openValueMapper: (c, _) => c.open, highValueMapper: (c, _) => c.high, lowValueMapper: (c, _) => c.low, closeValueMapper: (c, _) => c.close,
        ),
      ])), note: hlocNote),
  34: _impl(34, _n, 'BoxAndWhiskerSeries', (_, d) {
        final byFormat = <String, List<num>>{};
        for (final a in scoredTitles(d.g)) {
          if (d.g.formats.contains(a.format)) (byFormat[a.format] ??= []).add(a.score!);
        }
        final entries = [for (final e in byFormat.entries) if (e.value.length >= 2) e];
        return _cartesian([
          BoxAndWhiskerSeries<MapEntry<String, List<num>>, String>(
            dataSource: entries, xValueMapper: (e, _) => e.key, yValueMapper: (e, _) => e.value,
            color: casePalette[0].withAlpha(160), borderColor: casePalette[0], showMean: true,
          ),
        ]);
      }),
  35: _impl(35, _v, 'ColumnSeries + un ErrorBarSeries (custom) por género', (_, d) {
        final stats = d.g.errorByGenre;
        return _cartesian([
          ColumnSeries<GErrorStat, String>(dataSource: stats, xValueMapper: (e, _) => e.label, yValueMapper: (e, _) => e.mean, color: casePalette[0].withAlpha(150)),
          for (final e in stats)
            ErrorBarSeries<GErrorStat, String>(
              dataSource: [e], xValueMapper: (e, _) => e.label, yValueMapper: (e, _) => e.mean,
              type: ErrorBarType.custom, mode: RenderingMode.vertical,
              verticalPositiveErrorValue: (e.high - e.mean).toDouble(), verticalNegativeErrorValue: (e.mean - e.low).toDouble(),
              color: const Color(0xFFFFB74D), width: 2,
            ),
        ], yMin: 0, yMax: 100);
      }, note: 'ErrorBarSeries aplica un error por serie; se usa una serie por género para mostrar su σ.'),
  36: _impl(36, _n, 'ColumnSeries + LineSeries con eje secundario', (_, d) => _cartesian([
        ColumnSeries<GCategory, String>(dataSource: d.g.countByYear, xValueMapper: _x, yValueMapper: _y, name: 'Obras', color: casePalette[0].withAlpha(170)),
        LineSeries<GCategory, String>(dataSource: d.g.scoreByYear, xValueMapper: _x, yValueMapper: _y, name: 'Score medio', yAxisName: 'score', color: casePalette[1], markerSettings: const MarkerSettings(isVisible: true)),
      ], secondaryAxis: 'score', legend: true)),
  37: _impl(37, _n, 'axes: NumericAxis(opposedPosition) + yAxisName', (_, d) {
        final top = [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 8), a.popularity)];
        final scores = [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 8), a.score ?? 0)];
        return _cartesian([
          LineSeries<GCategory, String>(dataSource: top, xValueMapper: _x, yValueMapper: _y, name: 'popularity', color: casePalette[0], markerSettings: const MarkerSettings(isVisible: true)),
          LineSeries<GCategory, String>(dataSource: scores, xValueMapper: _x, yValueMapper: _y, name: 'averageScore', yAxisName: 'score', color: casePalette[1], markerSettings: const MarkerSettings(isVisible: true)),
        ], secondaryAxis: 'score', legend: true, labelRotation: -45);
      }),
  38: _impl(38, _n, 'ZoomPanBehavior (pinch, pan, rueda)', (_, d) {
        final items = [...d.g.datedTitles]..sort((a, b) => a.date.compareTo(b.date));
        return SfCartesianChart(
          primaryXAxis: const DateTimeAxis(),
          primaryYAxis: const NumericAxis(numberFormat: null),
          zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, enableMouseWheelZooming: true, zoomMode: ZoomMode.x),
          series: [
            ScatterSeries<GDatedValue, DateTime>(dataSource: items, xValueMapper: (t, _) => t.date, yValueMapper: (t, _) => t.value, color: casePalette[5]),
          ],
        );
      }, note: 'Pellizca, arrastra o usa la rueda del ratón.'),
  39: _impl(39, _n, 'CrosshairBehavior', (_, d) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        crosshairBehavior: CrosshairBehavior(enable: true, activationMode: ActivationMode.singleTap, lineType: CrosshairLineType.both),
        series: [_lineSeries(d.g.scoreByYear, markers: true)],
      )),
  40: _impl(40, _n, 'TrackballBehavior (groupAllPoints)', (_, d) => _multi(d.g.yearFormatSeries, (s, pts, i) =>
        LineSeries<GSeriesPoint, String>(dataSource: pts, xValueMapper: _sx, yValueMapper: _sy, name: s, color: casePalette[i], markerSettings: const MarkerSettings(isVisible: true)),
        trackball: TrackballBehavior(enable: true, activationMode: ActivationMode.singleTap, tooltipDisplayMode: TrackballDisplayMode.groupAllPoints))),
  41: _impl(41, _n, 'SmaIndicator (period 7)', (_, d) => withTrends(d, () => _indicatorChart(d, (data) => [
        SmaIndicator<GCategory, String>(dataSource: data, xValueMapper: _xDate, closeValueMapper: _y, period: 7, signalLineColor: casePalette[3]),
      ])), note: trendsIndicatorNote),
  42: _impl(42, _n, 'BollingerBandIndicator (20, 2σ)', (_, d) => withTrends(d, () => _indicatorChart(d, (data) => [
        BollingerBandIndicator<GCategory, String>(dataSource: data, xValueMapper: _xDate, closeValueMapper: _y, period: 20, standardDeviation: 2),
      ])), note: trendsIndicatorNote),
  43: _impl(43, _n, 'RsiIndicator (14) en eje secundario', (_, d) => withTrends(d, () => _indicatorChart(d, (data) => [
        RsiIndicator<GCategory, String>(dataSource: data, xValueMapper: _xDate, closeValueMapper: _y, period: 14, showZones: true, overbought: 70, oversold: 30, yAxisName: 'ind'),
      ], indicatorAxis: const NumericAxis(name: 'ind', opposedPosition: true, minimum: 0, maximum: 100))), note: trendsIndicatorNote),
  44: _impl(44, _n, 'MacdIndicator (12, 26, 9) en eje secundario', (_, d) => withTrends(d, () => _indicatorChart(d, (data) => [
        MacdIndicator<GCategory, String>(dataSource: data, xValueMapper: _xDate, closeValueMapper: _y, shortPeriod: 12, longPeriod: 26, period: 9, yAxisName: 'ind'),
      ], indicatorAxis: const NumericAxis(name: 'ind', opposedPosition: true))), note: trendsIndicatorNote),
  45: _impl(45, _n, 'ScatterSeries + Trendline(linear)', (_, d) => _numeric([
        ScatterSeries<GAnime, num>(
          dataSource: scoredTitles(d.g), xValueMapper: (a, _) => a.popularity, yValueMapper: (a, _) => a.score, color: casePalette[0],
          trendlines: [Trendline(type: TrendlineType.linear, color: casePalette[1], width: 2)],
        ),
      ])),
  46: _impl(46, _n, 'PlotBand (banda + línea en la media)', (_, d) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(labelRotation: -45),
        primaryYAxis: NumericAxis(minimum: 0, maximum: 100, plotBands: [
          PlotBand(start: 80, end: 100, color: Colors.green.withAlpha(50), text: '≥ 80', textStyle: const TextStyle(fontSize: 9)),
          PlotBand(start: 0, end: 60, color: Colors.red.withAlpha(35)),
          PlotBand(start: d.g.globalMeanScore, end: d.g.globalMeanScore, borderColor: casePalette[3], borderWidth: 2, dashArray: const [6, 4]),
        ]),
        series: [
          ColumnSeries<GCategory, String>(dataSource: [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 8), a.score ?? 0)], xValueMapper: _x, yValueMapper: _y, color: casePalette[0]),
        ],
      )),
  47: _impl(47, _n, 'CartesianChartAnnotation (widget en coordenadas de dato)', (_, d) {
        final items = _topPopularity(d);
        final max = items.reduce((a, b) => a.value >= b.value ? a : b);
        final full = d.g.topByPopularity[items.indexOf(max)].title;
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(labelRotation: -45),
          primaryYAxis: NumericAxis(maximum: max.value * 1.3),
          annotations: [
            CartesianChartAnnotation(
              widget: Card(child: Padding(padding: const EdgeInsets.all(4), child: Text('Máximo: $full', style: const TextStyle(fontSize: 9)))),
              coordinateUnit: CoordinateUnit.point,
              x: max.label,
              y: max.value * 1.15,
            ),
          ],
          series: [ColumnSeries<GCategory, String>(dataSource: items, xValueMapper: _x, yValueMapper: _y, color: casePalette[0])],
        );
      }),
  48: _impl(48, _n, 'LineSeries.pointColorMapper', (_, d) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: NumericAxis(plotBands: [
          PlotBand(start: d.g.globalMeanScore, end: d.g.globalMeanScore, borderColor: Colors.grey, borderWidth: 1, dashArray: const [4, 4]),
        ]),
        series: [
          LineSeries<GCategory, String>(
            dataSource: d.g.scoreByYear, xValueMapper: _x, yValueMapper: _y, width: 3,
            pointColorMapper: (c, _) => c.value >= d.g.globalMeanScore ? casePalette[2] : casePalette[1],
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      )),
  49: _impl(49, _n, 'ColumnSeries.gradient', (_, d) => _cartesian([
        ColumnSeries<GCategory, String>(
          dataSource: _topScore(d, 10), xValueMapper: _x, yValueMapper: _y,
          gradient: const LinearGradient(colors: [Color(0xFF7E57C2), Color(0xFF26C6DA)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
      ], labelRotation: -45, yMin: 0, yMax: 100)),
  50: _impl(50, _n, 'DateTimeCategoryAxis (fechas sin huecos)', (_, d) => SfCartesianChart(
        primaryXAxis: DateTimeCategoryAxis(dateFormat: null, axisLabelFormatter: (a) => ChartAxisLabel(a.text.split('/').last, a.textStyle)),
        series: [
          LineSeries<GCategory, DateTime>(
            dataSource: d.g.countByYear, xValueMapper: (c, _) => DateTime(int.tryParse(c.label) ?? 0), yValueMapper: _y,
            color: casePalette[5], markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      )),
  51: _impl(51, _n, 'LogarithmicAxis', (_, d) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(labelRotation: -45),
        primaryYAxis: const LogarithmicAxis(),
        series: [
          ColumnSeries<GAnime, String>(dataSource: spreadByPopularity(d.g), xValueMapper: (a, _) => shortLabel(a.title, 8), yValueMapper: (a, _) => a.popularity, color: casePalette[4]),
        ],
      )),
  52: _impl(52, _c, 'ColumnSeries + ScrollController + paginación AniList', (_, d) => LazyLoadingHost(
        chartBuilder: (items) => _cartesian([
          ColumnSeries<GCategory, String>(
            dataSource: [for (final m in items) GCategory('${shortLabel(m.title, 8)}·${m.id}', m.popularity ?? 0)],
            xValueMapper: _x, yValueMapper: _y, color: casePalette[5], animationDuration: 0,
          ),
        ], labelRotation: -60))),
  53: _impl(53, _n, 'DoughnutSeries + onCreateShader (SweepGradient)', (_, d) => SfCircularChart(
        legend: const Legend(isVisible: true, position: LegendPosition.right),
        onCreateShader: (details) => SweepGradient(colors: const [Color(0xFF42A5F5), Color(0xFF7E57C2), Color(0xFFEF5350), Color(0xFF42A5F5)])
            .createShader(details.outerRect),
        series: [
          DoughnutSeries<GCategory, String>(dataSource: d.g.countByFormat, xValueMapper: _x, yValueMapper: _y, strokeColor: Colors.white, strokeWidth: 1, dataLabelSettings: _labelsOn),
        ],
      )),
  54: _impl(54, _v, 'DoughnutSeries(startAngle/endAngle) + CircularChartAnnotation', (_, d) {
        final top = d.g.topByPopularity.first;
        return SyncfusionSemiCircleGauge(value: (top.score ?? 0).toDouble(), valueLabel: '${top.score ?? '–'}', caption: shortLabel(top.title, 28));
      }),
  55: _impl(55, _c, 'RangeSlider (Flutter) + ColumnSeries filtrada', (_, d) => _SfRangeFilter(items: d.g.countByYear),
      note: 'SfRangeSelector pertenece a syncfusion_flutter_sliders (no instalado): el rango se elige con RangeSlider.'),
  56: _impl(56, _c, 'RadialBarSeries + pointRadiusMapper + onPointTap', (_, d) => _SfExploding(items: _topScore(d, 5))),
  57: _impl(57, _n, 'SfSparkWinLossChart', (_, d) => Center(
        child: SizedBox(height: 70, child: SfSparkWinLossChart(data: [for (final c in d.g.winLossByYear) c.value], color: casePalette[2], negativePointColor: casePalette[1])),
      )),
  58: _impl(58, _n, 'SfSparkAreaChart + highPointColor/lowPointColor', (_, d) => Center(
        child: SizedBox(
          height: 90,
          child: SfSparkAreaChart(
            data: [for (final c in d.g.countByYear) c.value],
            color: casePalette[0].withAlpha(90),
            borderColor: casePalette[0],
            borderWidth: 2,
            marker: const SparkChartMarker(displayMode: SparkChartMarkerDisplayMode.all, size: 4),
            highPointColor: casePalette[2],
            lowPointColor: casePalette[1],
          ),
        ),
      )),
  59: _impl(59, _n, 'ScatterSeries por formato + MarkerSettings.shape', (_, d) {
        const shapes = [DataMarkerType.circle, DataMarkerType.rectangle, DataMarkerType.triangle, DataMarkerType.diamond];
        return _numeric([
          for (var i = 0; i < d.g.formats.length; i++)
            ScatterSeries<GAnime, num>(
              name: d.g.formats[i],
              dataSource: [for (final a in scoredTitles(d.g)) if (a.format == d.g.formats[i]) a],
              xValueMapper: (a, _) => a.popularity, yValueMapper: (a, _) => a.score, color: casePalette[i],
              markerSettings: MarkerSettings(shape: shapes[i % shapes.length], height: 8, width: 8),
            ),
        ], legend: true);
      }),
  60: _impl(60, _n, 'TooltipBehavior.builder (widget propio)', (_, d) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(labelRotation: -45),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            final a = d.g.topByPopularity[pointIndex];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('popularity: ${a.popularity}', style: const TextStyle(fontSize: 10)),
                  Text('score: ${a.score ?? '–'} · ${a.format}', style: const TextStyle(fontSize: 10)),
                  if (a.episodes != null) Text('episodios/capítulos: ${a.episodes}', style: const TextStyle(fontSize: 10)),
                ]),
              ),
            );
          },
        ),
        series: [ColumnSeries<GCategory, String>(dataSource: _topPopularity(d), xValueMapper: _x, yValueMapper: _y, color: casePalette[0])],
      )),
  61: _impl(61, _v, 'Una serie por barra con animationDelay creciente', (_, d) => _SfStaggered(items: _topPopularity(d))),
  62: _impl(62, _n, 'NumericAxis(isInversed) + CategoryAxis(opposedPosition)', (_, d) {
        final ranked = d.g.rankedTitles.take(10).toList();
        if (ranked.length < 2) return const TechnicalIssue('AniList no devolvió rankings para esta muestra.');
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(opposedPosition: true, labelRotation: -45),
          primaryYAxis: const NumericAxis(isInversed: true, opposedPosition: true, title: AxisTitle(text: 'ranking', textStyle: TextStyle(fontSize: 9))),
          series: [
            LineSeries<GAnime, String>(dataSource: ranked, xValueMapper: (a, _) => shortLabel(a.title, 8), yValueMapper: (a, _) => a.rank, color: casePalette[4], markerSettings: const MarkerSettings(isVisible: true)),
          ],
        );
      }),
  63: _impl(63, _c, 'Timer → GraphQL → ChartSeriesController.updateDataSource', (_, d) => LiveStreamingHost(chartBuilder: (s) => _SfLive(samples: s))),
};

// ---------------------------------------------------------------------------
// Mappers y datos
// ---------------------------------------------------------------------------

String _x(GCategory c, int _) => c.label;
num _y(GCategory c, int _) => c.value;
String _xDate(GCategory c, int _) => c.label.length >= 10 ? c.label.substring(5) : c.label;
String _sx(GSeriesPoint p, int _) => p.x;
num _sy(GSeriesPoint p, int _) => p.value;

const _labelsOn = DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside, textStyle: TextStyle(fontSize: 9));

List<GCategory> _topPopularity(CaseData d) =>
    [for (final a in d.g.topByPopularity) GCategory(shortLabel(a.title, 10), a.popularity)];

List<GCategory> _topScore(CaseData d, int n) =>
    [for (final a in d.g.topByScore.take(n)) GCategory(shortLabel(a.title, 12), a.score ?? 0)];

double? _minRange(List<GRange> r) => r.isEmpty ? null : r.map((e) => e.low.toDouble()).reduce((a, b) => a < b ? a : b) - 1;

// ---------------------------------------------------------------------------
// Contenedores reutilizados
// ---------------------------------------------------------------------------

LineSeries<GCategory, String> _lineSeries(List<GCategory> data, {bool markers = false}) => LineSeries<GCategory, String>(
      dataSource: data, xValueMapper: _x, yValueMapper: _y, color: casePalette[0], width: 2.5,
      markerSettings: MarkerSettings(isVisible: markers),
    );

Widget _cartesian(
  List<CartesianSeries> series, {
  double labelRotation = 0,
  double? yMin,
  double? yMax,
  String? secondaryAxis,
  bool legend = false,
}) =>
    SfCartesianChart(
      primaryXAxis: CategoryAxis(labelRotation: labelRotation.toInt(), arrangeByIndex: true, labelStyle: const TextStyle(fontSize: 9)),
      primaryYAxis: NumericAxis(minimum: yMin, maximum: yMax, labelStyle: const TextStyle(fontSize: 9)),
      axes: [if (secondaryAxis != null) NumericAxis(name: secondaryAxis, opposedPosition: true, labelStyle: const TextStyle(fontSize: 9))],
      legend: Legend(isVisible: legend, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: series,
    );

Widget _numeric(List<CartesianSeries> series, {bool legend = false}) => SfCartesianChart(
      primaryXAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 9)),
      primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 9)),
      legend: Legend(isVisible: legend, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: series,
    );

Widget _circular(List<CircularSeries> series, {LegendPosition legend = LegendPosition.right}) => SfCircularChart(
      legend: Legend(isVisible: true, position: legend, overflowMode: LegendItemOverflowMode.wrap),
      series: series,
    );

/// Una serie por nombre del formato largo.
Widget _multi(
  List<GSeriesPoint> points,
  CartesianSeries Function(String name, List<GSeriesPoint> pts, int index) build, {
  TrackballBehavior? trackball,
}) {
  final bySeries = <String, List<GSeriesPoint>>{};
  for (final p in points) {
    (bySeries[p.series] ??= []).add(p);
  }
  final names = bySeries.keys.toList();
  return SfCartesianChart(
    primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9)),
    primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 9)),
    legend: const Legend(isVisible: true, position: LegendPosition.bottom),
    trackballBehavior: trackball,
    tooltipBehavior: trackball == null ? TooltipBehavior(enable: true) : null,
    series: [for (var i = 0; i < names.length; i++) build(names[i], bySeries[names[i]]!, i)],
  );
}

/// Serie diaria (variación de popularidad) + indicador técnico nativo.
Widget _indicatorChart(
  CaseData d,
  List<TechnicalIndicator<GCategory, String>> Function(List<GCategory> data) indicators, {
  NumericAxis? indicatorAxis,
}) {
  final data = [for (var i = 0; i < d.g.trendValues.length; i++) GCategory(d.g.trendLabels[i], d.g.trendValues[i])];
  return SfCartesianChart(
    primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9), labelIntersectAction: AxisLabelIntersectAction.hide),
    primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 9)),
    axes: [?indicatorAxis],
    legend: const Legend(isVisible: true, position: LegendPosition.bottom),
    indicators: indicators(data),
    series: [
      LineSeries<GCategory, String>(dataSource: data, xValueMapper: _xDate, yValueMapper: _y, name: 'Variación diaria', color: casePalette[9], width: 1.2),
    ],
  );
}

// ---------------------------------------------------------------------------
// Composiciones con estado
// ---------------------------------------------------------------------------

class _SfRangeFilter extends StatefulWidget {
  const _SfRangeFilter({required this.items});
  final List<GCategory> items;

  @override
  State<_SfRangeFilter> createState() => _SfRangeFilterState();
}

class _SfRangeFilterState extends State<_SfRangeFilter> {
  late RangeValues _range = RangeValues(0, (widget.items.length - 1).clamp(0, 1 << 20).toDouble());

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.length < 2) return const TechnicalIssue('Pocos años en la muestra para filtrar.');
    final from = _range.start.round(), to = _range.end.round();
    return Column(children: [
      SizedBox(
        height: 60,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(isVisible: false, plotBands: [PlotBand(start: from, end: to, color: casePalette[0].withAlpha(60))]),
          primaryYAxis: const NumericAxis(isVisible: false),
          series: [AreaSeries<GCategory, String>(dataSource: items, xValueMapper: _x, yValueMapper: _y, color: casePalette[9].withAlpha(120))],
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
      Expanded(child: _cartesian([ColumnSeries<GCategory, String>(dataSource: items.sublist(from, to + 1), xValueMapper: _x, yValueMapper: _y, color: casePalette[0])])),
    ]);
  }
}

class _SfExploding extends StatefulWidget {
  const _SfExploding({required this.items});
  final List<GCategory> items;

  @override
  State<_SfExploding> createState() => _SfExplodingState();
}

class _SfExplodingState extends State<_SfExploding> {
  int? _selected;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(_selected == null ? 'Toca un anillo' : '${widget.items[_selected!].label}: ${widget.items[_selected!].value}',
            style: const TextStyle(fontSize: 11)),
        Expanded(
          child: SfCircularChart(
            legend: const Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
            series: [
              RadialBarSeries<GCategory, String>(
                innerRadius: '25%',
                dataSource: widget.items,
                xValueMapper: _x,
                yValueMapper: _y,
                maximumValue: 100,
                gap: '4%',
                pointRadiusMapper: (c, i) => i == _selected ? '100%' : '82%',
                pointColorMapper: (c, i) => casePalette[i].withAlpha(_selected == null || _selected == i ? 255 : 90),
                onPointTap: (details) => setState(() => _selected = details.pointIndex == _selected ? null : details.pointIndex),
              ),
            ],
          ),
        ),
      ]);
}

class _SfStaggered extends StatefulWidget {
  const _SfStaggered({required this.items});
  final List<GCategory> items;

  @override
  State<_SfStaggered> createState() => _SfStaggeredState();
}

class _SfStaggeredState extends State<_SfStaggered> {
  int _run = 0;

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
          child: SfCartesianChart(
            key: ValueKey(_run),
            enableSideBySideSeriesPlacement: false,
            primaryXAxis: const CategoryAxis(labelRotation: -45, labelStyle: TextStyle(fontSize: 9)),
            series: [
              for (var i = 0; i < widget.items.length; i++)
                ColumnSeries<GCategory, String>(
                  dataSource: [widget.items[i]], xValueMapper: _x, yValueMapper: _y, color: casePalette[i % casePalette.length],
                  animationDuration: 600, animationDelay: i * 150.0,
                ),
            ],
          ),
        ),
        TextButton(onPressed: () => setState(() => _run++), child: const Text('Repetir animación')),
      ]);
}

/// #63: añade cada lectura nueva con `updateDataSource` (sin reconstruir la serie).
class _SfLive extends StatefulWidget {
  const _SfLive({required this.samples});
  final List<LiveSample> samples;

  @override
  State<_SfLive> createState() => _SfLiveState();
}

class _SfLiveState extends State<_SfLive> {
  late final List<LiveSample> _data = List.of(widget.samples);
  ChartSeriesController? _controller;

  @override
  void didUpdateWidget(covariant _SfLive oldWidget) {
    super.didUpdateWidget(oldWidget);
    final fresh = widget.samples.where((s) => _data.isEmpty || s.time.isAfter(_data.last.time)).toList();
    if (fresh.isEmpty) return;
    final start = _data.length;
    _data.addAll(fresh);
    _controller?.updateDataSource(addedDataIndexes: [for (var i = start; i < _data.length; i++) i]);
  }

  @override
  Widget build(BuildContext context) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9)),
        primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 9)),
        series: [
          LineSeries<LiveSample, String>(
            dataSource: _data,
            xValueMapper: (s, _) => liveLabel(s),
            yValueMapper: (s, _) => s.totalPopularity,
            color: casePalette[1],
            markerSettings: const MarkerSettings(isVisible: true),
            onRendererCreated: (c) => _controller = c,
          ),
        ],
      );
}
