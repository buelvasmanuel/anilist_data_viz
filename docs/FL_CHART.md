# FL Chart en AniList Data Viz — Matriz 63×4

> Documento orientado al proyecto. Capacidad y estado salen de `master_chart_registry.dart`; estrategia, API y origen de datos salen de `CaseImpl` (el código). Las tablas se generan desde el código, no a mano.

## 1. Introducción

FL Chart es una librería de gráficos para Flutter, de código abierto (MIT), que dibuja con `CustomPainter`. Su enfoque es **declarativo por familias**: cada gráfico es un widget (`LineChart`, `BarChart`…) que recibe un objeto de datos con toda la configuración. No tiene 63 widgets: los 63 casos se construyen con sus **seis familias nativas** (`LineChart`, `BarChart`, `PieChart`, `ScatterChart`, `RadarChart`, `CandlestickChart`), configurándolas (VARIANTE), combinándolas con Flutter (COMPOSICIÓN) o dibujando una representación equivalente (ADAPTACIÓN). Ningún caso de la matriz necesita `RadarChart`.

## 2. Versión utilizada

- `fl_chart: 1.2.0` (fijada en `pubspec.yaml`, confirmada en `pubspec.lock`).
- Flutter 3.47.2 (stable) en el entorno de desarrollo.

## 3. Instalación

```bash
flutter pub add fl_chart:1.2.0
```

