import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SyncfusionScatterTrendChart extends StatelessWidget {
  final List<ChartDataXY> points;
  final List<double> regressionLine;
  final String xAxisLabel;
  final String yAxisLabel;

  const SyncfusionScatterTrendChart({
    super.key,
    required this.points,
    required this.regressionLine,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Center(child: Text('Sin datos'));

    double minX = points.first.x.toDouble();
    double maxX = points.first.x.toDouble();
    for (var p in points) {
      if (p.x < minX) minX = p.x.toDouble();
      if (p.x > maxX) maxX = p.x.toDouble();
    }

    final slope = regressionLine[0];
    final intercept = regressionLine[1];

    final yStart = slope * minX + intercept;
    final yEnd = slope * maxX + intercept;

    final trendPoints = [
      ChartDataXY(x: minX, y: yStart),
      ChartDataXY(x: maxX, y: yEnd),
    ];

    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: xAxisLabel),
        majorGridLines: const MajorGridLines(width: 1),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: yAxisLabel),
        majorGridLines: const MajorGridLines(width: 1),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ScatterSeries<ChartDataXY, double>(
          dataSource: points,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          color: primaryColor.withValues(alpha: 0.5),
          markerSettings: const MarkerSettings(width: 6, height: 6),
        ),
        LineSeries<ChartDataXY, double>(
          dataSource: trendPoints,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          color: errorColor,
          width: 2,
          dashArray: const <double>[5, 5],
          enableTooltip: false,
        ),
      ],
    );
  }
}
