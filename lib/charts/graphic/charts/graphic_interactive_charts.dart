// Interactivas y dinámicas: #38, #39, #40, #47, #52, #55, #60, #61, #63.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import '../data/graphic_view_models.dart';
import 'graphic_chart_helpers.dart';

Map<String, Variable<GDatedValue, dynamic>> _datedVars() => {
      'date': Variable<GDatedValue, DateTime>(
        accessor: (v) => v.date,
        scale: TimeScale(formatter: (t) => '${t.year}'),
      ),
      'value': Variable<GDatedValue, num>(accessor: (v) => v.value, scale: LinearScale(min: 0)),
      'title': Variable<GDatedValue, String>(accessor: (v) => v.label),
    };

// ---------------------------------------------------------------------------
// #38 Pan & Zoom — NATIVO — DIRECTO
// ---------------------------------------------------------------------------

/// Pellizcar/arrastrar (táctil) o rueda (ratón) sobre el eje X.
/// Nota: dentro de un ScrollView, el gesto compite con el scroll del padre.
Widget g38PanZoom(GraphicDataset d) => guard(
      d.datedTitles.length >= 3,
      () => Chart(
        data: d.datedTitles,
        variables: _datedVars(),
        marks: [PointMark(position: Varset('date') * Varset('value'), size: SizeEncode(value: 5))],
        coord: RectCoord(
          horizontalRangeUpdater: Defaults.horizontalRangeEvent,
          verticalRangeUpdater: Defaults.verticalRangeEvent,
        ),
        axes: standardAxes,
      ),
    );

// ---------------------------------------------------------------------------
// #39 Crosshair — NATIVO — DIRECTO
// ---------------------------------------------------------------------------

Widget g39Crosshair(GraphicDataset d) {
  final data = [for (final a in d.titles) if (a.score != null) a];
  return guard(
    data.length >= 3,
    () => Chart<GAnime>(
      data: data,
      variables: {
        'title': Variable<GAnime, String>(accessor: (a) => a.title),
        'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity),
        'score': Variable<GAnime, num>(accessor: (a) => a.score!, scale: LinearScale(min: 0, max: 100)),
      },
      marks: [PointMark(position: Varset('popularity') * Varset('score'))],
      selections: {
        'cursor': PointSelection(
          on: {GestureType.hover, GestureType.tapDown, GestureType.longPressMoveUpdate},
        ),
      },
      crosshair: CrosshairGuide(followPointer: [true, true]),
      tooltip: TooltipGuide(variables: ['title', 'popularity', 'score']),
      axes: standardAxes,
    ),
  );
}

// ---------------------------------------------------------------------------
// #40 Trackball — VARIANTE — DERIVADO
// ---------------------------------------------------------------------------

/// No existe TrackballGuide: selección por X de todas las series +
/// tooltip multi-tupla + crosshair + marcadores que aparecen al seleccionar.
Widget g40Trackball(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty && d.years.length >= 2,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          marks: [
            LineMark(
              position: Varset('x') * Varset('value') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
            ),
            PointMark(
              position: Varset('x') * Varset('value') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              size: SizeEncode(value: 0, updaters: {
                'track': {true: (_) => 8},
              }),
            ),
          ],
          selections: {
            'track': PointSelection(
              on: {
                GestureType.hover,
                GestureType.tapDown,
                GestureType.longPressMoveUpdate,
                GestureType.scaleUpdate,
              },
              dim: Dim.x,
              variable: 'x',
            ),
          },
          tooltip: TooltipGuide(multiTuples: true, variables: ['series', 'value']),
          crosshair: CrosshairGuide(followPointer: [false, true]),
          axes: standardAxes,
        ),
        d.formats,
      ),
    );

// ---------------------------------------------------------------------------
// #47 Cartesian Widget Annotations — COMPOSICIÓN — DIRECTO
// ---------------------------------------------------------------------------

