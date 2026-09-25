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
}
