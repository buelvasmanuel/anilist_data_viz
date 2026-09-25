// Piezas comunes a los 252 casos (63 × 4 librerías).
//
// Cada librería expone un `Map<int, CaseImpl>` con los 63 casos maestros.
// La clasificación de CAPACIDAD de la librería vive en `masterChartRegistry`;
// aquí se describe cómo el proyecto consigue DIBUJAR el caso
// ([ImplementationStrategy]), de dónde salen los datos y con qué API.

import 'package:anilist_data_viz/charts/graphic/data/graphic_dataset.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_view_models.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:flutter/material.dart';

/// Cómo se dibuja el caso en el proyecto (independiente de la capacidad
/// teórica registrada en la matriz).
enum ImplementationStrategy {
  /// Widget/serie de la librería usado directamente.
  nativo('NATIVO', Color(0xFF2E7D32)),

  /// Configuración de un gráfico nativo o datos preparados antes.
  variante('VARIANTE', Color(0xFF1565C0)),

  /// La librería combinada con widgets o estado de Flutter.
  composicion('COMPOSICIÓN', Color(0xFFEF6C00)),

  /// Representación visual equivalente construida con otro gráfico de la
  /// librería (p. ej. un funnel dibujado con barras centradas) o sobre datos
  /// adaptados (velas sobre popularidad). Se explica en la nota del caso.
  adaptacion('ADAPTACIÓN', Color(0xFF6A1B9A));

  const ImplementationStrategy(this.label, this.color);
  final String label;
  final Color color;
}

/// Grupos de la galería para filtrar los 63 casos.
enum CaseCategory {
  basicos('Básicos'),
  apiladosRangos('Apilados / Rangos'),
  interaccion('Interacción'),
  escalas('Escalas'),
  estadisticos('Estadísticos'),
  especiales('Especiales');

  const CaseCategory(this.label);
  final String label;
}

CaseCategory caseCategoryOf(int number) {
  if (number <= 15 || number == 29 || number == 31) return CaseCategory.basicos;
  if (number >= 17 && number <= 28) return CaseCategory.apiladosRangos;
  if ({16, 32, 33, 34, 35, 41, 42, 43, 44, 45}.contains(number)) return CaseCategory.estadisticos;
  if ({38, 39, 40, 52, 55, 56, 60, 61, 63}.contains(number)) return CaseCategory.interaccion;
  if ({36, 37, 46, 47, 50, 51, 62}.contains(number)) return CaseCategory.escalas;
  return CaseCategory.especiales;
}

/// Datos que recibe cada builder. Todo sale de la muestra real de AniList
/// ya cargada por `ChartsDatasetProvider`.
class CaseData {
  /// Dataset común precalculado (GraphicTransformations). Pese al nombre,
  /// lo usan las cuatro librerías para que cada caso muestre los mismos datos.
  final GraphicDataset g;
  final List<Media> media;

  /// 'ANIME' o 'MANGA'.
  final String type;

  /// Obra de la que se descargó `Media.trends`.
  final String? trendsTitle;

  /// Error al descargar trends ('' si no hubo).
  final String trendsError;

  const CaseData({
    required this.g,
    required this.media,
    required this.type,
    this.trendsTitle,
    this.trendsError = '',
  });
}

typedef CaseBuilder = Widget Function(BuildContext context, CaseData data);

/// Implementación de un caso maestro en una librería.
class CaseImpl {
  final ImplementationStrategy strategy;

  /// Origen de los datos (campo de AniList y transformación).
  final String origin;

  /// Widgets/API de la librería que se usan.
  final String api;

  /// Aclaración visible sobre adaptaciones o límites (opcional).
  final String? note;

  final CaseBuilder builder;

  const CaseImpl({
    required this.strategy,
    required this.origin,
    required this.api,
    required this.builder,
    this.note,
  });
}

// --------------------------------------------------------------------------
// Textos compartidos
// --------------------------------------------------------------------------

const ohlcNote = 'Candlestick adaptado a tendencia de popularidad AniList. '
    'No representa cotización financiera. Cada vela = 7 días de la variación '
    'diaria de popularidad (open = primer día, high = máximo, low = mínimo, close = último día).';

const hlocNote = 'HLOC adaptado a tendencia de popularidad AniList (misma agrupación semanal que #32). '
    'No representa cotización financiera.';

const trendsIndicatorNote = 'Indicador calculado sobre la variación diaria de popularidad '
    '(Media.trends de AniList). No es un dato financiero.';

const trendsOrigin = 'DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria';

// --------------------------------------------------------------------------
// Adaptadores del dataset común a los Chart Models del proyecto
// --------------------------------------------------------------------------

List<ChartDataCategory> toCategories(Iterable<GCategory> items) =>
    [for (final c in items) ChartDataCategory(category: c.label, value: c.value)];

