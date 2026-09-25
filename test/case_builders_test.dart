// Verifica los 252 casos (63 × 4 librerías):
// 1. cada librería declara los 63 casos con estrategia, origen y API;
// 2. cada builder se monta con datos de la muestra y dibuja un gráfico REAL
//    de su librería (no un fallback ni un aviso técnico).

import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/common/library_cases.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:anilist_data_viz/presentation/state/anilist_live_provider.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:d_chart/d_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

void main() {
  test('252/252: las cuatro librerías declaran los 63 casos maestros', () {
    var total = 0;
    for (final library in ChartLibrary.values) {
      final cases = casesFor(library);
      expect(cases.keys.toSet(), {for (final m in masterChartRegistry) m.number}, reason: library.name);
      for (final e in cases.entries) {
        expect(e.value.origin.trim(), isNotEmpty, reason: '${library.name} #${e.key} sin origen');
        expect(e.value.api.trim(), isNotEmpty, reason: '${library.name} #${e.key} sin API');
      }
      total += cases.length;
    }
    expect(total, 252);
  });

  test('ningún caso queda como NO VERIFICADO ni NO DISPONIBLE en la matriz', () {
    for (final m in masterChartRegistry) {
      for (final library in ChartLibrary.values) {
        final state = m.getFor(library).state;
        expect(state, isNot(anyOf(ChartState.noVerificado, ChartState.noDisponible, ChartState.roto)),
            reason: '#${m.number} ${library.name}');
      }
    }
  });

  for (final library in ChartLibrary.values) {
    group('${library.name}: 63 builders visuales', () {
      late ChartsDatasetProvider dataset;
      late FakeRepository repo;

      setUpAll(() async {
        repo = FakeRepository();
        dataset = ChartsDatasetProvider(repository: repo);
        await dataset.load();
      });

      for (final m in masterChartRegistry) {
        testWidgets('#${m.number} ${m.name}', (tester) async {
          final impl = casesFor(library)[m.number]!;
          final data = CaseData(
            g: dataset.graphicDataset!,
            media: dataset.media,
            type: dataset.loadedType,
            trendsTitle: dataset.trendsMedia?.title,
          );
          await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: dataset),
              ChangeNotifierProvider(create: (_) => AniListLiveProvider(repository: repo)),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(width: 480, height: 300, child: Builder(builder: (c) => impl.builder(c, data))),
                ),
              ),
            ),
          ));
          // Deja llegar las respuestas del repositorio falso (#52, #63).
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));

          expect(tester.takeException(), isNull);
          expect(find.byType(TechnicalIssue), findsNothing, reason: 'aviso técnico en lugar del gráfico');
          expect(findLibraryChart(library), findsWidgets, reason: 'no se dibujó un gráfico de ${library.name}');

          await tester.pumpWidget(const SizedBox());
          // Timers internos de animación (p. ej. animationDelay de Syncfusion).
          await tester.pump(const Duration(seconds: 5));
        });
      }
    });
  }
}

/// Encuentra cualquier widget de gráfico de [library].
Finder findLibraryChart(ChartLibrary library) => find.byWidgetPredicate((w) => switch (library) {
      ChartLibrary.flChart =>
        w is LineChart || w is BarChart || w is PieChart || w is ScatterChart || w is RadarChart || w is CandlestickChart,
      ChartLibrary.syncfusion => w is SfCartesianChart ||
          w is SfCircularChart ||
          w is SfPyramidChart ||
          w is SfFunnelChart ||
          w is SfSparkLineChart ||
          w is SfSparkAreaChart ||
          w is SfSparkBarChart ||
          w is SfSparkWinLossChart,
      ChartLibrary.dChart => w is DChartBarO ||
          w is DChartBarT ||
          w is DChartComboN ||
          w is DChartComboO ||
          w is DChartComboT ||
          w is DChartLineN ||
          w is DChartLineT ||
          w is DChartScatterN ||
          w is DChartScatterT ||
          w is DChartPieN ||
          w is DChartPieO ||
          w is DChartPieT,
      ChartLibrary.graphic => w is graphic.Chart,
    });
