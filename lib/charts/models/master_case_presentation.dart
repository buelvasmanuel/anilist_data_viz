// Etiquetas de la matriz 63x4 (clasificación de capacidad y estado) comunes
// a las cuatro galerías.

import 'package:flutter/material.dart';

import 'master_chart_registry.dart';

extension ChartLibraryLabel on ChartLibrary {
  String get label => switch (this) {
        ChartLibrary.flChart => 'FL Chart',
        ChartLibrary.syncfusion => 'Syncfusion',
        ChartLibrary.dChart => 'DChart',
        ChartLibrary.graphic => 'Graphic',
      };
}

extension ChartClassificationLabel on ChartClassification {
  String get label => switch (this) {
        ChartClassification.nativo => 'NATIVO',
        ChartClassification.variante => 'VARIANTE',
        ChartClassification.composicion => 'COMPOSICIÓN',
        ChartClassification.noSoportado => 'NO SOPORTADO',
      };

  Color get color => switch (this) {
        ChartClassification.nativo => Colors.green.shade700,
        ChartClassification.variante => Colors.blue.shade700,
        ChartClassification.composicion => Colors.orange.shade800,
        ChartClassification.noSoportado => Colors.grey.shade700,
      };
}

extension ChartStateLabel on ChartState {
  String get label => switch (this) {
        ChartState.funcional => 'FUNCIONAL',
        ChartState.parcial => 'PARCIAL',
        ChartState.demo => 'DEMO',
        ChartState.roto => 'ROTO',
        ChartState.noDisponible => 'NO DISPONIBLE',
        ChartState.noVerificado => 'NO VERIFICADO',
      };

  Color get color => switch (this) {
        ChartState.funcional => Colors.green.shade700,
        ChartState.parcial => Colors.amber.shade800,
        ChartState.demo => Colors.purple.shade400,
        ChartState.roto => Colors.red.shade700,
        ChartState.noDisponible => Colors.red.shade400,
        ChartState.noVerificado => Colors.grey.shade600,
      };
}

/// Etiqueta de color usada en las tarjetas de las galerías.
class MasterBadge extends StatelessWidget {
  const MasterBadge(this.text, this.color, {super.key});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}
