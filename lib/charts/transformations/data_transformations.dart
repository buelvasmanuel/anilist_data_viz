import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';

class DataTransformations {
  /// B. Transforms a list of Media into chart data representing the count per genre (ChartDataCategory)
  static List<ChartDataCategory> mediaToGenreCount(List<Media> mediaList) {
    if (mediaList.isEmpty) return [];

    final Map<String, int> genreCounts = {};

    for (final media in mediaList) {
      for (final genre in media.genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    final chartData = genreCounts.entries
        .map((e) => ChartDataCategory(category: e.key, value: e.value))
        .toList();

    chartData.sort((a, b) {
      final valueComparison = b.value.compareTo(a.value);
      if (valueComparison != 0) return valueComparison;
      return a.category.compareTo(b.category);
    });

    return chartData;
  }

  /// A. Transforms Media list to show average score per year (ChartDataXY)
  static List<ChartDataXY> mediaToAverageScorePerYear(List<Media> mediaList) {
    if (mediaList.isEmpty) return [];

    final Map<int, List<int>> scoresPerYear = {};

    for (final media in mediaList) {
      final int? year = media.startDate?.year ?? media.seasonYear;
      if (year != null && media.averageScore != null) {
        if (!scoresPerYear.containsKey(year)) {
          scoresPerYear[year] = [];
        }
        scoresPerYear[year]!.add(media.averageScore!);
      }
    }

    final chartData = scoresPerYear.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return ChartDataXY(x: e.key, y: avg);
    }).toList();

    chartData.sort((a, b) => a.x.compareTo(b.x));
    return chartData;
  }

  /// C. Transforms Media list to multiple series (e.g. Anime vs Manga over time) (ChartSeries)
  static List<ChartSeries<ChartDataXY>> mediaToTypeScorePerYear(List<Media> mediaList) {
    if (mediaList.isEmpty) return [];

    final Map<String, Map<int, List<int>>> data = {};

    for (final media in mediaList) {
      final type = media.type ?? 'Unknown';
      final int? year = media.startDate?.year ?? media.seasonYear;
      
      if (year != null && media.averageScore != null) {
        data.putIfAbsent(type, () => {});
        data[type]!.putIfAbsent(year, () => []);
        data[type]![year]!.add(media.averageScore!);
      }
    }

    final series = data.entries.map((typeEntry) {
      final points = typeEntry.value.entries.map((yearEntry) {
        final avg = yearEntry.value.reduce((a, b) => a + b) / yearEntry.value.length;
        return ChartDataXY(x: yearEntry.key, y: avg);
      }).toList();
      
      points.sort((a, b) => a.x.compareTo(b.x));
      return ChartSeries<ChartDataXY>(seriesName: typeEntry.key, data: points);
    }).toList();

    series.sort((a, b) => a.seriesName.compareTo(b.seriesName));
    return series;
  }

  /// D. Transforms Media list to a Matrix (Genre x Year) (ChartDataMatrix)
  static List<ChartDataMatrix> mediaToGenreYearMatrix(List<Media> mediaList) {
    final List<ChartDataMatrix> matrix = [];
    final Map<String, Map<String, int>> counts = {};

    for (final media in mediaList) {
      final int? year = media.startDate?.year ?? media.seasonYear;
      if (year == null) continue;
      
      final yearStr = year.toString();
      for (final genre in media.genres) {
        counts.putIfAbsent(genre, () => {});
        counts[genre]![yearStr] = (counts[genre]![yearStr] ?? 0) + 1;
      }
    }

    for (final genreEntry in counts.entries) {
      for (final yearEntry in genreEntry.value.entries) {
        matrix.add(ChartDataMatrix(row: genreEntry.key, column: yearEntry.key, value: yearEntry.value));
      }
    }

    return matrix;
  }

  /// E. Transforms Media list to Ranges grouped by Format (ChartDataRange)
  static List<ChartDataRange> mediaToScoreRangesByFormat(List<Media> mediaList) {
    final Map<String, List<num>> formatScores = {};

    for (final media in mediaList) {
      final format = media.format ?? 'Unknown';
      if (media.averageScore != null) {
        formatScores.putIfAbsent(format, () => []);
        formatScores[format]!.add(media.averageScore!);
      }
    }

    final ranges = formatScores.entries.map((e) {
      final scores = e.value..sort();
      if (scores.isEmpty) {
        return ChartDataRange(category: e.key, min: 0, max: 0);
      }
      
      final min = scores.first;
      final max = scores.last;
      final median = scores[scores.length ~/ 2];
      
      return ChartDataRange(
        category: e.key,
        min: min,
        max: max,
        median: median,
      );
    }).toList();

    ranges.sort((a, b) => a.category.compareTo(b.category));
    return ranges;
  }

