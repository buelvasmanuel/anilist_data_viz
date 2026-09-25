// Los 63 casos de Graphic en el formato común de las galerías.
//
// No rehace nada: toma los builders g01…g63 de `graphicChartRegistry` y les
// añade la estrategia de implementación, el origen de datos y las notas.

import 'package:anilist_data_viz/charts/common/case_support.dart';

import 'common/graphic_common.dart';
import 'graphic_chart_registry.dart';

const Map<int, String> _origins = {
  1: 'DERIVADO: averageScore medio por año (scoreByYear)',
  2: 'DIRECTO: popularity de las 10 obras más populares',
  3: 'DIRECTO: averageScore de las 10 mejor puntuadas',
  4: 'DERIVADO: averageScore medio por año (scoreByYear)',
  5: 'DERIVADO: obras por año (countByYear)',
  6: 'DERIVADO: obras por año (countByYear)',
  7: 'DERIVADO: obras por format',
  8: 'DERIVADO: obras por status',
  9: 'DIRECTO: averageScore de las 5 mejor puntuadas',
  10: 'DIRECTO: popularity × averageScore',
  11: 'DIRECTO: popularity × averageScore; tamaño = episodes (anime) o chapters (manga)',
  12: 'DERIVADO: obras acumuladas por año',
  13: 'DERIVADO: obras acumuladas por año',
  14: 'DERIVADO: obras por format, ordenado',
  15: 'DERIVADO: obras por status, ordenado',
  16: 'DERIVADO: bins de 10 puntos de averageScore',
  17: 'DERIVADO: obras por año × format',
  18: 'DERIVADO: obras por género × status',
  19: 'DERIVADO: obras por año × format',
  20: 'DERIVADO: obras por año × format',
  21: 'DERIVADO: obras por año × format (proporción)',
  22: 'DERIVADO: obras por género × status (proporción)',
  23: 'DERIVADO: obras por año × format (proporción)',
  24: 'DERIVADO: obras por año × format (proporción)',
  25: 'DIRECTO: startDate.year – endDate.year',
  26: 'DERIVADO: averageScore mínimo y máximo por año',
  27: 'DERIVADO: averageScore mínimo y máximo por año',
  28: 'DERIVADO: variación de obras de un año al siguiente',
  29: 'DERIVADO: averageScore medio por año',
  30: 'DERIVADO: score medio del género − media de la muestra',
  31: 'DERIVADO: obras por año',
  32: '$trendsOrigin → velas de 7 días',
  33: '$trendsOrigin → velas de 7 días',
  34: 'DERIVADO: cuartiles de averageScore por format',
  35: 'DERIVADO: media ± σ de averageScore por género',
  36: 'DERIVADO: obras por año + averageScore medio por año',
  37: 'DIRECTO: popularity y averageScore de las 10 más populares',
  38: 'DIRECTO: popularity de cada obra por fecha de inicio',
  39: 'DIRECTO: popularity × averageScore',
  40: 'DERIVADO: obras por año × format',
  41: '$trendsOrigin → SMA de 7 días',
  42: '$trendsOrigin → bandas de Bollinger (20, ±2σ)',
  43: '$trendsOrigin → RSI de Wilder (14)',
  44: '$trendsOrigin → MACD (12, 26, 9)',
  45: 'DERIVADO: regresión lineal de averageScore sobre popularity',
  46: 'DIRECTO: averageScore de las 10 más populares + media de la muestra',
  47: 'DIRECTO: popularity de las 10 más populares',
  48: 'DERIVADO: averageScore medio por año vs media de la muestra',
  49: 'DIRECTO: averageScore de las 10 mejor puntuadas',
  50: 'DIRECTO: startDate.year de las obras más populares',
  51: 'DIRECTO: popularity (log10 en la Variable)',
  52: sharedCaseOriginsPaged,
  53: 'DERIVADO: obras por format',
  54: 'DIRECTO: averageScore de la obra más popular',
  55: 'DIRECTO: popularity por fecha de inicio',
  56: 'DIRECTO: averageScore de las 10 mejor puntuadas',
  57: 'DERIVADO: score medio del año por encima (+1) o por debajo (−1) de la media',
  58: 'DERIVADO: obras por año',
  59: 'DIRECTO: popularity × averageScore; forma = format',
  60: 'DIRECTO: campos de las 10 más populares',
  61: 'DIRECTO: popularity y averageScore de las 10 más populares',
  62: 'DIRECTO: rankings "highest rated all time" de AniList',
  63: 'DIRECTO: popularity actual de las 5 obras más populares, consultada periódicamente',
};

/// Mismo origen que en las otras librerías para #52.
const sharedCaseOriginsPaged = 'DIRECTO: popularity de páginas pedidas a AniList bajo demanda (Page, perPage 20)';

const Map<int, String> _notes = {
  32: ohlcNote,
  33: hlocNote,
  41: trendsIndicatorNote,
  42: trendsIndicatorNote,
  43: trendsIndicatorNote,
  44: trendsIndicatorNote,
  50: 'Graphic no dibuja ruptura de eje: se compara TimeScale (con huecos) y OrdinalScale (sin huecos).',
};

ImplementationStrategy _strategy(int number, GraphicClassification c) {
  if (number == 32 || number == 33) return ImplementationStrategy.adaptacion;
  return switch (c) {
    GraphicClassification.nativo => ImplementationStrategy.nativo,
    GraphicClassification.variante => ImplementationStrategy.variante,
    GraphicClassification.composicion => ImplementationStrategy.composicion,
  };
}

/// Los 63 casos de Graphic.
final Map<int, CaseImpl> graphicCases = {
  for (final spec in graphicChartRegistry)
    spec.number: CaseImpl(
      strategy: _strategy(spec.number, spec.classification),
      origin: _origins[spec.number]!,
      api: spec.construction,
      note: _notes[spec.number],
      builder: (context, d) => spec.number >= 41 && spec.number <= 44 || spec.number == 32 || spec.number == 33
          ? withTrends(d, () => spec.builder(d.g))
          : spec.builder(d.g),
    ),
};
