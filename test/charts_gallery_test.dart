import 'package:anilist_data_viz/charts/fl_chart/fl_bar_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_gauge_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_line_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_pie_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_progress_charts.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/common/master_case_gallery.dart';
import 'package:anilist_data_viz/charts/d_chart/d_chart_gallery_screen.dart';
import 'package:anilist_data_viz/charts/graphic/graphic_charts_gallery_screen.dart';
import 'package:anilist_data_viz/presentation/screens/charts_gallery_screen.dart';
import 'package:anilist_data_viz/presentation/screens/syncfusion_charts_gallery_screen.dart';
import 'package:anilist_data_viz/presentation/state/anilist_live_provider.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: Scaffold(body: child),
    );

void main() {
  group('ChartsDatasetProvider', () {
    test('carga todas las páginas del tipo pedido', () async {
      final repo = FakeRepository();
      final provider = ChartsDatasetProvider(repository: repo, pages: 4, perPage: 10);
      await provider.load();
      expect(provider.state, ProviderState.success);
      expect(provider.media.length, 40);
      expect(repo.requestedTypes.toSet(), {'ANIME'});
    });

    test('conserva la muestra anterior si falla una recarga', () async {
      final repo = FakeRepository();
      final provider = ChartsDatasetProvider(repository: repo, pages: 1, perPage: 10);
      await provider.load();
      repo.fail = true;
      await provider.load(type: 'MANGA');
      expect(provider.media.length, 10);
      expect(provider.loadedType, 'ANIME');
      expect(provider.errorMessage, 'sin red');
      expect(provider.state, ProviderState.success);
    });

    test('error inicial sin datos', () async {
      final repo = FakeRepository()..fail = true;
      final provider = ChartsDatasetProvider(repository: repo);
      await provider.load();
      expect(provider.state, ProviderState.error);
    });
  });

  group('Wrappers FL Chart', () {
    final categories = [
      ChartDataCategory(category: 'A', value: 5),
      ChartDataCategory(category: 'B', value: -3),
    ];
    final points = [ChartDataXY(x: 1, y: 2), ChartDataXY(x: 2, y: 4)];

    testWidgets('BasicBarChart horizontal usa rotationQuarterTurns', (tester) async {
      await tester.pumpWidget(_wrap(BasicBarChart(data: categories, isHorizontal: true)));
      final chart = tester.widget<BarChart>(find.byType(BarChart));
      expect(chart.data.rotationQuarterTurns, 1);
      expect(find.byType(RotatedBox), findsWidgets); // RotatedBox interno de FL Chart
    });

    testWidgets('BasicBarChart separa barWidth y groupsSpace', (tester) async {
      await tester.pumpWidget(_wrap(BasicBarChart(data: categories, barWidth: 10, groupsSpace: 30)));
      final data = tester.widget<BarChart>(find.byType(BarChart)).data;
      expect(data.groupsSpace, 30);
      expect(data.alignment, BarChartAlignment.center);
      expect(data.barGroups.first.barRods.first.width, 10);
    });

    testWidgets('BasicBarChart cuadrícula horizontal y color por signo', (tester) async {
      await tester.pumpWidget(_wrap(BasicBarChart(
        data: categories, showGrid: true, colorMode: BarColorMode.bySign,
      )));
      final data = tester.widget<BarChart>(find.byType(BarChart)).data;
      expect(data.gridData.drawHorizontalLine, isTrue);
      expect(data.gridData.drawVerticalLine, isFalse);
      final colors = data.barGroups.map((g) => g.barRods.first.color).toList();
      expect(colors[0], isNot(colors[1]));
    });

    testWidgets('BasicBarChart etiquetas con tooltip fijo', (tester) async {
      await tester.pumpWidget(_wrap(BasicBarChart(data: categories, showValueLabels: true)));
      final data = tester.widget<BarChart>(find.byType(BarChart)).data;
      expect(data.barGroups.every((g) => g.showingTooltipIndicators.contains(0)), isTrue);
      expect(data.barTouchData.enabled, isFalse);
    });

    testWidgets('BasicBarChart sin animación', (tester) async {
      await tester.pumpWidget(_wrap(BasicBarChart(data: categories, animated: false)));
      expect(tester.widget<BarChart>(find.byType(BarChart)).duration, Duration.zero);
    });

    testWidgets('BasicLineChart minimalista', (tester) async {
      await tester.pumpWidget(_wrap(BasicLineChart(
        points: points, showTitles: false, showGrid: false, showBorder: false,
      )));
      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.titlesData.show, isFalse);
      expect(data.gridData.show, isFalse);
      expect(data.borderData.show, isFalse);
    });

    testWidgets('BasicPieChart donut y separación', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        width: 300, height: 300,
        child: BasicPieChart(data: [categories.first], isDonut: true, spacing: 3),
      )));
      final data = tester.widget<PieChart>(find.byType(PieChart)).data;
      expect(data.centerSpaceRadius, greaterThan(0));
      expect(data.sectionsSpace, 3);
    });

    testWidgets('ProgressBarChart y SemiCircleGauge se renderizan', (tester) async {
      await tester.pumpWidget(_wrap(const Column(children: [
        SizedBox(height: 40, width: 300, child: ProgressBarChart(value: 70)),
        SizedBox(height: 150, width: 300, child: SemiCircleGauge(value: 70, valueLabel: '70')),
      ])));
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      // El PieChart del gauge debe ser un cuadrado completo (diámetro 300),
      // del que ClipRect solo muestra la mitad superior (alto 150).
      expect(tester.getSize(find.byType(PieChart)), const Size(300, 300));
      expect(tester.getSize(find.byType(ClipRect).last).height, 150);
      expect(tester.takeException(), isNull);
    });
  });

  final galleries = <String, Widget Function()>{
    'FL Chart': () => const ChartsGalleryScreen(),
    'Syncfusion': () => const SyncfusionChartsGalleryScreen(),
    'DChart': () => const DChartGalleryScreen(),
    'Graphic': () => const GraphicChartsGalleryScreen(),
  };

  for (final entry in galleries.entries) {
    testWidgets('La galería ${entry.key} muestra las 63 tarjetas con gráfico', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repo = FakeRepository();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MediaProvider(repository: repo)),
            ChangeNotifierProvider(create: (_) => ChartsDatasetProvider(repository: repo)),
            ChangeNotifierProvider(create: (_) => AniListLiveProvider(repository: repo)),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            home: entry.value(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final list = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
      for (var number = 1; number <= 63; number++) {
        final finder = find.descendant(of: find.byType(CircleAvatar), matching: find.text('$number'));
        await tester.scrollUntilVisible(finder, 300, scrollable: list);
        expect(finder, findsOneWidget, reason: 'caso $number');
        expect(find.byType(MasterCaseCard), findsWidgets);
        expect(tester.takeException(), isNull, reason: 'caso $number');
      }
      expect(find.byType(TechnicalIssue), findsNothing);
      // La galería no debe modificar el estado de MediaProvider.
      expect(tester.element(find.byType(MasterCaseGallery)).read<MediaProvider>().mediaList, isEmpty);

      // Desmonta para cancelar el sondeo de #63 y los timers de animación.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
