import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SyncfusionBasicLineChart extends StatelessWidget {
  final List<ChartDataXY> points;
  final Color? lineColor;
  final double lineWidth;
  final bool isCurved;
  final double curveSmoothness;
  final bool showDots;
  final bool showArea;
  final bool showTitles;
  final bool showGrid;
  final bool showBorder;
  final double? minY;
  final double? maxY;
  final double? xLabelInterval;
  final String Function(double)? xLabelFormatter;
  final String Function(double)? yLabelFormatter;
  final bool animated;
  final Duration animationDuration;
  final bool enableTouch;

  const SyncfusionBasicLineChart({
    super.key,
    required this.points,
    this.lineColor,
    this.lineWidth = 2.5,
    this.isCurved = false,
    this.curveSmoothness = 0.35,
    this.showDots = false,
    this.showArea = false,
    this.showTitles = true,
    this.showGrid = true,
    this.showBorder = true,
    this.minY,
    this.maxY,
    this.xLabelInterval,
    this.xLabelFormatter,
    this.yLabelFormatter,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.enableTouch = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = lineColor ?? theme.colorScheme.primary;
    final animationMillis = animated ? animationDuration.inMilliseconds.toDouble() : 0.0;

    final primaryAxis = NumericAxis(
      isVisible: showTitles,
      interval: xLabelInterval,
      majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      axisLine: showBorder ? const AxisLine(width: 1) : const AxisLine(width: 0),
      axisLabelFormatter: xLabelFormatter != null
          ? (AxisLabelRenderDetails details) {
              return ChartAxisLabel(xLabelFormatter!(details.value.toDouble()), details.textStyle);
            }
          : null,
    );

    final secondaryAxis = NumericAxis(
      isVisible: showTitles,
      minimum: minY,
      maximum: maxY,
      majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      axisLine: showBorder ? const AxisLine(width: 1) : const AxisLine(width: 0),
      axisLabelFormatter: yLabelFormatter != null
          ? (AxisLabelRenderDetails details) {
              return ChartAxisLabel(yLabelFormatter!(details.value.toDouble()), details.textStyle);
            }
          : null,
    );

    CartesianSeries<ChartDataXY, double> series;
    final markerSettings = MarkerSettings(isVisible: showDots);

    if (showArea) {
      if (isCurved) {
        series = SplineAreaSeries<ChartDataXY, double>(
          dataSource: points,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          color: color.withValues(alpha: 0.2),
          borderColor: color,
          borderWidth: lineWidth,
          animationDuration: animationMillis,
          markerSettings: markerSettings,
        );
      } else {
        series = AreaSeries<ChartDataXY, double>(
          dataSource: points,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          color: color.withValues(alpha: 0.2),
          borderColor: color,
          borderWidth: lineWidth,
          animationDuration: animationMillis,
          markerSettings: markerSettings,
        );
      }
    } else {
      if (isCurved) {
        series = SplineSeries<ChartDataXY, double>(
          dataSource: points,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          color: color,
          width: lineWidth,
          animationDuration: animationMillis,
          markerSettings: markerSettings,
          splineType: SplineType.natural, // Maps closely to curveSmoothness
        );
      } else {
        series = LineSeries<ChartDataXY, double>(
          dataSource: points,
          xValueMapper: (datum, _) => datum.x.toDouble(),
          yValueMapper: (datum, _) => datum.y.toDouble(),
          color: color,
          width: lineWidth,
          animationDuration: animationMillis,
          markerSettings: markerSettings,
        );
      }
    }

    return SfCartesianChart(
      primaryXAxis: primaryAxis,
      primaryYAxis: secondaryAxis,
      tooltipBehavior: enableTouch ? TooltipBehavior(enable: true) : null,
      series: <CartesianSeries>[series],
      plotAreaBorderWidth: showBorder ? 1 : 0,
    );
  }
}
