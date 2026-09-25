import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/media_trend.dart';
import 'package:anilist_data_viz/domain/entities/page_info.dart';

abstract class AniListRepository {
  Future<({List<Media> mediaList, PageInfo pageInfo})> getMediaList({
    required int page,
    required int perPage,
    String? type,
    String? format,
    String? status,
    String? season,
    int? seasonYear,
    String? genre,
  });

  Future<Media> getMediaById(int id);

  /// Una página de la serie diaria `Media.trends` (fecha descendente).
  Future<({List<MediaTrend> trends, PageInfo pageInfo})> getMediaTrends({
    required int mediaId,
    required int page,
    int perPage = 25,
  });

  /// Contadores actuales de varias obras (para el sondeo periódico).
  Future<List<Media>> getMediaSnapshots(List<int> ids);
}
