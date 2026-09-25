// Conjunto de datos precalculado para las 63 gráficas de Graphic.
//
// Se construye UNA vez en el Provider (no en los widgets) a partir de los
// títulos ya obtenidos de AniList. Cada gráfica recibe este objeto y solo
// lee la lista que necesita: ningún widget hace cálculos estadísticos.
//
// Origen de cada lista:
//   DIRECTO  → campo leído tal cual de AniList.
//   DERIVADO → calculado aquí con GraphicTransformations.
//   Las listas financieras (OHLC) NO existen en AniList y viven en

import 'graphic_transformations.dart';
import 'graphic_view_models.dart';

class GraphicDataset {
  GraphicDataset._({
    required this.titles,
    required this.trends,
    required this.topByPopularity,
    required this.topByScore,
    required this.years,
    required this.scoreByYear,
    required this.countByYear,
    required this.cumulativeByYear,
    required this.countByFormat,
    required this.countByStatus,
    required this.formats,
    required this.yearFormatSeries,
    required this.genreStatusSeries,
    required this.scoreRangeByYear,
    required this.airingRanges,
    required this.waterfallSteps,
    required this.genreDeviation,
    required this.scoreBins,
    required this.boxByFormat,
    required this.errorByGenre,
    required this.regression,
    required this.winLossByYear,
    required this.globalMeanScore,
    required this.datedTitles,
    required this.rankedTitles,
    required this.trendLabels,
    required this.trendValues,
    required this.trendSma,
    required this.bollingerPoints,
    required this.rsiPoints,
    required this.macdPoints,
    required this.trendOhlc,
  });

