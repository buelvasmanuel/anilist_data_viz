import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SyncfusionSemiCircleGauge extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? color;
  final String valueLabel;
  final String? caption;
  final bool animated;

  const SyncfusionSemiCircleGauge({
    super.key,
    required this.value,
    required this.valueLabel,
    this.maxValue = 100,
    this.caption,
    this.color,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final arcColor = color ?? ChartPalette.primary(context);
    final clamped = value.clamp(0, maxValue).toDouble();
    final animationMillis = animated ? 1500.0 : 0.0;
    final trackColor = ChartPalette.gridLine(context).withValues(alpha: 0.5);

    return Center(
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valueLabel,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (caption != null)
                  Text(
                    caption!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ChartPalette.axisText(context),
                        ),
                  ),
              ],
            ),
          )
        ],
        series: <CircularSeries>[
          DoughnutSeries<Map<String, dynamic>, String>(
            dataSource: [
              {'category': 'Value', 'value': clamped, 'color': arcColor},
              {'category': 'Rest', 'value': maxValue - clamped, 'color': trackColor},
            ],
            xValueMapper: (datum, _) => datum['category'] as String,
            yValueMapper: (datum, _) => datum['value'] as double,
            pointColorMapper: (datum, _) => datum['color'] as Color,
            radius: '100%',
            innerRadius: '80%',
            startAngle: 270,
            endAngle: 90,
            animationDuration: animationMillis,
          )
        ],
      ),
    );
  }
}
