# Fase 2: Investigación de Syncfusion Flutter Charts

## 1. Versión Seleccionada
- **Librería**: `syncfusion_flutter_charts`
- **Versión**: `^34.2.9`
- **Compatibilidad verificada**: 
  - Flutter 3.47.5 (Sí)
  - Dart 3.13.4 (SDK mínimo requerido: 3.2.0, cumple)
  - Plataforma: Web, Android, iOS, Windows, macOS, Linux (Sí)
- **Licencia**: Comercial / Community License (requiere registro de clave en producción, pero es gratuita para uso de comunidad).
- **Instalación**: `flutter pub add syncfusion_flutter_charts` (Aún no ejecutada, pendiente de finalizar esta matriz).

## 2. Familias de Gráficos y Widgets Reales
A diferencia de FL Chart, Syncfusion separa fuertemente la estructura. No se usa un `BarChart` genérico para barras verticales y horizontales.

### Cartesianas (`SfCartesianChart`)
- **ColumnSeries**: Barras verticales.
- **BarSeries**: Barras horizontales (rotadas).
- **LineSeries**: Líneas rectas.
- **SplineSeries**: Líneas suavizadas (curvas).
- **AreaSeries** / **SplineAreaSeries**: Áreas bajo la curva.
- **ScatterSeries**: Dispersión.
- **HistogramSeries**: Histograma automático (o manual).
- **StackedColumnSeries** / **StackedBarSeries**: Barras apiladas.

### Circulares (`SfCircularChart`)
- **PieSeries**: Torta tradicional.
- **DoughnutSeries**: Dona.
- **RadialBarSeries**: Ideal para barras de progreso circulares (Gauge/Medidor).

### Funcionalidades Integradas Nativas
- **Tooltips**: `TooltipBehavior` a nivel de gráfico.
- **Zoom/Pan**: `ZoomPanBehavior(enablePanning: true)`.
- **Labels (Etiquetas Superiores)**: `DataLabelSettings(isVisible: true)` (soluciona el caso 40 de manera 100% nativa).
- **Anotaciones**: `annotations: <CartesianChartAnnotation>[]` o `CircularChartAnnotation` para colocar widgets en medio (como en Donut + KPI).
- **Exportación**: Syncfusion puede capturar y exportar como imagen o PDF con otros paquetes, pero usar `RepaintBoundary` de Flutter sigue siendo la forma más universal y sin dependencias extra para Web.
- **Interacción / Selección**: `SelectionBehavior(enable: true, unselectedOpacity: 0.5)` (resuelve el caso 54 nativamente).

## 3. Matriz Syncfusion 1–63

*LISTA_CANDIDATA_63 = lista provisional de trabajo; no se afirma que sea la lista oficial del profesor.*

