import 'dart:async';

import 'package:anilist_data_viz/core/errors/failure.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/domain/repositories/anilist_repository.dart';
import 'package:flutter/foundation.dart';

/// Una lectura del sondeo periódico (#63).
class LiveSample {
  final DateTime time;

  /// Suma de `popularity` de las obras vigiladas en esta lectura.
  final int totalPopularity;

  /// Diferencia con la lectura anterior (0 en la primera).
  final int delta;

  /// Popularidad por obra (título → valor) en esta lectura.
  final Map<String, int> byTitle;

  const LiveSample({
    required this.time,
    required this.totalPopularity,
    required this.delta,
    required this.byTitle,
  });
}

/// Estado "vivo" de las galerías, separado de la muestra fija
/// ([ChartsDatasetProvider]) para que sus cambios solo reconstruyan las
/// tarjetas #52 y #63.
///
/// - #52: paginación real contra AniList (`Page(page, perPage)`).
/// - #63: sondeo periódico real (Timer → GraphQL → comparar → notificar).
///   AniList no ofrece push/WebSocket; esto es polling y así se indica.
class AniListLiveProvider extends ChangeNotifier {
  final AniListRepository repository;
  final int lazyPerPage;
  final Duration pollInterval;
  final int maxSamples;

  AniListLiveProvider({
    required this.repository,
    this.lazyPerPage = 20,
    this.pollInterval = const Duration(seconds: 30),
    this.maxSamples = 30,
  });

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ---------------------------------------------------------------- #52

  String? _lazyType;
  final List<Media> _lazyItems = [];
  int _lazyPage = 0;
  bool _lazyHasNext = true;
  bool _lazyLoading = false;
  String _lazyError = '';

  List<Media> get lazyItems => List.unmodifiable(_lazyItems);
  int get lazyPage => _lazyPage;
  bool get lazyHasNext => _lazyHasNext;
  bool get lazyLoading => _lazyLoading;
  String get lazyError => _lazyError;

  /// Prepara la paginación para [type] y carga la primera página si hace
  /// falta. Si cambia el tipo, se reinicia.
  Future<void> ensureLazyStarted(String type) async {
    if (_lazyType != type) {
      _lazyType = type;
      _lazyItems.clear();
      _lazyPage = 0;
      _lazyHasNext = true;
      _lazyError = '';
    }
    if (_lazyPage == 0) await loadNextPage();
  }

  /// Pide a AniList la página siguiente y la añade a [lazyItems].
  Future<void> loadNextPage() async {
    final type = _lazyType;
    if (type == null || _lazyLoading || !_lazyHasNext) return;
    _lazyLoading = true;
    _lazyError = '';
    _notify();
    try {
      final result = await repository.getMediaList(page: _lazyPage + 1, perPage: lazyPerPage, type: type);
      if (_disposed || type != _lazyType) return;
      final seen = {for (final m in _lazyItems) m.id};
      _lazyItems.addAll(result.mediaList.where((m) => seen.add(m.id)));
      _lazyPage++;
      _lazyHasNext = result.pageInfo.hasNextPage ?? false;
    } on Failure catch (e) {
      _lazyError = e.message;
    } finally {
      _lazyLoading = false;
      _notify();
    }
  }

  // ---------------------------------------------------------------- #63

  final List<LiveSample> _samples = [];
  List<int> _pollIds = const [];
  Timer? _timer;
  int _pollUsers = 0;
  bool _polling = false;
  String _pollError = '';
  DateTime? _lastPoll;

  List<LiveSample> get samples => List.unmodifiable(_samples);
  String get pollError => _pollError;
  DateTime? get lastPoll => _lastPoll;

  /// Número de lecturas en las que la popularidad cambió respecto a la anterior.
  int get changesDetected => _samples.where((s) => s.delta != 0).length;

  /// Registra un consumidor del sondeo. El Timer solo corre mientras haya
  /// al menos uno (la tarjeta #63 visible).
  void acquirePolling(List<int> ids) {
    if (!listEquals(ids, _pollIds)) {
      _pollIds = List.of(ids);
      _samples.clear();
    }
    _pollUsers++;
    if (_timer == null && _pollIds.isNotEmpty) {
      _timer = Timer.periodic(pollInterval, (_) => pollNow());
      pollNow();
    }
  }

  void releasePolling() {
    if (_pollUsers > 0) _pollUsers--;
    if (_pollUsers == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Una lectura: GraphQL → comparar con la anterior → notificar.
  Future<void> pollNow() async {
    if (_polling || _pollIds.isEmpty) return;
    _polling = true;
    try {
      final snapshot = await repository.getMediaSnapshots(_pollIds);
      if (_disposed) return;
      final byTitle = {for (final m in snapshot) m.title: m.popularity ?? 0};
      final total = byTitle.values.fold<int>(0, (a, b) => a + b);
      final previous = _samples.isEmpty ? null : _samples.last.totalPopularity;
      _samples.add(LiveSample(
        time: DateTime.now(),
        totalPopularity: total,
        delta: previous == null ? 0 : total - previous,
        byTitle: byTitle,
      ));
      if (_samples.length > maxSamples) _samples.removeAt(0);
      _lastPoll = DateTime.now();
      _pollError = '';
    } on Failure catch (e) {
      _pollError = e.message;
    } finally {
      _polling = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
