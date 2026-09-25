// Transformaciones puras (sin Flutter, sin Graphic) para las gráficas que
// necesitan datos DERIVADOS.
//
// Graphic NO calcula bins, acumulados, cuartiles, desviaciones, regresiones
// ni indicadores. Todo eso se calcula aquí, fuera del renderer.
//
// Si el proyecto ya tiene una clase `DataTransformations`, mover estas
// funciones allí (o llamarlas desde allí). No dependen de nada externo.

import 'dart:math' as math;

import 'graphic_view_models.dart';

class GraphicTransformations {
  const GraphicTransformations._();

  // ---------------------------------------------------------------------
  // Estadística básica
  // ---------------------------------------------------------------------

  static double mean(Iterable<num> values) {
    if (values.isEmpty) return double.nan;
    return values.fold<double>(0, (a, b) => a + b.toDouble()) / values.length;
  }

  /// Desviación estándar poblacional.
  static double stdDev(Iterable<num> values) {
    if (values.length < 2) return 0;
    final m = mean(values);
    final variance = values.fold<double>(0, (a, b) {
          final d = b.toDouble() - m;
          return a + d * d;
        }) /
        values.length;
    return math.sqrt(variance);
  }

  /// Cuantil por interpolación lineal (método R-7, el de Excel/NumPy).
  static double quantile(List<num> sorted, double q) {
    if (sorted.isEmpty) return double.nan;
    if (sorted.length == 1) return sorted.first.toDouble();
    final pos = (sorted.length - 1) * q;
    final lower = pos.floor();
    final upper = pos.ceil();
    final lo = sorted[lower].toDouble();
    final hi = sorted[upper].toDouble();
    if (lower == upper) return lo;
    return lo + (hi - lo) * (pos - lower);
  }

  // ---------------------------------------------------------------------
  // #16 Histogram
  // ---------------------------------------------------------------------

  /// Agrupa [values] en intervalos de ancho [binWidth] entre [min] y [max].
  /// Devuelve una categoría por bin (etiqueta "50-60") con su frecuencia.
  static List<GCategory> histogramBins(
    Iterable<num> values, {
    num binWidth = 10,
    num min = 0,
    num max = 100,
  }) {
    final binCount = ((max - min) / binWidth).ceil();
    final counts = List<int>.filled(binCount, 0);
    for (final v in values) {
      if (v < min || v > max) continue;
      var i = ((v - min) / binWidth).floor();
      if (i >= binCount) i = binCount - 1; // el valor máximo entra en el último bin
      counts[i]++;
    }
    return [
      for (var i = 0; i < binCount; i++)
        GCategory(
          '${_fmt(min + i * binWidth)}-${_fmt(min + (i + 1) * binWidth)}',
          counts[i],
        ),
    ];
  }

  // ---------------------------------------------------------------------
  // #12 / #13 acumulados
  // ---------------------------------------------------------------------

  static List<GCategory> cumulative(List<GCategory> items) {
    var acc = 0.0;
    final out = <GCategory>[];
    for (final c in items) {
      acc += c.value.toDouble();
      out.add(GCategory(c.label, acc));
    }
    return out;
  }

  // ---------------------------------------------------------------------
  // #28 Waterfall
  // ---------------------------------------------------------------------

  /// Convierte una serie ordenada en pasos de cascada:
  /// primer valor como base, luego las diferencias, y un total final.
  static List<GWaterfallStep> waterfall(List<GCategory> ordered) {
    if (ordered.isEmpty) return const [];
    final steps = <GWaterfallStep>[
      GWaterfallStep(ordered.first.label, 0, ordered.first.value, isTotal: true),
    ];
    var current = ordered.first.value;
    for (var i = 1; i < ordered.length; i++) {
      final next = ordered[i].value;
      steps.add(GWaterfallStep(ordered[i].label, current, next));
      current = next;
    }
    steps.add(GWaterfallStep('Total', 0, current, isTotal: true));
    return steps;
  }

  // ---------------------------------------------------------------------
  // #34 Box and Whisker
  // ---------------------------------------------------------------------

  static GBoxStat fiveNumberSummary(String label, Iterable<num> values) {
    final sorted = values.toList()..sort();
    return GBoxStat(
      label,
      sorted.first,
      quantile(sorted, 0.25),
      quantile(sorted, 0.5),
      quantile(sorted, 0.75),
      sorted.last,
    );
  }

  // ---------------------------------------------------------------------
  // #35 Error Bars
  // ---------------------------------------------------------------------

  static GErrorStat meanStd(String label, Iterable<num> values) {
    final m = mean(values);
    final s = stdDev(values);
    return GErrorStat(label, m - s, m, m + s);
  }

  // ---------------------------------------------------------------------
  // #45 Trendline Regression (mínimos cuadrados)
  // ---------------------------------------------------------------------

  /// Devuelve los puntos ordenados por x con su valor ajustado `a + b·x`.
  static List<GRegressionPoint> linearRegression(List<({num x, num y})> points) {
    if (points.length < 2) return const [];
    final mx = mean(points.map((p) => p.x));
    final my = mean(points.map((p) => p.y));
    var sxy = 0.0, sxx = 0.0;
    for (final p in points) {
      final dx = p.x.toDouble() - mx;
      sxy += dx * (p.y.toDouble() - my);
      sxx += dx * dx;
    }
    final slope = sxx == 0 ? 0.0 : sxy / sxx;
    final intercept = my - slope * mx;
    final sorted = [...points]..sort((a, b) => a.x.compareTo(b.x));
    return [
      for (final p in sorted) GRegressionPoint(p.x, p.y, intercept + slope * p.x),
    ];
  }