/// Categorías con etiqueta numérica (años) → puntos X-Y. Si la etiqueta no
/// es numérica se usa la posición.
List<ChartDataXY> toXY(List<GCategory> items) => [
      for (var i = 0; i < items.length; i++)
        ChartDataXY(x: num.tryParse(items[i].label) ?? i, y: items[i].value, label: items[i].label),
    ];

/// Formato largo (x, valor, serie) → una [ChartSeries] por serie.
List<ChartSeries<ChartDataCategory>> toCategorySeries(List<GSeriesPoint> points) {
  final bySeries = <String, List<ChartDataCategory>>{};
  for (final p in points) {
    (bySeries[p.series] ??= []).add(ChartDataCategory(category: p.x, value: p.value));
  }
  return [for (final e in bySeries.entries) ChartSeries(seriesName: e.key, data: e.value)];
}

/// Formato largo con x numérica (años) → series X-Y.
List<ChartSeries<ChartDataXY>> toXYSeries(List<GSeriesPoint> points) {
  final bySeries = <String, List<ChartDataXY>>{};
  final xs = <String>[];
  for (final p in points) {
    if (!xs.contains(p.x)) xs.add(p.x);
  }
  for (final p in points) {
    (bySeries[p.series] ??= [])
        .add(ChartDataXY(x: num.tryParse(p.x) ?? xs.indexOf(p.x), y: p.value, label: p.x));
  }
  return [for (final e in bySeries.entries) ChartSeries(seriesName: e.key, data: e.value)];
}

/// Normaliza cada x del formato largo para que las series sumen 100.
List<GSeriesPoint> toPercent(List<GSeriesPoint> points) {
  final totals = <String, num>{};
  for (final p in points) {
    totals[p.x] = (totals[p.x] ?? 0) + p.value;
  }
  return [
    for (final p in points)
      GSeriesPoint(p.x, totals[p.x] == 0 ? 0 : p.value * 100 / totals[p.x]!, p.series),
  ];
}

/// Acumula el formato largo por serie (para "stacked line" dibujado a mano).
List<GSeriesPoint> toStackedCumulative(List<GSeriesPoint> points) {
  final running = <String, num>{};
  return [
    for (final p in points)
      GSeriesPoint(p.x, running[p.x] = (running[p.x] ?? 0) + p.value, p.series),
  ];
}

String shortLabel(String s, [int max = 14]) => s.length <= max ? s : '${s.substring(0, max - 1)}…';

// --------------------------------------------------------------------------
// Widgets comunes
// --------------------------------------------------------------------------

/// Aviso sobre el gráfico (adaptación, fuente de datos, límites).
class CaseNote extends StatelessWidget {
  const CaseNote(this.text, {super.key, this.color = const Color(0xFF6A1B9A)});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withAlpha(28), borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

/// Problema técnico temporal que impide dibujar (p. ej. fallo de red al
/// pedir trends). No es un estado final: al recargar se intenta de nuevo.
class TechnicalIssue extends StatelessWidget {
  const TechnicalIssue(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      );
}

/// Dibuja [build] si hay serie de trends; si no, informa del fallo técnico.
Widget withTrends(CaseData d, Widget Function() build) {
  if (d.g.hasTrends) return build();
  return TechnicalIssue(
    'No se pudo cargar Media.trends desde AniList'
    '${d.trendsError.isEmpty ? '' : ': ${d.trendsError}'}. Cambia Anime/Manga para reintentar.',
  );
}

/// Gráfico con una nota encima.
Widget noted(String note, Widget chart) => Column(
      children: [CaseNote(note), Expanded(child: chart)],
    );

/// Leyenda simple (color + etiqueta) como widget Flutter.
class SimpleLegend extends StatelessWidget {
  const SimpleLegend({super.key, required this.labels, required this.colors});
  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 2,
        children: [
          for (var i = 0; i < labels.length; i++)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, color: colors[i % colors.length]),
              const SizedBox(width: 4),
              Text(labels[i], style: const TextStyle(fontSize: 10)),
            ]),
        ],
      );
}

/// Paleta categórica común para las composiciones hechas a mano.
const casePalette = <Color>[
  Color(0xFF42A5F5),
  Color(0xFFEF5350),
  Color(0xFF66BB6A),
  Color(0xFFFFA726),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
  Color(0xFFD4E157),
  Color(0xFF8D6E63),
  Color(0xFFEC407A),
  Color(0xFF78909C),
];

// --------------------------------------------------------------------------
// Origen de datos por caso (el mismo en FL Chart, Syncfusion y DChart para
// que la comparación 63×4 sea directa). Graphic declara el suyo.
// --------------------------------------------------------------------------