  /// F. Transforms Media list to Hierarchy (Genre -> Titles -> score) (ChartDataHierarchy)
  static List<ChartDataHierarchy> mediaToGenreHierarchy(List<Media> mediaList) {
    final List<ChartDataHierarchy> hierarchy = [];
    final Set<String> addedGenres = {};

    // Root nodes (Genres)
    for (final media in mediaList) {
      for (final genre in media.genres) {
        if (!addedGenres.contains(genre)) {
          hierarchy.add(ChartDataHierarchy(id: genre, label: genre));
          addedGenres.add(genre);
        }
        
        // Leaf nodes (Titles)
        final id = '${genre}_${media.id}';
        hierarchy.add(ChartDataHierarchy(
          id: id,
          label: media.title,
          parentId: genre,
          value: media.popularity,
        ));
      }
    }

    return hierarchy;
  }

  // ---------------------------------------------------------------------------
  // Transformaciones para los casos básicos 1–31 (LISTA_CANDIDATA_63).
  // Todas trabajan solo con los campos recibidos de AniList; no se generan
  // valores que no se deriven de la muestra cargada.
  // ---------------------------------------------------------------------------

  static int? _yearOf(Media media) => media.startDate?.year ?? media.seasonYear;

  /// N1. Número de obras por año de inicio (`startDate.year`, o `seasonYear`
  /// si falta). Con [fillGaps] los años intermedios sin obras aparecen con
  /// conteo 0 (es un conteo real de la muestra, no un valor inventado).
  static List<ChartDataXY> mediaToCountPerYear(
    List<Media> mediaList, {
    bool fillGaps = true,
  }) {
    final Map<int, int> counts = {};
    for (final media in mediaList) {
      final year = _yearOf(media);
      if (year == null) continue;
      counts[year] = (counts[year] ?? 0) + 1;
    }
    if (counts.isEmpty) return [];

    final years = counts.keys.toList()..sort();
    final List<int> xs = fillGaps
        ? [for (var y = years.first; y <= years.last; y++) y]
        : years;

    return xs
        .map((y) => ChartDataXY(x: y, y: counts[y] ?? 0, label: '$y'))
        .toList();
  }

  /// N2. Agrupa un campo numérico entero en intervalos (bins) de ancho
  /// [binSize]. Devuelve un punto por bin: `x` = inicio del bin, `y` = número
  /// de obras, `label` = rango legible ("60–69").
  ///
  /// - [start]: inicio del primer bin. Si es `null` se usa el múltiplo de
  ///   [binSize] inmediatamente inferior al valor mínimo. Los valores menores
  ///   que [start] se descartan.
  /// - [openEndFrom]: los valores `>=` este límite se agrupan en un único bin
  ///   final abierto ("≥60"), útil para colas largas (p. ej. episodios).
  /// - Los bins intermedios vacíos se incluyen con conteo 0.
  static List<ChartDataXY> mediaToNumericBins(
    List<Media> mediaList, {
    required num? Function(Media media) valueOf,
    required int binSize,
    int? start,
    int? openEndFrom,
  }) {
    assert(binSize > 0, 'binSize debe ser positivo');
    final values = mediaList.map(valueOf).whereType<num>().toList();
    if (values.isEmpty) return [];

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final firstBin = start ?? (minValue / binSize).floor() * binSize;
    if (openEndFrom != null && (openEndFrom - firstBin) % binSize != 0) {
      throw ArgumentError(
          'openEndFrom ($openEndFrom) debe coincidir con el inicio de un bin');
    }

    int binIndexOf(num value) {
      if (openEndFrom != null && value >= openEndFrom) {
        return ((openEndFrom - firstBin) / binSize).floor();
      }
      return ((value - firstBin) / binSize).floor();
    }

    final Map<int, int> counts = {};
    for (final value in values) {
      if (value < firstBin) continue;
      final index = binIndexOf(value);
      counts[index] = (counts[index] ?? 0) + 1;
    }
    if (counts.isEmpty) return [];

    final lastIndex = counts.keys.reduce((a, b) => a > b ? a : b);
    final List<ChartDataXY> bins = [];
    for (var i = 0; i <= lastIndex; i++) {
      final binStart = firstBin + i * binSize;
      final isOpen = openEndFrom != null && binStart >= openEndFrom;
      bins.add(ChartDataXY(
        x: binStart,
        y: counts[i] ?? 0,
        label: isOpen ? '≥$binStart' : '$binStart–${binStart + binSize - 1}',
      ));
    }
    return bins;
  }

  /// Convierte bins de [mediaToNumericBins] en categorías (para PieChart o
  /// BarChart ordinal). Con [dropEmpty] se omiten los bins con 0 obras.
  static List<ChartDataCategory> binsToCategories(
    List<ChartDataXY> bins, {
    bool dropEmpty = true,
  }) {
    return bins
        .where((b) => !dropEmpty || b.y > 0)
        .map((b) => ChartDataCategory(category: b.label ?? '${b.x}', value: b.y))
        .toList();
  }