| # | Nombre | Tipo | Familia Syncfusion | Widget/Clase Real | NATIVO / COMPOSICIÓN | Transformación |
|---|---|---|---|---|---|---|
| 1 | Barra Vertical Ordinal Estándar | Básica | Cartesiana | `ColumnSeries` | NATIVO | T1 |
| 2 | Barra Horizontal Ordinal | Básica | Cartesiana | `BarSeries` | NATIVO | T1 |
| 3 | Barra Numérica (Eje Continuo) | Básica | Cartesiana | `ColumnSeries` (Eje numérico) | NATIVO | N2 |
| 4 | Barra Temporal Simple | Básica | Cartesiana | `ColumnSeries` (Eje temporal/numérico) | NATIVO | N1 |
| 5 | Barra Personalizada Ligera | Básica | Cartesiana | `ColumnSeries` con `borderWidth`, `width` | NATIVO | T1 |
| 6 | Barras Color Estático Único | Básica | Cartesiana | `ColumnSeries(color: ...)` | NATIVO | T1 |
| 7 | Barras Color por Categoría | Básica | Cartesiana | `ColumnSeries(pointColorMapper: ...)` | NATIVO | T1 |
| 8 | Barras Esquinas Redondeadas | Básica | Cartesiana | `ColumnSeries(borderRadius: ...)` | NATIVO | T1 |
| 9 | Barras sin Ejes (Sparkline) | Básica | Cartesiana | `ColumnSeries` + ejes ocultos | NATIVO | N1 |
| 10| Barras Línea Base Cero | Básica | Cartesiana | `ColumnSeries` + eje cruzando en 0 | NATIVO | N3 |
| 11| Barras Valores Negativos | Básica | Cartesiana | `BarSeries` + `pointColorMapper` condicional| NATIVO | N3b |
| 12| Línea Numérica Simple | Básica | Cartesiana | `LineSeries` | NATIVO | N2 |
| 13| Línea Temporal Básica | Básica | Cartesiana | `LineSeries` | NATIVO | T2 |
| 14| Línea Puntos Marcadores | Básica | Cartesiana | `LineSeries(markerSettings: ...)` | NATIVO | T2 |
| 15| Área Bajo la Curva Simple | Básica | Cartesiana | `AreaSeries` | NATIVO | T2 |
| 16| Línea Minimalista | Básica | Cartesiana | `LineSeries` + ocultar ejes | NATIVO | T2 |
| 17| Torta Estándar Ordinal | Básica | Circular | `PieSeries` | NATIVO | N4 |
| 18| Torta Datos Numéricos | Básica | Circular | `PieSeries` | NATIVO | N2 |
| 19| Dona Clásica | Básica | Circular | `DoughnutSeries` | NATIVO | N4 |
| 20| Dona Anillo Delgado | Básica | Circular | `DoughnutSeries(innerRadius: '80%')` | NATIVO | N4 |
| 21| Torta Monocromática | Básica | Circular | `PieSeries(pointColorMapper: ...)` | NATIVO | N4 |
| 22| Gauge Base Semicircular | Básica | Circular | `RadialBarSeries(startAngle: 180, endAngle: 0)` | NATIVO (Variante) | N7 |
| 23| Barras con Espaciado | Básica | Cartesiana | `ColumnSeries(spacing: ...)` | NATIVO | T1 |
| 24| Barras Cuadrícula Activa | Básica | Cartesiana | `majorGridLines` en Y axis | NATIVO | T1 |
| 25| Barras sin Animación | Básica | Cartesiana | `ColumnSeries(animationDuration: 0)` | NATIVO | T1 |
| 26| Línea sin Animación | Básica | Cartesiana | `LineSeries(animationDuration: 0)` | NATIVO | T2 |
| 27| Torta sin Animación | Básica | Circular | `PieSeries(animationDuration: 0)` | NATIVO | N4 |
| 28| Barra de Progreso KPI | Básica | Cartesiana | `StackedBarSeries` 100% | NATIVO | N7 |
| 29| Torta Borde Separación | Básica | Circular | `PieSeries(explode: true/strokeWidth)` | NATIVO | N4 |
| 30| Comparativa Binaria | Básica | Cartesiana | `ColumnSeries` (2 categorías) | NATIVO | N4 |
| 31| Tarjeta de Resumen | Básica | Composición| `LineSeries` dentro de `Card` | COMPOSICIÓN | N7 + N1 |
| 32| Barras Agrupadas Multiserie | Avanzada| Cartesiana | Varias `ColumnSeries` | NATIVO | N5 |
| 33| Barras Apiladas | Avanzada| Cartesiana | Varias `StackedColumnSeries` | NATIVO | N5 |
| 34| Líneas Multiserie Comparativas | Avanzada| Cartesiana | Varias `LineSeries` | NATIVO | N10 |
| 35| Línea Relleno Semitransparente | Avanzada| Cartesiana | `AreaSeries(color: color.withOpacity)` | NATIVO | T2 |
| 36| Donut Widget Central | Avanzada| Circular | `DoughnutSeries` + `CircularChartAnnotation` | NATIVO | N4 + total |
| 37| Donut Etiquetas Externas | Avanzada| Circular | `DoughnutSeries(labelPosition: outside)` | NATIVO | N4 |
| 38| Donut Etiquetas Internas | Avanzada| Circular | `DoughnutSeries(labelPosition: inside)` | NATIVO | N4 |
| 39| Serie Temporal Multivariable | Avanzada| Cartesiana | 2 `LineSeries` con 2 `NumericAxis` (eje doble) | NATIVO | N9 |
| 40| Barras Etiquetas Numéricas | Avanzada| Cartesiana | `DataLabelSettings(isVisible: true)` | NATIVO | T1 |
| 41| Líneas Ejes Rotados | Avanzada| Cartesiana | `LineSeries` transpuesta (isTransposed: true)| NATIVO | T2 |
| 42| Barras Línea de Meta | Avanzada| Cartesiana | `PlotBand` o `LineSeries` combinada | NATIVO | T1 |
| 43| Barras Panning Horizontal | Avanzada| Cartesiana | `ZoomPanBehavior(enablePanning: true)` | NATIVO | T1 |
| 44| Gráfica Reactiva Tiempo Real | Avanzada| Cartesiana | `LineSeries` (StreamBuilder simulado) | COMPOSICIÓN | T2 |
| 45| Medidor Gauge 3 Segmentos | Avanzada| Circular | `DoughnutSeries(startAngle/endAngle: 180/0)` | NATIVO | N4 |
| 46| Líneas Selección Punto | Avanzada| Cartesiana | `SelectionBehavior` en `LineSeries` | NATIVO | T2 |
| 47| Barras Rango Y Forzado | Avanzada| Cartesiana | `NumericAxis(minimum: 0, maximum: 100)` | NATIVO | T1 |
| 48| Barras Horizontales Multiserie| Avanzada| Cartesiana | `BarSeries` múltiples | NATIVO | N5 |
| 49| Formato Monetario Eje Y | Avanzada| Cartesiana | `NumericAxis(numberFormat: ...)` | NATIVO | T1 (Adaptado)|
| 50| Formato Fecha Personalizado | Avanzada| Cartesiana | `DateTimeAxis` o labelFormatter | NATIVO | N6 |
| 51| Barras Gradiente Vertical | Avanzada| Cartesiana | `ColumnSeries(gradient: ...)` | NATIVO | T1 |
| 52| Gráfica Filtrable | Avanzada| Cartesiana | Filtro Flutter + `ColumnSeries` | COMPOSICIÓN | T1 |
| 53| Líneas Suavizadas (Spline) | Avanzada| Cartesiana | `SplineSeries` | NATIVO | T2 |
| 54| Dona Porción Resaltada | Avanzada| Circular | `SelectionBehavior(enable: true)` | NATIVO | N4 |
| 55| Distribución Frecuencias | Avanzada| Cartesiana | `HistogramSeries` o `ColumnSeries` pegadas| NATIVO | N2 |
| 56| Tendencia y Dispersión | Avanzada| Cartesiana | `ScatterSeries` + `LineSeries` superpuesta | NATIVO | N8 |
| 57| Tarjeta Dashboard KPI | Avanzada| Composición| Flutter Card + `LineSeries` minimalista | COMPOSICIÓN | N7 + N1 |
| 58| Exportable a Imagen | Avanzada| Composición| `RepaintBoundary` Flutter | COMPOSICIÓN | T1 (Limitación Web)|
| 59| Donut Multianillo | Avanzada| Circular | 2 `DoughnutSeries` con distintos radios | NATIVO | N4 |
| 60| Barras Cuadrícula Secundaria | Avanzada| Cartesiana | `minorGridLines` en Ejes | NATIVO | T1 |
| 61| Progreso Multinivel | Avanzada| Cartesiana | `StackedBarSeries` 100% horizontal | NATIVO | N7 |
| 62| Fondo Área Condicional | Avanzada| Cartesiana | `AreaSeries` con clip o `SplineRangeAreaSeries`| NATIVO | T2 |
| 63| Dashboard Sincronizado | Avanzada| Composición| `Column` con 2 gráficas | COMPOSICIÓN | T2 + T1 |

**Nota sobre adaptaciones:**
- "Radar", si bien existía como sugerencia, no está soportado nativamente en `syncfusion_flutter_charts`. No se instalarán librerías de terceros (se adaptará mediante otras visualizaciones o composiciones si el usuario lo solicita, o se asume descartado como en FL Chart).
- No hay websockets reales, se simulará reactividad en el caso 44 (como en FL Chart).
- No hay ingresos reales, se formateará moneda usando métricas normales en el caso 49 (como en FL Chart).
