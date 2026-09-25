// Contenedores de los casos que dependen de peticiones vivas a AniList.
// Cada librería solo aporta la función que dibuja el gráfico.
//
// #52: paginación REAL. Al llegar al final del scroll se pide la página
//      siguiente a AniList (AniListLiveProvider.loadNextPage).
// #63: sondeo periódico REAL. Timer → GraphQL → comparar → notificar.

import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/presentation/state/anilist_live_provider.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// #52 Infinite Scrolling / Lazy Loading.
class LazyLoadingHost extends StatefulWidget {
  const LazyLoadingHost({super.key, required this.chartBuilder, this.itemWidth = 34});

  /// Dibuja las obras cargadas hasta ahora (en el orden de AniList).
  final Widget Function(List<Media> items) chartBuilder;

  /// Ancho horizontal por obra: el gráfico crece al llegar páginas.
  final double itemWidth;

  @override
  State<LazyLoadingHost> createState() => _LazyLoadingHostState();
}

class _LazyLoadingHostState extends State<LazyLoadingHost> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final type = context.read<ChartsDatasetProvider>().loadedType;
      context.read<AniListLiveProvider>().ensureLazyStarted(type);
    });
  }

  void _onScroll() {
    final p = _controller.position;
    if (p.pixels >= p.maxScrollExtent - 40) context.read<AniListLiveProvider>().loadNextPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = context.watch<AniListLiveProvider>();
    final items = live.lazyItems;
    final status = live.lazyLoading
        ? 'Pidiendo la página ${live.lazyPage + 1} a AniList…'
        : live.lazyError.isNotEmpty
            ? 'Error: ${live.lazyError}'
            : live.lazyHasNext
                ? 'Desplázate al final para pedir la página ${live.lazyPage + 1}'
                : 'No hay más páginas';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(
              'Paginación real contra AniList · ${live.lazyPage} páginas × ${live.lazyPerPage} · '
              '${items.length} obras. $status',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: live.lazyHasNext && !live.lazyLoading ? live.loadNextPage : null,
            child: const Text('Siguiente página'),
          ),
        ]),
        Expanded(
          child: items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (items.length * widget.itemWidth).clamp(constraints.maxWidth, double.infinity);
                    return Scrollbar(
                      controller: _controller,
                      child: SingleChildScrollView(
                        controller: _controller,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(width: width, child: widget.chartBuilder(items)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// #63 Real-time Streaming (actualización periódica, no push).
class LiveStreamingHost extends StatefulWidget {
  const LiveStreamingHost({super.key, required this.chartBuilder, this.titles = 5});

  /// Dibuja las lecturas acumuladas (la más reciente al final).
  final Widget Function(List<LiveSample> samples) chartBuilder;

  /// Número de obras vigiladas (las más populares de la muestra).
  final int titles;

  @override
  State<LiveStreamingHost> createState() => _LiveStreamingHostState();
}

class _LiveStreamingHostState extends State<LiveStreamingHost> {
  AniListLiveProvider? _live;

  @override
  void initState() {
    super.initState();
    final ids = context.read<ChartsDatasetProvider>().media.take(widget.titles).map((m) => m.id).toList();
    _live = context.read<AniListLiveProvider>()..acquirePolling(ids);
  }

  @override
  void dispose() {
    _live?.releasePolling();
    super.dispose();
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final live = context.watch<AniListLiveProvider>();
    final samples = live.samples;
    final last = samples.isEmpty ? null : samples.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actualización periódica desde AniList · cada ${live.pollInterval.inSeconds} s · '
          'popularidad total de ${widget.titles} obras más populares',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Text(
          last == null
              ? 'Primera consulta en curso…'
              : 'Última consulta ${_time(live.lastPoll!)} · ${samples.length} lecturas · '
                  'cambios detectados: ${live.changesDetected} · Δ última: ${last.delta >= 0 ? '+' : ''}${last.delta}'
                  '${live.pollError.isEmpty ? '' : ' · error: ${live.pollError}'}',
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: samples.isEmpty ? const Center(child: CircularProgressIndicator()) : widget.chartBuilder(samples),
        ),
      ],
    );
  }
}

/// Etiqueta de hora de una lectura (eje X de #63).
String liveLabel(LiveSample s) =>
    '${s.time.hour.toString().padLeft(2, '0')}:${s.time.minute.toString().padLeft(2, '0')}:${s.time.second.toString().padLeft(2, '0')}';
