# Implementación de Syncfusion Flutter Charts (Fase 2)

## 1. Arquitectura y Enfoque
Para cumplir con la directiva de no tocar ni borrar la implementación de FL Chart, se creó un directorio dedicado `lib/charts/syncfusion/` que contiene un conjunto de wrappers reutilizables nativos de Syncfusion.

Se crearon los siguientes archivos:
- `syncfusion_bar_charts.dart`: Wrapper `SyncfusionBasicBarChart` con `ColumnSeries` y `BarSeries`.
- `syncfusion_line_charts.dart`: Wrapper `SyncfusionBasicLineChart` con `LineSeries`, `SplineSeries`, `AreaSeries`, y `SplineAreaSeries`.
- `syncfusion_pie_charts.dart`: Wrapper `SyncfusionBasicPieChart` con `PieSeries` y `DoughnutSeries`.
- `syncfusion_multi_bar_charts.dart`: Wrapper `SyncfusionMultiSeriesBarChart` con `StackedColumnSeries`, etc.
- `syncfusion_multi_line_charts.dart`: Wrapper `SyncfusionMultiLineChart`.
- `syncfusion_progress_charts.dart`: Wrapper `SyncfusionProgressBarChart` (Case 28 y 61).
- `syncfusion_gauge_charts.dart`: Wrapper `SyncfusionSemiCircleGauge` con `RadialBarSeries` (Case 22, 45).
- `syncfusion_scatter_trend_charts.dart`: Wrapper `SyncfusionScatterTrendChart` con `ScatterSeries` + `LineSeries`.
- `syncfusion_summary_cards.dart`: Wrapper `SyncfusionCompactSummaryCard`.

Se clonó `charts_gallery_screen.dart` hacia `syncfusion_charts_gallery_screen.dart`, donde se reemplazaron todos los widgets antiguos de FL Chart por sus contrapartes en Syncfusion. En la pantalla principal (`home_screen.dart`), se agregó un botón para ingresar a la galería de Syncfusion.

## 2. Auditoría de los 63 Casos

Los 63 casos han sido recreados utilizando la nueva librería.

**Casos Destacados donde Syncfusion supera a FL Chart (100% Nativo):**
- **Caso 40 (Etiquetas Numéricas Superiores):** Resuelto usando `DataLabelSettings(isVisible: true)`, sin usar plugins de texto libre.
- **Caso 54 (Porción Resaltada):** Resuelto nativamente mediante `SelectionBehavior(enable: true)` en `DoughnutSeries`.
- **Caso 36 (Donut + KPI):** Resuelto con `CircularChartAnnotation`, sin usar `Stack`.
- **Caso 56 (Tendencia y Dispersión):** Resuelto de manera mucho más natural usando series múltiples (`ScatterSeries` y `LineSeries`) en un mismo `SfCartesianChart`.

## 3. Limitaciones / Disclaimers
1. **Limitaciones Web para Exportación (Caso 58):** Si bien Syncfusion posee un método de exportación de imagen nativo, hemos seguido utilizando `RepaintBoundary` porque es consistente con el resto de la App.
2. **Caso 44 (Reactivo):** Como no tenemos una API real de Websockets de AniList para actualizaciones constantes, sigue usando un `StreamBuilder` simulado cada 2 segundos para efectos de la demo.
3. **Caso 49 (Formato Monetario):** AniList no devuelve valores financieros (ventas en dólares). Se usó un formato de "precio simulado" con base en la cuenta o puntaje de favoritos, sin alterar el backend, aplicando el formato en la vista.

## 4. Estado de QA
- `flutter analyze`: Pasa exitosamente (0 warnings).
- `flutter test`: Todos los tests pasan correctamente, confirmando que la lógica base no fue dañada.
- **Datos Reales**: Se continúan usando los objetos `ChartDataCategory` y `ChartDataXY` traídos del backend de AniList GraphQL sin alterar el dominio.

## Conclusión
La migración y duplicación de la galería en Syncfusion Flutter Charts se completó de manera aislada, reutilizando los modelos existentes y los transformadores de negocio con cero impacto en la arquitectura de datos existente.