```dart
import 'package:fl_chart/fl_chart.dart';
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

Archivos de FL Chart:

- `lib/charts/fl_chart/fl_case_builders.dart` — `flChartCases`: los 63 casos. Reutiliza piezas comunes (`_lineChart`, `_barChart`, `_segment`…) en lugar de 63 motores distintos.
- Wrappers heredados reutilizados: `BasicBarChart`, `BasicLineChart`, `BasicPieChart`, `MultiSeriesBarChart`, `SemiCircleGauge`.
- `lib/presentation/screens/charts_gallery_screen.dart` — galería (envoltorio de `MasterCaseGallery`).

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

| Familia | Qué aporta en el proyecto |
|---|---|
| `LineChart` | Líneas, curvas (`isCurved`), áreas (`belowBarData`, `betweenBarsData`), escalones (`isStepLineChart`), puntos (`FlDotData`, `checkToShowDot`), degradados con cortes (`gradient`), zoom/pan (`FlTransformationConfig`), anotaciones (`ExtraLinesData`, `RangeAnnotations`), touch (`LineTouchData`) |
| `BarChart` | Columnas, barras (`rotationQuarterTurns`), apiladas (`BarChartRodStackItem`), rangos (`fromY`/`toY`), negativos, degradado, barras de error (`toYErrorRange`) |
| `PieChart` | Pie, donut (`centerSpaceRadius`), degradado por sección, anillos concéntricos |
| `ScatterChart` | Dispersión, radio y forma por punto (`FlDotCirclePainter`, `FlDotSquarePainter`, `FlDotCrossPainter`) |
| `CandlestickChart` | Velas (`CandlestickSpot`) |
| `RadarChart` | Disponible, sin uso en la matriz |

## 8. Limitaciones

- No hay widgets de pirámide, funnel, box plot, HLOC, gauge, radial bar, combinado barras+línea ni doble eje: se construyen (ver ADAPTACIÓN/COMPOSICIÓN en la tabla).
- No hay escala logarítmica ni ruptura de eje: #51 transforma a log10 y rotula 10^n; #50 usa un eje por índice sin huecos, pero **no dibuja la marca de ruptura** (por eso es PARCIAL).
- Superponer gráficos en `Stack` (#36, #37) exige reservar el mismo espacio de ejes en ambos para que coincidan.
- Los tooltips se dibujan en el canvas; un tooltip con widgets (#60) requiere composición.

## 9. Tabla completa de los 63 casos

### Cómo leer la tabla

- **Clasificación (capacidad):** lo que ofrece la librería para ese caso, según la matriz `masterChartRegistry`. NATIVO = widget/serie propio; VARIANTE = configuración de un gráfico nativo o datos preparados antes; COMPOSICIÓN = librería + widgets/estado de Flutter; NO SOPORTADO = la librería no tiene un constructo para el caso.
- **Implementación actual:** cómo lo dibuja *este proyecto*. Además de las tres anteriores aparece **ADAPTACIÓN**: una representación visual equivalente construida con otro gráfico de la librería o sobre datos adaptados (por ejemplo, velas sobre popularidad). Que un caso esté implementado como ADAPTACIÓN o COMPOSICIÓN **no** significa que la librería lo tenga como widget nativo.
- **Estado:** FUNCIONAL = el caso se dibuja completo con datos reales; PARCIAL = se dibuja con datos reales pero cubre el caso solo en parte (se explica en Observaciones).
- **Widget/API** y **Datos AniList** se exportan del código (`CaseImpl.api` y `CaseImpl.origin`), no se escriben a mano.

### Resumen

- Clasificación de capacidad (matriz) → NATIVO: **23** · VARIANTE: **27** · COMPOSICIÓN: **13** · NO SOPORTADO: **0**
- Implementación en el proyecto → NATIVO: **10** · VARIANTE: **35** · COMPOSICIÓN: **13** · ADAPTACIÓN: **5**
- Estado → FUNCIONAL: **62** · PARCIAL: **1** · DEMO: **0** · ROTO: **0** · NO DISPONIBLE: **0** · NO VERIFICADO: **0**
- Casos con visualización real en la galería: **63/63**

| # | Caso maestro | Clasificación (capacidad) | Estado | Widget/API | Implementación actual | Datos AniList | Observaciones |
|---:|---|---|---|---|---|---|---|
| 1 | Línea Simple | NATIVO | FUNCIONAL | `LineChart` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 2 | Columna Vertical | NATIVO | FUNCIONAL | `BarChart (BasicBarChart)` | NATIVO | DIRECTO: popularity de las 10 obras más populares |  |
| 3 | Barra Horizontal | NATIVO | FUNCIONAL | `BarChart + rotationQuarterTurns` | VARIANTE | DIRECTO: averageScore de las 10 obras mejor puntuadas |  |
| 4 | Línea Curva / Spline | NATIVO | FUNCIONAL | `LineChart + isCurved` | VARIANTE | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 5 | Área | NATIVO | FUNCIONAL | `LineChart + belowBarData` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 6 | Spline Area | NATIVO | FUNCIONAL | `LineChart + isCurved + belowBarData` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 7 | Pie | NATIVO | FUNCIONAL | `PieChart (BasicPieChart)` | NATIVO | DERIVADO: obras por format |  |
| 8 | Doughnut | NATIVO | FUNCIONAL | `PieChart + centerSpaceRadius` | VARIANTE | DERIVADO: obras por status |  |
| 9 | Radial Bar | COMPOSICIÓN | FUNCIONAL | `PieChart concéntricos en Stack` | COMPOSICIÓN | DIRECTO: averageScore de las 5 obras mejor puntuadas |  |
| 10 | Scatter | NATIVO | FUNCIONAL | `ScatterChart` | NATIVO | DIRECTO: popularity × averageScore de cada obra puntuada |  |
| 11 | Bubble | VARIANTE | FUNCIONAL | `ScatterChart + radio por punto` | VARIANTE | DIRECTO: popularity × averageScore; tamaño = episodes | Solo entran obras con episodes (AniList no lo informa para manga). |
| 12 | Step Line | NATIVO | FUNCIONAL | `LineChartBarData(isStepLineChart)` | VARIANTE | DERIVADO: obras acumuladas por año de inicio |  |
| 13 | Step Area | NATIVO | FUNCIONAL | `isStepLineChart + belowBarData` | VARIANTE | DERIVADO: obras acumuladas por año de inicio |  |
| 14 | Pyramid | VARIANTE | FUNCIONAL | `BarChart horizontal con rangos simétricos (fromY/toY)` | ADAPTACIÓN | DERIVADO: obras por format, ordenado | FL Chart no tiene Pyramid: se dibuja con barras centradas (la más corta arriba). |
| 15 | Funnel | VARIANTE | FUNCIONAL | `BarChart horizontal con rangos simétricos (fromY/toY)` | ADAPTACIÓN | DERIVADO: obras por status, ordenado | FL Chart no tiene Funnel: se dibuja con barras centradas (la más ancha arriba). |
| 16 | Histogram | VARIANTE | FUNCIONAL | `BarChart sobre bins externos (groupsSpace 0)` | VARIANTE | DERIVADO: bins de 10 puntos de averageScore |  |
| 17 | Stacked Column | NATIVO | FUNCIONAL | `BarChartRodStackItem (MultiSeriesBarChart)` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 18 | Stacked Bar | NATIVO | FUNCIONAL | `BarChartRodStackItem + rotationQuarterTurns` | VARIANTE | DERIVADO: obras por género × status (5 géneros más frecuentes) |  |
| 19 | Stacked Area | VARIANTE | FUNCIONAL | `LineChart + betweenBarsData sobre acumulados` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 20 | Stacked Line | VARIANTE | FUNCIONAL | `LineChart con series acumuladas` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 21 | 100% Stacked Column | VARIANTE | FUNCIONAL | `BarChartRodStackItem con valores normalizados` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 22 | 100% Stacked Bar | VARIANTE | FUNCIONAL | `BarChartRodStackItem normalizado + rotationQuarterTurns` | VARIANTE | DERIVADO: obras por género × status (5 géneros más frecuentes), normalizado a 100 % |  |
| 23 | 100% Stacked Area | VARIANTE | FUNCIONAL | `betweenBarsData con acumulados normalizados` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 24 | 100% Stacked Line | VARIANTE | FUNCIONAL | `LineChart con acumulados normalizados` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 25 | Range Column | NATIVO | FUNCIONAL | `BarChartRodData(fromY, toY)` | VARIANTE | DIRECTO: startDate.year – endDate.year de las obras más populares |  |
| 26 | Range Area | VARIANTE | FUNCIONAL | `betweenBarsData entre dos líneas` | VARIANTE | DERIVADO: averageScore mínimo y máximo por año |  |
| 27 | Spline Range Area | VARIANTE | FUNCIONAL | `betweenBarsData + isCurved` | VARIANTE | DERIVADO: averageScore mínimo y máximo por año |  |
| 28 | Waterfall | VARIANTE | FUNCIONAL | `BarChartRodData(fromY, toY) con acumulados` | VARIANTE | DERIVADO: variación de obras de un año al siguiente (cascada) |  |
| 29 | Line with markers | NATIVO | FUNCIONAL | `LineChart + FlDotData` | VARIANTE | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 30 | Diverging Bar | NATIVO | FUNCIONAL | `BarChart con negativos (BasicBarChart bySign)` | VARIANTE | DERIVADO: averageScore medio del género − media de la muestra |  |
| 31 | Sparkline Line | VARIANTE | FUNCIONAL | `LineChart sin títulos, cuadrícula ni borde` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 32 | Candlestick | NATIVO | FUNCIONAL | `CandlestickChart (CandlestickSpot)` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera. Cada vela = 7 días de la variación diaria de popularidad (open = primer día, high = máximo, low = mínimo, close = último día). |
| 33 | HLOC | COMPOSICIÓN | FUNCIONAL | `LineChart: segmentos high-low + ticks open/close` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | HLOC adaptado a tendencia de popularidad AniList (misma agrupación semanal que #32). No representa cotización financiera. |
| 34 | Box and Whisker | VARIANTE | FUNCIONAL | `LineChart: cajas y bigotes con segmentos` | ADAPTACIÓN | DERIVADO: cuartiles de averageScore por format | FL Chart no tiene Box Plot: caja y bigotes dibujados con segmentos de LineChart. |
| 35 | Error Bars | NATIVO | FUNCIONAL | `BarChartRodData.toYErrorRange + errorIndicatorData` | NATIVO | DERIVADO: media ± desviación estándar de averageScore por género |  |
| 36 | Combined Column + Line | COMPOSICIÓN | FUNCIONAL | `BarChart + LineChart superpuestos en Stack` | COMPOSICIÓN | DERIVADO: obras por año (columnas) + averageScore medio por año (línea) |  |
| 37 | Dual Y Axis | VARIANTE | FUNCIONAL | `Dos LineChart en Stack (eje izquierdo y derecho)` | COMPOSICIÓN | DIRECTO: popularity y averageScore de las 10 obras más populares |  |
| 38 | Pan & Zoom | NATIVO | FUNCIONAL | `LineChart + FlTransformationConfig (zoom/pan horizontal)` | NATIVO | DIRECTO: popularity de cada obra, ordenada por año de inicio | Pellizca o usa la rueda + arrastre sobre el gráfico. |
| 39 | Crosshair | COMPOSICIÓN | FUNCIONAL | `LineTouchData.touchCallback + ExtraLinesData` | COMPOSICIÓN | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 40 | Trackball | VARIANTE | FUNCIONAL | `LineTouchData con tooltip multiserie` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 41 | SMA | VARIANTE | FUNCIONAL | `LineChart: serie + SMA` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → SMA de 7 días | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 42 | Bollinger Bands | VARIANTE | FUNCIONAL | `LineChart + betweenBarsData (bandas)` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → bandas de Bollinger (20 días, ±2σ) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 43 | RSI | VARIANTE | FUNCIONAL | `LineChart + HorizontalRangeAnnotation` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → RSI de Wilder (14 días) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 44 | MACD | COMPOSICIÓN | FUNCIONAL | `LineChart: MACD, señal e histograma como segmentos` | COMPOSICIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → MACD (12, 26, 9) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 45 | Trendline Regression | VARIANTE | FUNCIONAL | `LineChart: puntos + recta de regresión` | VARIANTE | DERIVADO: regresión lineal de averageScore sobre popularity |  |
| 46 | Plot Bands / Strip Lines | NATIVO | FUNCIONAL | `RangeAnnotations + ExtraLinesData` | NATIVO | DIRECTO: averageScore de las 10 más populares + media de la muestra |  |
| 47 | Cartesian Widget Annotations | COMPOSICIÓN | FUNCIONAL | `BarChart + widget Flutter posicionado en Stack` | COMPOSICIÓN | DIRECTO: popularity de las 10 obras más populares |  |
| 48 | Multi-colored Line | VARIANTE | FUNCIONAL | `LineChartBarData.gradient con cortes duros` | VARIANTE | DERIVADO: averageScore medio por año comparado con la media de la muestra |  |
| 49 | Palette Gradient Series | NATIVO | FUNCIONAL | `BarChartRodData.gradient` | NATIVO | DIRECTO: averageScore de las 10 obras mejor puntuadas |  |
| 50 | Break / Gapless DateTime Axis | VARIANTE | PARCIAL | `Eje X por índice + getTitlesWidget (sin huecos)` | VARIANTE | DERIVADO: obras por año de inicio con eje ordinal (sin huecos) | Eje sin huecos (gapless). FL Chart no dibuja la marca de ruptura de eje. |
| 51 | Logarithmic Scale | VARIANTE | FUNCIONAL | `log10 externo + etiquetas 10^n` | VARIANTE | DIRECTO: popularity de obras repartidas por toda la muestra (escala log10) |  |
| 52 | Infinite Scrolling / Lazy Loading | COMPOSICIÓN | FUNCIONAL | `BarChart + ScrollController + paginación AniList` | COMPOSICIÓN | DIRECTO: popularity de páginas pedidas a AniList bajo demanda (Page, perPage 20) |  |
| 53 | Shaded Doughnut | NATIVO | FUNCIONAL | `PieChartSectionData.gradient` | NATIVO | DERIVADO: obras por format |  |
| 54 | Semi-Doughnut Progress | COMPOSICIÓN | FUNCIONAL | `PieChart + ClipRect/OverflowBox + Stack (SemiCircleGauge)` | COMPOSICIÓN | DIRECTO: averageScore de la obra más popular |  |
| 55 | Range Selection Data Filter | COMPOSICIÓN | FUNCIONAL | `RangeSlider + LineChart resumen + BarChart filtrado` | COMPOSICIÓN | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 56 | Exploding Radial Bar | COMPOSICIÓN | FUNCIONAL | `PieChart concéntricos + selección con estado` | COMPOSICIÓN | DIRECTO: averageScore de las 5 obras mejor puntuadas |  |
| 57 | Sparkline Win-Loss | VARIANTE | FUNCIONAL | `BarChart ±1 sin ejes` | VARIANTE | DERIVADO: score medio del año por encima (+1) o por debajo (−1) de la media |  |
| 58 | Sparkline Area with Min/Max | VARIANTE | FUNCIONAL | `LineChart + FlDotData.checkToShowDot (mín./máx.)` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 59 | Multi-shape Categorical Scatter | NATIVO | FUNCIONAL | `ScatterSpot.dotPainter (círculo, cuadrado, cruz)` | NATIVO | DIRECTO: popularity × averageScore; forma = format |  |
| 60 | Fully Customized Widget Tooltip | COMPOSICIÓN | FUNCIONAL | `BarTouchData.touchCallback + Card en Stack` | COMPOSICIÓN | DIRECTO: popularity, averageScore, format y episodes de las 10 más populares |  |
| 61 | Staggered Animation | COMPOSICIÓN | FUNCIONAL | `AnimationController + Interval por barra` | COMPOSICIÓN | DIRECTO: popularity de las 10 obras más populares |  |
| 62 | Inverted / Opposed Axis | VARIANTE | FUNCIONAL | `Valores negados + rightTitles/topTitles` | VARIANTE | DIRECTO: rankings "highest rated all time" de AniList |  |
| 63 | Real-time Streaming | COMPOSICIÓN | FUNCIONAL | `Timer → GraphQL → ChangeNotifier → LineChart` | COMPOSICIÓN | DIRECTO: popularity actual de las 5 obras más populares, consultada periódicamente |  |

## Casos especiales

- **#32 Candlestick y #33 HLOC.** *Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera.* Cada vela agrupa 7 días de la variación diaria de popularidad: open = primer día, high = máximo, low = mínimo, close = último día. HLOC usa la misma agrupación.
- **#41 SMA, #42 Bollinger Bands, #43 RSI, #44 MACD.** Se calculan con sus fórmulas habituales (SMA 7; Bollinger 20 días ± 2σ; RSI de Wilder 14; MACD 12-26-9) sobre la variación diaria real de popularidad. No son indicadores bursátiles.
- **#52 Infinite Scrolling / Lazy Loading.** Paginación real: al llegar al final del scroll (o con el botón "Siguiente página") se pide la página siguiente a AniList y el gráfico crece.
- **#63 Real-time Streaming.** Actualización periódica real desde AniList (polling, no WebSocket): Timer → GraphQL → comparar con la lectura anterior → `ChangeNotifier` → gráfico.

## 10. Conclusión

FL Chart muestra los **63/63** casos con gráfico real. Solo 10 casos usan un widget nativo tal cual; el resto son variantes o composiciones de sus seis familias, y 5 son adaptaciones visuales (#14 pirámide y #15 funnel con barras centradas, #32 velas sobre popularidad, #33 HLOC y #34 box plot dibujados con segmentos). #50 queda PARCIAL por la falta de marca de ruptura de eje. FL Chart da mucho control a bajo nivel a cambio de construir a mano lo que otras librerías traen hecho.
