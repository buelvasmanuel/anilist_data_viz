import 'dart:math' as math;

import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Cómo se colorean las barras de [BasicBarChart].
enum BarColorMode {
  /// Un único color (`staticColor` o el color primario del tema).
  single,

  /// Un color por categoría (`ChartDataCategory.color` o la paleta).
  byCategory,

  /// Verde para valores >= 0 y rojo para valores negativos.
  bySign,
}

/// Wrapper reutilizable sobre [BarChart] (FL Chart 1.2.0) para una serie de
/// `ChartDataCategory`. Todas las opciones son configuraciones del widget
/// nativo `BarChart` (VARIANTES): no se usan widgets de Flutter adicionales
/// alrededor del gráfico.
class BasicBarChart extends StatelessWidget {
  final List<ChartDataCategory> data;

  /// Barras horizontales mediante `BarChartData.rotationQuarterTurns: 1`.
  final bool isHorizontal;

  /// Grosor de cada barra (`BarChartRodData.width`).
  final double barWidth;

  /// Espacio entre grupos (`BarChartData.groupsSpace`). FL Chart solo lo
  /// aplica con `BarChartAlignment.start/center/end`; por eso, cuando se
  /// indica, la alineación pasa a `center`. Si es `null` se usa
  /// `BarChartAlignment.spaceAround` y el espacio lo reparte FL Chart.
  final double? groupsSpace;

  final bool rounded;
  final double cornerRadius;

  final BarColorMode colorMode;
  final Color? staticColor;

  /// Borde de cada barra (`BarChartRodData.borderSide`).
  final BorderSide? rodBorderSide;

  /// Si no es `null`, dibuja una barra de fondo hasta este valor
  /// (`BarChartRodData.backDrawRodData`).
  final double? backgroundRodToY;

  final bool showTitles;
  final bool showGrid;
  final bool showBorder;

  /// Intervalo de la cuadrícula y de las etiquetas del eje de valores.
  final double? gridInterval;

  /// Muestra una de cada N etiquetas de categoría (útil con muchos años).
  final int categoryLabelEvery;

  /// Espacio reservado para las etiquetas de categoría.
  final double? categoryLabelSize;

  final double? minY;
  final double? maxY;
  final double? baselineY;

  /// Dibuja una línea en `baselineY` (o 0) con `ExtraLinesData`.
  final bool showBaselineLine;

  final bool animated;
  final Duration animationDuration;

  /// Muestra el valor sobre cada barra usando un tooltip fijo
  /// (`BarChartGroupData.showingTooltipIndicators` + `BarTouchTooltipData`).
  final bool showValueLabels;

  /// Tooltips al tocar/pasar el ratón (`BarTouchData`).
  final bool enableTouch;

  final bool showRodLabels;

  /// Gradiente vertical para las barras.
  final Gradient? barGradient;

  final String Function(num value)? valueFormatter;

