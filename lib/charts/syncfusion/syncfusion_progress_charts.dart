import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SyncfusionProgressBarChart extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? color;
  final double thickness;
  final bool animated;

  const SyncfusionProgressBarChart({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.color,
    this.thickness = 22,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? ChartPalette.primary(context);
    final radius = BorderRadius.circular(thickness / 2);
    final animationMillis = animated ? 1500.0 : 0.0;

    return SfCartesianChart(
      primaryXAxis: const NumericAxis(isVisible: false),
      primaryYAxis: NumericAxis(
        isVisible: false,
        minimum: 0,
        maximum: maxValue,
      ),
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      series: <CartesianSeries>[
        BarSeries<Map<String, dynamic>, num>(
          dataSource: [
            {'x': 0, 'y': maxValue, 'color': ChartPalette.gridLine(context).withValues(alpha: 0.5)}
          ],
          xValueMapper: (datum, _) => datum['x'] as num,
          yValueMapper: (datum, _) => datum['y'] as num,
          pointColorMapper: (datum, _) => datum['color'] as Color,
          width: 0.8,
          borderRadius: radius,
          animationDuration: 0, // background doesn't need animation
          enableTooltip: false,
        ),
        BarSeries<Map<String, dynamic>, num>(
          dataSource: [
            {'x': 0, 'y': value.clamp(0, maxValue)}
          ],
          xValueMapper: (datum, _) => datum['x'] as num,
          yValueMapper: (datum, _) => datum['y'] as num,
          color: barColor,
          width: 0.8, // will overlap exactly with background if width is same
          borderRadius: radius,
          animationDuration: animationMillis,
          enableTooltip: false,
        ),
      ],
    );
  }
}
