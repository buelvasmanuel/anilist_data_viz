import 'package:flutter_test/flutter_test.dart';

import 'package:anilist_data_viz/charts/graphic/graphic_charts.dart';

void main() {
  test('mean y stdDev', () {
    expect(GraphicTransformations.mean([2, 4, 6]), 4);
    expect(GraphicTransformations.stdDev([2, 4, 4, 4, 5, 5, 7, 9]), 2);
  });

  test('quantile R-7', () {
    expect(GraphicTransformations.quantile([1, 2, 3, 4], 0.5), 2.5);
    expect(GraphicTransformations.quantile([1, 2, 3, 4], 0.25), 1.75);
  });

  test('histogramBins cuenta cada valor en su bin y el máximo en el último', () {
    final bins = GraphicTransformations.histogramBins([0, 5, 10, 95, 100], binWidth: 10);
    expect(bins.length, 10);
    expect(bins.first.label, '0-10');
    expect(bins.first.value, 2);
    expect(bins[1].value, 1);
    expect(bins.last.value, 2);
  });

  test('cumulative y waterfall', () {
    final c = [const GCategory('a', 1), const GCategory('b', 3), const GCategory('c', 2)];
    expect(GraphicTransformations.cumulative(c).map((e) => e.value), [1, 4, 6]);
    final w = GraphicTransformations.waterfall(c);
    expect(w.length, 4); // base + 2 pasos + total
    expect(w[1].from, 1);
    expect(w[1].to, 3);
    expect(w.last.isTotal, isTrue);
  });

  test('linearRegression recupera una recta exacta', () {
    final r = GraphicTransformations.linearRegression([
      for (var x = 0; x < 5; x++) (x: x, y: 2 * x + 1),
    ]);
    for (final p in r) {
      expect(p.fitted, closeTo(p.y, 1e-9));
    }
  });

  test('sma deja null los primeros period-1 valores', () {
    expect(GraphicTransformations.sma([1, 2, 3, 4], 2), [null, 1.5, 2.5, 3.5]);
  });

  test('rsi = 100 en una serie siempre creciente', () {
    final r = GraphicTransformations.rsi([for (var i = 0; i < 20; i++) i], period: 14);
    expect(r[14], 100);
    expect(r.take(14).every((v) => v == null), isTrue);
  });

  test('macd descarta los primeros slow puntos', () {
    final values = [for (var i = 0; i < 40; i++) i * 1.0];
    final labels = [for (var i = 0; i < 40; i++) '$i'];
    expect(GraphicTransformations.macd(labels, values).length, 40 - 26);
  });

  test('alignSeries rellena con 0 y respeta el orden', () {
    final out = GraphicTransformations.alignSeries(
      [const GSeriesPoint('2020', 5, 'TV')],
      xOrder: ['2020', '2021'],
      seriesOrder: ['TV', 'MOVIE'],
    );
    expect(out.map((p) => '${p.series}/${p.x}=${p.value}'),
        ['TV/2020=5', 'TV/2021=0', 'MOVIE/2020=0', 'MOVIE/2021=0']);
  });

  test('winLoss', () {
    final wl = GraphicTransformations.winLoss(
        [const GCategory('a', 80), const GCategory('b', 60), const GCategory('c', 70)], 70);
    expect(wl.map((e) => e.value), [1, -1, 0]);
  });

}
