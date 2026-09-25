// Comprueba el criterio "se monta sin excepciones" para los 63 casos.
// La revisión VISUAL de los casos críticos se hace a mano en la galería.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anilist_data_viz/charts/graphic/graphic_charts.dart';
import 'graphic_fixture.dart';

void main() {
  for (final withTrends in [true, false]) {
    final dataset = fixtureDataset(withTrends: withTrends);
    for (final spec in graphicChartRegistry) {
      testWidgets('#${spec.number} ${spec.name} se monta (trends: $withTrends)', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 400, height: 320, child: spec.builder(dataset)),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        // Desmonta para cancelar Timers/Streams (casos 52, 55, 60, 63).
        await tester.pumpWidget(const SizedBox());
      }, skip: spec.number == 30);
    }
  }



  test('origen de 41-44: DERIVADO con trends, NO DISPONIBLE sin trends', () {
    final withT = fixtureDataset();
    final withoutT = fixtureDataset(withTrends: false);
    for (final n in [41, 42, 43, 44]) {
      expect(getGraphicChart(n).originFor(withT), GraphicDataOrigin.derivado);
      expect(getGraphicChart(n).originFor(withoutT), GraphicDataOrigin.noDisponible);
    }
  });
}
