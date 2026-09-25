import 'package:anilist_data_viz/domain/entities/media_trend.dart';

class MediaTrendModel extends MediaTrend {
  MediaTrendModel({required super.mediaId, required super.date, super.popularity, super.trending});

  /// `date` llega como timestamp Unix en segundos.
  factory MediaTrendModel.fromJson(Map<String, dynamic> json) {
    return MediaTrendModel(
      mediaId: json['mediaId'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch((json['date'] as int) * 1000, isUtc: true),
      popularity: json['popularity'],
      trending: json['trending'],
    );
  }
}
