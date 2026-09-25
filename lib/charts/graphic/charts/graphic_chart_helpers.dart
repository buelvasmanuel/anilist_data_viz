// Helpers compartidos por los archivos de gráficas.

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_view_models.dart';

/// Variables estándar para [GCategory]: 'x' (categoría) e 'y' (valor).
///
/// Los tipos genéricos son explícitos a propósito: `Variable.scale` es
/// `Scale<V, num>`, y si Dart infiriera `V = double` una `LinearScale`
/// dejaría de encajar.
Map<String, Variable<GCategory, dynamic>> categoryVars({LinearScale? yScale}) => {
      'x': Variable<GCategory, String>(accessor: (d) => d.label),
      'y': Variable<GCategory, num>(
        accessor: (d) => d.value,
        scale: yScale ?? LinearScale(min: 0),
      ),
    };

/// Variables estándar para [GSeriesPoint]: 'x', 'value', 'series'.
Map<String, Variable<GSeriesPoint, dynamic>> seriesVars({LinearScale? valueScale}) => {
      'x': Variable<GSeriesPoint, String>(accessor: (d) => d.x),
      'value': Variable<GSeriesPoint, num>(
        accessor: (d) => d.value,
        scale: valueScale ?? LinearScale(min: 0),
      ),
      'series': Variable<GSeriesPoint, String>(accessor: (d) => d.series),
    };

/// Variables estándar para [GRange]: 'x', 'low', 'high' con LA MISMA escala.
Map<String, Variable<GRange, dynamic>> rangeVars(List<GRange> data) {
  final s = sharedScale([for (final r in data) ...[r.low, r.high]]);
  return {
    'x': Variable<GRange, String>(accessor: (d) => d.x),
    'low': Variable<GRange, num>(accessor: (d) => d.low, scale: s),
    'high': Variable<GRange, num>(accessor: (d) => d.high, scale: s),
  };
}

/// Escala lineal compartida para variables de la misma dimensión
/// (rangos, velas, cajas, bandas, waterfall).
///
/// Evita `min == max`, que produce una escala degenerada.
LinearScale sharedScale(Iterable<num> values, {num padding = 0}) {
  if (values.isEmpty) return LinearScale(min: 0, max: 1);
  var lo = values.reduce((a, b) => a < b ? a : b) - padding;
  var hi = values.reduce((a, b) => a > b ? a : b) + padding;
  if (lo == hi) {
    lo -= 1;
    hi += 1;
  }
  return LinearScale(min: lo, max: hi);
}

/// Series únicas en el orden en que aparecen.
List<String> seriesNames(List<GSeriesPoint> data) =>
    [for (final s in {for (final p in data) p.series}) s];

/// Devuelve el gráfico o un estado vacío si no hay datos suficientes.
Widget guard(bool hasData, Widget Function() build,
        {String message = 'Sin datos suficientes en el dataset actual'}) =>
    hasData ? build() : GraphicEmptyState(message);

/// Selección y tooltip básicos por eje X (táctil y ratón).
Map<String, Selection> xSelection({String? variable}) => {
      'sel': PointSelection(
        on: {GestureType.tapDown, GestureType.hover, GestureType.longPressMoveUpdate},
        dim: Dim.x,
        variable: variable,
      ),
    };
