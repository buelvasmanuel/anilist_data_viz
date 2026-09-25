import 'dart:math' as math;

import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gauge semicircular. COMPOSICIÓN propia del proyecto: FL Chart no tiene un
/// widget de gauge.
///
/// - FL Chart: un [PieChart] con tres secciones: valor, resto hasta
///   `maxValue` y una mitad transparente (valor = `maxValue`), empezando en
///   180° (`startDegreeOffset`) para que el valor y el resto ocupen el
///   semicírculo superior.
/// - Flutter: `ClipRect` + `OverflowBox` recortan la mitad
///   inferior vacía y un `Stack` superpone el texto central.
class SemiCircleGauge extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? color;

  /// Texto principal bajo el arco (p. ej. "78.4").
  final String valueLabel;

  /// Texto secundario (p. ej. "/ 100").
  final String? caption;

  final bool animated;

  const SemiCircleGauge({
    super.key,
    required this.value,
    required this.valueLabel,
    this.maxValue = 100,
    this.caption,
    this.color,
    this.animated = true,
  }) : assert(maxValue > 0);

  @override
  Widget build(BuildContext context) {
    final arcColor = color ?? ChartPalette.primary(context);
    final trackColor = ChartPalette.gridLine(context).withValues(alpha: 0.5);
    final clamped = value.clamp(0, maxValue).toDouble();

    return LayoutBuilder(builder: (context, constraints) {
      // El gauge ocupa medio círculo: ancho = diámetro, alto = radio.
      final diameter = math.min(constraints.maxWidth, constraints.maxHeight * 2);
      final radius = diameter / 2;
      final thickness = radius * 0.28;

      return Center(
        child: SizedBox(
          width: diameter,
          height: radius,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // El PieChart se dibuja en un cuadrado completo (diámetro ×
              // diámetro) que desborda hacia abajo; ClipRect recorta la mitad
              // inferior transparente.
              ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minWidth: diameter,
                  maxWidth: diameter,
                  minHeight: diameter,
                  maxHeight: diameter,
                  child: SizedBox(
                    width: diameter,
                    height: diameter,
                    child: PieChart(
                      PieChartData(
                        startDegreeOffset: 180,
                        sectionsSpace: 0,
                        centerSpaceRadius: radius - thickness,
                        pieTouchData: PieTouchData(enabled: false),
                        sections: [
                          PieChartSectionData(
                            value: clamped,
                            color: arcColor,
                            radius: thickness,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: maxValue - clamped,
                            color: trackColor,
                            radius: thickness,
                            showTitle: false,
                          ),
                          // Mitad inferior invisible.
                          PieChartSectionData(
                            value: maxValue,
                            color: Colors.transparent,
                            radius: thickness,
                            showTitle: false,
                          ),
                        ],
                      ),
                      duration: animated
                          ? const Duration(milliseconds: 400)
                          : Duration.zero,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    valueLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (caption != null)
                    Text(caption!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
