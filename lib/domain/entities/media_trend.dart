/// Un nodo de `Media.trends` de AniList: estadísticas diarias de una obra.
///
/// `popularity` es el número acumulado de usuarios que tienen la obra en su
/// lista ese día. No es un precio ni un dato financiero.
class MediaTrend {
  final int mediaId;
  final DateTime date;
  final int? popularity;
  final int? trending;

  MediaTrend({required this.mediaId, required this.date, this.popularity, this.trending});
}
