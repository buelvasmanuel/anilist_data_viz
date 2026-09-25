import 'package:anilist_data_viz/core/errors/exceptions.dart';
import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/data/datasources/anilist/anilist_remote_datasource.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/media_trend.dart';
import 'package:anilist_data_viz/domain/entities/page_info.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';

class AniListRepositoryImpl implements AniListRepository {
  final AniListRemoteDataSource remoteDataSource;

  AniListRepositoryImpl({required this.remoteDataSource});

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
    try {
      final result = await remoteDataSource.getMediaList(
        page: page,
        perPage: perPage,
        type: type,
        format: format,
        status: status,
        season: season,
        seasonYear: seasonYear,
        genre: genre,
      );

      return (
        mediaList: result.mediaList, // Type is implicitly handled by PaginatedMediaModel
        pageInfo: result.pageInfo,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ParsingFailure(e.toString());
    }
  }

  @override
  Future<Media> getMediaById(int id) => _guard(() => remoteDataSource.getMediaById(id));

  @override
  Future<({List<MediaTrend> trends, PageInfo pageInfo})> getMediaTrends({
    required int mediaId,
    required int page,
    int perPage = 25,
  }) =>
      _guard(() async {
        final r = await remoteDataSource.getMediaTrends(mediaId: mediaId, page: page, perPage: perPage);
        return (trends: <MediaTrend>[...r.trends], pageInfo: r.pageInfo as PageInfo);
      });

  @override
  Future<List<Media>> getMediaSnapshots(List<int> ids) =>
      _guard(() async => <Media>[...await remoteDataSource.getMediaSnapshots(ids)]);

  /// Traduce las excepciones de la capa de datos a [Failure].
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ParsingFailure(e.toString());
    }
  }
}
