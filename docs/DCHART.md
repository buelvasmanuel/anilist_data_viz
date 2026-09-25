# d_chart en AniList Data Viz — Matriz 63×4

> Documento orientado al proyecto. Capacidad y estado salen de `master_chart_registry.dart`; estrategia, API y origen de datos salen de `CaseImpl` (el código). Las tablas se generan desde el código, no a mano.

## 1. Introducción

d_chart es una librería de código abierto que envuelve `community_charts_flutter2` (derivada de Google Charts para Flutter). Organiza los gráficos por **tipo de dominio** del eje X: **O** (ordinal, texto), **N** (numérico) y **T** (tiempo, `DateTime`). Por eso sus widgets se llaman `DChartBarO`, `DChartLineN`, `DChartComboT`, etc. Su catálogo es el más pequeño de las cuatro librerías, así que muchos casos se resuelven combinando sus componentes.

## 2. Versión utilizada

- `d_chart: ^3.0.0`, resuelto a **3.0.0** (`pubspec.lock`); depende de `community_charts_common2` y `community_charts_flutter2` 1.0.7.

## 3. Instalación

```bash
flutter pub add d_chart:^3.0.0
```

```dart
import 'package:d_chart/d_chart.dart';
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

Archivos de d_chart:

- `lib/charts/d_chart/d_chart_case_builders.dart` — `dChartCases`: los 63 casos.
- `lib/charts/d_chart/d_chart_gallery_screen.dart` — galería.

### Constructos de d_chart 3.0.0 (verificados en el código del paquete)

| Constructo | Uso en el proyecto |
|---|---|
| `OrdinalData` / `OrdinalGroup`, `NumericData` / `NumericGroup`, `TimeData` / `TimeGroup` | Datos y series por tipo de dominio. `others` guarda el índice o la obra de cada punto. |
| `DChartBarO`, `DChartBarT` | Barras (`arrangeVertically: true` = barras horizontales), agrupadas o apiladas (`BarGroupingType`), `measureOffset` para que la barra empiece en otro valor (rangos, pirámide, funnel, cascada, velas). |
| `DChartLineN`, `DChartLineT` | Líneas con `includeArea`, `includePoints`, `stacked`, `pointRadius`, `pointColor`, `dashPattern`. **No existe `DChartLineO`.** |
| `DChartComboO`, `DChartComboN`, `DChartComboT` | Barras, líneas y puntos en un mismo gráfico (`renderType` por grupo) y eje secundario (`useSecondaryMeasureAxis`). |
| `DChartScatterN`, `DChartScatterT` | Dispersión con `symbolRender` y `pointRadius`. |
| `DChartPieO`, `DChartPieN`, `DChartPieT` | Pie/donut (`arcWidth`, `startAngle`, `arcLength`, `fillGradient`). |
| Ejes y parámetros comunes | `DomainAxisO/N/T`, `MeasureAxis`, `NumericViewport`, `OrdinalViewport`, `NumericTickProvider`, `allowSliding`, `flipVerticalAxis`, `defaultInteractions`, `onChangedListener`. |

`DChartBarCustom` existe pero está marcado como obsoleto y no se usa; `DChartSingleBar` está en el paquete pero **no se exporta**.

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

- Barras de categorías, tiempo y apiladas; líneas numéricas y temporales con área, puntos y apilado; combinados con eje secundario; dispersión; pie/donut con ángulos y degradado.
- `measureOffset` (por punto) permite barras que no empiezan en 0.
- `allowSliding` activa `SlidingViewport` + `PanAndZoomBehavior`.
- `flipVerticalAxis` invierte el eje vertical y lleva el eje X arriba.

## 8. Limitaciones

- No hay velas, HLOC, box plot, funnel, pirámide, waterfall, radial bar, curvas suavizadas, escalones, escala logarítmica, ruptura de eje, crosshair ni trackball configurables: todo eso es COMPOSICIÓN o ADAPTACIÓN (ver tabla).
- Las curvas (#4, #6, #27) se dibujan interpolando los puntos reales con **Catmull-Rom**: la curva pasa por los datos, no añade valores nuevos, y los puntos reales se marcan cuando corresponde.
- `symbolRender` es único por gráfico: #59 superpone un `DChartScatterN` por formato con el mismo viewport.
- d_chart no sombrea regiones: #46 marca las bandas con sus líneas límite (PARCIAL).
- #50 no dibuja la marca de ruptura de eje (PARCIAL).
- Detalles encontrados al revisar las imágenes: el eje X numérico empieza en 0 por defecto (hay que usar `NumericTickProvider(zeroBound: false)` para los años); las etiquetas ordinales repetidas rompen las líneas (se numeran); el degradado de barras necesita `fillPatternBase: FillPattern.gradient`; y las etiquetas por defecto son negras (se fuerza gris para el tema oscuro).

## 9. Tabla completa de los 63 casos

### Cómo leer la tabla

- **Clasificación (capacidad):** lo que ofrece la librería para ese caso, según la matriz `masterChartRegistry`. NATIVO = widget/serie propio; VARIANTE = configuración de un gráfico nativo o datos preparados antes; COMPOSICIÓN = librería + widgets/estado de Flutter; NO SOPORTADO = la librería no tiene un constructo para el caso.
- **Implementación actual:** cómo lo dibuja *este proyecto*. Además de las tres anteriores aparece **ADAPTACIÓN**: una representación visual equivalente construida con otro gráfico de la librería o sobre datos adaptados (por ejemplo, velas sobre popularidad). Que un caso esté implementado como ADAPTACIÓN o COMPOSICIÓN **no** significa que la librería lo tenga como widget nativo.
- **Estado:** FUNCIONAL = el caso se dibuja completo con datos reales; PARCIAL = se dibuja con datos reales pero cubre el caso solo en parte (se explica en Observaciones).
- **Widget/API** y **Datos AniList** se exportan del código (`CaseImpl.api` y `CaseImpl.origin`), no se escriben a mano.

### Resumen

- Clasificación de capacidad (matriz) → NATIVO: **20** · VARIANTE: **30** · COMPOSICIÓN: **10** · NO SOPORTADO: **3**
- Implementación en el proyecto → NATIVO: **19** · VARIANTE: **24** · COMPOSICIÓN: **13** · ADAPTACIÓN: **7**
- Estado → FUNCIONAL: **61** · PARCIAL: **2** · DEMO: **0** · ROTO: **0** · NO DISPONIBLE: **0** · NO VERIFICADO: **0**
- Casos con visualización real en la galería: **63/63**

| # | Caso maestro | Clasificación (capacidad) | Estado | Widget/API | Implementación actual | Datos AniList | Observaciones |
|---:|---|---|---|---|---|---|---|
| 1 | Línea Simple | NATIVO | FUNCIONAL | `DChartLineN + NumericGroup` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 2 | Columna Vertical | NATIVO | FUNCIONAL | `DChartBarO (arrangeVertically: false)` | NATIVO | DIRECTO: popularity de las 10 obras más populares |  |
| 3 | Barra Horizontal | NATIVO | FUNCIONAL | `DChartBarO (arrangeVertically: true)` | NATIVO | DIRECTO: averageScore de las 10 obras mejor puntuadas |  |
| 4 | Línea Curva / Spline | VARIANTE | FUNCIONAL | `DChartLineN sobre puntos interpolados (Catmull-Rom)` | ADAPTACIÓN | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) | d_chart no suaviza líneas: la curva interpola (Catmull-Rom) los puntos reales, que se marcan encima. |
| 5 | Área | NATIVO | FUNCIONAL | `DChartLineN + includeArea` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 6 | Spline Area | VARIANTE | FUNCIONAL | `DChartLineN + includeArea sobre puntos interpolados` | ADAPTACIÓN | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) | Curva por interpolación Catmull-Rom de los conteos reales por año. |
| 7 | Pie | NATIVO | FUNCIONAL | `DChartPieO` | NATIVO | DERIVADO: obras por format |  |
| 8 | Doughnut | NATIVO | FUNCIONAL | `DChartPieO + ConfigSeriesPieO(arcWidth)` | NATIVO | DERIVADO: obras por status |  |
| 9 | Radial Bar | COMPOSICIÓN | FUNCIONAL | `DChartPieO concéntricos en Stack` | COMPOSICIÓN | DIRECTO: averageScore de las 5 obras mejor puntuadas |  |
| 10 | Scatter | NATIVO | FUNCIONAL | `DChartScatterN` | NATIVO | DIRECTO: popularity × averageScore de cada obra puntuada |  |
| 11 | Bubble | VARIANTE | FUNCIONAL | `DChartScatterN + radiusPx por punto` | VARIANTE | DIRECTO: popularity × averageScore; tamaño = episodes | Tamaño = episodes (anime) o chapters (manga). |
| 12 | Step Line | VARIANTE | FUNCIONAL | `DChartLineN con puntos duplicados en escalón` | VARIANTE | DERIVADO: obras acumuladas por año de inicio |  |
| 13 | Step Area | VARIANTE | FUNCIONAL | `DChartLineN escalonado + includeArea` | VARIANTE | DERIVADO: obras acumuladas por año de inicio |  |
| 14 | Pyramid | VARIANTE | FUNCIONAL | `DChartBarO horizontal + measureOffset (barras centradas)` | ADAPTACIÓN | DERIVADO: obras por format, ordenado | d_chart no tiene Pyramid: barras centradas con measureOffset. |
| 15 | Funnel | VARIANTE | FUNCIONAL | `DChartBarO horizontal + measureOffset (barras centradas)` | ADAPTACIÓN | DERIVADO: obras por status, ordenado | d_chart no tiene Funnel: barras centradas con measureOffset. |
| 16 | Histogram | VARIANTE | FUNCIONAL | `DChartBarO sobre bins externos` | VARIANTE | DERIVADO: bins de 10 puntos de averageScore |  |
| 17 | Stacked Column | NATIVO | FUNCIONAL | `DChartBarO + BarGroupingType.stacked` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 18 | Stacked Bar | NATIVO | FUNCIONAL | `BarGroupingType.stacked + arrangeVertically` | NATIVO | DERIVADO: obras por género × status (5 géneros más frecuentes) |  |
| 19 | Stacked Area | NATIVO | FUNCIONAL | `DChartLineN + ConfigSeriesLineN(stacked, includeArea)` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 20 | Stacked Line | NATIVO | FUNCIONAL | `DChartLineN + ConfigSeriesLineN(stacked)` | NATIVO | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 21 | 100% Stacked Column | VARIANTE | FUNCIONAL | `stacked sobre valores normalizados a 100 %` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 22 | 100% Stacked Bar | VARIANTE | FUNCIONAL | `stacked + arrangeVertically sobre valores normalizados` | VARIANTE | DERIVADO: obras por género × status (5 géneros más frecuentes), normalizado a 100 % |  |
| 23 | 100% Stacked Area | VARIANTE | FUNCIONAL | `stacked + includeArea sobre valores normalizados` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 24 | 100% Stacked Line | VARIANTE | FUNCIONAL | `stacked sobre valores normalizados` | VARIANTE | DERIVADO: obras por año × format (4 formatos más frecuentes), normalizado a 100 % |  |
| 25 | Range Column | VARIANTE | FUNCIONAL | `DChartBarO + measureOffset (inicio de la barra)` | VARIANTE | DIRECTO: startDate.year – endDate.year de las obras más populares |  |
| 26 | Range Area | VARIANTE | FUNCIONAL | `DChartLineN apilado: base transparente + banda` | VARIANTE | DERIVADO: averageScore mínimo y máximo por año |  |
| 27 | Spline Range Area | VARIANTE | FUNCIONAL | `Banda apilada sobre puntos interpolados` | ADAPTACIÓN | DERIVADO: averageScore mínimo y máximo por año | Bordes suavizados por interpolación Catmull-Rom de los mínimos y máximos reales. |
| 28 | Waterfall | VARIANTE | FUNCIONAL | `DChartBarO + measureOffset (cascada)` | VARIANTE | DERIVADO: variación de obras de un año al siguiente (cascada) |  |
| 29 | Line with markers | NATIVO | FUNCIONAL | `ConfigSeriesLineN(includePoints)` | NATIVO | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 30 | Diverging Bar | NATIVO | FUNCIONAL | `DChartBarO con medidas negativas + customColor` | NATIVO | DERIVADO: averageScore medio del género − media de la muestra |  |
| 31 | Sparkline Line | VARIANTE | FUNCIONAL | `DChartLineN con ejes noRenderSpec` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 32 | Candlestick | NO SOPORTADO | FUNCIONAL | `Dos DChartBarO superpuestos (mecha y cuerpo) con measureOffset` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera. Cada vela = 7 días de la variación diaria de popularidad (open = primer día, high = máximo, low = mínimo, close = último día). |
| 33 | HLOC | NO SOPORTADO | FUNCIONAL | `DChartComboO: barra high-low (measureOffset) + marcadores open/close` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | HLOC adaptado a tendencia de popularidad AniList (misma agrupación semanal que #32). No representa cotización financiera. |
| 34 | Box and Whisker | NO SOPORTADO | FUNCIONAL | `Tres DChartBarO superpuestos (bigote, caja, mediana)` | COMPOSICIÓN | DERIVADO: cuartiles de averageScore por format | d_chart no tiene Box Plot: se superponen tres DChartBarO con el mismo viewport. |
| 35 | Error Bars | VARIANTE | FUNCIONAL | `Dos DChartBarO superpuestos (media y rango ±σ)` | COMPOSICIÓN | DERIVADO: media ± desviación estándar de averageScore por género |  |
| 36 | Combined Column + Line | NATIVO | FUNCIONAL | `DChartComboO (bar + line) + secondaryMeasureAxis` | NATIVO | DERIVADO: obras por año (columnas) + averageScore medio por año (línea) |  |
| 37 | Dual Y Axis | NATIVO | FUNCIONAL | `DChartComboO (dos líneas) + secondaryMeasureAxis` | NATIVO | DIRECTO: popularity y averageScore de las 10 obras más populares |  |
| 38 | Pan & Zoom | NATIVO | FUNCIONAL | `DChartBarO(allowSliding) + OrdinalViewport` | NATIVO | DIRECTO: popularity de cada obra, ordenada por año de inicio | Arrastra o pellizca horizontalmente (SlidingViewport + PanAndZoomBehavior). |
| 39 | Crosshair | COMPOSICIÓN | FUNCIONAL | `DChartLineN + onChangedListener + grupos de guía` | COMPOSICIÓN | DERIVADO: averageScore medio por año de inicio (últimos 10 años de la muestra) |  |
| 40 | Trackball | COMPOSICIÓN | FUNCIONAL | `DChartLineN multiserie + onChangedListener + panel` | COMPOSICIÓN | DERIVADO: obras por año × format (4 formatos más frecuentes) |  |
| 41 | SMA | VARIANTE | FUNCIONAL | `DChartLineT + TimeGroup (serie y SMA)` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → SMA de 7 días | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 42 | Bollinger Bands | VARIANTE | FUNCIONAL | `DChartLineT con banda media ± 2σ` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → bandas de Bollinger (20 días, ±2σ) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 43 | RSI | VARIANTE | FUNCIONAL | `DChartLineT + líneas de referencia 70/30` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → RSI de Wilder (14 días) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 44 | MACD | VARIANTE | FUNCIONAL | `DChartComboT (histograma bar + MACD y señal line)` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → MACD (12, 26, 9) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 45 | Trendline Regression | VARIANTE | FUNCIONAL | `DChartComboN (scatterPlot + line de regresión)` | VARIANTE | DERIVADO: regresión lineal de averageScore sobre popularity |  |
| 46 | Plot Bands / Strip Lines | VARIANTE | PARCIAL | `DChartComboO: barras + líneas de referencia (strip lines)` | VARIANTE | DIRECTO: averageScore de las 10 más populares + media de la muestra | d_chart no sombrea regiones: las bandas se marcan con sus líneas límite (80 y 60) y la media. |
| 47 | Cartesian Widget Annotations | COMPOSICIÓN | FUNCIONAL | `DChartBarO + widget Flutter posicionado en Stack` | COMPOSICIÓN | DIRECTO: popularity de las 10 obras más populares |  |
| 48 | Multi-colored Line | NATIVO | FUNCIONAL | `ConfigSeriesLineN.customColor por punto` | NATIVO | DERIVADO: averageScore medio por año comparado con la media de la muestra |  |
| 49 | Palette Gradient Series | NATIVO | FUNCIONAL | `ConfigSeriesBarO.fillGradient` | NATIVO | DIRECTO: averageScore de las 10 obras mejor puntuadas |  |
| 50 | Break / Gapless DateTime Axis | VARIANTE | PARCIAL | `DChartComboO: dominio ordinal de años (sin huecos)` | VARIANTE | DERIVADO: obras por año de inicio con eje ordinal (sin huecos) | Eje sin huecos (gapless). d_chart no dibuja la marca de ruptura de eje. |
| 51 | Logarithmic Scale | VARIANTE | FUNCIONAL | `log10 externo + MeasureAxis.tickLabelFormatter` | VARIANTE | DIRECTO: popularity de obras repartidas por toda la muestra (escala log10) |  |
| 52 | Infinite Scrolling / Lazy Loading | COMPOSICIÓN | FUNCIONAL | `DChartBarO + ScrollController + paginación AniList` | COMPOSICIÓN | DIRECTO: popularity de páginas pedidas a AniList bajo demanda (Page, perPage 20) |  |
| 53 | Shaded Doughnut | NATIVO | FUNCIONAL | `DChartPieO + ConfigSeriesPieO.fillGradient` | NATIVO | DERIVADO: obras por format |  |
| 54 | Semi-Doughnut Progress | VARIANTE | FUNCIONAL | `DChartPieO(startAngle π, arcLength π) + Stack` | VARIANTE | DIRECTO: averageScore de la obra más popular |  |
| 55 | Range Selection Data Filter | COMPOSICIÓN | FUNCIONAL | `RangeSlider (Flutter) + DChartBarO filtrado` | COMPOSICIÓN | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 56 | Exploding Radial Bar | COMPOSICIÓN | FUNCIONAL | `DChartPieO concéntricos + selección con estado` | COMPOSICIÓN | DIRECTO: averageScore de las 5 obras mejor puntuadas |  |
| 57 | Sparkline Win-Loss | VARIANTE | FUNCIONAL | `DChartBarO ±1 sin ejes` | VARIANTE | DERIVADO: score medio del año por encima (+1) o por debajo (−1) de la media |  |
| 58 | Sparkline Area with Min/Max | VARIANTE | FUNCIONAL | `DChartLineN + includeArea + radiusPx solo en mín./máx.` | VARIANTE | DERIVADO: obras por año de inicio (últimos 10 años de la muestra) |  |
| 59 | Multi-shape Categorical Scatter | VARIANTE | FUNCIONAL | `Un DChartScatterN por formato (symbolRender) superpuestos` | COMPOSICIÓN | DIRECTO: popularity × averageScore; forma = format | symbolRender es único por gráfico: se superpone un DChartScatterN por formato con el mismo viewport. |
| 60 | Fully Customized Widget Tooltip | COMPOSICIÓN | FUNCIONAL | `DChartBarO.onChangedListener + Card en Stack` | COMPOSICIÓN | DIRECTO: popularity, averageScore, format y episodes de las 10 más populares |  |
| 61 | Staggered Animation | COMPOSICIÓN | FUNCIONAL | `AnimationController + Interval por barra` | COMPOSICIÓN | DIRECTO: popularity de las 10 obras más populares |  |
| 62 | Inverted / Opposed Axis | NATIVO | FUNCIONAL | `DChartLineN(flipVerticalAxis) — ranking invertido, eje X arriba` | NATIVO | DIRECTO: rankings "highest rated all time" de AniList |  |
| 63 | Real-time Streaming | COMPOSICIÓN | FUNCIONAL | `Timer → GraphQL → ChangeNotifier → DChartLineN` | COMPOSICIÓN | DIRECTO: popularity actual de las 5 obras más populares, consultada periódicamente |  |

## Casos especiales

- **#32 Candlestick y #33 HLOC.** *Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera.* Cada vela agrupa 7 días de la variación diaria de popularidad: open = primer día, high = máximo, low = mínimo, close = último día. HLOC usa la misma agrupación.
- **#41 SMA, #42 Bollinger Bands, #43 RSI, #44 MACD.** Se calculan con sus fórmulas habituales (SMA 7; Bollinger 20 días ± 2σ; RSI de Wilder 14; MACD 12-26-9) sobre la variación diaria real de popularidad. No son indicadores bursátiles.
- **#52 Infinite Scrolling / Lazy Loading.** Paginación real: al llegar al final del scroll (o con el botón "Siguiente página") se pide la página siguiente a AniList y el gráfico crece.
- **#63 Real-time Streaming.** Actualización periódica real desde AniList (polling, no WebSocket): Timer → GraphQL → comparar con la lectura anterior → `ChangeNotifier` → gráfico.

## 10. Conclusión

d_chart muestra los **63/63** casos con gráfico real, a pesar de tener el catálogo más limitado. Lo consigue reutilizando pocos constructos: `measureOffset` en `DChartBarO` resuelve rangos, pirámide, funnel, cascada y velas; superponer `DChartBarO` con el mismo viewport resuelve velas, box plot y barras de error; y los `DChartPieO` concéntricos resuelven las barras radiales. Hay 7 adaptaciones y 2 casos PARCIAL (#46 y #50). En la matriz de capacidad, #32–#34 siguen como NO SOPORTADO, porque la librería no los trae: lo que se ve es una construcción del proyecto.