  const BasicBarChart({
    super.key,
    required this.data,
    this.isHorizontal = false,
    this.barWidth = 16,
    this.groupsSpace,
    this.rounded = false,
    this.cornerRadius = 6,
    this.colorMode = BarColorMode.single,
    this.staticColor,
    this.rodBorderSide,
    this.backgroundRodToY,
    this.showTitles = true,
    this.showGrid = false,
    this.showBorder = false,
    this.gridInterval,
    this.categoryLabelEvery = 1,
    this.categoryLabelSize,
    this.minY,
    this.maxY,
    this.baselineY,
    this.showBaselineLine = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 400),
    this.showValueLabels = false,
    this.showRodLabels = false,
    this.barGradient,
    this.enableTouch = true,
    this.valueFormatter,
  });

  String _format(num value) {
    if (valueFormatter != null) return valueFormatter!(value);
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  Color _colorFor(BuildContext context, int index, ChartDataCategory item) {
    switch (colorMode) {
      case BarColorMode.single:
        return staticColor ?? ChartPalette.primary(context);
      case BarColorMode.byCategory:
        return ChartPalette.parseHex(item.color) ??
            ChartPalette.categoryColor(index);
      case BarColorMode.bySign:
        return item.value >= 0 ? ChartPalette.positive : ChartPalette.negative;
    }
  }

  /// Si se muestran etiquetas de valor y no se fijó `maxY`, se deja un margen
  /// superior para que el tooltip fijo no quede cortado.
  double? _effectiveMaxY() {
    if (maxY != null) return maxY;
    if (!showValueLabels || data.isEmpty) return null;
    final maxValue = data.map((e) => e.value.toDouble()).reduce(math.max);
    if (maxValue <= 0) return null;
    return maxValue * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Sin datos'));
    return LayoutBuilder(
      builder: (context, constraints) => _buildChart(context, constraints),
    );
  }

  /// Ancho disponible para cada etiqueta de categoría en vertical: la
  /// distancia real entre barras, para que las etiquetas no se solapen.
  double _categoryLabelWidth(BoxConstraints constraints) {
    if (isHorizontal) return (categoryLabelSize ?? 90) - 8;
    final slot = groupsSpace != null
        ? barWidth + groupsSpace!
        : (constraints.maxWidth - 40) / data.length;
    return (slot * categoryLabelEvery - 4).clamp(16, 120).toDouble();
  }

  Widget _buildChart(BuildContext context, BoxConstraints constraints) {

    final axisStyle = TextStyle(fontSize: 10, color: ChartPalette.axisText(context));
    final lineColor = ChartPalette.gridLine(context);
    final radius = rounded ? Radius.circular(cornerRadius) : Radius.zero;

    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = item.value.toDouble();
      // Para barras negativas el extremo "libre" es el inferior.
      final borderRadius = value >= 0
          ? BorderRadius.vertical(top: radius)
          : BorderRadius.vertical(bottom: radius);

      return BarChartGroupData(
        x: index,
        showingTooltipIndicators: showValueLabels ? const [0] : const [],
        barRods: [
          showRodLabels
            ? BarChartRodData(
                toY: value,
                color: barGradient == null ? _colorFor(context, index, item) : null,
                gradient: barGradient,
                width: barWidth,
                borderRadius: borderRadius,
                borderSide: rodBorderSide,
                backDrawRodData: BackgroundBarChartRodData(
                  show: backgroundRodToY != null,
                  toY: backgroundRodToY ?? 0,
                  color: lineColor.withValues(alpha: 0.35),
                ),
                label: BarChartRodLabel(
                  text: _format(value),
                  style: TextStyle(
                    color: ChartPalette.axisText(context),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : BarChartRodData(
                toY: value,
                color: barGradient == null ? _colorFor(context, index, item) : null,
                gradient: barGradient,
                width: barWidth,
                borderRadius: borderRadius,
                borderSide: rodBorderSide,
                backDrawRodData: BackgroundBarChartRodData(
                  show: backgroundRodToY != null,
                  toY: backgroundRodToY ?? 0,
                  color: lineColor.withValues(alpha: 0.35),
                ),
              ),
        ],
      );
    }).toList();

    final labelWidth = _categoryLabelWidth(constraints);
    final categoryTitles = SideTitles(
      showTitles: true,
      reservedSize: categoryLabelSize ?? (isHorizontal ? 90 : 30),
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        if (index < 0 || index >= data.length || index % categoryLabelEvery != 0) {
          return const SizedBox.shrink();
        }
        // SideTitleWidget contrarrota el texto cuando se usa
        // rotationQuarterTurns, por eso se mantiene legible en horizontal.
        return SideTitleWidget(
          meta: meta,
          space: 4,
          child: SizedBox(
            width: labelWidth,
            child: Text(
              data[index].category,
              style: axisStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isHorizontal ? TextAlign.right : TextAlign.center,
            ),
          ),
        );
      },
    );

    final valueTitles = SideTitles(
      showTitles: true,
      reservedSize: 40,
      interval: gridInterval,
      getTitlesWidget: (value, meta) {
        // FL Chart siempre etiqueta min y max; si no coinciden con el
        // intervalo se omiten para que no se solapen con la vecina.
        if ((value == meta.max || value == meta.min) &&
            value % meta.appliedInterval != 0) {
          return const SizedBox.shrink();
        }
        return SideTitleWidget(
          meta: meta,
          child: Text(_format(value), style: axisStyle),
        );
      },
    );

    final chart = BarChart(
      BarChartData(
        rotationQuarterTurns: isHorizontal ? 1 : 0,
        alignment: groupsSpace != null
            ? BarChartAlignment.center
            : BarChartAlignment.spaceAround,
        groupsSpace: groupsSpace,
        minY: minY,
        maxY: _effectiveMaxY(),
        baselineY: baselineY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: showTitles,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: categoryTitles),
          leftTitles: AxisTitles(sideTitles: valueTitles),
        ),
        // Las líneas de la cuadrícula siguen el eje de valores (horizontales en
        // coordenadas de datos). Con rotationQuarterTurns FL Chart las rota
        // junto con el gráfico, así que en horizontal quedan verticales.
        gridData: FlGridData(
          show: showGrid,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: gridInterval,
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
        extraLinesData: ExtraLinesData(
          horizontalLines: showBaselineLine
              ? [
                  HorizontalLine(
                    y: baselineY ?? 0,
                    color: ChartPalette.axisText(context),
                    strokeWidth: 1.5,
                  ),
                ]
              : const [],
        ),
        barTouchData: showValueLabels
            ? BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                    _format(rod.toY),
                    TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              )
            : BarTouchData(
                enabled: enableTouch,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                    '${data[group.x].category}\n${_format(rod.toY)}',
                    const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
      ),
      duration: animated ? animationDuration : Duration.zero,
    );

    return chart;
  }
}
