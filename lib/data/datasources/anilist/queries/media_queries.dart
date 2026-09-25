class MediaQueries {
  static const String mediaFragment = r'''
    fragment MediaFields on Media {
      id
      title {
        romaji
        english
        native
        userPreferred
      }
      type
      format
      status
      description
      startDate {
        year
        month
        day
      }
      endDate {
        year
        month
        day
      }
      season
      seasonYear
      episodes
      duration
      chapters
      volumes
      countryOfOrigin
      isAdult
      source
      averageScore
      meanScore
      popularity
      trending
      favourites
      rankings {
        rank
        type
        allTime
      }
      genres
      tags {
        name
        rank
        category
      }
      studios(isMain: true) {
        nodes {
          id
          name
        }
      }
      characters(sort: ROLE, perPage: 5) {
        edges {
          role
          node {
            id
            name {
              full
            }
          }
        }
      }
      relations {
        edges {
          relationType
          node {
            id
            title {
              userPreferred
              english
              romaji
            }
          }
        }
      }
      coverImage {
        medium
        large
        extraLarge
      }
      bannerImage
    }
  ''';

  static const String getMediaList = mediaFragment + r'''
    query MediaList(
      $page: Int, 
      $perPage: Int, 
      $type: MediaType, 
      $format: MediaFormat, 
      $status: MediaStatus,
      $season: MediaSeason,
      $seasonYear: Int,
      $genre: String
    ) {
      Page(page: $page, perPage: $perPage) {
        pageInfo {
          currentPage
          hasNextPage
          lastPage
          perPage
          total
        }
        media(
          type: $type, 
          format: $format, 
          status: $status, 
          season: $season,
          seasonYear: $seasonYear,
          genre: $genre,
          sort: POPULARITY_DESC
        ) {
          ...MediaFields
        }
      }
    }
  ''';

  /// Serie diaria `Media.trends`. AniList devuelve como máximo 25 nodos por
  /// página en este campo.
  static const String getMediaTrends = r'''
    query MediaTrends($id: Int, $page: Int, $perPage: Int) {
      Media(id: $id) {
        trends(sort: DATE_DESC, page: $page, perPage: $perPage) {
          pageInfo {
            currentPage
            hasNextPage
            lastPage
            perPage
            total
          }
          nodes {
            mediaId
            date
            popularity
            trending
          }
        }
      }
    }
  ''';

  /// Consulta ligera para el sondeo periódico (#63): solo contadores vivos.
  static const String getMediaSnapshots = r'''
    query MediaSnapshots($ids: [Int], $perPage: Int) {
      Page(page: 1, perPage: $perPage) {
        media(id_in: $ids) {
          id
          title {
            userPreferred
            romaji
          }
          popularity
          trending
          favourites
        }
      }
    }
  ''';

  static const String getMediaDetail = mediaFragment + r'''
    query MediaDetail($id: Int) {
      Media(id: $id) {
        ...MediaFields
      }
    }
  ''';
}
