import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

class SyncfusionMultiLineChart extends StatelessWidget {
  final List<ChartSeries<ChartDataXY>> seriesList;
  final bool showDots;
  final bool isCurved;
  final bool showGrid;
  final bool showLegend;
  final double? minY;
  final double? maxY;

  const SyncfusionMultiLineChart({
    super.key,
    required this.seriesList,
    this.showDots = false,
    this.isCurved = false,
    this.showGrid = true,
    this.showLegend = true,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (seriesList.isEmpty || seriesList.every((s) => s.data.isEmpty)) {
      return const Center(child: Text('Sin datos'));
    }

    final cartesianSeries = <CartesianSeries>[];
    final markerSettings = MarkerSettings(isVisible: showDots);

    for (int i = 0; i < seriesList.length; i++) {
      final s = seriesList[i];
      final color = ChartPalette.categoryColor(i);

      if (isCurved) {
        cartesianSeries.add(SplineSeries<ChartDataXY, double>(
          dataSource: s.data,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          name: s.seriesName,
          color: color,
          width: 2,
          markerSettings: markerSettings,
        ));
      } else {
        cartesianSeries.add(LineSeries<ChartDataXY, double>(
          dataSource: s.data,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          name: s.seriesName,
          color: color,
          width: 2,
          markerSettings: markerSettings,
        ));
      }
    }

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        minimum: minY,
        maximum: maxY,
        majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: showLegend ? Legend(isVisible: true, position: LegendPosition.bottom) : const Legend(isVisible: false),
      series: cartesianSeries,
    );
  }
}
