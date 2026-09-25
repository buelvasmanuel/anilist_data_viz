import 'package:anilist_data_viz/data/models/fuzzy_date_model.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';

class StudioModel extends Studio {
  StudioModel({required super.id, required super.name});
  factory StudioModel.fromJson(Map<String, dynamic> json) {
    return StudioModel(id: json['id'], name: json['name']);
  }
}

class TagModel extends Tag {
  TagModel({required super.name, super.rank, super.category});
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(name: json['name'], rank: json['rank'], category: json['category']);
  }
}

class MediaRelationModel extends MediaRelation {
  MediaRelationModel({required super.id, super.relationType, required super.title});
  factory MediaRelationModel.fromJson(Map<String, dynamic> json) {
    final node = json['node'] ?? {};
    final titleNode = node['title'] ?? {};
    final title = titleNode['userPreferred'] ?? titleNode['english'] ?? titleNode['romaji'] ?? 'Unknown Title';
    return MediaRelationModel(id: node['id'] ?? 0, relationType: json['relationType'], title: title);
  }
}

class CharacterModel extends Character {
  CharacterModel({required super.id, required super.name, super.role});
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final node = json['node'] ?? {};
    final nameNode = node['name'] ?? {};
    return CharacterModel(id: node['id'] ?? 0, name: nameNode['full'] ?? 'Unknown', role: json['role']);
  }
}

class MediaModel extends Media {
  MediaModel({
    required super.id,
    required super.title,
    super.titleRomaji,
    super.titleEnglish,
    super.titleNative,
    super.titleUserPreferred,
    super.type,
    super.format,
    super.status,
    super.description,
    super.startDate,
    super.endDate,
    super.season,
    super.seasonYear,
    super.episodes,
    super.duration,
    super.chapters,
    super.volumes,
    super.countryOfOrigin,
    super.isAdult,
    super.source,
    super.averageScore,
    super.meanScore,
    super.popularity,
    super.trending,
    super.favourites,
    super.popularAllTimeRank,
    super.ratedAllTimeRank,
    super.genres = const [],
    super.tags = const [],
    super.studios = const [],
    super.characters = const [],
    super.relations = const [],
    super.coverImageMedium,
    super.coverImageLarge,
    super.coverImageExtraLarge,
    super.bannerImage,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    final titleNode = json['title'] ?? {};
    final romaji = titleNode['romaji'];
    final english = titleNode['english'];
    final native = titleNode['native'];
    final userPreferred = titleNode['userPreferred'];
    
    final parsedTitle = userPreferred ?? english ?? romaji ?? native ?? 'Unknown Title';
    final coverNode = json['coverImage'] ?? {};

    final tagsList = (json['tags'] as List<dynamic>?)?.map((t) => TagModel.fromJson(t)).toList() ?? [];
    
    final studiosNodes = json['studios']?['nodes'] as List<dynamic>?;
    final studiosList = studiosNodes?.map((s) => StudioModel.fromJson(s)).toList() ?? [];

    final charactersEdges = json['characters']?['edges'] as List<dynamic>?;
    final charactersList = charactersEdges?.map((c) => CharacterModel.fromJson(c)).toList() ?? [];

    int? allTimeRank(String type) {
      final rankings = json['rankings'] as List<dynamic>? ?? const [];
      for (final r in rankings) {
        if (r['type'] == type && r['allTime'] == true) return r['rank'] as int?;
      }
      return null;
    }

    final relationsEdges = json['relations']?['edges'] as List<dynamic>?;
    final relationsList = relationsEdges?.map((r) => MediaRelationModel.fromJson(r)).toList() ?? [];

    return MediaModel(
      id: json['id'] ?? 0,
      title: parsedTitle,
      titleRomaji: romaji,
      titleEnglish: english,
      titleNative: native,
      titleUserPreferred: userPreferred,
      type: json['type'],
      format: json['format'],
      status: json['status'],
      description: json['description'],
      startDate: json['startDate'] != null ? FuzzyDateModel.fromJson(json['startDate']) : null,
      endDate: json['endDate'] != null ? FuzzyDateModel.fromJson(json['endDate']) : null,
      season: json['season'],
      seasonYear: json['seasonYear'],
      episodes: json['episodes'],
      duration: json['duration'],
      chapters: json['chapters'],
      volumes: json['volumes'],
      countryOfOrigin: json['countryOfOrigin'],
      isAdult: json['isAdult'],
      source: json['source'],
      averageScore: json['averageScore'],
      meanScore: json['meanScore'],
      popularity: json['popularity'],
      trending: json['trending'],
      favourites: json['favourites'],
      popularAllTimeRank: allTimeRank('POPULAR'),
      ratedAllTimeRank: allTimeRank('RATED'),
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tags: tagsList,
      studios: studiosList,
      characters: charactersList,
      relations: relationsList,
      coverImageMedium: coverNode['medium'],
      coverImageLarge: coverNode['large'],
      coverImageExtraLarge: coverNode['extraLarge'],
      bannerImage: json['bannerImage'],
    );
  }
}
