# Syncfusion Flutter Charts en AniList Data Viz — Matriz 63×4

> Documento orientado al proyecto. Capacidad y estado salen de `master_chart_registry.dart`; estrategia, API y origen de datos salen de `CaseImpl` (el código). Las tablas se generan desde el código, no a mano.

## 1. Introducción

Syncfusion Flutter Charts es una librería comercial con licencia comunitaria gratuita (en producción requiere registrar la licencia). Su enfoque es **por series**: un contenedor (`SfCartesianChart`, `SfCircularChart`, `SfPyramidChart`, `SfFunnelChart`, sparklines) recibe series (`LineSeries`, `CandleSeries`…), indicadores, *behaviors* (zoom, crosshair, trackball) y anotaciones. Es la librería con más casos nativos.

## 2. Versión utilizada

- `syncfusion_flutter_charts: 34.2.9` y `syncfusion_flutter_core 34.2.9` (`pubspec.lock`).

## 3. Instalación

```bash
flutter pub add syncfusion_flutter_charts:34.2.9
```

```dart
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
```

## 4. Arquitectura utilizada en el proyecto

```text
AniList GraphQL
  → AniListRemoteDataSource            getMediaList · getMediaTrends · getMediaSnapshots
  → AniListRepositoryImpl              (traduce excepciones a Failure)
  → Media / MediaTrend (dominio)
  → ChartsDatasetProvider              muestra fija + Media.trends
    AniListLiveProvider                #52 paginación · #63 sondeo
  → GraphicDataset + GraphicTransformations   dataset común precalculado
  → CaseImpl por librería (63 × 4)     lib/charts/*/…_case_builders.dart, graphic_cases.dart
  → MasterCaseGallery                  galería común con filtros
```

- **Fuente de verdad de la matriz:** `lib/charts/models/master_chart_registry.dart` (capacidad y estado por caso y librería).
- **Implementación:** cada librería expone un `Map<int, CaseImpl>` con los 63 casos (`flChartCases`, `syncfusionCases`, `dChartCases`, `graphicCases`), reunidos en `lib/charts/common/library_cases.dart`. `CaseImpl` guarda la estrategia de implementación, el origen de datos, la API usada, una nota opcional y el builder.
- **Dataset común:** `GraphicDataset` nació para Graphic, pero es Dart puro y ya contenía casi todas las series de los 63 casos. Ahora lo usan las cuatro librerías, de modo que **cada caso muestra los mismos datos en las cuatro** y la comparación es directa. Se construye una sola vez en el provider; los widgets no calculan estadística.
- **Galería común:** `lib/charts/common/master_case_gallery.dart`. Filtros por implementación (Todas, Nativo, Variante, Composición, Adaptación) y por categoría (Básicos, Apilados / Rangos, Interacción, Escalas, Estadísticos, Especiales). Cada tarjeta muestra número, nombre maestro, capacidad, implementación, estado, categoría, origen de datos, API, nota y el gráfico.
- **Casos vivos:** `lib/charts/common/live_case_hosts.dart` (`LazyLoadingHost`, `LiveStreamingHost`). Cada librería solo aporta la función que dibuja.

Archivos de Syncfusion:

- `lib/charts/syncfusion/syncfusion_case_builders.dart` — `syncfusionCases`: los 63 casos, con contenedores comunes (`_cartesian`, `_multi`, `_indicatorChart`…).
- `lib/presentation/screens/syncfusion_charts_gallery_screen.dart` — galería.

## 5. Datos provenientes de AniList

La app usa datos **reales** de AniList (API GraphQL pública), pero **no toda la base**:

1. **Muestra principal.** `ChartsDatasetProvider` descarga 4 páginas × 50 obras del tipo elegido (Anime o Manga), ordenadas por `POPULARITY_DESC`: las **200 obras más populares**. Todas las estadísticas describen solo esta muestra.
2. **Serie temporal `Media.trends`.** Para la obra más popular de la muestra se piden 4 páginas × 25 días (AniList limita este campo a 25 nodos por página) → unos **100 días** de `popularity`. Esa `popularity` es un **acumulado** de usuarios que tienen la obra en su lista y casi nunca baja; con ella el RSI quedaría fijo en 100 y todas las velas saldrían alcistas. Por eso la serie base de #32, #33 y #41–#44 es la **variación neta diaria**: `(pop[día] − pop[día anterior]) / días transcurridos`. Es una transformación determinista de datos reales.
3. **Rankings.** El fragmento GraphQL ahora pide `rankings { rank type allTime }`. Se usa el puesto *highest rated all time* (#62).
4. **Paginación bajo demanda (#52).** `AniListLiveProvider.loadNextPage()` pide a AniList la página siguiente (`Page(page, perPage: 20)`) cuando el usuario llega al final del scroll.
5. **Sondeo periódico (#63).** Mientras la tarjeta #63 está visible, un `Timer` consulta cada 30 s la `popularity` actual de las 5 obras más populares (consulta ligera `Page(media(id_in: …))`), la compara con la lectura anterior y notifica a la UI.

**Lo que AniList no tiene y no se inventa:** precios, ingresos, cotizaciones, OHLC financiero, WebSocket/push. No se usa `Random` ni listas fijas para rellenar gráficos. Las velas y los indicadores técnicos son **adaptaciones sobre popularidad**, y así se indica en cada tarjeta.

**Límites honestos:** AniList actualiza `popularity` por lotes, así que en #63 es normal ver varias lecturas seguidas con Δ = 0; la UI lo muestra tal cual. La API tiene límite de peticiones por minuto: al alternar Anime/Manga muchas veces seguidas puede responder "Too Many Requests"; entonces la tarjeta afectada muestra el error técnico hasta el siguiente intento.

## 6. Transformaciones utilizadas

| Transformación | Dónde | Uso |
|---|---|---|
| Conteos, medias y rangos por año, formato, estado y género | `GraphicDataset.fromAnime` | Básicos, apilados, rangos |
| `histogramBins`, `cumulative`, `waterfall` | `GraphicTransformations` | #16, #12–#13, #28 |
| `fiveNumberSummary`, `meanStd`, `linearRegression` | `GraphicTransformations` | #34, #35, #45 |
| `dailyGains` (variación neta diaria de `trends.popularity`) | `GraphicTransformations` | base de #32, #33, #41–#44 |
| `ohlc` (ventanas de 7 días: open, high, low, close) | `GraphicTransformations` | #32, #33 |
| `sma`, `bollinger`, `rsi` (Wilder), `ema`, `macd` | `GraphicTransformations` | #41–#44 |
| `winLoss`, `alignSeries` | `GraphicTransformations` | #57, multiserie |
| `toPercent`, `toStackedCumulative`, `toCategories`, `toXY` | `lib/charts/common/case_support.dart` | 100 % y apilados dibujados a mano, adaptadores a los Chart Models |

`DataTransformations` (T1, T2, N1–N10) sigue en el proyecto y lo usan los wrappers heredados y sus tests, pero las galerías 63×4 leen del dataset común.

## 7. Capacidades nativas de la librería

Verificadas en el código del paquete y usadas en el proyecto:

- **Series cartesianas:** `LineSeries`, `SplineSeries`, `StepLineSeries`, `AreaSeries`, `SplineAreaSeries`, `StepAreaSeries`, `ColumnSeries`, `BarSeries`, `ScatterSeries`, `BubbleSeries`, `HistogramSeries`, `Stacked*Series` y `Stacked*100Series`, `RangeColumnSeries`, `RangeAreaSeries`, `SplineRangeAreaSeries`, `WaterfallSeries`, `BoxAndWhiskerSeries`, `ErrorBarSeries`, `CandleSeries`, `HiloOpenCloseSeries`.
- **Circulares y embudos:** `PieSeries`, `DoughnutSeries`, `RadialBarSeries`, `SfPyramidChart`, `SfFunnelChart`.
- **Indicadores:** `SmaIndicator`, `BollingerBandIndicator`, `RsiIndicator`, `MacdIndicator`; `Trendline`.
- **Ejes:** `CategoryAxis`, `NumericAxis`, `DateTimeAxis`, `DateTimeCategoryAxis`, `LogarithmicAxis`, ejes múltiples, `isInversed`, `opposedPosition`, `PlotBand`.
- **Interacción:** `ZoomPanBehavior`, `CrosshairBehavior`, `TrackballBehavior`, `TooltipBehavior.builder`, `onPointTap`.
- **Otros:** `CartesianChartAnnotation`, `CircularChartAnnotation`, `onCreateShader`, `ChartSeriesController.updateDataSource`, sparklines (`SfSparkLineChart`, `SfSparkAreaChart`, `SfSparkWinLossChart`).

## 8. Limitaciones

- Licencia comercial/comunitaria: revisar condiciones antes de publicar.
- `SfRangeSelector` pertenece a `syncfusion_flutter_sliders`, que no está instalado: #55 usa `RangeSlider` de Flutter (COMPOSICIÓN).
- `ErrorBarSeries` aplica un único error por serie; #35 usa una serie por género para mostrar la σ de cada uno.
- #52 usa el host común de paginación (scroll de Flutter) en lugar de `loadMoreIndicatorBuilder`, para que las cuatro librerías compartan el mismo mecanismo de carga.
- Paquete pesado: aumenta el tamaño del build web.

## 9. Tabla completa de los 63 casos

### Cómo leer la tabla

- **Clasificación (capacidad):** lo que ofrece la librería para ese caso, según la matriz `masterChartRegistry`. NATIVO = widget/serie propio; VARIANTE = configuración de un gráfico nativo o datos preparados antes; COMPOSICIÓN = librería + widgets/estado de Flutter; NO SOPORTADO = la librería no tiene un constructo para el caso.
- **Implementación actual:** cómo lo dibuja *este proyecto*. Además de las tres anteriores aparece **ADAPTACIÓN**: una representación visual equivalente construida con otro gráfico de la librería o sobre datos adaptados (por ejemplo, velas sobre popularidad). Que un caso esté implementado como ADAPTACIÓN o COMPOSICIÓN **no** significa que la librería lo tenga como widget nativo.
- **Estado:** FUNCIONAL = el caso se dibuja completo con datos reales; PARCIAL = se dibuja con datos reales pero cubre el caso solo en parte (se explica en Observaciones).
- **Widget/API** y **Datos AniList** se exportan del código (`CaseImpl.api` y `CaseImpl.origin`), no se escriben a mano.

### Resumen

- Clasificación de capacidad (matriz) → NATIVO: **61** · VARIANTE: **0** · COMPOSICIÓN: **2** · NO SOPORTADO: **0**
- Implementación en el proyecto → NATIVO: **54** · VARIANTE: **3** · COMPOSICIÓN: **4** · ADAPTACIÓN: **2**
- Estado → FUNCIONAL: **63** · PARCIAL: **0** · DEMO: **0** · ROTO: **0** · NO DISPONIBLE: **0** · NO VERIFICADO: **0**
- Casos con visualización real en la galería: **63/63**

| # | Caso maestro | Clasificación (capacidad) | Estado | Widget/API | Implementación actual | Datos AniList | Observaciones |
|---:|---|---|---|---|---|---|---|
| 1 | Línea Simple | NATIVO | FUNCIONAL | `SfCartesianChart + LineSeries` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 2 | Columna Vertical | NATIVO | FUNCIONAL | `ColumnSeries` | NATIVO | DIRECTO: popularity de las 10 obras más populares |  |
| 3 | Barra Horizontal | NATIVO | FUNCIONAL | `BarSeries` | NATIVO | DIRECTO: averageScore de las 10 obras mejor puntuadas |  |
| 4 | Línea Curva / Spline | NATIVO | FUNCIONAL | `SplineSeries` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 5 | Área | NATIVO | FUNCIONAL | `AreaSeries` | NATIVO | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 6 | Spline Area | NATIVO | FUNCIONAL | `SplineAreaSeries` | NATIVO | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 7 | Pie | NATIVO | FUNCIONAL | `SfCircularChart + PieSeries` | NATIVO | DERIVADO: obras por format |  |
| 8 | Doughnut | NATIVO | FUNCIONAL | `DoughnutSeries` | NATIVO | DERIVADO: obras por status |  |
| 9 | Radial Bar | NATIVO | FUNCIONAL | `RadialBarSeries` | NATIVO | DIRECTO: averageScore de las 5 obras mejor puntuadas |  |
| 10 | Scatter | NATIVO | FUNCIONAL | `ScatterSeries` | NATIVO | DIRECTO: popularity × averageScore de cada obra puntuada |  |
| 11 | Bubble | NATIVO | FUNCIONAL | `BubbleSeries (sizeValueMapper)` | NATIVO | DIRECTO: popularity × averageScore; tamaño = episodes | Tamaño = episodes (anime) o chapters (manga). |
| 12 | Step Line | NATIVO | FUNCIONAL | `StepLineSeries` | NATIVO | DERIVADO: obras acumuladas por año de inicio |  |
| 13 | Step Area | NATIVO | FUNCIONAL | `StepAreaSeries` | NATIVO | DERIVADO: obras acumuladas por año de inicio |  |
| 14 | Pyramid | NATIVO | FUNCIONAL | `SfPyramidChart + PyramidSeries` | NATIVO | DERIVADO: obras por format, ordenado |  |
| 15 | Funnel | NATIVO | FUNCIONAL | `SfFunnelChart + FunnelSeries` | NATIVO | DERIVADO: obras por status, ordenado |  |
| 16 | Histogram | NATIVO | FUNCIONAL | `HistogramSeries (binInterval 10)` | NATIVO | DERIVADO: bins de 10 puntos de averageScore |  |
| 17 | Stacked Column | NATIVO | FUNCIONAL | `StackedColumnSeries` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 18 | Stacked Bar | NATIVO | FUNCIONAL | `StackedBarSeries` | NATIVO | DERIVADO: obras por género × status (5 géneros más frecuentes) |  |
| 19 | Stacked Area | NATIVO | FUNCIONAL | `StackedAreaSeries` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 20 | Stacked Line | NATIVO | FUNCIONAL | `StackedLineSeries` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 21 | 100% Stacked Column | NATIVO | FUNCIONAL | `StackedColumn100Series` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 22 | 100% Stacked Bar | NATIVO | FUNCIONAL | `StackedBar100Series` | NATIVO | DERIVADO: obras por género × status (5 géneros más frecuentes), normalizado a 100 % |  |
| 23 | 100% Stacked Area | NATIVO | FUNCIONAL | `StackedArea100Series` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 24 | 100% Stacked Line | NATIVO | FUNCIONAL | `StackedLine100Series` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 25 | Range Column | NATIVO | FUNCIONAL | `RangeColumnSeries` | NATIVO | DIRECTO: startDate.year – endDate.year de las obras más populares |  |
| 26 | Range Area | NATIVO | FUNCIONAL | `RangeAreaSeries` | NATIVO | DERIVADO: averageScore mínimo y máximo por año |  |
| 27 | Spline Range Area | NATIVO | FUNCIONAL | `SplineRangeAreaSeries` | NATIVO | DERIVADO: averageScore mínimo y máximo por año |  |
| 28 | Waterfall | NATIVO | FUNCIONAL | `WaterfallSeries (totalSumPredicate)` | NATIVO | DERIVADO: variación de obras de un año al siguiente (cascada) |  |
| 29 | Line with markers | NATIVO | FUNCIONAL | `LineSeries + MarkerSettings` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 30 | Diverging Bar | NATIVO | FUNCIONAL | `BarSeries + pointColorMapper` | NATIVO | DERIVADO: averageScore medio del género − media de la muestra |  |
| 31 | Sparkline Line | NATIVO | FUNCIONAL | `SfSparkLineChart` | NATIVO | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 32 | Candlestick | NATIVO | FUNCIONAL | `CandleSeries` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera. Cada vela = 7 días de la variación diaria de popularidad (open = primer día, high = máximo, low = mínimo, close = último día). |
| 33 | HLOC | NATIVO | FUNCIONAL | `HiloOpenCloseSeries` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | HLOC adaptado a tendencia de popularidad AniList (misma agrupación semanal que #32). No representa cotización financiera. |
| 34 | Box and Whisker | NATIVO | FUNCIONAL | `BoxAndWhiskerSeries` | NATIVO | DERIVADO: cuartiles de averageScore por format |  |
| 35 | Error Bars | NATIVO | FUNCIONAL | `ColumnSeries + un ErrorBarSeries (custom) por género` | VARIANTE | DERIVADO: media ± desviación estándar de averageScore por género | ErrorBarSeries aplica un error por serie; se usa una serie por género para mostrar su σ. |
| 36 | Combined Column + Line | NATIVO | FUNCIONAL | `ColumnSeries + LineSeries con eje secundario` | NATIVO | DERIVADO: obras por año (columnas) + averageScore medio por año (línea) |  |
| 37 | Dual Y Axis | NATIVO | FUNCIONAL | `axes: NumericAxis(opposedPosition) + yAxisName` | NATIVO | DIRECTO: popularity y averageScore de las 10 obras más populares |  |
| 38 | Pan & Zoom | NATIVO | FUNCIONAL | `ZoomPanBehavior (pinch, pan, rueda)` | NATIVO | DIRECTO: popularity de cada obra, ordenada por año de inicio | Pellizca, arrastra o usa la rueda del ratón. |
| 39 | Crosshair | NATIVO | FUNCIONAL | `CrosshairBehavior` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 40 | Trackball | NATIVO | FUNCIONAL | `TrackballBehavior (groupAllPoints)` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 41 | SMA | NATIVO | FUNCIONAL | `SmaIndicator (period 7)` | NATIVO | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → SMA de 7 días | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 42 | Bollinger Bands | NATIVO | FUNCIONAL | `BollingerBandIndicator (20, 2σ)` | NATIVO | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → bandas de Bollinger (20 días, ±2σ) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 43 | RSI | NATIVO | FUNCIONAL | `RsiIndicator (14) en eje secundario` | NATIVO | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → RSI de Wilder (14 días) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 44 | MACD | NATIVO | FUNCIONAL | `MacdIndicator (12, 26, 9) en eje secundario` | NATIVO | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → MACD (12, 26, 9) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 45 | Trendline Regression | NATIVO | FUNCIONAL | `ScatterSeries + Trendline(linear)` | NATIVO | DERIVADO: regresión lineal de averageScore sobre popularity |  |
| 46 | Plot Bands / Strip Lines | NATIVO | FUNCIONAL | `PlotBand (banda + línea en la media)` | NATIVO | DIRECTO: averageScore de las 10 más populares + media de la muestra |  |
| 47 | Cartesian Widget Annotations | NATIVO | FUNCIONAL | `CartesianChartAnnotation (widget en coordenadas de dato)` | NATIVO | DIRECTO: popularity de las 10 obras más populares |  |
| 48 | Multi-colored Line | NATIVO | FUNCIONAL | `LineSeries.pointColorMapper` | NATIVO | DERIVADO: averageScore medio por año comparado con la media de la muestra |  |
| 49 | Palette Gradient Series | NATIVO | FUNCIONAL | `ColumnSeries.gradient` | NATIVO | DIRECTO: averageScore de las 10 obras mejor puntuadas |  |
| 50 | Break / Gapless DateTime Axis | NATIVO | FUNCIONAL | `DateTimeCategoryAxis (fechas sin huecos)` | NATIVO | DERIVADO: obras por año de inicio con eje ordinal (sin huecos) |  |
| 51 | Logarithmic Scale | NATIVO | FUNCIONAL | `LogarithmicAxis` | NATIVO | DIRECTO: popularity de obras repartidas por toda la muestra (escala log10) |  |
| 52 | Infinite Scrolling / Lazy Loading | NATIVO | FUNCIONAL | `ColumnSeries + ScrollController + paginación AniList` | COMPOSICIÓN | DIRECTO: popularity de páginas pedidas a AniList bajo demanda (Page, perPage 20) |  |
| 53 | Shaded Doughnut | NATIVO | FUNCIONAL | `DoughnutSeries + onCreateShader (SweepGradient)` | NATIVO | DERIVADO: obras por format |  |
| 54 | Semi-Doughnut Progress | NATIVO | FUNCIONAL | `DoughnutSeries(startAngle/endAngle) + CircularChartAnnotation` | VARIANTE | DIRECTO: averageScore de la obra más popular |  |
| 55 | Range Selection Data Filter | COMPOSICIÓN | FUNCIONAL | `RangeSlider (Flutter) + ColumnSeries filtrada` | COMPOSICIÓN | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) | SfRangeSelector pertenece a syncfusion_flutter_sliders (no instalado): el rango se elige con RangeSlider. |
| 56 | Exploding Radial Bar | COMPOSICIÓN | FUNCIONAL | `RadialBarSeries + pointRadiusMapper + onPointTap` | COMPOSICIÓN | DIRECTO: averageScore de las 5 obras mejor puntuadas |  |
| 57 | Sparkline Win-Loss | NATIVO | FUNCIONAL | `SfSparkWinLossChart` | NATIVO | DERIVADO: score medio del año por encima (+1) o por debajo (−1) de la media |  |
| 58 | Sparkline Area with Min/Max | NATIVO | FUNCIONAL | `SfSparkAreaChart + highPointColor/lowPointColor` | NATIVO | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 59 | Multi-shape Categorical Scatter | NATIVO | FUNCIONAL | `ScatterSeries por formato + MarkerSettings.shape` | NATIVO | DIRECTO: popularity × averageScore; forma = format |  |
| 60 | Fully Customized Widget Tooltip | NATIVO | FUNCIONAL | `TooltipBehavior.builder (widget propio)` | NATIVO | DIRECTO: popularity, averageScore, format y episodes de las 10 más populares |  |
| 61 | Staggered Animation | NATIVO | FUNCIONAL | `Una serie por barra con animationDelay creciente` | VARIANTE | DIRECTO: popularity de las 10 obras más populares |  |
| 62 | Inverted / Opposed Axis | NATIVO | FUNCIONAL | `NumericAxis(isInversed) + CategoryAxis(opposedPosition)` | NATIVO | DIRECTO: rankings "highest rated all time" de AniList |  |
| 63 | Real-time Streaming | NATIVO | FUNCIONAL | `Timer → GraphQL → ChartSeriesController.updateDataSource` | COMPOSICIÓN | DIRECTO: popularity actual de las 5 obras más populares, consultada periódicamente |  |

## Casos especiales

- **#32 Candlestick y #33 HLOC.** *Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera.* Cada vela agrupa 7 días de la variación diaria de popularidad: open = primer día, high = máximo, low = mínimo, close = último día. HLOC usa la misma agrupación.
- **#41 SMA, #42 Bollinger Bands, #43 RSI, #44 MACD.** Se calculan con sus fórmulas habituales (SMA 7; Bollinger 20 días ± 2σ; RSI de Wilder 14; MACD 12-26-9) sobre la variación diaria real de popularidad. No son indicadores bursátiles.
- **#52 Infinite Scrolling / Lazy Loading.** Paginación real: al llegar al final del scroll (o con el botón "Siguiente página") se pide la página siguiente a AniList y el gráfico crece.
- **#63 Real-time Streaming.** Actualización periódica real desde AniList (polling, no WebSocket): Timer → GraphQL → comparar con la lectura anterior → `ChangeNotifier` → gráfico.

## 10. Conclusión

Syncfusion muestra los **63/63** casos, casi todos con su serie, indicador o behavior nativo; solo #52, #55, #56 y #63 son composiciones, y #32/#33 se marcan como ADAPTACIÓN por los datos (velas sobre popularidad), aunque la serie sea nativa. Es la librería que menos código propio necesita para cubrir la matriz.