/// Capa Graphic: TagAnnotation (canvas). Capa Flutter: Chip real en un Stack.
/// Datos: DIRECTO (popularity de los 10 títulos más populares).
/// Para convertir datos → píxeles se fijan padding y escala (niceRange: false).
/// La conversión replica la de Graphic para OrdinalScale sin inflate:
///   x_norm = (índice + 0.5) / n.
/// El widget NO sigue al zoom/pan (este gráfico no los activa).
Widget g47WidgetAnnotations(GraphicDataset d) {
  final data = d.topByPopularity;
  return guard(data.length >= 2, () {
    const pad = EdgeInsets.fromLTRB(48, 16, 12, 28);
    final maxV = data.first.popularity; // topByPopularity viene ordenado desc.
    final yMax = maxV * 1.3;
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth - pad.horizontal;
      final h = box.maxHeight - pad.vertical;
      final px = pad.left + (0 + 0.5) / data.length * w; // índice 0 = el más popular
      final py = pad.top + (1 - maxV / yMax) * h;
      return Stack(children: [
        Positioned.fill(
          child: Chart<GAnime>(
            data: data,
            padding: (_) => pad,
            variables: {
              'title': Variable<GAnime, String>(accessor: (a) => a.title),
              'popularity': Variable<GAnime, num>(
                accessor: (a) => a.popularity,
                scale: LinearScale(min: 0, max: yMax, niceRange: false),
              ),
            },
            marks: [IntervalMark(position: Varset('title') * Varset('popularity'))],
            annotations: [
              TagAnnotation(label: Label('máx.'), values: [data.first.title, maxV]),
            ],
            axes: [Defaults.verticalAxis],
          ),
        ),
        Positioned(
          left: (px - 20).clamp(0.0, box.maxWidth - 140),
          top: (py - 40).clamp(0.0, box.maxHeight - 32),
          child: Chip(
            label: Text('Más popular: ${data.first.title}',
                style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
            backgroundColor: Colors.amber,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ]);
    });
  });
}

// ---------------------------------------------------------------------------
// #52 Infinite Scrolling / Lazy Loading — COMPOSICIÓN — DIRECTO
// ---------------------------------------------------------------------------

/// Graphic no tiene "load more". Se compone:
///   EventUpdater propio (sobre Defaults.horizontalRangeEvent) detecta el borde
///   → callback → se añade una página → nueva lista → el Chart se reevalúa.
///
/// [loadPage] debería venir del Provider (paginación Page/pageInfo de AniList).
/// Si es null, se pagina LOCALMENTE sobre los títulos ya cargados.
class G52InfiniteScroll extends StatefulWidget {
  const G52InfiniteScroll(this.data, {super.key, this.loadPage, this.pageSize = 10});

  final GraphicDataset data;
  final Future<List<GDatedValue>> Function(int page)? loadPage;
  final int pageSize;

  @override
  State<G52InfiniteScroll> createState() => _G52InfiniteScrollState();
}

class _G52InfiniteScrollState extends State<G52InfiniteScroll> {
  late List<GDatedValue> _items;
  int _page = 1;
  bool _loading = false;
  bool _exhausted = false;

  @override
  void initState() {
    super.initState();
    _items = widget.data.datedTitles.take(widget.pageSize * 2).toList();
  }

  Future<void> _loadMore() async {
    if (_loading || _exhausted) return;
    setState(() => _loading = true);
    final next = widget.loadPage != null
        ? await widget.loadPage!(_page + 1)
        : widget.data.datedTitles.skip(_items.length).take(widget.pageSize).toList();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _page++;
      if (next.isEmpty) {
        _exhausted = true;
      } else {
        _items = [..._items, ...next]; // NUEVA instancia → changeData
      }
    });
  }

  /// Delegamos en el updater oficial y solo observamos el resultado.
  /// El rango es un ratio respecto a la región: `last <= 1` significa que el
  /// borde derecho del contenido ya es visible. VERIFICAR con debugPrint.
  List<double> _rangeUpdater(List<double> initial, List<double> previous, Event event) {
    final next = Defaults.horizontalRangeEvent(initial, previous, event);
    if (next.last <= 1.02) {
      scheduleMicrotask(_loadMore);
    }
    return next;
  }

  @override
  Widget build(BuildContext context) => guard(
        _items.length >= 2,
        () => Stack(children: [
          Chart(
            data: _items,
            variables: _datedVars(),
            marks: [PointMark(position: Varset('date') * Varset('value'), size: SizeEncode(value: 5))],
            coord: RectCoord(horizontalRange: [0, 2], horizontalRangeUpdater: _rangeUpdater),
            axes: standardAxes,
          ),
          Positioned(
            right: 8,
            top: 4,
            child: Text(
              _loading
                  ? 'Cargando…'
                  : '${_items.length} títulos${_exhausted ? ' (fin)' : ''}'
                      '${widget.loadPage == null ? ' · paginación local' : ''}',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ]),
      );
}

// ---------------------------------------------------------------------------
// #55 Range Selection Data Filter — COMPOSICIÓN — DIRECTO
// ---------------------------------------------------------------------------

/// IntervalSelection (Graphic) → selectionStream → estado Flutter →
/// filtrado → gráfico de detalle. Graphic NO conecta la selección con Filter.
/// En el proyecto, el filtrado debería vivir en el Provider.
class G55RangeSelectionFilter extends StatefulWidget {
  const G55RangeSelectionFilter(this.data, {super.key});
  final GraphicDataset data;

  @override
  State<G55RangeSelectionFilter> createState() => _G55RangeSelectionFilterState();
}

class _G55RangeSelectionFilterState extends State<G55RangeSelectionFilter> {
  final _brush = StreamController<Selected?>.broadcast();
  late final StreamSubscription<Selected?> _sub;
  List<GDatedValue> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.data.datedTitles;
    _sub = _brush.stream.listen((selected) {
      final all = widget.data.datedTitles;
      final idx = (selected?['brush'] ?? <int>{}).toList()..sort();
      setState(() => _filtered = idx.isEmpty ? all : [for (final i in idx) all[i]]);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _brush.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.data.datedTitles;
    return guard(all.length >= 3, () => Column(children: [
          const Text('Arrastra en horizontal para seleccionar un rango de fechas (doble tap limpia)',
              style: TextStyle(fontSize: 10)),
          Expanded(
            child: Chart(
              data: all,
              variables: _datedVars(),
              selections: {'brush': IntervalSelection(dim: Dim.x)},
              marks: [
                PointMark(
                  position: Varset('date') * Varset('value'),
                  size: SizeEncode(value: 4),
                  color: ColorEncode(value: Defaults.primaryColor, updaters: {
                    'brush': {false: (c) => c.withAlpha(60)},
                  }),
                  selectionStream: _brush,
                ),
              ],
              axes: [Defaults.horizontalAxis],
            ),
          ),
          Text('${_filtered.length} títulos en el rango', style: const TextStyle(fontSize: 10)),
          Expanded(
            flex: 2,
            child: _filtered.length < 2
                ? const GraphicEmptyState('Rango con menos de 2 títulos')
                : Chart(
                    data: _filtered,
                    variables: _datedVars(),
                    marks: [PointMark(position: Varset('date') * Varset('value'), size: SizeEncode(value: 6))],
                    axes: standardAxes,
                  ),
          ),
        ]));
  }
}

// ---------------------------------------------------------------------------
// #60 Fully Customized Widget Tooltip — COMPOSICIÓN — DIRECTO
// ---------------------------------------------------------------------------

/// TooltipGuide.renderer devuelve MarkElement (canvas), NO widgets.
/// Para un tooltip con widgets Flutter reales:
///   selectionStream (índice) + gestureStream (posición) → Card en un Stack.
class G60WidgetTooltip extends StatefulWidget {
  const G60WidgetTooltip(this.data, {super.key});
  final GraphicDataset data;

  @override
  State<G60WidgetTooltip> createState() => _G60WidgetTooltipState();
}

class _G60WidgetTooltipState extends State<G60WidgetTooltip> {
  final _selection = StreamController<Selected?>.broadcast();
  final _gestures = StreamController<GestureEvent>.broadcast();
  late final List<StreamSubscription<dynamic>> _subs;
  late final List<GAnime> _data;
  GAnime? _selected;
  Offset _pointer = Offset.zero;

  @override
  void initState() {
    super.initState();
    _data = [for (final a in widget.data.topByPopularity) if (a.score != null) a];
    _subs = [
      _gestures.stream.listen((e) {
        if (e.gesture.type == GestureType.tapDown) _pointer = e.gesture.localPosition;
      }),
      _selection.stream.listen((sel) {
        final idx = sel?['tap'];
        setState(() => _selected = (idx == null || idx.isEmpty) ? null : _data[idx.first]);
      }),
    ];
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _selection.close();
    _gestures.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => guard(_data.length >= 2, () {
        return LayoutBuilder(builder: (context, box) {
          final sel = _selected;
          return Stack(children: [
            Positioned.fill(
              child: Chart<GAnime>(
                data: _data,
                gestureStream: _gestures,
                variables: {
                  'title': Variable<GAnime, String>(accessor: (a) => a.title),
                  'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity),
                  'score': Variable<GAnime, num>(accessor: (a) => a.score!, scale: LinearScale(min: 0, max: 100)),
                },
                selections: {'tap': PointSelection(on: {GestureType.tapDown})},
                marks: [
                  PointMark(
                    position: Varset('popularity') * Varset('score'),
                    size: SizeEncode(value: 9, updaters: {'tap': {true: (_) => 14}}),
                    selectionStream: _selection,
                  ),
                ],
                axes: standardAxes,
              ),
            ),
            if (sel != null)
              Positioned(
                left: (_pointer.dx + 8).clamp(0.0, box.maxWidth - 180),
                top: (_pointer.dy - 70).clamp(0.0, box.maxHeight - 90),
                child: SizedBox(
                  width: 180,
                  child: Card(
                    color: Colors.black87,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(sel.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(' ${sel.score}  ', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            const Icon(Icons.people, size: 14, color: Colors.lightBlueAccent),
                            Text(' ${sel.popularity}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ]),
                          if (sel.studio != null)
                            Text(sel.studio!, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          if (sel.genres.isNotEmpty)
                            Text(sel.genres.take(3).join(' · '),
                                style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ]);
        });
      });
}

// ---------------------------------------------------------------------------
// #61 Staggered Animation — COMPOSICIÓN — DIRECTO
// ---------------------------------------------------------------------------

/// Graphic anima por MARK (Mark.transition / Mark.entrance), no por punto.
/// El escalonado se compone con varias marcas y curvas `Interval` de Flutter
/// con inicios desplazados: primero entran las barras (popularity) y después
/// la línea y los puntos (score). "Repetir" recrea el Chart (nueva Key) para
/// volver a lanzar la animación de entrada.
/// Datos: DIRECTO (popularity y averageScore de los 10 títulos más populares).
class G61StaggeredAnimation extends StatefulWidget {
  const G61StaggeredAnimation(this.data, {super.key});
  final GraphicDataset data;

  @override
  State<G61StaggeredAnimation> createState() => _G61StaggeredAnimationState();
}

class _G61StaggeredAnimationState extends State<G61StaggeredAnimation> {
  int _run = 0;

  Transition _staggered(int step) => Transition(
        duration: const Duration(milliseconds: 1800),
        curve: Interval(step * 0.3, 1.0, curve: Curves.easeOut),
      );

  @override
  Widget build(BuildContext context) {
    final data = [for (final a in widget.data.topByPopularity) if (a.score != null) a];
    return guard(data.length >= 2, () {
      return Column(children: [
        Expanded(
          child: Chart<GAnime>(
            key: ValueKey(_run),
            data: data,
            variables: {
              'title': Variable<GAnime, String>(accessor: (a) => a.title),
              'popularity': Variable<GAnime, num>(accessor: (a) => a.popularity, scale: LinearScale(min: 0)),
              'score': Variable<GAnime, num>(accessor: (a) => a.score!, scale: LinearScale(min: 0, max: 100)),
            },
            marks: [
              IntervalMark(
                position: Varset('title') * Varset('popularity'),
                transition: _staggered(0),
                entrance: {MarkEntrance.y},
              ),
              LineMark(
                position: Varset('title') * Varset('score'),
                color: ColorEncode(value: Colors.orange),
                transition: _staggered(1),
                entrance: {MarkEntrance.y, MarkEntrance.opacity},
              ),
              PointMark(
                position: Varset('title') * Varset('score'),
                color: ColorEncode(value: Colors.orange),
                transition: _staggered(2),
                entrance: {MarkEntrance.size},
              ),
            ],
            axes: [rotatedHorizontalAxis(), Defaults.verticalAxis],
          ),
        ),
        TextButton(onPressed: () => setState(() => _run++), child: const Text('Repetir animación')),
      ]);
    });
  }
}

// ---------------------------------------------------------------------------
// #63 Real-time Streaming — NATIVO — DERIVADO
// ---------------------------------------------------------------------------

/// Mecanismo nativo de Graphic: `Chart.changeDataStream` + `ChangeDataEvent`.
/// Los datos nuevos entran SIN setState ni reconstrucción del widget.
///
/// [updates] debe venir del Provider (polling a AniList respetando el rate
/// limit; AniList no tiene push). Si es null, se REPRODUCE localmente la serie
/// ya cargada (Media.trends si existe, si no títulos por año) y se indica en la UI.
class G63RealTimeStreaming extends StatefulWidget {
  const G63RealTimeStreaming(this.data, {super.key, this.updates, this.window = 12});

  final GraphicDataset data;
  final Stream<List<GCategory>>? updates;
  final int window;

  @override
  State<G63RealTimeStreaming> createState() => _G63RealTimeStreamingState();
}

class _G63RealTimeStreamingState extends State<G63RealTimeStreaming> {
  final _changeData = StreamController<ChangeDataEvent<GCategory>>.broadcast();
  StreamSubscription<List<GCategory>>? _sub;
  Timer? _replay;
  late final List<GCategory> _source;
  late final List<GCategory> _initial;
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _source = d.hasTrends
        ? [for (var i = 0; i < d.trendValues.length; i++) GCategory(d.trendLabels[i], d.trendValues[i])]
        : d.countByYear;
    _cursor = _source.length < widget.window ? _source.length : widget.window;
    _initial = _source.take(_cursor).toList();

    if (widget.updates != null) {
      _sub = widget.updates!.listen((w) => _changeData.add(ChangeDataEvent<GCategory>(w)));
    } else if (_source.length > widget.window) {
      _replay = Timer.periodic(const Duration(seconds: 1), (_) {
        _cursor = _cursor >= _source.length ? widget.window : _cursor + 1;
        final window = _source.sublist(_cursor - widget.window, _cursor);
        _changeData.add(ChangeDataEvent<GCategory>(window));
      });
    }
  }

  @override
  void dispose() {
    _replay?.cancel();
    _sub?.cancel();
    _changeData.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => guard(_initial.length >= 2, () {
        return Column(children: [
          if (widget.updates == null)
            const GraphicNotice(
              'Reproducción local de datos AniList ya cargados (AniList no tiene push). '
              'En producción: Stream del Provider con polling.',
              color: Color(0xFF1565C0),
            ),
          Expanded(
            child: Chart<GCategory>(
              data: _initial,
              changeDataStream: _changeData,
              variables: {
                'x': Variable<GCategory, String>(accessor: (c) => c.label, scale: OrdinalScale(tickCount: 4)),
                'y': Variable<GCategory, num>(
                  accessor: (c) => c.value,
                  scale: sharedScale([for (final c in _source) c.value]),
                ),
              },
              marks: [
                LineMark(
                  position: Varset('x') * Varset('y'),
                  transition: Transition(duration: const Duration(milliseconds: 500)),
                ),
              ],
              axes: standardAxes,
            ),
          ),
        ]);
      });
}
