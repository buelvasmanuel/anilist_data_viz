import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MultiLineChart extends StatelessWidget {
  final List<ChartSeries<ChartDataXY>> seriesList;
  final bool showDots;
  final bool isCurved;
  final bool showGrid;
  final bool showLegend;
  final double? minY;
  final double? maxY;

  const MultiLineChart({
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

    final axisStyle = TextStyle(fontSize: 10, color: ChartPalette.axisText(context));
    final gridColor = ChartPalette.gridLine(context);

    final lineBars = List.generate(seriesList.length, (index) {
      final color = ChartPalette.categoryColor(index);
      return LineChartBarData(
        spots: seriesList[index].data.map((e) => FlSpot(e.x.toDouble(), e.y.toDouble())).toList(),
        isCurved: isCurved,
        color: color,
        barWidth: 2,
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
      );
    });

    final chart = LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: lineBars,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if ((value == meta.min || value == meta.max) && value % meta.appliedInterval != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: axisStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if ((value == meta.min || value == meta.max) && value % meta.appliedInterval != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(value.toStringAsFixed(1), style: axisStyle),
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
          show: true,
          border: Border(left: BorderSide(color: gridColor), bottom: BorderSide(color: gridColor)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff121212),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final seriesName = seriesList[spot.barIndex].seriesName;
                return LineTooltipItem(
                  '$seriesName\n${spot.y.toStringAsFixed(1)}',
                  TextStyle(color: ChartPalette.categoryColor(spot.barIndex), fontWeight: FontWeight.bold, fontSize: 10),
                );
              }).toList();
            },
          ),
        ),
      ),
    );

    if (!showLegend) return chart;

    return Column(
      children: [
        Expanded(child: chart),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: List.generate(seriesList.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 2, color: ChartPalette.categoryColor(index)),
                const SizedBox(width: 4),
                Text(seriesList[index].seriesName, style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        ),
      ],
    );
  }
}