  /// N3. Media de `averageScore` por género. Cada obra aporta su score a
  /// todos sus géneros. Con [minCount] se descartan géneros con menos obras
  /// puntuadas (medias con muy pocas obras son poco representativas).
  static List<ChartDataCategory> mediaToAverageScoreByGenre(
    List<Media> mediaList, {
    int minCount = 1,
  }) {
    final Map<String, List<int>> scores = {};
    for (final media in mediaList) {
      final score = media.averageScore;
      if (score == null) continue;
      for (final genre in media.genres) {
        scores.putIfAbsent(genre, () => []).add(score);
      }
    }

    final result = scores.entries
        .where((e) => e.value.length >= minCount)
        .map((e) => ChartDataCategory(
              category: e.key,
              value: e.value.reduce((a, b) => a + b) / e.value.length,
            ))
        .toList();

    result.sort((a, b) {
      final byValue = b.value.compareTo(a.value);
      return byValue != 0 ? byValue : a.category.compareTo(b.category);
    });
    return result;
  }

  /// Media de `averageScore` de la muestra (cada obra cuenta una vez).
  /// `null` si ninguna obra tiene score.
  static double? meanAverageScore(List<Media> mediaList) {
    final scores =
        mediaList.map((m) => m.averageScore).whereType<int>().toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// N3b. Desviación del score medio de cada género respecto de la media
  /// global de la muestra: `media(género) − media(muestra)`. Los valores
  /// negativos son legítimos: indican géneros por debajo de la media.
  static List<ChartDataCategory> mediaToGenreScoreDeviation(
    List<Media> mediaList, {
    int minCount = 1,
  }) {
    final globalMean = meanAverageScore(mediaList);
    if (globalMean == null) return [];

    return mediaToAverageScoreByGenre(mediaList, minCount: minCount)
        .map((e) => ChartDataCategory(
              category: e.category,
              value: e.value - globalMean,
            ))
        .toList();
  }

  /// N4. Conteo por un campo categórico univaluado (format, status, source,
  /// countryOfOrigin, season, type...). Cada obra cuenta exactamente una vez,
  /// por lo que los porcentajes representan obras.
  ///
  /// Si [unknownLabel] es `null`, las obras sin valor se omiten; en caso
  /// contrario se agrupan bajo esa etiqueta.
  static List<ChartDataCategory> mediaToCategoryCount(
    List<Media> mediaList, {
    required String? Function(Media media) selector,
    String? unknownLabel,
  }) {
    final Map<String, int> counts = {};
    for (final media in mediaList) {
      final key = selector(media) ?? unknownLabel;
      if (key == null) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final result = counts.entries
        .map((e) => ChartDataCategory(category: e.key, value: e.value))
        .toList();
    result.sort((a, b) {
      final byValue = b.value.compareTo(a.value);
      return byValue != 0 ? byValue : a.category.compareTo(b.category);
    });
    return result;
  }

  /// Conserva las [n] primeras categorías y suma el resto en [othersLabel].
  /// La suma total se mantiene (agregación, no se inventan valores).
  static List<ChartDataCategory> topNWithOthers(
    List<ChartDataCategory> data,
    int n, {
    String othersLabel = 'Otros',
  }) {
    if (data.length <= n) return List.of(data);
    final head = data.take(n).toList();
    final rest = data.skip(n).fold<num>(0, (sum, e) => sum + e.value);
    return [...head, ChartDataCategory(category: othersLabel, value: rest)];
  }

  /// N7. KPIs de resumen de la muestra cargada.
  static ChartDataSummary mediaToSummaryKpis(List<Media> mediaList) {
    final scored = mediaList.where((m) => m.averageScore != null).length;
    final withStatus = mediaList.where((m) => m.status != null).length;
    final finished = mediaList.where((m) => m.status == 'FINISHED').length;

    return ChartDataSummary(
      totalMedia: mediaList.length,
      scoredMedia: scored,
      meanAverageScore: meanAverageScore(mediaList),
      finishedCount: finished,
      withStatusCount: withStatus,
      finishedPercent: withStatus == 0 ? null : finished / withStatus * 100,
    );
  }
  /// N5. Agrupa obras por una categoría (ej. género, status) y las divide por serie (ej. source).
  static List<ChartSeries<ChartDataCategory>> mediaToSeriesByCategory(
    List<Media> mediaList, {
    required String? Function(Media media) categorySelector,
    required String? Function(Media media) seriesSelector,
    int? topCategories,
  }) {
    final Map<String, Map<String, int>> counts = {};
    for (final media in mediaList) {
      final category = categorySelector(media);
      final series = seriesSelector(media);
      if (category == null || series == null) continue;
      counts.putIfAbsent(series, () => {});
      counts[series]![category] = (counts[series]![category] ?? 0) + 1;
    }

    final Map<String, int> categoryTotals = {};
    for (final seriesMap in counts.values) {
      for (final entry in seriesMap.entries) {
        categoryTotals[entry.key] = (categoryTotals[entry.key] ?? 0) + entry.value;
      }
    }
    List<String> sortedCategories = categoryTotals.keys.toList()
      ..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));
    if (topCategories != null) {
      sortedCategories = sortedCategories.take(topCategories).toList();
    }

    final List<ChartSeries<ChartDataCategory>> result = [];
    for (final seriesEntry in counts.entries) {
      final List<ChartDataCategory> data = [];
      for (final cat in sortedCategories) {
        data.add(ChartDataCategory(category: cat, value: seriesEntry.value[cat] ?? 0));
      }
      result.add(ChartSeries<ChartDataCategory>(seriesName: seriesEntry.key, data: data));
    }
    result.sort((a, b) => a.seriesName.compareTo(b.seriesName));
    return result;
  }

