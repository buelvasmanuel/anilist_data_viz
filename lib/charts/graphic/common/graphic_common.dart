// Componentes comunes de la galería Graphic: clasificación, origen de datos,
// leyenda (Graphic NO tiene leyenda propia), estados vacíos y ejes.

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

/// Clasificación auditada (Sección C del prompt: 36 / 18 / 9).
enum GraphicClassification {
  nativo('NATIVO', Color(0xFF2E7D32)),
  variante('VARIANTE', Color(0xFFEF6C00)),
  composicion('COMPOSICIÓN', Color(0xFF6A1B9A));

  const GraphicClassification(this.label, this.color);
  final String label;
  final Color color;
}

/// Origen del dato (solo tres estados).
enum GraphicDataOrigin {
  directo('DIRECTO'),
  derivado('DERIVADO'),
  noDisponible('NO DISPONIBLE');

  const GraphicDataOrigin(this.label);
  final String label;
}

/// Paleta categórica: la de Graphic, para ser coherentes con sus defaults.
List<Color> get graphicPalette => Defaults.colors10;

/// Ejes estándar.
List<AxisGuide> get standardAxes => [Defaults.horizontalAxis, Defaults.verticalAxis];

/// Eje horizontal con etiquetas rotadas: útil con muchas categorías.
AxisGuide rotatedHorizontalAxis() => Defaults.horizontalAxis
  ..label = LabelStyle(
    textStyle: const TextStyle(fontSize: 9, color: Color(0xFF808080)),
    offset: const Offset(0, 7.5),
    rotation: -0.5,
    align: Alignment.bottomLeft,
  );

/// Mensaje de estado vacío o no disponible (no se inventan datos).
class GraphicEmptyState extends StatelessWidget {
  const GraphicEmptyState(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
}

/// Aviso visible sobre el gráfico (datos sintéticos, reproducción local...).
class GraphicNotice extends StatelessWidget {
  const GraphicNotice(this.text, {super.key, this.color = const Color(0xFFC62828)});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: color.withAlpha(25),
        child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

/// Leyenda como widget Flutter. Graphic 2.7.0 no tiene guía de leyenda:
/// se construye a partir de las mismas categorías y la misma paleta.
class GraphicLegend extends StatelessWidget {
  const GraphicLegend({super.key, required this.labels, List<Color>? colors})
      : _colors = colors;

  final List<String> labels;
  final List<Color>? _colors;

  @override
  Widget build(BuildContext context) {
    final colors = _colors ?? graphicPalette;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, color: colors[i % colors.length]),
            const SizedBox(width: 4),
            Text(labels[i], style: const TextStyle(fontSize: 11)),
          ]),
      ],
    );
  }
}

/// Coloca una leyenda bajo un gráfico.
Widget withLegend(Widget chart, List<String> labels, {List<Color>? colors}) => Column(
      children: [
        Expanded(child: chart),
        const SizedBox(height: 6),
        GraphicLegend(labels: labels, colors: colors),
      ],
    );

/// Selección táctil + ratón para tooltips simples.
Map<String, Selection> tapSelection({Dim? dim, String? variable}) => {
      'tap': PointSelection(
        on: {GestureType.tapDown, GestureType.hover},
        dim: dim,
        variable: variable,
      ),
    };
