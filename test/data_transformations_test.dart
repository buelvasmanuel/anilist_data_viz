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
  });
}
