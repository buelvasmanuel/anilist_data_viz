import 'package:anilist_data_viz/charts/graphic/data/graphic_transformations.dart';
import 'package:anilist_data_viz/charts/graphic/data/graphic_view_models.dart';
import 'package:anilist_data_viz/presentation/state/anilist_live_provider.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_repository.dart';

void main() {
  group('Media.trends → serie diaria', () {
    test('dailyGains divide la variación entre los días transcurridos', () {
      final gains = GraphicTransformations.dailyGains([
        GTrendPoint(DateTime.utc(2026, 1, 1), 100),
        GTrendPoint(DateTime.utc(2026, 1, 2), 130),
        GTrendPoint(DateTime.utc(2026, 1, 4), 150), // faltó un día
      ]);
      expect([for (final g in gains) g.label], ['2026-01-02', '2026-01-04']);
      expect([for (final g in gains) g.value], [30, 10]);
    });

    test('ohlc agrupa ventanas completas: open, high, low, close', () {
      final labels = [for (var i = 1; i <= 15; i++) 'd$i'];
      final values = [5, 9, 1, 4, 7, 3, 6, 2, 8, 2, 2, 2, 2, 3, 99];
      final candles = GraphicTransformations.ohlc(labels, values);
      expect(candles.length, 2); // el día 15 no completa semana
      expect([candles[0].open, candles[0].high, candles[0].low, candles[0].close], [5, 9, 1, 6]);
      expect([candles[1].open, candles[1].high, candles[1].low, candles[1].close], [2, 8, 2, 3]);
      expect(candles[1].label, 'd8');
    });
  });

  group('ChartsDatasetProvider', () {
    test('descarga Media.trends de la obra más popular y calcula los indicadores', () async {
      final provider = ChartsDatasetProvider(repository: FakeRepository(), pages: 1, perPage: 20);
      await provider.load();
      expect(provider.trendsMedia?.id, provider.media.first.id);
      expect(provider.trends.length, 100); // 4 páginas × 25 días
      final g = provider.graphicDataset!;
      expect(g.hasTrends, isTrue);
      expect(g.trendValues.length, 99); // variaciones entre días consecutivos
      expect(g.trendOhlc.length, 14);
      expect(g.macdPoints, isNotEmpty);
      expect(g.rankedTitles, isNotEmpty); // rankings reales → #62
    });

    test('un fallo de trends no invalida la muestra', () async {
      final repo = FakeRepository()..failTrends = true;
      final provider = ChartsDatasetProvider(repository: repo, pages: 1, perPage: 10);
      await provider.load();
      expect(provider.media, isNotEmpty);
      expect(provider.trendsError, isNotEmpty);
      expect(provider.graphicDataset!.hasTrends, isFalse);
    });
  });

  group('AniListLiveProvider', () {
    test('#52 pide páginas reales y las acumula', () async {
      final repo = FakeRepository();
      final live = AniListLiveProvider(repository: repo, lazyPerPage: 10);
      await live.ensureLazyStarted('ANIME');
      expect(live.lazyItems.length, 10);
      await live.loadNextPage();
      expect(live.lazyItems.length, 20);
      expect(live.lazyPage, 2);
      expect(repo.calls, 2);
      live.dispose();
    });

    test('#63 cada lectura consulta AniList y compara con la anterior', () async {
      final repo = FakeRepository();
      final live = AniListLiveProvider(repository: repo, pollInterval: const Duration(hours: 1));
      live.acquirePolling([1, 2, 3]);
      await live.pollNow(); // la primera lectura ya está en curso: se ignora
      await Future<void>.delayed(Duration.zero);
      await live.pollNow();
      expect(repo.snapshotCalls, 2);
      expect(live.samples.length, 2);
      expect(live.samples.last.delta, 3); // el falso suma +1 por obra y lectura
      expect(live.changesDetected, 1);
      live.releasePolling();
      live.dispose();
    });
  });
}
