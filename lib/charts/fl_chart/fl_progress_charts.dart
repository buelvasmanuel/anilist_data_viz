import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Barra de progreso (KPI lineal). Wrapper propio del proyecto sobre el
/// widget nativo [BarChart]: no es un widget de FL Chart.
///
/// Técnica (VARIANTE de BarChart):
/// - una sola barra con `toY = value`;
/// - `backDrawRodData` hasta `maxValue` como pista de fondo;
/// - `rotationQuarterTurns: 1` para dibujarla en horizontal;
/// - sin ejes, cuadrícula ni borde.
class ProgressBarChart extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? color;
  final double thickness;
  final bool animated;

  const ProgressBarChart({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.color,
    this.thickness = 22,
    this.animated = true,
  }) : assert(maxValue > 0);

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? ChartPalette.primary(context);
    final radius = BorderRadius.circular(thickness / 2);

    return BarChart(
      BarChartData(
        rotationQuarterTurns: 1,
        alignment: BarChartAlignment.center,
        minY: 0,
        maxY: maxValue,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: value.clamp(0, maxValue).toDouble(),
                color: barColor,
                width: thickness,
                borderRadius: radius,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue,
                  color: ChartPalette.gridLine(context).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
      duration: animated ? const Duration(milliseconds: 400) : Duration.zero,
    );
  }
}
