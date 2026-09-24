import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MultiSeriesBarChart extends StatelessWidget {
  final List<ChartSeries<ChartDataCategory>> seriesList;
  final bool isHorizontal;
  final bool isStacked;
  final double barWidth;
  final double groupsSpace;
  final bool showTitles;
  final bool showGrid;
  final bool showBorder;
  final bool showLegend;

  const MultiSeriesBarChart({
    super.key,
    required this.seriesList,
    this.isHorizontal = false,
    this.isStacked = false,
    this.barWidth = 12,
    this.groupsSpace = 24,
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

    final categories = seriesList.first.data.map((e) => e.category).toList();
    final axisStyle = TextStyle(fontSize: 10, color: ChartPalette.axisText(context));
    final lineColor = ChartPalette.gridLine(context);

    final barGroups = List.generate(categories.length, (catIndex) {
      if (isStacked) {
        double currentY = 0;
        final rodStackItems = <BarChartRodStackItem>[];
        for (int i = 0; i < seriesList.length; i++) {
          final val = seriesList[i].data[catIndex].value.toDouble();
          if (val > 0) {
            rodStackItems.add(BarChartRodStackItem(
              currentY,
              currentY + val,
              ChartPalette.categoryColor(i),
            ));
            currentY += val;
          }
        }
        return BarChartGroupData(
          x: catIndex,
          barRods: [
            BarChartRodData(
              toY: currentY,
              width: barWidth,
              borderRadius: BorderRadius.zero,
              rodStackItems: rodStackItems,
            ),
          ],
        );
      } else {
        return BarChartGroupData(
          x: catIndex,
          barRods: List.generate(seriesList.length, (seriesIndex) {
            final val = seriesList[seriesIndex].data[catIndex].value.toDouble();
            return BarChartRodData(
              toY: val,
              color: ChartPalette.categoryColor(seriesIndex),
              width: barWidth,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            );
          }),
        );
      }
    });

    double maxY = 0;
    if (isStacked) {
      for (int catIndex = 0; catIndex < categories.length; catIndex++) {
        double sum = 0;
        for (var s in seriesList) {
          sum += s.data[catIndex].value.toDouble();
        }
        if (sum > maxY) maxY = sum;
      }
    } else {
      for (var s in seriesList) {
        for (var d in s.data) {
          if (d.value.toDouble() > maxY) maxY = d.value.toDouble();
        }
      }
    }
    maxY = maxY > 0 ? maxY * 1.1 : 10;

    final chart = BarChart(
      BarChartData(
        rotationQuarterTurns: isHorizontal ? 1 : 0,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: groupsSpace,
        maxY: maxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: showTitles,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isHorizontal ? 90 : 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= categories.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    categories[index],
                    style: axisStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: axisStyle),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: lineColor,
            strokeWidth: 0.8,
            dashArray: const [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: showBorder,
          border: Border(
            left: BorderSide(color: lineColor),
            bottom: BorderSide(color: lineColor),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff121212),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (isStacked) {
                return BarTooltipItem(
                  '${categories[group.x]}\nTotal: ${rod.toY.toInt()}',
                  const TextStyle(fontSize: 11, color: Colors.white),
                );
              } else {
                return BarTooltipItem(
                  '${seriesList[rodIndex].seriesName}\n${rod.toY.toInt()}',
                  const TextStyle(fontSize: 11, color: Colors.white),
                );
              }
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
                Container(width: 12, height: 12, color: ChartPalette.categoryColor(index)),
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
