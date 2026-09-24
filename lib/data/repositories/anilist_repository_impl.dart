import 'package:anilist_data_viz/core/errors/exceptions.dart';
import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/data/datasources/anilist/anilist_remote_datasource.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
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
  Future<Media> getMediaById(int id) async {
    try {
      return await remoteDataSource.getMediaById(id);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ParsingFailure(e.toString());
    }
  }
}
