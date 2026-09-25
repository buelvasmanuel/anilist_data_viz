// Financieros, estadísticos e indicadores: #32, #33, #34, #35, #41, #42, #43, #44.
//
// Reglas de datos:
// - #32 y #33: AniList NO tiene OHLC → datos SINTÉTICOS etiquetados.
// - #34 y #35: DERIVADOS de averageScore (cuartiles, media ± σ).
// - #41-#44: DERIVADOS de Media.trends (serie temporal REAL, NO financiera).
//   Si el DataSource no consulta trends → NO DISPONIBLE (no se inventa nada).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import '../data/graphic_view_models.dart';
import '../shapes/graphic_custom_shapes.dart';
import 'graphic_chart_helpers.dart';

const _noTrends =
    'NO DISPONIBLE: el DataSource no consulta Media.trends.\n'
    'AniList no ofrece otra serie temporal adecuada para este indicador.';

const _trendsNotice =
    'Indicador calculado sobre Media.trends (popularidad diaria de AniList). No es un dato financiero.';


/// #32 Candlestick — NATIVO (capacidad gráfica) — NO DISPONIBLE en AniList.
/// Orden de posición de CandlestickShape: [start, end, max, min].
Widget g32Candlestick(GraphicDataset d) {
  return const GraphicEmptyState('NO DISPONIBLE: AniList no proporciona datos financieros OHLC.');
}

/// #33 HLOC — COMPOSICIÓN (Shape propio) — NO DISPONIBLE en AniList.
/// Orden de posición de HlocShape: [open, high, low, close].
Widget g33Hloc(GraphicDataset d) {
  return const GraphicEmptyState('NO DISPONIBLE: AniList no proporciona datos financieros OHLC.');
}

/// #34 Box and Whisker — COMPOSICIÓN — DERIVADO (cuartiles de score por formato).
Widget g34BoxPlot(GraphicDataset d) => guard(
      d.boxByFormat.isNotEmpty,
      () {
        final s = LinearScale(min: 0, max: 100); // misma escala para las 5 variables
        return Chart<GBoxStat>(
          data: d.boxByFormat,
          variables: {
            'format': Variable<GBoxStat, String>(accessor: (b) => b.label),
            'min': Variable<GBoxStat, num>(accessor: (b) => b.min, scale: s),
            'q1': Variable<GBoxStat, num>(accessor: (b) => b.q1, scale: s),
            'median': Variable<GBoxStat, num>(accessor: (b) => b.median, scale: s),
            'q3': Variable<GBoxStat, num>(accessor: (b) => b.q3, scale: s),
            'max': Variable<GBoxStat, num>(accessor: (b) => b.max, scale: s),
          },
          marks: [
            CustomMark(
              shape: ShapeEncode(value: BoxPlotShape()),
              position: Varset('format') *
                  (Varset('min') + Varset('q1') + Varset('median') + Varset('q3') + Varset('max')),
              color: ColorEncode(variable: 'format', values: graphicPalette),
              size: SizeEncode(value: 28),
            ),
          ],
          axes: standardAxes,
        );
      },
    );

/// #35 Error Bars — COMPOSICIÓN — DERIVADO (media ± σ de score por género).
Widget g35ErrorBars(GraphicDataset d) => guard(
      d.errorByGenre.isNotEmpty,
      () {
        final s = sharedScale([for (final e in d.errorByGenre) ...[e.low, e.high]], padding: 5);
        return Chart<GErrorStat>(
          data: d.errorByGenre,
          variables: {
            'genre': Variable<GErrorStat, String>(accessor: (e) => e.label),
            'low': Variable<GErrorStat, num>(accessor: (e) => e.low, scale: s),
            'mean': Variable<GErrorStat, num>(accessor: (e) => e.mean, scale: s),
            'high': Variable<GErrorStat, num>(accessor: (e) => e.high, scale: s),
          },
          marks: [
            CustomMark(
              shape: ShapeEncode(value: ErrorBarShape()),
              position: Varset('genre') * (Varset('low') + Varset('mean') + Varset('high')),
              color: ColorEncode(value: Colors.black87),
            ),
          ],
          axes: standardAxes,
        );
      },
    );

/// #41 SMA — VARIANTE — DERIVADO de Media.trends (o NO DISPONIBLE).
Widget g41Sma(GraphicDataset d) {
  if (!d.hasTrends) return const GraphicEmptyState(_noTrends);
  return Column(children: [
    const GraphicNotice(_trendsNotice, color: Color(0xFF1565C0)),
    Expanded(
      child: Chart<GSeriesPoint>(
        data: d.trendSma,
        variables: {
          'x': Variable<GSeriesPoint, String>(accessor: (p) => p.x, scale: OrdinalScale(tickCount: 5)),
          'value': Variable<GSeriesPoint, num>(
            accessor: (p) => p.value,
            scale: sharedScale([for (final p in d.trendSma) p.value]),
          ),
          'series': Variable<GSeriesPoint, String>(accessor: (p) => p.series),
        },
        marks: [
          LineMark(
            position: Varset('x') * Varset('value') / Varset('series'),
            color: ColorEncode(variable: 'series', values: [Colors.blueGrey, Colors.orange]),
          ),
        ],
        axes: standardAxes,
      ),
    ),
  ]);
}

