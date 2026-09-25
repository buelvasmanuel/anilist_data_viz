import 'package:flutter/foundation.dart';
import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';

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

  ChartsDatasetProvider({
    required this.repository,
    this.pages = 4,
    this.perPage = 50,
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

      _media = collected;
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
}
