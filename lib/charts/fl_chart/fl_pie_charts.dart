import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Wrapper reutilizable sobre [PieChart] (FL Chart 1.2.0) para una serie de
/// `ChartDataCategory`. Donut, anillo delgado, separación, colores y
/// animación son configuraciones del widget nativo `PieChart` (VARIANTES).
class BasicPieChart extends StatelessWidget {
  final List<ChartDataCategory> data;

  /// Donut mediante `PieChartData.centerSpaceRadius`.
  final bool isDonut;

  /// Anillo delgado: mayor `centerSpaceRadius` y menor
  /// `PieChartSectionData.radius`.
  final bool isThinDonut;

  /// Separación entre porciones (`PieChartData.sectionsSpace`).
  final double spacing;

  /// Borde de cada porción (`PieChartSectionData.borderSide`).
  final BorderSide? sectionBorder;

  final bool animated;
  final Duration animationDuration;

  /// Tonos de un único color (variando luminosidad, no opacidad).
  final bool monochromatic;
  final Color? baseColor;

  final bool showTitles;

  /// Qué texto se muestra en cada porción.
  final PieTitleMode titleMode;

  /// Porciones con un porcentaje menor no muestran título para evitar
  /// solapamientos.
  final double minPercentForTitle;

  /// Índice de porción resaltada (preparado para selección futura).
  final int? highlightedIndex;

  /// Callback de toque (preparado para selección futura).
  final void Function(int? sectionIndex)? onSectionTapped;

  /// Offset para las etiquetas, útil para colocarlas afuera del donut.
  final double? titlePositionPercentageOffset;

  const BasicPieChart({
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
    this.titleMode = PieTitleMode.categoryAndPercent,
    this.minPercentForTitle = 5,
    this.highlightedIndex,
    this.onSectionTapped,
    this.titlePositionPercentageOffset,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Sin datos'));

    final total = data.fold<double>(0, (sum, e) => sum + e.value.toDouble());
    if (total <= 0) return const Center(child: Text('Sin datos'));

    final shades = monochromatic
        ? ChartPalette.monochromeShades(
            baseColor ?? ChartPalette.primary(context), data.length)
        : const <Color>[];

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest.shortestSide;
      final outer = (size / 2) - 8;
      final double center;
      final double ring;
      if (isThinDonut) {
        ring = outer * 0.22;
        center = outer - ring;
      } else if (isDonut) {
        ring = outer * 0.45;
        center = outer - ring;
      } else {
        ring = outer;
        center = 0;
      }

      final sections = data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final value = item.value.toDouble();
        final percent = value / total * 100;

        final color = monochromatic
            ? shades[index]
            : ChartPalette.parseHex(item.color) ??
                ChartPalette.categoryColor(index);

        final title = switch (titleMode) {
          PieTitleMode.category => item.category,
          PieTitleMode.percent => '${percent.toStringAsFixed(1)}%',
          PieTitleMode.categoryAndPercent =>
            '${item.category}\n${percent.toStringAsFixed(0)}%',
        };

        final highlighted = highlightedIndex == index;

        return PieChartSectionData(
          value: value,
          color: color,
          radius: highlighted ? ring * 1.1 : ring,
          showTitle: showTitles && percent >= minPercentForTitle,
          title: title,
          titlePositionPercentageOffset: titlePositionPercentageOffset ?? (isDonut ? 0.5 : 0.6),
          borderSide: sectionBorder,
          // Texto blanco con sombra: legible sobre la porción y también si
          // desborda un anillo delgado sobre el fondo oscuro.
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        );
      }).toList();

      return PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: spacing,
          centerSpaceRadius: center,
          pieTouchData: PieTouchData(
            enabled: onSectionTapped != null,
            touchCallback: onSectionTapped == null
                ? null
                : (event, response) {
                    if (!event.isInterestedForInteractions) return;
                    onSectionTapped!(
                        response?.touchedSection?.touchedSectionIndex);
                  },
          ),
        ),
        duration: animated ? animationDuration : Duration.zero,
      );
    });
  }
}

enum PieTitleMode { category, percent, categoryAndPercent }
