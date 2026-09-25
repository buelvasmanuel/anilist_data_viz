import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/domain/entities/fuzzy_date.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/media_trend.dart';
import 'package:anilist_data_viz/domain/entities/page_info.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';

/// Repositorio falso para tests: devuelve obras de prueba sin red.
class FakeRepository implements AniListRepository {
  int calls = 0;
  bool failTrends = false;
  bool fail = false;
  final List<String?> requestedTypes = [];

  static const _genres = ['Action', 'Comedy', 'Drama', 'Romance', 'Fantasy', 'Horror'];
  static const _formats = ['TV', 'MOVIE', 'OVA', 'ONA', 'TV_SHORT', 'SPECIAL', 'MUSIC'];
  static const _statuses = ['FINISHED', 'RELEASING', 'NOT_YET_RELEASED'];
  static const _sources = ['MANGA', 'ORIGINAL', 'LIGHT_NOVEL', 'NOVEL', 'GAME', 'OTHER', 'WEB_NOVEL'];

  @override
  Future<({List<Media> mediaList, PageInfo pageInfo})> getMediaList({
    required int page,
    required int perPage,
    String? type,
    String? format,
    String? status,
    String? season,
    int? seasonYear,
    String? genre,
  }) async {
    calls++;
    requestedTypes.add(type);
    if (fail) throw NetworkFailure('sin red');
    final list = List.generate(perPage, (i) {
      final id = (page - 1) * perPage + i;
      return Media(
        id: id,
        title: 'T$id',
        type: type,
        format: _formats[id % _formats.length],
        status: _statuses[id % _statuses.length],
        source: _sources[id % _sources.length],
        startDate: FuzzyDate(year: 1995 + id % 30),
        endDate: FuzzyDate(year: 1995 + id % 30 + id % 4),
        popularity: 500000 - id * 1200,
        ratedAllTimeRank: id * 3 + 1,
        averageScore: 55 + (id * 7) % 40,
        episodes: 1 + (id * 5) % 90,
        chapters: 10 + (id * 13) % 400,
        genres: [_genres[id % _genres.length], _genres[(id + 2) % _genres.length]],
      );
    });
    return (
      mediaList: list,
      pageInfo: PageInfo(currentPage: page, hasNextPage: page < 4),
    );
  }

  @override
  Future<Media> getMediaById(int id) async => Media(id: id, title: 'T$id');

  /// Serie de prueba: 25 días por página hacia atrás desde una fecha fija.
  /// Solo para tests; la app usa la serie real de AniList.
  @override
  Future<({List<MediaTrend> trends, PageInfo pageInfo})> getMediaTrends({
    required int mediaId,
    required int page,
    int perPage = 25,
  }) async {
    if (fail || failTrends) throw NetworkFailure('sin red');
    final end = DateTime.utc(2026, 9, 1);
    return (
      trends: [
        for (var i = 0; i < perPage; i++)
          MediaTrend(
            mediaId: mediaId,
            date: end.subtract(Duration(days: (page - 1) * perPage + i)),
            popularity: 100000 - ((page - 1) * perPage + i) * 300 + ((page * 31 + i * 17) % 97),
            trending: 50 + i,
          ),
      ],
      pageInfo: PageInfo(currentPage: page, hasNextPage: page < 4),
    );
  }

  int snapshotCalls = 0;

  @override
  Future<List<Media>> getMediaSnapshots(List<int> ids) async {
    snapshotCalls++;
    return [for (final id in ids) Media(id: id, title: 'T$id', popularity: 1000 + id + snapshotCalls)];
  }
}