  /// Construye todos los datasets. [trends] es opcional: si el DataSource no
  /// consulta `Media.trends`, los casos 41-44 quedan como NO DISPONIBLE.
  factory GraphicDataset.fromAnime(
    List<GAnime> titles, {
    List<GTrendPoint> trends = const [],
    int maxYears = 10,
    int maxFormats = 4,
    int maxGenres = 5,
    int smaPeriod = 7,
  }) {
    final scored = titles.where((a) => a.score != null).toList();
    final globalMean = GraphicTransformations.mean(scored.map((a) => a.score!));

    // --- Top N (DIRECTO) ---
    final topPop = [...titles]..sort((a, b) => b.popularity.compareTo(a.popularity));
    final topScore = [...scored]..sort((a, b) => b.score!.compareTo(a.score!));

    // --- Por año (DERIVADO) ---
    final byYear = <int, List<GAnime>>{};
    for (final a in titles) {
      final y = a.seasonYear ?? a.startYear;
      if (y != null) (byYear[y] ??= []).add(a);
    }
    final allYears = byYear.keys.toList()..sort();
    final yearsInt = allYears.length > maxYears
        ? allYears.sublist(allYears.length - maxYears)
        : allYears;
    final years = [for (final y in yearsInt) '$y'];

    final scoreByYear = <GCategory>[];
    final scoreRangeByYear = <GRange>[];
    for (final y in yearsInt) {
      final s = byYear[y]!.where((a) => a.score != null).map((a) => a.score!).toList();
      if (s.isEmpty) continue;
      scoreByYear.add(GCategory('$y', GraphicTransformations.mean(s)));
      s.sort();
      scoreRangeByYear.add(GRange('$y', s.first, s.last));
    }
    final countByYear = [for (final y in yearsInt) GCategory('$y', byYear[y]!.length)];

    // --- Por formato / estado (DERIVADO) ---
    List<GCategory> countBy(String Function(GAnime) key) {
      final m = <String, int>{};
      for (final a in titles) {
        m[key(a)] = (m[key(a)] ?? 0) + 1;
      }
      final out = [for (final e in m.entries) GCategory(e.key, e.value)];
      out.sort((a, b) => b.value.compareTo(a.value)); // ordenado: requisito de funnel/pyramid
      return out;
    }

    final countByFormat = countBy((a) => a.format);
    final countByStatus = countBy((a) => a.status);
    final formats = [for (final c in countByFormat.take(maxFormats)) c.label];

    // --- Multiserie año × formato, alineada para StackModifier ---
    final rawYF = <GSeriesPoint>[];
    for (final y in yearsInt) {
      for (final f in formats) {
        rawYF.add(GSeriesPoint('$y', byYear[y]!.where((a) => a.format == f).length, f));
      }
    }
    final yearFormatSeries = GraphicTransformations.alignSeries(rawYF, xOrder: years, seriesOrder: formats);

    // --- Multiserie género × estado ---
    final genreCount = <String, int>{};
    for (final a in titles) {
      for (final g in a.genres) {
        genreCount[g] = (genreCount[g] ?? 0) + 1;
      }
    }
    final topGenres = (genreCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(maxGenres)
        .map((e) => e.key)
        .toList();
    final statuses = [for (final c in countByStatus) c.label];
    final rawGS = <GSeriesPoint>[];
    for (final g in topGenres) {
      for (final s in statuses) {
        rawGS.add(GSeriesPoint(
            g, titles.where((a) => a.genres.contains(g) && a.status == s).length, s));
      }
    }
    final genreStatusSeries = GraphicTransformations.alignSeries(rawGS, xOrder: topGenres, seriesOrder: statuses);

    // --- Rangos de emisión (DIRECTO: startDate.year / endDate.year) ---
    final airing = [
      for (final a in topPop)
        if (a.startYear != null && a.endYear != null)
          GRange(a.title, a.startYear!, a.endYear!),
    ].take(10).toList();

    // --- Desviación por género (DERIVADO) ---
    final genreDeviation = <GCategory>[];
    final genreScores = <String, List<num>>{};
    for (final g in topGenres) {
      final s = scored.where((a) => a.genres.contains(g)).map((a) => a.score!).toList();
      if (s.isEmpty) continue;
      genreScores[g] = s;
      genreDeviation.add(GCategory(g, GraphicTransformations.mean(s) - globalMean));
    }

    // --- Box plot por formato (DERIVADO) ---
    final boxByFormat = <GBoxStat>[];
    for (final f in formats) {
      final s = scored.where((a) => a.format == f).map((a) => a.score!).toList();
      if (s.length >= 2) boxByFormat.add(GraphicTransformations.fiveNumberSummary(f, s));
    }

    // --- Error bars por género (DERIVADO) ---
    final errorByGenre = [
      for (final e in genreScores.entries)
        if (e.value.length >= 2) GraphicTransformations.meanStd(e.key, e.value),
    ];

    // --- Regresión score ~ popularity (DERIVADO) ---
    final regression = GraphicTransformations.linearRegression([
      for (final a in scored) (x: a.popularity, y: a.score!),
    ]);

    // --- Títulos con fecha (DIRECTO) ---
    final dated = [
      for (final a in titles)
        if ((a.startYear ?? a.seasonYear) != null)
          GDatedValue(DateTime(a.startYear ?? a.seasonYear!), a.title, a.popularity),
    ]..sort((a, b) => a.date.compareTo(b.date));

    // --- Ranking (DIRECTO: rankings.rank) ---
    final ranked = [for (final a in titles) if (a.rank != null) a]
      ..sort((a, b) => a.rank!.compareTo(b.rank!));

    // --- Serie temporal Media.trends (REAL, NO financiera) ---
    // `popularity` de trends es un acumulado (usuarios con la obra en su
    // lista) y casi nunca baja. La serie base de #32, #33 y #41-#44 es su
    // variación neta por día: (pop[i] − pop[i−1]) / días entre ambos nodos.
    final sortedTrends = [...trends]..sort((a, b) => a.date.compareTo(b.date));
    final gains = GraphicTransformations.dailyGains(sortedTrends);
    final trendLabels = [for (final g in gains) g.label];
    final trendValues = [for (final g in gains) g.value];
    final smaValues = GraphicTransformations.sma(trendValues, smaPeriod);
    final rsiValues = GraphicTransformations.rsi(trendValues);

    return GraphicDataset._(
      titles: titles,
      trends: sortedTrends,
      topByPopularity: topPop.take(10).toList(),
      topByScore: topScore.take(10).toList(),
      years: years,
      scoreByYear: scoreByYear,
      countByYear: countByYear,
      cumulativeByYear: GraphicTransformations.cumulative(countByYear),
      countByFormat: countByFormat,
      countByStatus: countByStatus,
      formats: formats,
      yearFormatSeries: yearFormatSeries,
      genreStatusSeries: genreStatusSeries,
      scoreRangeByYear: scoreRangeByYear,
      airingRanges: airing,
      waterfallSteps: GraphicTransformations.waterfall(countByYear),
      genreDeviation: genreDeviation,
      scoreBins: GraphicTransformations.histogramBins(scored.map((a) => a.score!)),
      boxByFormat: boxByFormat,
      errorByGenre: errorByGenre,
      regression: regression,
      winLossByYear: GraphicTransformations.winLoss(scoreByYear, globalMean.isNaN ? 0 : globalMean),
      globalMeanScore: globalMean,
      datedTitles: dated,
      rankedTitles: ranked.take(15).toList(),
      trendLabels: trendLabels,
      trendValues: trendValues,
      trendSma: [
        for (var i = 0; i < trendValues.length; i++)
          if (smaValues[i] != null) ...[
            GSeriesPoint(trendLabels[i], trendValues[i], 'Variación diaria'),
            GSeriesPoint(trendLabels[i], smaValues[i]!, 'SMA $smaPeriod'),
          ],
      ],
      bollingerPoints: GraphicTransformations.bollinger(trendLabels, trendValues),
      rsiPoints: [
        for (var i = 0; i < trendValues.length; i++)
          if (rsiValues[i] != null) GCategory(trendLabels[i], rsiValues[i]!),
      ],
      macdPoints: GraphicTransformations.macd(trendLabels, trendValues),
      trendOhlc: GraphicTransformations.ohlc(trendLabels, trendValues),
    );
  }

  // Datos base
  final List<GAnime> titles;
  final List<GTrendPoint> trends;

  // DIRECTO
  final List<GAnime> topByPopularity;
  final List<GAnime> topByScore;
  final List<GRange> airingRanges;
  final List<GDatedValue> datedTitles;
  final List<GAnime> rankedTitles;

  // DERIVADO
  final List<String> years;
  final List<GCategory> scoreByYear;
  final List<GCategory> countByYear;
  final List<GCategory> cumulativeByYear;
  final List<GCategory> countByFormat;
  final List<GCategory> countByStatus;
  final List<String> formats;
  final List<GSeriesPoint> yearFormatSeries;
  final List<GSeriesPoint> genreStatusSeries;
  final List<GRange> scoreRangeByYear;
  final List<GWaterfallStep> waterfallSteps;
  final List<GCategory> genreDeviation;
  final List<GCategory> scoreBins;
  final List<GBoxStat> boxByFormat;
  final List<GErrorStat> errorByGenre;
  final List<GRegressionPoint> regression;
  final List<GCategory> winLossByYear;
  final double globalMeanScore;

  // DERIVADO de Media.trends: variación neta diaria de popularidad.
  // Vacío si no llegaron trends (fallo de red).
  final List<String> trendLabels;
  final List<num> trendValues;
  final List<GSeriesPoint> trendSma;
  final List<GBollingerPoint> bollingerPoints;
  final List<GCategory> rsiPoints;
  final List<GMacdPoint> macdPoints;

  /// Velas semanales (7 días) sobre la variación diaria de popularidad.
  /// Adaptación NO financiera: open = primer día, high = máximo,
  /// low = mínimo, close = último día de la semana.
  final List<GOhlc> trendOhlc;

  bool get hasTrends => trendValues.length >= 30;
}
