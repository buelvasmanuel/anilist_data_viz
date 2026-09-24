abstract class ChartData {}

class ChartDataCategory extends ChartData {
  final String category;
  final num value;
  final String? color;

  ChartDataCategory({
    required this.category,
    required this.value,
    this.color,
  });
}

class ChartDataXY extends ChartData {
  final num x;
  final num y;
  final String? label;

  ChartDataXY({
    required this.x,
    required this.y,
    this.label,
  });
}

class ChartSeries<T extends ChartData> {
  final String seriesName;
  final List<T> data;

  ChartSeries({
    required this.seriesName,
    required this.data,
  });
}

class ChartDataMatrix extends ChartData {
  final String row;
  final String column;
  final num value;

  ChartDataMatrix({
    required this.row,
    required this.column,
    required this.value,
  });
}

class ChartDataHierarchy extends ChartData {
  final String id;
  final String label;
  final String? parentId;
  final num? value;

  ChartDataHierarchy({
    required this.id,
    required this.label,
    this.parentId,
    this.value,
  });
}

class ChartDataRange extends ChartData {
  final String category;
  final num min;
  final num max;
  final num? q1;
  final num? median;
  final num? q3;

  ChartDataRange({
    required this.category,
    required this.min,
    required this.max,
    this.q1,
    this.median,
    this.q3,
  });
}

/// Resumen agregado de la muestra cargada (N7). Todos los valores se
/// calculan a partir de los datos recibidos de AniList; si un valor no puede
/// calcularse (p. ej. ninguna obra tiene score) queda en `null`.
class ChartDataSummary extends ChartData {
  /// Número total de obras en la muestra.
  final int totalMedia;

  /// Obras con `averageScore` informado.
  final int scoredMedia;

  /// Media de `averageScore` (0–100) de las obras con score.
  final double? meanAverageScore;

  /// Obras con estado `FINISHED`.
  final int finishedCount;

  /// Obras con `status` informado.
  final int withStatusCount;

  /// Porcentaje (0–100) de obras `FINISHED` sobre las que tienen estado.
  final double? finishedPercent;

  ChartDataSummary({
    required this.totalMedia,
    required this.scoredMedia,
    required this.meanAverageScore,
    required this.finishedCount,
    required this.withStatusCount,
    required this.finishedPercent,
  });
}
