// FIXTURE DE PRUEBA — solo para tests automáticos.
// No son datos de AniList ni se usan en la app: sirven para comprobar que las
// 63 gráficas se montan sin excepciones con un dataset de forma realista.

import 'package:anilist_data_viz/charts/graphic/graphic_charts.dart';

const _formats = ['TV', 'MOVIE', 'OVA', 'ONA', 'SPECIAL'];
const _statuses = ['FINISHED', 'RELEASING', 'NOT_YET_RELEASED'];
const _genres = ['Action', 'Comedy', 'Drama', 'Fantasy', 'Romance', 'Sci-Fi'];

List<GAnime> fixtureAnime({int count = 40}) => [
      for (var i = 0; i < count; i++)
        GAnime(
          title: 'Título $i',
          score: 50 + (i * 7) % 45,
          popularity: 1000 + (i * 7919) % 250000,
          episodes: 1 + (i * 5) % 50,
          format: _formats[i % _formats.length],
          status: _statuses[i % _statuses.length],
          genres: [_genres[i % _genres.length], _genres[(i + 2) % _genres.length]],
          seasonYear: 2012 + i % 12,
          startYear: 2012 + i % 12,
          endYear: 2012 + i % 12 + (i % 3),
          rank: i + 1,
          studio: 'Estudio ${i % 4}',
        ),
    ];

List<GTrendPoint> fixtureTrends({int days = 80}) => [
      for (var i = 0; i < days; i++)
        GTrendPoint(DateTime.utc(2025, 1, 1).add(Duration(days: i)), 5000 + (i * 37) % 900 + i * 12),
    ];

GraphicDataset fixtureDataset({bool withTrends = true}) =>
    GraphicDataset.fromAnime(fixtureAnime(), trends: withTrends ? fixtureTrends() : const []);