  // ---------------------------------------------------------------------
  // #41 SMA
  // ---------------------------------------------------------------------

  /// Media móvil simple. Los primeros `period - 1` puntos son `null`.
  static List<double?> sma(List<num> values, int period) {
    final out = List<double?>.filled(values.length, null);
    var sum = 0.0;
    for (var i = 0; i < values.length; i++) {
      sum += values[i].toDouble();
      if (i >= period) sum -= values[i - period].toDouble();
      if (i >= period - 1) out[i] = sum / period;
    }
    return out;
  }

  // ---------------------------------------------------------------------
  // #42 Bollinger Bands
  // ---------------------------------------------------------------------

  static List<GBollingerPoint> bollinger(
    List<String> labels,
    List<num> values, {
    int period = 20,
    double k = 2,
  }) {
    final out = <GBollingerPoint>[];
    for (var i = period - 1; i < values.length; i++) {
      final window = values.sublist(i - period + 1, i + 1);
      final m = mean(window);
      final s = stdDev(window);
      out.add(GBollingerPoint(labels[i], values[i], m, m - k * s, m + k * s));
    }
    return out;
  }

  // ---------------------------------------------------------------------
  // #43 RSI (Wilder)
  // ---------------------------------------------------------------------

  /// RSI de Wilder. Devuelve `null` en los primeros [period] puntos.
  static List<double?> rsi(List<num> values, {int period = 14}) {
    final out = List<double?>.filled(values.length, null);
    if (values.length <= period) return out;
    var gain = 0.0, loss = 0.0;
    for (var i = 1; i <= period; i++) {
      final d = values[i].toDouble() - values[i - 1].toDouble();
      if (d >= 0) {
        gain += d;
      } else {
        loss -= d;
      }
    }
    var avgGain = gain / period, avgLoss = loss / period;
    out[period] = _rsiValue(avgGain, avgLoss);
    for (var i = period + 1; i < values.length; i++) {
      final d = values[i].toDouble() - values[i - 1].toDouble();
      avgGain = (avgGain * (period - 1) + (d > 0 ? d : 0.0)) / period;
      avgLoss = (avgLoss * (period - 1) + (d < 0 ? -d : 0.0)) / period;
      out[i] = _rsiValue(avgGain, avgLoss);
    }
    return out;
  }

  static double _rsiValue(double avgGain, double avgLoss) {
    if (avgLoss == 0) return 100;
    final rs = avgGain / avgLoss;
    return 100 - 100 / (1 + rs);
  }

  // ---------------------------------------------------------------------
  // #44 MACD
  // ---------------------------------------------------------------------

  static List<double> ema(List<num> values, int period) {
    if (values.isEmpty) return const [];
    final k = 2 / (period + 1);
    final out = <double>[values.first.toDouble()];
    for (var i = 1; i < values.length; i++) {
      out.add(values[i].toDouble() * k + out[i - 1] * (1 - k));
    }
    return out;
  }

  /// MACD(12, 26, 9). Se descartan los primeros [slow] puntos (EMA inestable).
  static List<GMacdPoint> macd(
    List<String> labels,
    List<num> values, {
    int fast = 12,
    int slow = 26,
    int signal = 9,
  }) {
    if (values.length <= slow) return const [];
    final emaFast = ema(values, fast);
    final emaSlow = ema(values, slow);
    final macdLine = [for (var i = 0; i < values.length; i++) emaFast[i] - emaSlow[i]];
    final signalLine = ema(macdLine, signal);
    return [
      for (var i = slow; i < values.length; i++)
        GMacdPoint(labels[i], macdLine[i], signalLine[i], macdLine[i] - signalLine[i]),
    ];
  }

  // ---------------------------------------------------------------------
  // #57 Win-Loss
  // ---------------------------------------------------------------------

  /// +1 si el valor supera la [reference], -1 si queda por debajo, 0 si empata.
  static List<GCategory> winLoss(List<GCategory> items, num reference) => [
        for (final c in items)
          GCategory(c.label, c.value > reference ? 1 : (c.value < reference ? -1 : 0)),
      ];

  // ---------------------------------------------------------------------
  // #17-#24 alineación de series para StackModifier
  // ---------------------------------------------------------------------

  /// Completa con 0 todas las combinaciones (x, serie) que falten y ordena
  /// por [xOrder] y [seriesOrder]. StackModifier exige que todas las series
  /// tengan las mismas x en el mismo orden.
  static List<GSeriesPoint> alignSeries(
    List<GSeriesPoint> points, {
    required List<String> xOrder,
    required List<String> seriesOrder,
  }) {
    final map = <String, num>{
      for (final p in points) '${p.x}\u0000${p.series}': p.value,
    };
    return [
      for (final s in seriesOrder)
        for (final x in xOrder) GSeriesPoint(x, map['$x\u0000$s'] ?? 0, s),
    ];
  }

  static String _fmt(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
