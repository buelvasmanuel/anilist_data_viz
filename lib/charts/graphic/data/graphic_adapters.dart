// Adaptadores: Chart Models / Domain del proyecto → modelos de vista de Graphic.
//
// IMPORTANTE: este archivo NO conoce los nombres de campos del proyecto.
// Cada adaptador recibe funciones "accessor" que el proyecto rellena con sus
// campos REALES. Así no se inventa ningún campo de AniList ni del dominio.
//
// Ejemplo de uso en el Provider (adaptar a los nombres reales):
//
//   final items = GraphicAdapters.animeFrom<Media>(
//     mediaList,
//     title: (m) => m.title,
//     popularity: (m) => m.popularity,
//     format: (m) => m.format,
//     status: (m) => m.status,
//     score: (m) => m.averageScore,
//     episodes: (m) => m.episodes,
//     genres: (m) => m.genres,
//     seasonYear: (m) => m.seasonYear,
//     startYear: (m) => m.startDate?.year,
//     endYear: (m) => m.endDate?.year,
//     rank: (m) => m.rankAllTimePopular,
//     studio: (m) => m.mainStudio,
//   );
//   final dataset = GraphicDataset.fromAnime(items, trends: trendPoints);

import 'graphic_view_models.dart';

class GraphicAdapters {
  const GraphicAdapters._();

  /// Dominio (títulos AniList) → [GAnime].
  static List<GAnime> animeFrom<T>(
    Iterable<T> source, {
    required String Function(T) title,
    required num Function(T) popularity,
    required String Function(T) format,
    required String Function(T) status,
    num? Function(T)? score,
    int? Function(T)? episodes,
    List<String> Function(T)? genres,
    int? Function(T)? seasonYear,
    int? Function(T)? startYear,
    int? Function(T)? endYear,
    int? Function(T)? rank,
    String? Function(T)? studio,
  }) =>
      [
        for (final m in source)
          GAnime(
            title: title(m),
            popularity: popularity(m),
            format: format(m),
            status: status(m),
            score: score?.call(m),
            episodes: episodes?.call(m),
            genres: genres?.call(m) ?? const [],
            seasonYear: seasonYear?.call(m),
            startYear: startYear?.call(m),
            endYear: endYear?.call(m),
            rank: rank?.call(m),
            studio: studio?.call(m),
          ),
      ];

  /// `Media.trends.nodes` → [GTrendPoint].
  /// `date` en AniList es un timestamp Unix en SEGUNDOS.
  static List<GTrendPoint> trendsFrom<T>(
    Iterable<T> source, {
    required int Function(T) unixSeconds,
    required num? Function(T) popularity,
  }) =>
      [
        for (final n in source)
          if (popularity(n) != null)
            GTrendPoint(
              DateTime.fromMillisecondsSinceEpoch(unixSeconds(n) * 1000, isUtc: true),
              popularity(n)!,
            ),
      ];

  /// ChartDataCategory (o equivalente) → [GCategory].
  static List<GCategory> categoriesFrom<T>(
    Iterable<T> source, {
    required String Function(T) label,
    required num Function(T) value,
  }) =>
      [for (final c in source) GCategory(label(c), value(c))];

  /// ChartSeries (o equivalente) → filas en formato largo [GSeriesPoint].
  ///
  /// [series] devuelve las series; [seriesName] su nombre; [points] sus puntos;
  /// [x] y [y] leen cada punto.
  static List<GSeriesPoint> longFormatFrom<S, P>(
    Iterable<S> series, {
    required String Function(S) seriesName,
    required Iterable<P> Function(S) points,
    required String Function(P) x,
    required num Function(P) y,
  }) =>
      [
        for (final s in series)
          for (final p in points(s)) GSeriesPoint(x(p), y(p), seriesName(s)),
      ];

  /// ChartDataRange (o equivalente) → [GRange].
  static List<GRange> rangesFrom<T>(
    Iterable<T> source, {
    required String Function(T) x,
    required num Function(T) low,
    required num Function(T) high,
  }) =>
      [for (final r in source) GRange(x(r), low(r), high(r))];
}
