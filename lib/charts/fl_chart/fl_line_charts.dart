import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Wrapper reutilizable sobre [LineChart] (FL Chart 1.2.0) para una serie de
/// `ChartDataXY`. Todas las opciones son configuraciones del widget nativo
/// `LineChart` (VARIANTES).
class BasicLineChart extends StatelessWidget {
  final List<ChartDataXY> points;

  final Color? lineColor;
  final double lineWidth;

  /// Curva suavizada (`isCurved`, `curveSmoothness`,
  /// `preventCurveOverShooting`).
  final bool isCurved;
  final double curveSmoothness;

  final bool showDots;
  final bool showArea;

  final bool showTitles;
  final bool showGrid;
  final bool showBorder;

  final double? minY;
  final double? maxY;

  /// Intervalo de etiquetas del eje X (p. ej. 5 para mostrar cada 5 años).
  final double? xLabelInterval;

  /// Formato de las etiquetas del eje X; por defecto el entero de `x`.
  final String Function(double x)? xLabelFormatter;

  /// Formato de las etiquetas del eje Y.
  final String Function(double y)? yLabelFormatter;

  final bool animated;
  final Duration animationDuration;

  final bool enableTouch;

  const BasicLineChart({
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
    this.animationDuration = const Duration(milliseconds: 400),
    this.enableTouch = true,
  });

  static String _defaultY(double y) =>
      y == y.roundToDouble() ? y.toInt().toString() : y.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Center(child: Text('Sin datos'));

    final color = lineColor ?? ChartPalette.primary(context);
    final axisStyle = TextStyle(fontSize: 10, color: ChartPalette.axisText(context));
    final gridColor = ChartPalette.gridLine(context);
    final formatX = xLabelFormatter ?? (double x) => x.toInt().toString();
    final formatY = yLabelFormatter ?? _defaultY;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: points
                .map((e) => FlSpot(e.x.toDouble(), e.y.toDouble()))
                .toList(),
            isCurved: isCurved,
            curveSmoothness: curveSmoothness,
            preventCurveOverShooting: isCurved,
            color: color,
            barWidth: lineWidth,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: showDots,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 1.5,
                strokeColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: showArea,
              color: color.withValues(alpha: 0.25),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          show: showTitles,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: xLabelInterval,
              getTitlesWidget: (value, meta) {
                // FL Chart añade etiquetas en min/max aunque no caigan en el
                // intervalo; se omiten para evitar solapamientos.
                if ((value == meta.min || value == meta.max) &&
                    value % meta.appliedInterval != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(formatX(value), style: axisStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if ((value == meta.min || value == meta.max) &&
                    value % meta.appliedInterval != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(formatY(value), style: axisStyle),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: gridColor,
            strokeWidth: 0.8,
            dashArray: const [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: showBorder,
          border: Border(
            left: BorderSide(color: gridColor),
            bottom: BorderSide(color: gridColor),
          ),
        ),
        lineTouchData: LineTouchData(enabled: enableTouch),
      ),
      duration: animated ? animationDuration : Duration.zero,
    );
  }
}
