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

  static const String getMediaDetail = mediaFragment + r'''
    query MediaDetail($id: Int) {
      Media(id: $id) {
        ...MediaFields
      }
    }
  ''';
}
