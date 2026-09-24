import 'package:anilist_data_viz/data/models/media_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaModel', () {
    test('fromJson should parse correctly with fallback titles and images', () {
      final json = {
        'id': 1,
        'title': {
          'romaji': 'Naruto',
          'english': null,
          'userPreferred': 'Naruto Uzumaki',
        },
        'type': 'ANIME',
        'genres': ['Action'],
        'averageScore': 80,
        'coverImage': {
          'medium': 'medium.jpg',
          'large': 'large.jpg',
          'extraLarge': 'xlarge.jpg',
        },
        'startDate': {
          'year': 2002,
          'month': 10,
          'day': 3,
        }
      };

      final model = MediaModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Naruto Uzumaki');
      expect(model.coverImageMedium, 'medium.jpg');
      expect(model.startDate?.year, 2002);
    });

    test('fromJson should handle nulls gracefully', () {
      final json = {
        'id': 2,
        'title': null,
        'coverImage': null,
        'startDate': null,
      };

      final model = MediaModel.fromJson(json);
      expect(model.id, 2);
      expect(model.title, 'Unknown Title');
      expect(model.coverImageMedium, null);
      expect(model.startDate, null);
    });
  });
}
