import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

class SyncfusionMultiSeriesBarChart extends StatelessWidget {
  final List<ChartSeries<ChartDataCategory>> seriesList;
  final bool isHorizontal;
  final bool isStacked;
  final double barWidth;
  final double groupsSpace;
  final bool showTitles;
  final bool showGrid;
  final bool showBorder;
  final bool showLegend;

  const SyncfusionMultiSeriesBarChart({
    super.key,
    required this.seriesList,
    this.isHorizontal = false,
    this.isStacked = false,
    this.barWidth = 0.8,
    this.groupsSpace = 0.2,
    this.showTitles = true,
    this.showGrid = true,
    this.showBorder = true,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (seriesList.isEmpty || seriesList.every((s) => s.data.isEmpty)) {
      return const Center(child: Text('Sin datos'));
    }

    final primaryAxis = CategoryAxis(
      isVisible: showTitles,
      majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      axisLine: showBorder ? const AxisLine(width: 1) : const AxisLine(width: 0),
    );

    final secondaryAxis = NumericAxis(
      isVisible: showTitles,
      majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      axisLine: showBorder ? const AxisLine(width: 1) : const AxisLine(width: 0),
    );

    final cartesianSeries = <CartesianSeries>[];

    for (int i = 0; i < seriesList.length; i++) {
      final s = seriesList[i];
      final color = ChartPalette.categoryColor(i);

      if (isStacked) {
        if (isHorizontal) {
          cartesianSeries.add(StackedBarSeries<ChartDataCategory, String>(
            dataSource: s.data,
            xValueMapper: (datum, _) => datum.category,
            yValueMapper: (datum, _) => datum.value,
            name: s.seriesName,
            color: color,
            width: barWidth,
            spacing: groupsSpace,
          ));
        } else {
          cartesianSeries.add(StackedColumnSeries<ChartDataCategory, String>(
            dataSource: s.data,
            xValueMapper: (datum, _) => datum.category,
            yValueMapper: (datum, _) => datum.value,
            name: s.seriesName,
            color: color,
            width: barWidth,
            spacing: groupsSpace,
          ));
        }
      } else {
        if (isHorizontal) {
          cartesianSeries.add(BarSeries<ChartDataCategory, String>(
            dataSource: s.data,
            xValueMapper: (datum, _) => datum.category,
            yValueMapper: (datum, _) => datum.value,
            name: s.seriesName,
            color: color,
            width: barWidth,
            spacing: groupsSpace,
          ));
        } else {
          cartesianSeries.add(ColumnSeries<ChartDataCategory, String>(
            dataSource: s.data,
            xValueMapper: (datum, _) => datum.category,
            yValueMapper: (datum, _) => datum.value,
            name: s.seriesName,
            color: color,
            width: barWidth,
            spacing: groupsSpace,
          ));
        }
      }
    }

    return SfCartesianChart(
      primaryXAxis: primaryAxis,
      primaryYAxis: secondaryAxis,
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: showLegend ? Legend(isVisible: true, position: LegendPosition.bottom) : const Legend(isVisible: false),
      series: cartesianSeries,
      plotAreaBorderWidth: showBorder ? 1 : 0,
    );
  }
}
