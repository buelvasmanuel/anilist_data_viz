import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anilist_data_viz/data/datasources/anilist/anilist_remote_datasource.dart';
import 'package:anilist_data_viz/core/errors/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

class MockClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request) handler;
  MockClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

class TimeoutMockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw TimeoutException('Timeout');
  }
}

void main() {
  group('AniListRemoteDataSource', () {
    test('should return PaginatedMediaModel on 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({
          'data': {
            'Page': {
              'pageInfo': {'currentPage': 1, 'hasNextPage': false},
              'media': [{'id': 1, 'title': {'userPreferred': 'Test'}, 'type': 'ANIME'}]
            }
          }
        }), 200);
      });

      final dataSource = AniListRemoteDataSourceImpl(client: mockClient);
      final result = await dataSource.getMediaList(page: 1, perPage: 10);
      
      expect(result.mediaList.length, 1);
      expect(result.mediaList.first.id, 1);
    });

    test('should throw ServerException with GraphQL message on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({
          'errors': [{'message': 'GraphQL validation error'}],
          'data': null
        }), 200);
      });

      final dataSource = AniListRemoteDataSourceImpl(client: mockClient);
      expect(() => dataSource.getMediaList(page: 1, perPage: 10), 
          throwsA(isA<ServerException>().having((e) => e.message, 'message', 'GraphQL validation error')));
    });

    test('should throw ServerException with GraphQL message on HTTP 400', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({
          'errors': [{'message': 'Not Found.'}],
        }), 404);
      });

      final dataSource = AniListRemoteDataSourceImpl(client: mockClient);
      expect(() => dataSource.getMediaList(page: 1, perPage: 10), 
          throwsA(isA<ServerException>().having((e) => e.message, 'message', 'Not Found.')));
    });

    test('should throw NetworkException on Timeout', () async {
      final dataSource = AniListRemoteDataSourceImpl(client: TimeoutMockClient());
      expect(() => dataSource.getMediaList(page: 1, perPage: 10), 
          throwsA(isA<NetworkException>()));
    });
  });
}
