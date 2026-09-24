import 'package:anilist_data_viz/domain/entities/fuzzy_date.dart';

class Studio {
  final int id;
  final String name;
  Studio({required this.id, required this.name});
}

class Tag {
  final String name;
  final int? rank;
  final String? category;
  Tag({required this.name, this.rank, this.category});
}

class MediaRelation {
  final int id;
  final String? relationType;
  final String title;
  MediaRelation({required this.id, this.relationType, required this.title});
}

class Character {
  final int id;
  final String name;
  final String? role;
  Character({required this.id, required this.name, this.role});
}

class Media {
  final int id;
  final String title;
  final String? titleRomaji;
  final String? titleEnglish;
  final String? titleNative;
  final String? titleUserPreferred;
  final String? type;
  final String? format;
  final String? status;
  final String? description;
  final FuzzyDate? startDate;
  final FuzzyDate? endDate;
  final String? season;
  final int? seasonYear;
  final int? episodes;
  final int? duration;
  final int? chapters;
  final int? volumes;
  final String? countryOfOrigin;
  final bool? isAdult;
  final String? source;
  final int? averageScore;
  final int? meanScore;
  final int? popularity;
  final int? trending;
  final int? favourites;
  final List<String> genres;
  final List<Tag> tags;
  final List<Studio> studios;
  final List<Character> characters;
  final List<MediaRelation> relations;
  final String? coverImageMedium;
  final String? coverImageLarge;
  final String? coverImageExtraLarge;
  final String? bannerImage;

  Media({
    required this.id,
    required this.title,
    this.titleRomaji,
    this.titleEnglish,
    this.titleNative,
    this.titleUserPreferred,
    this.type,
    this.format,
    this.status,
    this.description,
    this.startDate,
    this.endDate,
    this.season,
    this.seasonYear,
    this.episodes,
    this.duration,
    this.chapters,
    this.volumes,
    this.countryOfOrigin,
    this.isAdult,
    this.source,
    this.averageScore,
    this.meanScore,
    this.popularity,
    this.trending,
    this.favourites,
    this.genres = const [],
    this.tags = const [],
    this.studios = const [],
    this.characters = const [],
    this.relations = const [],
    this.coverImageMedium,
    this.coverImageLarge,
    this.coverImageExtraLarge,
    this.bannerImage,
  });
}
