import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:anilist_data_viz/charts/transformations/data_transformations.dart';
import 'package:anilist_data_viz/domain/entities/fuzzy_date.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mediaList = [
    Media(id: 1, title: 'A', format: 'TV', status: 'FINISHED', startDate: FuzzyDate(year: 2020), averageScore: 80, episodes: 12, genres: ['Action']),
    Media(id: 2, title: 'B', format: 'TV', status: 'FINISHED', startDate: FuzzyDate(year: 2020), averageScore: 90, episodes: 24, genres: ['Action', 'Comedy']),
    Media(id: 3, title: 'C', format: 'MOVIE', status: 'RELEASING', seasonYear: 2022, averageScore: 70, episodes: 1, genres: ['Comedy']),
    Media(id: 4, title: 'D', format: null, status: null, averageScore: null, episodes: 150, genres: ['Drama']),
  ];

  group('T1 mediaToGenreCount', () {
    test('cuenta cada género y ordena por valor descendente', () {
      final result = DataTransformations.mediaToGenreCount(mediaList);
      expect(result.map((e) => e.category), ['Action', 'Comedy', 'Drama']);
      expect(result.map((e) => e.value), [2, 2, 1]);
    });
  });

  group('T2 mediaToAverageScorePerYear', () {
    test('promedia por año y usa seasonYear si falta startDate', () {
      final result = DataTransformations.mediaToAverageScorePerYear(mediaList);
      expect(result.map((e) => e.x), [2020, 2022]);
      expect(result.first.y, 85);
      expect(result.last.y, 70);
    });
  });

  group('N1 mediaToCountPerYear', () {
    test('rellena años intermedios con 0', () {
      final result = DataTransformations.mediaToCountPerYear(mediaList);
      expect(result.map((e) => e.x), [2020, 2021, 2022]);
      expect(result.map((e) => e.y), [2, 0, 1]);
    });

    test('sin fillGaps devuelve solo años con obras', () {
      final result = DataTransformations.mediaToCountPerYear(mediaList, fillGaps: false);
      expect(result.map((e) => e.x), [2020, 2022]);
    });

    test('lista vacía', () {
      expect(DataTransformations.mediaToCountPerYear([]), isEmpty);
    });
  });

  group('N2 mediaToNumericBins', () {
    test('agrupa scores en bins de 10 e incluye bins vacíos', () {
      final result = DataTransformations.mediaToNumericBins(
        mediaList,
        valueOf: (m) => m.averageScore,
        binSize: 10,
      );
      expect(result.map((e) => e.x), [70, 80, 90]);
      expect(result.map((e) => e.y), [1, 1, 1]);
      expect(result.first.label, '70–79');
    });

    test('bin final abierto para colas largas', () {
      final result = DataTransformations.mediaToNumericBins(
        mediaList,
        valueOf: (m) => m.episodes,
        binSize: 12,
        start: 0,
        openEndFrom: 36,
      );
      // 1 -> [0-11], 12 -> [12-23], 24 -> [24-35], 150 -> ≥36
      expect(result.map((e) => e.y), [1, 1, 1, 1]);
      expect(result.last.label, '≥36');
    });

    test('ignora obras sin valor', () {
      final result = DataTransformations.mediaToNumericBins(
        mediaList,
        valueOf: (m) => m.averageScore,
        binSize: 50,
        start: 50,
      );
      final total = result.fold<num>(0, (s, e) => s + e.y);
      expect(total, 3);
    });

    test('openEndFrom desalineado lanza ArgumentError', () {
      expect(
        () => DataTransformations.mediaToNumericBins(
          mediaList,
          valueOf: (m) => m.episodes,
          binSize: 12,
          start: 0,
          openEndFrom: 30,
        ),
        throwsArgumentError,
      );
    });

    test('binsToCategories omite bins vacíos', () {
      final bins = [
        ChartDataXY(x: 0, y: 2, label: '0–9'),
        ChartDataXY(x: 10, y: 0, label: '10–19'),
      ];
      final result = DataTransformations.binsToCategories(bins);
      expect(result.length, 1);
      expect(result.first.category, '0–9');
    });
  });

  group('N3 / N3b score por género', () {
    test('mediaToAverageScoreByGenre promedia por género', () {
      final result = DataTransformations.mediaToAverageScoreByGenre(mediaList);
      final action = result.firstWhere((e) => e.category == 'Action');
      final comedy = result.firstWhere((e) => e.category == 'Comedy');
      expect(action.value, 85); // (80 + 90) / 2
      expect(comedy.value, 80); // (90 + 70) / 2
      // Drama no tiene obras con score.
      expect(result.any((e) => e.category == 'Drama'), isFalse);
    });

    test('minCount descarta géneros con pocas obras', () {
      final result = DataTransformations.mediaToAverageScoreByGenre(mediaList, minCount: 3);
      expect(result, isEmpty);
    });

    test('mediaToGenreScoreDeviation resta la media global de la muestra', () {
      // Media global: (80 + 90 + 70) / 3 = 80
      final result = DataTransformations.mediaToGenreScoreDeviation(mediaList);
      final action = result.firstWhere((e) => e.category == 'Action');
      final comedy = result.firstWhere((e) => e.category == 'Comedy');
      expect(action.value, 5);
      expect(comedy.value, 0);
    });

    test('produce negativos reales cuando un género está por debajo', () {
      final list = [
        Media(id: 1, title: 'A', averageScore: 90, genres: ['Action']),
        Media(id: 2, title: 'B', averageScore: 60, genres: ['Horror']),
      ];
      final result = DataTransformations.mediaToGenreScoreDeviation(list);
      expect(result.firstWhere((e) => e.category == 'Horror').value, -15);
      expect(result.firstWhere((e) => e.category == 'Action').value, 15);
    });

    test('sin scores devuelve lista vacía', () {
      final list = [Media(id: 1, title: 'A', genres: ['Action'])];
      expect(DataTransformations.mediaToGenreScoreDeviation(list), isEmpty);
    });
  });

  group('N4 mediaToCategoryCount', () {
    test('cuenta un campo univaluado y omite nulos', () {
      final result = DataTransformations.mediaToCategoryCount(
        mediaList,
        selector: (m) => m.format,
      );
      expect(result.map((e) => e.category), ['TV', 'MOVIE']);
      expect(result.map((e) => e.value), [2, 1]);
      final total = result.fold<num>(0, (s, e) => s + e.value);
      expect(total, 3);
    });

    test('agrupa nulos si se indica unknownLabel', () {
      final result = DataTransformations.mediaToCategoryCount(
        mediaList,
        selector: (m) => m.status,
        unknownLabel: 'Sin dato',
      );
      expect(result.firstWhere((e) => e.category == 'Sin dato').value, 1);
    });

    test('topNWithOthers conserva la suma total', () {
      final data = [
        ChartDataCategory(category: 'a', value: 5),
        ChartDataCategory(category: 'b', value: 3),
        ChartDataCategory(category: 'c', value: 2),
        ChartDataCategory(category: 'd', value: 1),
      ];
      final result = DataTransformations.topNWithOthers(data, 2);
      expect(result.map((e) => e.category), ['a', 'b', 'Otros']);
      expect(result.last.value, 3);
    });
  });

  group('N7 mediaToSummaryKpis', () {
    test('calcula KPIs de la muestra', () {
      final kpis = DataTransformations.mediaToSummaryKpis(mediaList);
      expect(kpis.totalMedia, 4);
      expect(kpis.scoredMedia, 3);
      expect(kpis.meanAverageScore, 80);
      expect(kpis.finishedCount, 2);
      expect(kpis.withStatusCount, 3);
      expect(kpis.finishedPercent, closeTo(66.67, 0.01));
    });

    test('lista vacía no inventa valores', () {
      final kpis = DataTransformations.mediaToSummaryKpis([]);
      expect(kpis.totalMedia, 0);
      expect(kpis.meanAverageScore, isNull);
      expect(kpis.finishedPercent, isNull);
    });
  });
}
