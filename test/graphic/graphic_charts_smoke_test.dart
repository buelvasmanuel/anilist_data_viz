// Comprueba el criterio "se monta sin excepciones" para los 63 casos.
// La revisión VISUAL de los casos críticos se hace a mano en la galería.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:anilist_data_viz/presentation/state/anilist_live_provider.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import '../support/fake_repository.dart';

import 'package:anilist_data_viz/charts/graphic/graphic_charts.dart';
import 'graphic_fixture.dart';

void main() {
  for (final withTrends in [true, false]) {
    final dataset = fixtureDataset(withTrends: withTrends);
    for (final spec in graphicChartRegistry) {
      testWidgets('#${spec.number} ${spec.name} se monta (trends: $withTrends)', (tester) async {
        // #52 y #63 leen los providers (paginación y sondeo contra el repositorio falso).
        final repo = FakeRepository();
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ChartsDatasetProvider(repository: repo)),
            ChangeNotifierProvider(create: (_) => AniListLiveProvider(repository: repo)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(width: 400, height: 320, child: spec.builder(dataset)),
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        // Desmonta para cancelar Timers/Streams (casos 52, 55, 60, 63).
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      });
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
