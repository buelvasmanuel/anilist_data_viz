import 'package:flutter/foundation.dart';
import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/page_info.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';

enum ProviderState { initial, loading, success, empty, error }

class MediaProvider extends ChangeNotifier {
  final AniListRepository repository;

  MediaProvider({required this.repository});

  ProviderState _state = ProviderState.initial;
  ProviderState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Media> _mediaList = [];
  List<Media> get mediaList => _mediaList;

  PageInfo? _pageInfo;
  PageInfo? get pageInfo => _pageInfo;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _loadMoreError = false;
  bool get loadMoreError => _loadMoreError;

  int _currentRequestId = 0;

  // Filters
  String _currentType = 'ANIME';
  String get currentType => _currentType;

  String? _currentFormat;
  String? get currentFormat => _currentFormat;

  String? _currentStatus;
  String? get currentStatus => _currentStatus;

  String? _currentSeason;
  String? get currentSeason => _currentSeason;

  int? _currentSeasonYear;
  int? get currentSeasonYear => _currentSeasonYear;

  String? _currentGenre;
  String? get currentGenre => _currentGenre;

  void updateFilters({
    String? type,
    String? format,
    String? status,
    String? season,
    int? seasonYear,
    String? genre,
  }) {
    if (type != null) _currentType = type;
    _currentFormat = format;
    _currentStatus = status;
    _currentSeason = season;
    _currentSeasonYear = seasonYear;
    _currentGenre = genre;
    
    // Automatically fetch and clear existing list when filters change
    fetchMedia(refresh: true);
  }

  void clearFilters() {
    _currentFormat = null;
    _currentStatus = null;
    _currentSeason = null;
    _currentSeasonYear = null;
    _currentGenre = null;
    fetchMedia(refresh: true);
  }

  Future<void> fetchMedia({bool refresh = false, bool isRetry = false}) async {
    if (refresh) {
      _state = ProviderState.loading;
      _mediaList = [];
      _pageInfo = null;
      _loadMoreError = false;
      _currentRequestId++; 
      notifyListeners();
    } else {
      if (_state == ProviderState.loading || _isLoadingMore) return;
      if (!isRetry && _loadMoreError) return; // Stop scrolling if error is active unless it's a retry
      if (_pageInfo != null && !(_pageInfo!.hasNextPage ?? false)) return;
      
      _isLoadingMore = true;
      _loadMoreError = false; // clear error state when trying
      notifyListeners();
    }

    final int requestId = _currentRequestId; 

    try {
      final pageToFetch = (_pageInfo?.currentPage ?? 0) + 1;
      
      final result = await repository.getMediaList(
        page: pageToFetch,
        perPage: 20,
        type: _currentType,
        format: _currentFormat,
        status: _currentStatus,
        season: _currentSeason,
        seasonYear: _currentSeasonYear,
        genre: _currentGenre,
      );

      if (requestId != _currentRequestId) return;

      _pageInfo = result.pageInfo;
      
      if (refresh) {
        _mediaList = result.mediaList;
      } else {
        final newItems = result.mediaList.where((newItem) => 
          !_mediaList.any((existingItem) => existingItem.id == newItem.id)
        ).toList();
        _mediaList.addAll(newItems);
      }

      if (_mediaList.isEmpty) {
        _state = ProviderState.empty;
      } else {
        _state = ProviderState.success;
      }
    } on Failure catch (e) {
      if (requestId != _currentRequestId) return;
      
      _errorMessage = e.message;
      if (refresh) {
        _state = ProviderState.error;
      } else {
        _loadMoreError = true;
      }
    } finally {
      if (requestId == _currentRequestId) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // Detail State
  ProviderState _detailState = ProviderState.initial;
  ProviderState get detailState => _detailState;
  
  String _detailErrorMessage = '';
  String get detailErrorMessage => _detailErrorMessage;

  Media? _selectedMedia;
  Media? get selectedMedia => _selectedMedia;

  int _currentDetailRequestId = 0;

  Future<void> fetchMediaDetail(int id) async {
    _currentDetailRequestId++;
    final int requestId = _currentDetailRequestId;

    _detailState = ProviderState.loading;
    _selectedMedia = null;
    _detailErrorMessage = '';
    notifyListeners();

    try {
      final media = await repository.getMediaById(id);
      
      if (requestId != _currentDetailRequestId) return;
      
      _selectedMedia = media;
      _detailState = ProviderState.success;
    } on Failure catch (e) {
      if (requestId != _currentDetailRequestId) return;
      
      _detailState = ProviderState.error;
      _detailErrorMessage = e.message;
    } finally {
      if (requestId == _currentDetailRequestId) {
        notifyListeners();
      }
    }
  }
}
