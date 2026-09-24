import 'package:flutter/material.dart';

/// Paleta categórica compartida por los wrappers de FL Chart.
///
/// Los colores están elegidos para mantener contraste sobre el tema oscuro
/// de la aplicación (no se usa `ThemeData.primaryColor`, que en Material 3
/// oscuro equivale al color de superficie).
class ChartPalette {
  static const List<Color> categorical = [
    Color(0xFF4FC3F7), // light blue
    Color(0xFFFFB74D), // orange
    Color(0xFF81C784), // green
    Color(0xFFF06292), // pink
    Color(0xFFBA68C8), // purple
    Color(0xFFFFF176), // yellow
    Color(0xFF4DB6AC), // teal
    Color(0xFFE57373), // red
    Color(0xFF9575CD), // deep purple
    Color(0xFFA1887F), // brown
  ];

  static const Color positive = Color(0xFF81C784);
  static const Color negative = Color(0xFFE57373);

  static Color categoryColor(int index) =>
      categorical[index % categorical.length];

  /// Color principal por defecto para series únicas.
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Color de líneas auxiliares (grid, bordes, línea base).
  static Color gridLine(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  /// Color de texto de ejes.
  static Color axisText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Convierte `#RRGGBB` o `#AARRGGBB` en [Color]. Devuelve `null` si el
  /// formato no es válido.
  static Color? parseHex(String? hex) {
    if (hex == null) return null;
    var value = hex.replaceAll('#', '').trim();
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  /// Genera [count] tonos de un mismo color variando la luminosidad (HSL),
  /// en lugar de la opacidad, para que el contraste no dependa del fondo.
  static List<Color> monochromeShades(Color base, int count) {
    if (count <= 0) return const [];
    final hsl = HSLColor.fromColor(base);
    if (count == 1) return [base];
    const minLightness = 0.30;
    const maxLightness = 0.80;
    return List.generate(count, (i) {
      final t = i / (count - 1);
      return hsl
          .withLightness(maxLightness - (maxLightness - minLightness) * t)
          .toColor();
    });
  }
}
