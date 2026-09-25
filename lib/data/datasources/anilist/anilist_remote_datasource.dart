import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:anilist_data_viz/core/constants/api_constants.dart';
import 'package:anilist_data_viz/core/errors/exceptions.dart';
import 'package:anilist_data_viz/data/datasources/anilist/queries/media_queries.dart';
import 'package:anilist_data_viz/data/models/media_model.dart';
import 'package:anilist_data_viz/data/models/media_trend_model.dart';
import 'package:anilist_data_viz/data/models/page_info_model.dart';
import 'package:anilist_data_viz/data/models/paginated_media_model.dart';

abstract class AniListRemoteDataSource {
  Future<PaginatedMediaModel> getMediaList({
    required int page,
    required int perPage,
    String? type,
    String? format,
    String? status,
    String? season,
    int? seasonYear,
    String? genre,
  });

  Future<MediaModel> getMediaById(int id);

  /// Una página de `Media.trends` (orden: fecha descendente).
  Future<({List<MediaTrendModel> trends, PageInfoModel pageInfo})> getMediaTrends({
    required int mediaId,
    required int page,
    required int perPage,
  });

  /// Contadores actuales (popularity, trending, favourites) de varias obras.
  Future<List<MediaModel>> getMediaSnapshots(List<int> ids);
}

class AniListRemoteDataSourceImpl implements AniListRemoteDataSource {
  final http.Client client;

  AniListRemoteDataSourceImpl({required this.client});

  Future<Map<String, dynamic>> _performQuery(String query, Map<String, dynamic> variables) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.anilistGraphqlUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'variables': variables,
        }),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic>? jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (_) {
        // Fallback below
      }

      // Extract GraphQL errors even if HTTP status is 4xx
      if (jsonResponse != null && jsonResponse['errors'] != null && (jsonResponse['errors'] as List).isNotEmpty) {
        final errorMessage = jsonResponse['errors'][0]['message'] ?? 'Unknown GraphQL Error';
        throw ServerException(errorMessage);
      }

      if (response.statusCode == 200) {
        if (jsonResponse == null || jsonResponse['data'] == null) {
          throw ServerException('Unexpected response structure: data is null');
        }
        return jsonResponse['data'];
      } else {
        throw ServerException('HTTP Error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on http.ClientException {
      throw NetworkException('Client error during request');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<PaginatedMediaModel> getMediaList({
    required int page,
    required int perPage,
    String? type,
    String? format,
    String? status,
    String? season,
    int? seasonYear,
    String? genre,
  }) async {
    final variables = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };
    if (type != null && type.isNotEmpty) variables['type'] = type;
    if (format != null && format.isNotEmpty) variables['format'] = format;
    if (status != null && status.isNotEmpty) variables['status'] = status;
    if (season != null && season.isNotEmpty) variables['season'] = season;
    if (seasonYear != null) variables['seasonYear'] = seasonYear;
    if (genre != null && genre.isNotEmpty) variables['genre'] = genre;

    final data = await _performQuery(MediaQueries.getMediaList, variables);

    final pageInfo = PageInfoModel.fromJson(data['Page']['pageInfo']);
    final mediaList = (data['Page']['media'] as List)
        .map((e) => MediaModel.fromJson(e))
        .toList();

    return PaginatedMediaModel(
      pageInfo: pageInfo,
      mediaList: mediaList,
    );
  }

  @override
  Future<MediaModel> getMediaById(int id) async {
    final variables = {'id': id};
    final data = await _performQuery(MediaQueries.getMediaDetail, variables);
    return MediaModel.fromJson(data['Media']);
  }

  @override
  Future<({List<MediaTrendModel> trends, PageInfoModel pageInfo})> getMediaTrends({
    required int mediaId,
    required int page,
    required int perPage,
  }) async {
    final data = await _performQuery(
      MediaQueries.getMediaTrends,
      {'id': mediaId, 'page': page, 'perPage': perPage},
    );
    final connection = data['Media']?['trends'];
    if (connection == null) {
      return (trends: <MediaTrendModel>[], pageInfo: PageInfoModel(currentPage: page, hasNextPage: false));
    }
    return (
      trends: (connection['nodes'] as List).map((e) => MediaTrendModel.fromJson(e)).toList(),
      pageInfo: PageInfoModel.fromJson(connection['pageInfo']),
    );
  }

  @override
  Future<List<MediaModel>> getMediaSnapshots(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final data = await _performQuery(
      MediaQueries.getMediaSnapshots,
      {'ids': ids, 'perPage': ids.length},
    );
    return (data['Page']['media'] as List).map((e) => MediaModel.fromJson(e)).toList();
  }
}