/// #42 Bollinger Bands — VARIANTE — DERIVADO de Media.trends (o NO DISPONIBLE).
Widget g42Bollinger(GraphicDataset d) {
  final pts = d.bollingerPoints;
  if (!d.hasTrends || pts.length < 5) return const GraphicEmptyState(_noTrends);
  final s = sharedScale([for (final p in pts) ...[p.lower, p.upper, p.value]]);
  return Column(children: [
    const GraphicNotice(_trendsNotice, color: Color(0xFF1565C0)),
    Expanded(
      child: Chart<GBollingerPoint>(
        data: pts,
        variables: {
          'x': Variable<GBollingerPoint, String>(accessor: (p) => p.label, scale: OrdinalScale(tickCount: 5)),
          'value': Variable<GBollingerPoint, num>(accessor: (p) => p.value, scale: s),
          'mid': Variable<GBollingerPoint, num>(accessor: (p) => p.mid, scale: s),
          'lower': Variable<GBollingerPoint, num>(accessor: (p) => p.lower, scale: s),
          'upper': Variable<GBollingerPoint, num>(accessor: (p) => p.upper, scale: s),
        },
        marks: [
          AreaMark(
            position: Varset('x') * (Varset('lower') + Varset('upper')),
            color: ColorEncode(value: Colors.blue.withAlpha(40)),
          ),
          LineMark(position: Varset('x') * Varset('mid'), color: ColorEncode(value: Colors.blue)),
          LineMark(position: Varset('x') * Varset('value'), color: ColorEncode(value: Colors.black87)),
        ],
        axes: standardAxes,
      ),
    ),
  ]);
}

/// #43 RSI — VARIANTE — DERIVADO de Media.trends (o NO DISPONIBLE).
/// Panel de RSI sincronizado con el panel principal mediante un
/// `gestureStream` compartido (patrón oficial "Event Stream coupling").
class G43Rsi extends StatefulWidget {
  const G43Rsi(this.data, {super.key});
  final GraphicDataset data;

  @override
  State<G43Rsi> createState() => _G43RsiState();
}

class _G43RsiState extends State<G43Rsi> {
  final _gestures = StreamController<GestureEvent>.broadcast();

  @override
  void dispose() {
    _gestures.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    if (!d.hasTrends || d.rsiPoints.length < 5) return const GraphicEmptyState(_noTrends);
    final rsiLabels = {for (final p in d.rsiPoints) p.label};
    final main = [
      for (var i = 0; i < d.trendLabels.length; i++)
        if (rsiLabels.contains(d.trendLabels[i])) GCategory(d.trendLabels[i], d.trendValues[i]),
    ];
    final zoom = RectCoord(horizontalRangeUpdater: Defaults.horizontalRangeEvent);
    return Column(children: [
      const GraphicNotice(_trendsNotice, color: Color(0xFF1565C0)),
      Expanded(
        flex: 2,
        child: Chart(
          data: main,
          gestureStream: _gestures,
          variables: categoryVars(yScale: sharedScale([for (final c in main) c.value])),
          marks: [LineMark(position: Varset('x') * Varset('y'))],
          coord: zoom,
          axes: [Defaults.verticalAxis],
        ),
      ),
      Expanded(
        child: Chart(
          data: d.rsiPoints,
          gestureStream: _gestures,
          variables: {
            'x': Variable<GCategory, String>(accessor: (c) => c.label, scale: OrdinalScale(tickCount: 5)),
            'y': Variable<GCategory, num>(accessor: (c) => c.value, scale: LinearScale(min: 0, max: 100)),
          },
          marks: [LineMark(position: Varset('x') * Varset('y'), color: ColorEncode(value: Colors.purple))],
          annotations: [
            RegionAnnotation(dim: Dim.y, values: [70, 100], color: Colors.red.withAlpha(30)),
            RegionAnnotation(dim: Dim.y, values: [0, 30], color: Colors.green.withAlpha(30)),
          ],
          coord: RectCoord(horizontalRangeUpdater: Defaults.horizontalRangeEvent),
          axes: standardAxes,
        ),
      ),
    ]);
  }
}

/// #44 MACD — VARIANTE — DERIVADO de Media.trends (o NO DISPONIBLE).
Widget g44Macd(GraphicDataset d) {
  final pts = d.macdPoints;
  if (!d.hasTrends || pts.length < 5) return const GraphicEmptyState(_noTrends);
  final s = sharedScale([for (final p in pts) ...[p.macd, p.signal, p.histogram]]);
  return Column(children: [
    const GraphicNotice(_trendsNotice, color: Color(0xFF1565C0)),
    Expanded(
      child: Chart<GMacdPoint>(
        data: pts,
        variables: {
          'x': Variable<GMacdPoint, String>(accessor: (p) => p.label, scale: OrdinalScale(tickCount: 5)),
          'macd': Variable<GMacdPoint, num>(accessor: (p) => p.macd, scale: s),
          'signal': Variable<GMacdPoint, num>(accessor: (p) => p.signal, scale: s),
          'hist': Variable<GMacdPoint, num>(accessor: (p) => p.histogram, scale: s),
        },
        marks: [
          IntervalMark(
            position: Varset('x') * Varset('hist'),
            color: ColorEncode(encoder: (t) => (t['hist'] as num) >= 0 ? Colors.green : Colors.red),
          ),
          LineMark(position: Varset('x') * Varset('macd'), color: ColorEncode(value: Colors.blue)),
          LineMark(position: Varset('x') * Varset('signal'), color: ColorEncode(value: Colors.orange)),
        ],
        axes: standardAxes,
      ),
    ),
  ]);
}
