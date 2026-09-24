import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/page_info.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRepository implements AniListRepository {
  bool shouldFail = false;
  int pageCount = 1;
  String? lastFetchedType;

  @override
  Future<({List<Media> mediaList, PageInfo pageInfo})> getMediaList({
    required int page, required int perPage, String? type, String? format, String? status, String? season, int? seasonYear, String? genre
  }) async {
    lastFetchedType = type;
    if (shouldFail) throw ServerFailure('Failed');
    
    final mediaList = [Media(id: page, title: 'Title $page')];
    final pageInfo = PageInfo(currentPage: page, hasNextPage: page < pageCount);
    
    return (mediaList: mediaList, pageInfo: pageInfo);
  }

  @override
  Future<Media> getMediaById(int id) async {
    if (shouldFail) throw ServerFailure('Failed Detail');
    return Media(id: id, title: 'Title $id');
  }
}

void main() {
  group('MediaProvider', () {
    late MediaProvider provider;
    late MockRepository mockRepository;

    setUp(() {
      mockRepository = MockRepository();
      provider = MediaProvider(repository: mockRepository);
    });

    test('loadMoreError stops scrolling but allows retry', () async {
      mockRepository.pageCount = 3;
      await provider.fetchMedia(refresh: true); // Page 1
      
      mockRepository.shouldFail = true;
      await provider.fetchMedia(); // Page 2 fails
      expect(provider.loadMoreError, true);
      
      // Scroll should be ignored
      mockRepository.shouldFail = false;
      await provider.fetchMedia(); // Normal scroll
      expect(provider.loadMoreError, true); // Still blocked
      expect(provider.mediaList.length, 1);
      
      // Retry should pass
      await provider.fetchMedia(isRetry: true);
      expect(provider.loadMoreError, false);
      expect(provider.mediaList.length, 2);
    });

    test('updateFilters clears data and fetches new', () async {
      await provider.fetchMedia(refresh: true);
      expect(provider.mediaList.length, 1);
      
      provider.updateFilters(type: 'MANGA');
      // updateFilters calls fetchMedia(refresh: true) automatically
      // But we await a delay or just check the mock directly (synchronous call kicks off async)
      // Since it's async we can await fetchMedia here just to settle the Future
      await Future.delayed(Duration.zero); 
      
      expect(mockRepository.lastFetchedType, 'MANGA');
      expect(provider.currentType, 'MANGA');
    });

    test('detail state handles errors independently', () async {
      await provider.fetchMedia(refresh: true); // List succeeds
      
      mockRepository.shouldFail = true;
      await provider.fetchMediaDetail(1); // Detail fails
      
      expect(provider.detailState, ProviderState.error);
      expect(provider.detailErrorMessage, 'Failed Detail');
      
      // List state should still be success
      expect(provider.state, ProviderState.success);
      expect(provider.errorMessage, '');
    });
  });
}
