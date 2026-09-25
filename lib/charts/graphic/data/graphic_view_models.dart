// Modelos de vista para las 63 gráficas de Graphic.
//
// Son modelos PROPIOS de la capa de presentación de Graphic: pequeños,
// inmutables y sin dependencias de GraphQL. Se construyen a partir de los
// Chart Models del proyecto (ChartDataCategory, ChartDataXY, ChartSeries,
// ChartDataRange...) mediante `graphic_adapters.dart`.
//
// Regla de arquitectura:
//   AniList → DataSource → Repository → Domain → Provider
//   → DataTransformations → Chart Models → [adapters] → estos modelos → Chart

/// Un título de AniList con los campos que usan las gráficas.
///
/// Todos los campos corresponden a campos reales de `Media` en AniList.
/// Los opcionales son nulos cuando AniList no los devuelve.
class GAnime {
  const GAnime({
    required this.title,
    required this.popularity,
    required this.format,
    required this.status,
    this.score,
    this.episodes,
    this.genres = const [],
    this.seasonYear,
    this.startYear,
    this.endYear,
    this.rank,
    this.studio,
  });

  final String title; // title.romaji / english
  final num? score; // averageScore (0-100)
  final num popularity; // popularity
  final int? episodes; // episodes
  final String format; // format (TV, MOVIE, OVA...)
  final String status; // status (FINISHED, RELEASING...)
  final List<String> genres; // genres
  final int? seasonYear; // seasonYear
  final int? startYear; // startDate.year
  final int? endYear; // endDate.year
  final int? rank; // rankings[].rank (el que corresponda: p. ej. allTime popular)
  final String? studio; // studios.nodes.first.name
}

/// Punto de `Media.trends` (serie temporal diaria REAL de AniList, no financiera).
class GTrendPoint {
  const GTrendPoint(this.date, this.popularity);
  final DateTime date;
  final num popularity;
}

/// Categoría → valor (pie, barras, funnel...).
class GCategory {
  const GCategory(this.label, this.value);
  final String label;
  final num value;
}

/// Fila en formato largo para multiserie (x, valor, serie).
class GSeriesPoint {
  const GSeriesPoint(this.x, this.value, this.series);
  final String x;
  final num value;
  final String series;
}

/// Rango [low, high] por categoría.
class GRange {
  const GRange(this.x, this.low, this.high);
  final String x;
  final num low;
  final num high;
}

/// Punto X-Y numérico con fecha opcional (pan & zoom, gapless, log...).
class GDatedValue {
  const GDatedValue(this.date, this.label, this.value);
  final DateTime date;
  final String label;
  final num value;
}

/// Paso de cascada (waterfall): va de [from] a [to].
class GWaterfallStep {
  const GWaterfallStep(this.label, this.from, this.to, {this.isTotal = false});
  final String label;
  final num from;
  final num to;
  final bool isTotal;
}

/// Resumen de cinco números para box plot.
class GBoxStat {
  const GBoxStat(this.label, this.min, this.q1, this.median, this.q3, this.max);
  final String label;
  final num min;
  final num q1;
  final num median;
  final num q3;
  final num max;
}

/// Media ± desviación estándar para barras de error.
class GErrorStat {
  const GErrorStat(this.label, this.low, this.mean, this.high);
  final String label;
  final num low;
  final num mean;
  final num high;
}

/// Punto con valor observado y valor ajustado por regresión.
class GRegressionPoint {
  const GRegressionPoint(this.x, this.y, this.fitted);
  final num x;
  final num y;
  final num fitted;
}

/// Vela OHLC adaptada: se construye agrupando la variación diaria de
/// popularidad de `Media.trends`. AniList NO proporciona cotizaciones.
class GOhlc {
  const GOhlc(this.label, this.open, this.high, this.low, this.close);
  final String label;
  final num open;
  final num high;
  final num low;
  final num close;
}

/// Banda de Bollinger calculada sobre una serie temporal.
class GBollingerPoint {
  const GBollingerPoint(this.label, this.value, this.mid, this.lower, this.upper);
  final String label;
  final num value;
  final num mid;
  final num lower;
  final num upper;
}

/// Punto MACD.
class GMacdPoint {
  const GMacdPoint(this.label, this.macd, this.signal, this.histogram);
  final String label;
  final num macd;
  final num signal;
  final num histogram;
}
