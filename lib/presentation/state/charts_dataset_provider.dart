import 'package:flutter/foundation.dart';
import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/entities/media_trend.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_dataset.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_adapters.dart';
/// Muestra de datos para la galería de gráficas.
///
/// Es independiente de [MediaProvider]: no hereda los filtros ni el scroll de
/// las pantallas de listado y no modifica su estado. Carga [pages] páginas
/// de [perPage] obras del tipo seleccionado, en el orden que devuelve la
/// consulta existente (`sort: POPULARITY_DESC`). Las gráficas describen
/// solo esta muestra, no la base completa de AniList.
class ChartsDatasetProvider extends ChangeNotifier {
  final AniListRepository repository;
  final int pages;
  final int perPage;

  /// Páginas de `Media.trends` (25 días cada una) del título más popular.
  final int trendPages;

  ChartsDatasetProvider({
    required this.repository,
    this.pages = 4,
    this.perPage = 50,
    this.trendPages = 4,
  });

  ProviderState _state = ProviderState.initial;
  ProviderState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _type = 'ANIME';
  String get type => _type;

  /// Tipo de la muestra actualmente visible (puede diferir de [type]
  /// mientras se carga uno nuevo).
  String _loadedType = 'ANIME';
  String get loadedType => _loadedType;

  List<Media> _media = [];
  List<Media> get media => _media;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _loadedPages = 0;

  /// Páginas recibidas en la carga en curso (para mostrar progreso).
  int get loadedPages => _loadedPages;

  int _requestId = 0;

  GraphicDataset? _graphicDataset;

  /// Dataset común precalculado. Lo usan las cuatro galerías (no solo Graphic).
  GraphicDataset? get graphicDataset => _graphicDataset;

  List<MediaTrend> _trends = [];

  /// Serie diaria `Media.trends` de [trendsMedia] (orden cronológico).
  List<MediaTrend> get trends => _trends;

  Media? _trendsMedia;

  /// Obra cuya serie de trends se usa (#32, #33, #41-#44): la más popular.
  Media? get trendsMedia => _trendsMedia;

  String _trendsError = '';

  /// Error al cargar trends (la muestra principal sigue siendo válida).
  String get trendsError => _trendsError;

  /// Carga la muestra. Mientras se carga se conservan los datos anteriores
  /// para que las gráficas animen la transición al recibir los nuevos.
  Future<void> load({String? type}) async {
    if (type != null) _type = type;
    final requestId = ++_requestId;

    _isLoading = true;
    _errorMessage = '';
    if (_media.isEmpty) _state = ProviderState.loading;
    notifyListeners();

    _loadedPages = 0;
    try {
      // Las páginas se piden en paralelo (pocas peticiones, dentro del límite
      // de AniList). Si hay menos páginas, las sobrantes llegan vacías.
      final results = await Future.wait([
        for (var page = 1; page <= pages; page++)
          repository
              .getMediaList(page: page, perPage: perPage, type: _type)
              .then((result) {
            if (requestId == _requestId) {
              _loadedPages++;
              notifyListeners();
            }
            return result;
          }),
      ]);
      if (requestId != _requestId) return;

      final List<Media> collected = [];
      final seen = <int>{};
      for (final result in results) {
        for (final media in result.mediaList) {
          if (seen.add(media.id)) collected.add(media);
        }
      }

      final trendsMedia = collected.isEmpty ? null : collected.first;
      final trends = trendsMedia == null ? <MediaTrend>[] : await _loadTrends(trendsMedia.id);
      if (requestId != _requestId) return;

      _media = collected;
      _trendsMedia = trendsMedia;
      _trends = trends;
      _graphicDataset = GraphicDataset.fromAnime(
        GraphicAdapters.animeFrom<Media>(
          collected,
          title: (m) => m.title,
          popularity: (m) => m.popularity ?? 0,
          format: (m) => m.format ?? 'UNKNOWN',
          status: (m) => m.status ?? 'UNKNOWN',
          score: (m) => m.averageScore,
          // Tamaño de burbuja (#11): episodios en anime, capítulos en manga.
          episodes: (m) => m.type == 'MANGA' ? m.chapters : m.episodes,
          genres: (m) => m.genres,
          seasonYear: (m) => m.seasonYear,
          startYear: (m) => m.startDate?.year,
          endYear: (m) => m.endDate?.year,
          rank: (m) => m.ratedAllTimeRank,
          studio: (m) => m.studios.isNotEmpty ? m.studios.first.name : null,
        ),
        trends: GraphicAdapters.trendsFrom<MediaTrend>(
          trends,
          unixSeconds: (t) => t.date.millisecondsSinceEpoch ~/ 1000,
          popularity: (t) => t.popularity,
        ),
      );
      _loadedType = _type;
      _state = collected.isEmpty ? ProviderState.empty : ProviderState.success;
    } on Failure catch (e) {
      if (requestId != _requestId) return;
      _errorMessage = e.message;
      // Si ya había una muestra, se mantiene visible y solo se informa el error.
      if (_media.isEmpty) _state = ProviderState.error;
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Descarga [trendPages] páginas de `Media.trends` en paralelo. Un fallo
  /// aquí no invalida la muestra: se guarda en [trendsError].
  Future<List<MediaTrend>> _loadTrends(int mediaId) async {
    _trendsError = '';
    try {
      final pages = await Future.wait([
        for (var page = 1; page <= trendPages; page++)
          repository.getMediaTrends(mediaId: mediaId, page: page),
      ]);
      final byDate = <int, MediaTrend>{
        for (final p in pages)
          for (final t in p.trends) t.date.millisecondsSinceEpoch: t,
      };
      return byDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    } on Failure catch (e) {
      _trendsError = e.message;
      return [];
    }
  }
}
