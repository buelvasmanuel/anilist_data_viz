import 'package:flutter/material.dart';

/// Tarjeta de resumen compacta. COMPOSICIÓN propia del proyecto:
/// `Card` + textos KPI (Flutter) + un gráfico FL Chart existente pasado en
/// [chart] (p. ej. un `BasicLineChart` minimalista como sparkline).
class CompactSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? caption;
  final Widget chart;
  final double chartHeight;

  const CompactSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.chart,
    this.caption,
    this.chartHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (caption != null)
              Text(caption!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            SizedBox(height: chartHeight, child: chart),
          ],
        ),
      ),
    );
  }
}
