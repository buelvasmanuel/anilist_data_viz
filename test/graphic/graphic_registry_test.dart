import 'package:flutter_test/flutter_test.dart';

import 'package:anilist_data_viz/charts/graphic/graphic_charts.dart';

void main() {
  test('el registry contiene exactamente los casos 1..63', () {
    expect(graphicChartRegistry.length, 63);
    expect(graphicChartRegistry.map((s) => s.number).toList(), List.generate(63, (i) => i + 1));
  });

  test('clasificación auditada: 36 / 18 / 9 (Sección C del prompt)', () {
    List<int> of(GraphicClassification c) =>
        [for (final s in graphicChartRegistry) if (s.classification == c) s.number];

    expect(of(GraphicClassification.nativo), [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24,
      25, 26, 27, 29, 32, 36, 37, 38, 39, 46, 49, 59, 63,
    ]);
    expect(of(GraphicClassification.variante), [
      16, 28, 30, 31, 40, 41, 42, 43, 44, 45, 48, 50, 51, 53, 54, 57, 58, 62,
    ]);
    expect(of(GraphicClassification.composicion), [33, 34, 35, 47, 52, 55, 56, 60, 61]);
  });

  test('getGraphicChart devuelve el caso pedido', () {
    expect(getGraphicChart(1).name, 'Línea Simple');
    expect(getGraphicChart(63).name, 'Real-time Streaming');
    expect(() => getGraphicChart(64), throwsArgumentError);
  });
}