const _scoreYear = 'DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra)';
const _countYear = 'DERIVADO: obras por año de inicio (últimos 10 años de la muestra)';
const _yearFormat = 'DERIVADO: obras por año × format (4 formatos más frecuentes)';
const _genreStatus = 'DERIVADO: obras por género × status (5 géneros más frecuentes)';

const Map<int, String> sharedCaseOrigins = {
  1: _scoreYear,
  2: 'DIRECTO: popularity de las 10 obras más populares',
  3: 'DIRECTO: averageScore de las 10 obras mejor puntuadas',
  4: _scoreYear,
  5: _countYear,
  6: _countYear,
  7: 'DERIVADO: obras por format',
  8: 'DERIVADO: obras por status',
  9: 'DIRECTO: averageScore de las 5 obras mejor puntuadas',
  10: 'DIRECTO: popularity × averageScore de cada obra puntuada',
  11: 'DIRECTO: popularity × averageScore; tamaño = episodes',
  12: 'DERIVADO: obras acumuladas por año de inicio',
  13: 'DERIVADO: obras acumuladas por año de inicio',
  14: 'DERIVADO: obras por format, ordenado',
  15: 'DERIVADO: obras por status, ordenado',
  16: 'DERIVADO: bins de 10 puntos de averageScore',
  17: _yearFormat,
  18: _genreStatus,
  19: _yearFormat,
  20: _yearFormat,
  21: '$_yearFormat, normalizado a 100 %',
  22: '$_genreStatus, normalizado a 100 %',
  23: '$_yearFormat, normalizado a 100 %',
  24: '$_yearFormat, normalizado a 100 %',
  25: 'DIRECTO: startDate.year – endDate.year de las obras más populares',
  26: 'DERIVADO: averageScore mínimo y máximo por año',
  27: 'DERIVADO: averageScore mínimo y máximo por año',
  28: 'DERIVADO: variación de obras de un año al siguiente (cascada)',
  29: _scoreYear,
  30: 'DERIVADO: averageScore medio del género − media de la muestra',
  31: _countYear,
  32: '$trendsOrigin → velas de 7 días',
  33: '$trendsOrigin → velas de 7 días',
  34: 'DERIVADO: cuartiles de averageScore por format',
  35: 'DERIVADO: media ± desviación estándar de averageScore por género',
  36: 'DERIVADO: obras por año (columnas) + averageScore medio por año (línea)',
  37: 'DIRECTO: popularity y averageScore de las 10 obras más populares',
  38: 'DIRECTO: popularity de cada obra, ordenada por año de inicio',
  39: _scoreYear,
  40: _yearFormat,
  41: '$trendsOrigin → SMA de 7 días',
  42: '$trendsOrigin → bandas de Bollinger (20 días, ±2σ)',
  43: '$trendsOrigin → RSI de Wilder (14 días)',
  44: '$trendsOrigin → MACD (12, 26, 9)',
  45: 'DERIVADO: regresión lineal de averageScore sobre popularity',
  46: 'DIRECTO: averageScore de las 10 más populares + media de la muestra',
  47: 'DIRECTO: popularity de las 10 obras más populares',
  48: 'DERIVADO: averageScore medio por año comparado con la media de la muestra',
  49: 'DIRECTO: averageScore de las 10 obras mejor puntuadas',
  50: 'DERIVADO: obras por año de inicio con eje ordinal (sin huecos)',
  51: 'DIRECTO: popularity de obras repartidas por toda la muestra (escala log10)',
  52: 'DIRECTO: popularity de páginas pedidas a AniList bajo demanda (Page, perPage 20)',
  53: 'DERIVADO: obras por format',
  54: 'DIRECTO: averageScore de la obra más popular',
  55: _countYear,
  56: 'DIRECTO: averageScore de las 5 obras mejor puntuadas',
  57: 'DERIVADO: score medio del año por encima (+1) o por debajo (−1) de la media',
  58: _countYear,
  59: 'DIRECTO: popularity × averageScore; forma = format',
  60: 'DIRECTO: popularity, averageScore, format y episodes de las 10 más populares',
  61: 'DIRECTO: popularity de las 10 obras más populares',
  62: 'DIRECTO: rankings "highest rated all time" de AniList',
  63: 'DIRECTO: popularity actual de las 5 obras más populares, consultada periódicamente',
};

/// Obras puntuadas de la muestra.
List<GAnime> scoredTitles(GraphicDataset g) => [for (final a in g.titles) if (a.score != null) a];

/// [count] obras repartidas uniformemente por la muestra ordenada por popularidad.
List<GAnime> spreadByPopularity(GraphicDataset g, {int count = 12}) {
  final sorted = [...g.titles]..sort((a, b) => b.popularity.compareTo(a.popularity));
  if (sorted.length <= count) return sorted;
  final step = (sorted.length - 1) / (count - 1);
  return [for (var i = 0; i < count; i++) sorted[(i * step).round()]];
}
