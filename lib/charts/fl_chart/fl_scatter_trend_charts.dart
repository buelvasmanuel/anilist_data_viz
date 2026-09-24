import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScatterTrendChart extends StatelessWidget {
  final List<ChartDataXY> points;
  final List<double> regressionLine;
  final String xAxisLabel;
  final String yAxisLabel;

  const ScatterTrendChart({
    super.key,
    required this.points,
    required this.regressionLine,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Center(child: Text('Sin datos'));

    final axisStyle = TextStyle(fontSize: 10, color: ChartPalette.axisText(context));
    final gridColor = ChartPalette.gridLine(context);

    double minX = points.first.x.toDouble();
    double maxX = points.first.x.toDouble();
    double minY = points.first.y.toDouble();
    double maxY = points.first.y.toDouble();

    for (var p in points) {
      if (p.x < minX) minX = p.x.toDouble();
      if (p.x > maxX) maxX = p.x.toDouble();
      if (p.y < minY) minY = p.y.toDouble();
      if (p.y > maxY) maxY = p.y.toDouble();
    }

    final slope = regressionLine[0];
    final intercept = regressionLine[1];

    final yStart = slope * minX + intercept;
    final yEnd = slope * maxX + intercept;

    if (yStart < minY) minY = yStart;
    if (yStart > maxY) maxY = yStart;
    if (yEnd < minY) minY = yEnd;
    if (yEnd > maxY) maxY = yEnd;

    // Expand bounds slightly for better looks
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    minX -= xRange * 0.05;
    maxX += xRange * 0.05;
    minY -= yRange * 0.05;
    maxY += yRange * 0.05;

    return Stack(
      children: [
        ScatterChart(
          ScatterChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            scatterSpots: points.map((e) {
              return ScatterSpot(
                e.x.toDouble(),
                e.y.toDouble(),
                dotPainter: FlDotCirclePainter(
                  color: ChartPalette.primary(context).withValues(alpha: 0.6),
                  radius: 3,
                ),
              );
            }).toList(),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.min || value == meta.max) return const SizedBox.shrink();
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
                    if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(value.toInt().toString(), style: axisStyle),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
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
            scatterTouchData: ScatterTouchData(
              touchTooltipData: ScatterTouchTooltipData(
                getTooltipColor: (_) => const Color(0xff121212),
                getTooltipItems: (touchedSpot) {
                  return ScatterTooltipItem(
                    '$xAxisLabel: ${touchedSpot.x.toInt()}\n$yAxisLabel: ${touchedSpot.y.toInt()}',
                    textStyle: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
        LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(minX, yStart),
                  FlSpot(maxX, yEnd),
                ],
                isCurved: false,
                color: ChartPalette.negative,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
          ),
        ),
      ],
    );
  }
}
