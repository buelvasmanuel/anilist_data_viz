import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum SyncfusionPieTitleMode { category, value, percentage, both }

class SyncfusionBasicPieChart extends StatelessWidget {
  final List<ChartDataCategory> data;
  final bool isDonut;
  final bool isThinDonut;
  final double spacing; // map to explodeOffset or pointRenderMode
  final BorderSide? sectionBorder;
  final bool animated;
  final Duration animationDuration;
  final bool monochromatic;
  final Color? baseColor;
  final bool showTitles;
  final SyncfusionPieTitleMode titleMode;
  final double minPercentForTitle;
  final int? highlightedIndex;
  final void Function(int?)? onSectionTapped;
  final double? titlePositionPercentageOffset;

  const SyncfusionBasicPieChart({
    super.key,
    required this.data,
    this.isDonut = false,
    this.isThinDonut = false,
    this.spacing = 0,
    this.sectionBorder,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 400),
    this.monochromatic = false,
    this.baseColor,
    this.showTitles = true,
    this.titleMode = SyncfusionPieTitleMode.category,
    this.minPercentForTitle = 0.05,
    this.highlightedIndex,
    this.onSectionTapped,
    this.titlePositionPercentageOffset,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    final animationMillis = animated ? animationDuration.inMilliseconds.toDouble() : 0.0;
    
    // Calculate total for percentages
    double total = 0;
    for (var d in data) {
      total += d.value.toDouble();
    }

    final tooltipBehavior = TooltipBehavior(enable: true);
    final selectionBehavior = SelectionBehavior(
      enable: true,
      unselectedOpacity: 0.5,
    );

    // Map the label mode
    String labelMapper(ChartDataCategory datum, int index) {
      final val = datum.value.toDouble();
      final pct = total == 0 ? 0 : val / total;
      if (pct < minPercentForTitle) return '';
      
      switch (titleMode) {
        case SyncfusionPieTitleMode.category:
          return datum.category;
        case SyncfusionPieTitleMode.value:
          return val.toInt().toString();
        case SyncfusionPieTitleMode.percentage:
          return '${(pct * 100).toStringAsFixed(1)}%';
        case SyncfusionPieTitleMode.both:
          return '${datum.category}\n${(pct * 100).toStringAsFixed(1)}%';
      }
    }

    final dataLabelSettings = DataLabelSettings(
      isVisible: showTitles,
      labelPosition: titlePositionPercentageOffset != null && titlePositionPercentageOffset! > 1.0 
        ? ChartDataLabelPosition.outside 
        : ChartDataLabelPosition.inside,
    );

    Color? getPointColor(ChartDataCategory datum, int index) {
      if (monochromatic) {
        final color = baseColor ?? Theme.of(context).colorScheme.primary;
        final hsl = HSLColor.fromColor(color);
        // Vary lightness between 0.3 and 0.8 based on index
        final step = 0.5 / (data.length == 1 ? 1 : data.length - 1);
        return hsl.withLightness(0.3 + (step * index)).toColor();
      }
      final Color? c = ChartPalette.parseHex(datum.color);
      final Color fallback = ChartPalette.categoryColor(index);
      if (c != null) return c;
      return fallback;
    }

    final innerRadius = isThinDonut ? '80%' : (isDonut ? '50%' : '0%');
    final explode = spacing > 0;
    final explodeOffset = spacing > 0 ? '$spacing%' : '0%';
    final explodeIndex = highlightedIndex;

    CircularSeries<ChartDataCategory, String> series;
    
    if (isDonut || isThinDonut) {
      series = DoughnutSeries<ChartDataCategory, String>(
        dataSource: data,
        xValueMapper: (datum, _) => datum.category,
        yValueMapper: (datum, _) => datum.value,
        pointColorMapper: getPointColor,
        dataLabelMapper: labelMapper,
        dataLabelSettings: dataLabelSettings,
        innerRadius: innerRadius,
        explode: explode || explodeIndex != null,
        explodeIndex: explodeIndex ?? -1,
        explodeOffset: explodeOffset,
        animationDuration: animationMillis,
        selectionBehavior: selectionBehavior,
        strokeWidth: sectionBorder?.width ?? 0.0,
        strokeColor: sectionBorder?.color ?? Colors.transparent,
      );
    } else {
      series = PieSeries<ChartDataCategory, String>(
        dataSource: data,
        xValueMapper: (datum, _) => datum.category,
        yValueMapper: (datum, _) => datum.value,
        pointColorMapper: getPointColor,
        dataLabelMapper: labelMapper,
        dataLabelSettings: dataLabelSettings,
        explode: explode || explodeIndex != null,
        explodeIndex: explodeIndex ?? -1,
        explodeOffset: explodeOffset,
        animationDuration: animationMillis,
        selectionBehavior: selectionBehavior,
        strokeWidth: sectionBorder?.width ?? 0.0,
        strokeColor: sectionBorder?.color ?? Colors.transparent,
      );
    }

    return SfCircularChart(
      tooltipBehavior: tooltipBehavior,
      series: <CircularSeries>[series],
      onSelectionChanged: (selectionArgs) {
        if (onSectionTapped != null) {
          onSectionTapped!(selectionArgs.pointIndex);
        }
      },
    );
  }
}
