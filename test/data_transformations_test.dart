import 'package:anilist_data_viz/charts/transformations/data_transformations.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/fuzzy_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataTransformations', () {
    final mediaList = [
      Media(id: 1, title: 'A', type: 'ANIME', format: 'TV', startDate: FuzzyDate(year: 2020), averageScore: 80, genres: ['Action']),
      Media(id: 2, title: 'B', type: 'ANIME', format: 'TV', startDate: FuzzyDate(year: 2020), averageScore: 90, genres: ['Action', 'Comedy']),
      Media(id: 3, title: 'C', type: 'MANGA', format: 'MANGA', startDate: FuzzyDate(year: 2021), averageScore: 100, genres: ['Comedy']),
    ];

    test('mediaToTypeScorePerYear (Multiple Series)', () {
      final result = DataTransformations.mediaToTypeScorePerYear(mediaList);
      expect(result.length, 2); // ANIME, MANGA
      
      final animeSeries = result.firstWhere((s) => s.seriesName == 'ANIME');
      expect(animeSeries.data.length, 1);
      expect(animeSeries.data.first.x, 2020);
      expect(animeSeries.data.first.y, 85); // (80+90)/2
    });

    test('mediaToGenreYearMatrix (Matrix)', () {
      final result = DataTransformations.mediaToGenreYearMatrix(mediaList);
      expect(result.length, 3); // Action-2020, Comedy-2020, Comedy-2021
      
      final action2020 = result.firstWhere((m) => m.row == 'Action' && m.column == '2020');
      expect(action2020.value, 2);
    });

    test('mediaToScoreRangesByFormat (Range)', () {
      final result = DataTransformations.mediaToScoreRangesByFormat(mediaList);
      expect(result.length, 2); // TV, MANGA
      
      final tvRange = result.firstWhere((r) => r.category == 'TV');
      expect(tvRange.min, 80);
      expect(tvRange.max, 90);
    });

    test('mediaToGenreHierarchy (Hierarchy)', () {
      final result = DataTransformations.mediaToGenreHierarchy(mediaList);
      // Roots: Action, Comedy
      // Leaves: Action_1, Action_2, Comedy_2, Comedy_3
      expect(result.length, 6);
      
      final roots = result.where((h) => h.parentId == null).toList();
      expect(roots.length, 2);
    });
    test('N5 mediaToSeriesByCategory', () {
      final media = [
        Media(id: 1, title: 'A', source: 'ORIGINAL', status: 'FINISHED'),
        Media(id: 2, title: 'B', source: 'MANGA', status: 'FINISHED'),
        Media(id: 3, title: 'C', source: 'ORIGINAL', status: 'RELEASING'),
      ];
      final result = DataTransformations.mediaToSeriesByCategory(
        media,
        categorySelector: (m) => m.source,
        seriesSelector: (m) => m.status,
      );
      expect(result.length, 2); // FINISHED, RELEASING
      final fin = result.firstWhere((e) => e.seriesName == 'FINISHED');
      expect(fin.data.length, 2); // ORIGINAL, MANGA categories
      expect(fin.data.firstWhere((e) => e.category == 'ORIGINAL').value, 1);
      expect(fin.data.firstWhere((e) => e.category == 'MANGA').value, 1);
    });

    test('N6 mediaToCountPerYearMonth', () {
      final media = [
        Media(id: 1, title: 'A', startDate: FuzzyDate(year: 2020, month: 1)),
        Media(id: 2, title: 'B', startDate: FuzzyDate(year: 2020, month: 1)),
        Media(id: 3, title: 'C', startDate: FuzzyDate(year: 2020, month: 2)),
      ];
      final result = DataTransformations.mediaToCountPerYearMonth(media);
      expect(result.length, 2);
      expect(result.first.x, 202001);
      expect(result.first.y, 2);
      expect(result.last.x, 202002);
      expect(result.last.y, 1);
    });

    test('N8 mediaToScatterPoints and linearRegression', () {
      final media = [
        Media(id: 1, title: 'A', popularity: 100, averageScore: 50),
        Media(id: 2, title: 'B', popularity: 200, averageScore: 60),
        Media(id: 3, title: 'C', popularity: 300, averageScore: 70),
      ];
      final scatter = DataTransformations.mediaToScatterPoints(
        media,
        xSelector: (m) => m.popularity,
        ySelector: (m) => m.averageScore,
      );
      expect(scatter.length, 3);
      expect(scatter.first.x, 100);
      expect(scatter.first.y, 50);

      final regression = DataTransformations.linearRegression(scatter);
      expect(regression.length, 2); // slope, intercept
      expect(regression[0], closeTo(0.1, 0.001)); // slope = (70-50)/(300-100) = 0.1
      expect(regression[1], closeTo(40, 0.001)); // intercept = 50 - 0.1*100 = 40
    });

    test('N9 mediaToYearMetricsNormalized', () {
      final media = [
        Media(id: 1, title: 'A', startDate: FuzzyDate(year: 2020), averageScore: 50),
        Media(id: 2, title: 'B', startDate: FuzzyDate(year: 2020), averageScore: 100),
        Media(id: 3, title: 'C', startDate: FuzzyDate(year: 2021), averageScore: 100),
      ];
      final result = DataTransformations.mediaToYearMetricsNormalized(media);
      expect(result.length, 2); // Conteo, Score Promedio
      final countSeries = result.firstWhere((e) => e.seriesName == 'Conteo (Norm)');
      expect(countSeries.data.length, 2);
      expect(countSeries.data.firstWhere((e) => e.x == 2020).y, 1.0); // max count is 2, so 2/2 = 1.0
      expect(countSeries.data.firstWhere((e) => e.x == 2021).y, 0.5); // 1/2 = 0.5
      
      final scoreSeries = result.firstWhere((e) => e.seriesName == 'Score (Norm)');
      expect(scoreSeries.data.firstWhere((e) => e.x == 2020).y, 0.75); // (50+100)/2 = 75. 75/100 = 0.75
      expect(scoreSeries.data.firstWhere((e) => e.x == 2021).y, 1.0); // 100/100 = 1.0
    });

    test('N10 mediaToSeriesPerYear', () {
      final media = [
        Media(id: 1, title: 'A', startDate: FuzzyDate(year: 2020), source: 'ORIGINAL'),
        Media(id: 2, title: 'B', startDate: FuzzyDate(year: 2020), source: 'MANGA'),
        Media(id: 3, title: 'C', startDate: FuzzyDate(year: 2021), source: 'ORIGINAL'),
      ];
      final result = DataTransformations.mediaToSeriesPerYear(media, seriesSelector: (m) => m.source);
      expect(result.length, 2); // ORIGINAL, MANGA
      final original = result.firstWhere((e) => e.seriesName == 'ORIGINAL');
      expect(original.data.length, 2); // 2020, 2021
      expect(original.data.firstWhere((e) => e.x == 2020).y, 1);
      expect(original.data.firstWhere((e) => e.x == 2021).y, 1);
      
      final manga = result.firstWhere((e) => e.seriesName == 'MANGA');
      expect(manga.data.length, 1); // 2020 only
      expect(manga.data.firstWhere((e) => e.x == 2020).y, 1);
    });
  });
}
