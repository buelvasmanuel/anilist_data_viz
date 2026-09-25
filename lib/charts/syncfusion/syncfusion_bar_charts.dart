import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_bar_charts.dart' show BarColorMode;
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

class SyncfusionBasicBarChart extends StatelessWidget {
  final List<ChartDataCategory> data;
  final bool isHorizontal;
  final double barWidth; // Mapped to width property (0 to 1)
  final double? groupsSpace; // Mapped to spacing property (0 to 1)
  final bool rounded;
  final double cornerRadius;
  final BarColorMode colorMode;
  final Color? staticColor;
  final BorderSide? rodBorderSide;
  final bool showTitles;
  final bool showGrid;
  final bool showBorder;
  final double? gridInterval;
  final int categoryLabelEvery;
  final double? minY;
  final double? maxY;
  final double baselineY;
  final bool showBaselineLine;
  final bool enableTooltip;
  final Duration? animationDuration;
  final bool showRodLabels;
  final LinearGradient? barGradient;
  final bool enablePanning;
  final String Function(double)? yLabelFormatter;

  const SyncfusionBasicBarChart({
    super.key,
    required this.data,
    this.isHorizontal = false,
    this.barWidth = 0.7, // default width in syncfusion is 0.7
    this.groupsSpace = 0.2, // default spacing
    this.rounded = false,
    this.cornerRadius = 4.0,
    this.colorMode = BarColorMode.single,
    this.staticColor,
    this.rodBorderSide,
    this.showTitles = true,
    this.showGrid = true,
    this.showBorder = true,
    this.gridInterval,
    this.categoryLabelEvery = 1,
    this.minY,
    this.maxY,
    this.baselineY = 0,
    this.showBaselineLine = false,
    this.enableTooltip = true,
    this.animationDuration,
    this.showRodLabels = false,
    this.barGradient,
    this.enablePanning = false,
    this.yLabelFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryAxis = CategoryAxis(
      isVisible: showTitles,
      labelPlacement: LabelPlacement.onTicks,
      interval: categoryLabelEvery.toDouble(),
      majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      axisLine: showBorder ? const AxisLine(width: 1) : const AxisLine(width: 0),
    );

    final secondaryAxis = NumericAxis(
      isVisible: showTitles,
      minimum: minY,
      maximum: maxY,
      interval: gridInterval,
      majorGridLines: showGrid ? const MajorGridLines(width: 1) : const MajorGridLines(width: 0),
      axisLine: showBorder ? const AxisLine(width: 1) : const AxisLine(width: 0),
      crossesAt: baselineY != 0 ? baselineY : null,
      axisLabelFormatter: yLabelFormatter != null
          ? (AxisLabelRenderDetails details) => ChartAxisLabel(yLabelFormatter!(details.value.toDouble()), details.textStyle)
          : null,
      plotBands: showBaselineLine
          ? <PlotBand>[
              PlotBand(
                start: baselineY,
                end: baselineY,
                borderColor: theme.colorScheme.error,
                borderWidth: 2,
              )
            ]
          : const <PlotBand>[],
    );

    final animationMillis = animationDuration != null ? animationDuration!.inMilliseconds.toDouble() : 1500.0;
    
    final radius = rounded ? BorderRadius.circular(cornerRadius) : BorderRadius.zero;
    final borderWidth = rodBorderSide?.width ?? 0.0;
    final borderColor = rodBorderSide?.color ?? Colors.transparent;

    CartesianSeries<ChartDataCategory, String> series;
    if (isHorizontal) {
      series = BarSeries<ChartDataCategory, String>(
        dataSource: data,
        xValueMapper: (datum, _) => datum.category,
        yValueMapper: (datum, _) => datum.value,
        width: barWidth,
        spacing: groupsSpace ?? 0.2,
        borderRadius: radius,
        borderWidth: borderWidth,
        borderColor: borderColor,
        animationDuration: animationMillis,
        pointColorMapper: _getPointColor,
        dataLabelSettings: DataLabelSettings(isVisible: showRodLabels),
        gradient: barGradient,
      );
    } else {
      series = ColumnSeries<ChartDataCategory, String>(
        dataSource: data,
        xValueMapper: (datum, _) => datum.category,
        yValueMapper: (datum, _) => datum.value,
        width: barWidth,
        spacing: groupsSpace ?? 0.2,
        borderRadius: radius,
        borderWidth: borderWidth,
        borderColor: borderColor,
        animationDuration: animationMillis,
        pointColorMapper: _getPointColor,
        dataLabelSettings: DataLabelSettings(isVisible: showRodLabels),
        gradient: barGradient,
      );
    }

    return SfCartesianChart(
      primaryXAxis: primaryAxis,
      primaryYAxis: secondaryAxis,
      tooltipBehavior: enableTooltip ? TooltipBehavior(enable: true) : null,
      zoomPanBehavior: enablePanning ? ZoomPanBehavior(enablePanning: true) : null,
      series: <CartesianSeries>[series],
      plotAreaBorderWidth: showBorder ? 1 : 0,
    );
  }

  Color? _getPointColor(ChartDataCategory datum, int index) {
    if (colorMode == BarColorMode.bySign) {
      return datum.value >= 0 ? Colors.green : Colors.red;
    } else if (colorMode == BarColorMode.byCategory) {
      final Color? c = ChartPalette.parseHex(datum.color);
      final Color fallback = ChartPalette.categoryColor(index);
      if (c != null) return c;
      return fallback;
    }
    return staticColor; // If null, SfCartesianChart uses default palette or we can let it be null.
  }
}