  /// N6. Conteo por año-mes para serie temporal multivariable.
  static List<ChartDataXY> mediaToCountPerYearMonth(List<Media> mediaList) {
    final Map<int, int> counts = {};
    for (final media in mediaList) {
      final year = media.startDate?.year;
      final month = media.startDate?.month;
      if (year != null && month != null) {
        final key = year * 100 + month;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    final result = counts.entries
        .map((e) => ChartDataXY(x: e.key, y: e.value))
        .toList();
    result.sort((a, b) => a.x.compareTo(b.x));
    return result;
  }

  /// N8. Scatter points (X: un valor, Y: otro).
  static List<ChartDataXY> mediaToScatterPoints(
    List<Media> mediaList, {
    required num? Function(Media media) xSelector,
    required num? Function(Media media) ySelector,
  }) {
    final List<ChartDataXY> points = [];
    for (final media in mediaList) {
      final x = xSelector(media);
      final y = ySelector(media);
      if (x != null && y != null) {
        points.add(ChartDataXY(x: x, y: y));
      }
    }
    return points;
  }

  /// Regresión lineal simple: devuelve [slope, intercept].
  static List<double> linearRegression(List<ChartDataXY> points) {
    if (points.isEmpty) return [0, 0];
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = points.length;
    for (final p in points) {
      sumX += p.x;
      sumY += p.y;
      sumXY += p.x * p.y;
      sumX2 += p.x * p.x;
    }
    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return [0, 0];
    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;
    return [slope, intercept];
  }

  /// N9. Métricas normalizadas por año.
  static List<ChartSeries<ChartDataXY>> mediaToYearMetricsNormalized(
    List<Media> mediaList,
  ) {
    final counts = mediaToCountPerYear(mediaList, fillGaps: false);
    final scores = mediaToAverageScorePerYear(mediaList);

    double maxCount = 0;
    for (final p in counts) { if (p.y > maxCount) maxCount = p.y.toDouble(); }
    double maxScore = 0;
    for (final p in scores) { if (p.y > maxScore) maxScore = p.y.toDouble(); }

    final normCounts = counts.map((p) => ChartDataXY(x: p.x, y: maxCount == 0 ? 0 : p.y / maxCount)).toList();
    final normScores = scores.map((p) => ChartDataXY(x: p.x, y: maxScore == 0 ? 0 : p.y / maxScore)).toList();

    return [
      ChartSeries(seriesName: 'Conteo (Norm)', data: normCounts),
      ChartSeries(seriesName: 'Score (Norm)', data: normScores),
    ];
  }

  /// N10. Series por año separadas por un selector (ej. source).
  static List<ChartSeries<ChartDataXY>> mediaToSeriesPerYear(
    List<Media> mediaList, {
    required String? Function(Media media) seriesSelector,
  }) {
    final Map<String, Map<int, int>> counts = {};
    for (final media in mediaList) {
      final series = seriesSelector(media);
      final year = _yearOf(media);
      if (series == null || year == null) continue;
      counts.putIfAbsent(series, () => {});
      counts[series]![year] = (counts[series]![year] ?? 0) + 1;
    }

    final List<ChartSeries<ChartDataXY>> result = [];
    for (final entry in counts.entries) {
      final data = entry.value.entries.map((e) => ChartDataXY(x: e.key, y: e.value)).toList();
      data.sort((a, b) => a.x.compareTo(b.x));
      result.add(ChartSeries<ChartDataXY>(seriesName: entry.key, data: data));
    }
    result.sort((a, b) => a.seriesName.compareTo(b.seriesName));
    return result;
  }
}
