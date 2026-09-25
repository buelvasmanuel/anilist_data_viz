# Graphic en AniList Data Viz — Matriz 63×4

> Documento orientado al proyecto. Capacidad y estado salen de `master_chart_registry.dart`; estrategia, API y origen de datos salen de `CaseImpl` (el código). Las tablas se generan desde el código, no a mano.

## 1. Introducción

Graphic implementa la **Gramática de Gráficos** (Wilkinson; la misma idea de ggplot2 o Vega-Lite). No se elige un "tipo de gráfico": se **describe** por capas.

| Concepto | En Graphic | Ejemplo en el proyecto |
|---|---|---|
| Datos y variables | `Chart(data)`, `Variable(accessor, scale)` | score, año, formato |
| Álgebra | `Varset('x') * Varset('y')`, `/` para agrupar | año × score |
| Marca | `LineMark`, `IntervalMark`, `AreaMark`, `PointMark`, `CustomMark` | barras = `IntervalMark` |
| Codificación | `ColorEncode`, `SizeEncode`, `ShapeEncode`, `GradientEncode`, `ElevationEncode` | burbuja = tamaño variable |
| Modificadores | `StackModifier`, `SymmetricModifier`, `Proportion` | apilado, funnel, 100 % |
| Coordenadas | `RectCoord` (transpuesta, rango invertido), `PolarCoord` | pie = intervalo en polar |
| Guías y anotaciones | `AxisGuide`, `TooltipGuide`, `CrosshairGuide`, `RegionAnnotation`, `LineAnnotation`, `TagAnnotation` | plot bands |
| Interacción y datos vivos | `PointSelection`, `IntervalSelection`, `selectionStream`, `gestureStream`, `changeDataStream` | crosshair, filtro, #63 |

Por eso muchos "tipos" distintos son la misma marca con otra coordenada o modificador.

## 2. Versión utilizada

- `graphic: ^2.7.0`, resuelto a **2.7.0** (`pubspec.lock`).

## 3. Instalación

```bash
flutter pub add graphic:^2.7.0
```

```dart
import 'package:graphic/graphic.dart';
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

Archivos de Graphic:

- `lib/charts/graphic/charts/*.dart` — builders `g01…g63` (existentes; no se rehicieron).
- `lib/charts/graphic/graphic_chart_registry.dart` — registry interno (número, construcción, builder y su propia clasificación).
- `lib/charts/graphic/graphic_cases.dart` — `graphicCases`: convierte el registry al formato común y añade origen de datos y notas.
- `lib/charts/graphic/shapes/graphic_custom_shapes.dart` — shapes propios (`HlocShape`, `BoxPlotShape`, `ErrorBarShape`, `ExplodedRectShape`).

Cambios en esta fase: #32 y #33 dibujan velas reales de `Media.trends` (`CandlestickShape` nativo y `HlocShape` propio); #41–#44 ya reciben la serie de trends; #52 usa la paginación real; #63 recibe las lecturas del sondeo real por `changeDataStream`; #62 tiene datos gracias a `rankings`; #11 usa `chapters` como tamaño en manga. Además, la revisión visual detectó dos defectos que se corrigieron: #14/#15 salían descentrados (`SymmetricModifier` centra respecto al 0 de la escala, que empezaba en 0) y #35 dibujaba las barras de error en negro sobre el fondo oscuro.

**Clasificación.** El registry interno de Graphic usa su propia clasificación, que difiere de la matriz en #30, #61 y #62. La columna *Clasificación (capacidad)* usa la matriz; la columna *Implementación actual* usa la clasificación interna (cómo está construido cada builder).

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

- Todas las marcas, coordenadas, escalas (`LinearScale`, `OrdinalScale`, `TimeScale`) y modificadores de la tabla anterior.
- `CustomMark` + `Shape` para geometrías propias (velas, cajas, barras de error, HLOC).
- `Chart.changeDataStream` para actualizar datos sin reconstruir el widget; `Mark.transition` para animar.

## 8. Limitaciones

- No calcula estadística (bins, cuartiles, regresión, indicadores): todo se calcula antes, en `GraphicTransformations`.
- No hay ruptura de eje: #50 compara `TimeScale` (con huecos) y `OrdinalScale` (sin huecos) y queda PARCIAL.
- No hay "load more" nativo (#52) ni tooltip con widgets (#60): son composiciones.
- La animación es por marca, no por punto; el escalonado (#61) se compone con varias marcas.
- Dentro de una lista con scroll, los gestos de zoom/pan compiten con el scroll de la página (#38).

## 9. Tabla completa de los 63 casos

### Cómo leer la tabla

- **Clasificación (capacidad):** lo que ofrece la librería para ese caso, según la matriz `masterChartRegistry`. NATIVO = widget/serie propio; VARIANTE = configuración de un gráfico nativo o datos preparados antes; COMPOSICIÓN = librería + widgets/estado de Flutter; NO SOPORTADO = la librería no tiene un constructo para el caso.
- **Implementación actual:** cómo lo dibuja *este proyecto*. Además de las tres anteriores aparece **ADAPTACIÓN**: una representación visual equivalente construida con otro gráfico de la librería o sobre datos adaptados (por ejemplo, velas sobre popularidad). Que un caso esté implementado como ADAPTACIÓN o COMPOSICIÓN **no** significa que la librería lo tenga como widget nativo.
- **Estado:** FUNCIONAL = el caso se dibuja completo con datos reales; PARCIAL = se dibuja con datos reales pero cubre el caso solo en parte (se explica en Observaciones).
- **Widget/API** y **Datos AniList** se exportan del código (`CaseImpl.api` y `CaseImpl.origin`), no se escriben a mano.

### Resumen

- Clasificación de capacidad (matriz) → NATIVO: **38** · VARIANTE: **17** · COMPOSICIÓN: **8** · NO SOPORTADO: **0**
- Implementación en el proyecto → NATIVO: **35** · VARIANTE: **18** · COMPOSICIÓN: **8** · ADAPTACIÓN: **2**
- Estado → FUNCIONAL: **62** · PARCIAL: **1** · DEMO: **0** · ROTO: **0** · NO DISPONIBLE: **0** · NO VERIFICADO: **0**
- Casos con visualización real en la galería: **63/63**

| # | Caso maestro | Clasificación (capacidad) | Estado | Widget/API | Implementación actual | Datos AniList | Observaciones |
|---:|---|---|---|---|---|---|---|
| 1 | Línea Simple | NATIVO | FUNCIONAL | `LineMark` | NATIVO | DERIVADO: averageScore medio por año (scoreByYear) |  |
| 2 | Columna Vertical | NATIVO | FUNCIONAL | `IntervalMark + RectShape` | NATIVO | DIRECTO: popularity de las 10 obras más populares |  |
| 3 | Barra Horizontal | NATIVO | FUNCIONAL | `IntervalMark + RectCoord(transposed)` | NATIVO | DIRECTO: averageScore de las 10 mejor puntuadas |  |
| 4 | Línea Curva / Spline | NATIVO | FUNCIONAL | `LineMark + BasicLineShape(smooth)` | NATIVO | DERIVADO: averageScore medio por año (scoreByYear) |  |
| 5 | Área | NATIVO | FUNCIONAL | `AreaMark (+ LineMark borde)` | NATIVO | DERIVADO: obras por año (countByYear) |  |
| 6 | Spline Area | NATIVO | FUNCIONAL | `AreaMark + BasicAreaShape(smooth)` | NATIVO | DERIVADO: obras por año (countByYear) |  |
| 7 | Pie | NATIVO | FUNCIONAL | `IntervalMark + Proportion + StackModifier + PolarCoord(transposed, dimCount 1)` | NATIVO | DERIVADO: obras por format |  |
| 8 | Doughnut | NATIVO | FUNCIONAL | `Pie + PolarCoord(startRadius)` | NATIVO | DERIVADO: obras por status |  |
| 9 | Radial Bar | NATIVO | FUNCIONAL | `IntervalMark + PolarCoord(transposed)` | NATIVO | DIRECTO: averageScore de las 5 mejor puntuadas |  |
| 10 | Scatter | NATIVO | FUNCIONAL | `PointMark` | NATIVO | DIRECTO: popularity × averageScore |  |
| 11 | Bubble | NATIVO | FUNCIONAL | `PointMark + SizeEncode(variable)` | NATIVO | DIRECTO: popularity × averageScore; tamaño = episodes (anime) o chapters (manga) |  |
| 12 | Step Line | NATIVO | FUNCIONAL | `LineMark + BasicLineShape(stepped)` | NATIVO | DERIVADO: obras acumuladas por año |  |
| 13 | Step Area | NATIVO | FUNCIONAL | `AreaMark + BasicAreaShape(stepped)` | NATIVO | DERIVADO: obras acumuladas por año |  |
| 14 | Pyramid | NATIVO | FUNCIONAL | `IntervalMark + FunnelShape(pyramid) + SymmetricModifier` | NATIVO | DERIVADO: obras por format, ordenado |  |
| 15 | Funnel | NATIVO | FUNCIONAL | `IntervalMark + FunnelShape + SymmetricModifier` | NATIVO | DERIVADO: obras por status, ordenado |  |
| 16 | Histogram | VARIANTE | FUNCIONAL | `Bins externos + IntervalMark + RectShape(histogram)` | VARIANTE | DERIVADO: bins de 10 puntos de averageScore |  |
| 17 | Stacked Column | NATIVO | FUNCIONAL | `IntervalMark + StackModifier` | NATIVO | DERIVADO: obras por año × format |  |
| 18 | Stacked Bar | NATIVO | FUNCIONAL | `IntervalMark + StackModifier + transposed` | NATIVO | DERIVADO: obras por género × status |  |
| 19 | Stacked Area | NATIVO | FUNCIONAL | `AreaMark + StackModifier` | NATIVO | DERIVADO: obras por año × format |  |
| 20 | Stacked Line | NATIVO | FUNCIONAL | `LineMark + StackModifier` | NATIVO | DERIVADO: obras por año × format |  |
| 21 | 100% Stacked Column | NATIVO | FUNCIONAL | `Proportion(nest) + StackModifier + IntervalMark` | NATIVO | DERIVADO: obras por año × format (proporción) |  |
| 22 | 100% Stacked Bar | NATIVO | FUNCIONAL | `Proportion(nest) + StackModifier + transposed` | NATIVO | DERIVADO: obras por género × status (proporción) |  |
| 23 | 100% Stacked Area | NATIVO | FUNCIONAL | `Proportion(nest) + StackModifier + AreaMark` | NATIVO | DERIVADO: obras por año × format (proporción) |  |
| 24 | 100% Stacked Line | NATIVO | FUNCIONAL | `Proportion(nest) + StackModifier + LineMark` | NATIVO | DERIVADO: obras por año × format (proporción) |  |
| 25 | Range Column | NATIVO | FUNCIONAL | `IntervalMark [start, end]` | NATIVO | DIRECTO: startDate.year – endDate.year |  |
| 26 | Range Area | NATIVO | FUNCIONAL | `AreaMark [start, end]` | NATIVO | DERIVADO: averageScore mínimo y máximo por año |  |
| 27 | Spline Range Area | NATIVO | FUNCIONAL | `AreaMark [start, end] + BasicAreaShape(smooth)` | NATIVO | DERIVADO: averageScore mínimo y máximo por año |  |
| 28 | Waterfall | VARIANTE | FUNCIONAL | `Acumulados externos + IntervalMark [from, to]` | VARIANTE | DERIVADO: variación de obras de un año al siguiente |  |
| 29 | Line with markers | NATIVO | FUNCIONAL | `LineMark + PointMark` | NATIVO | DERIVADO: averageScore medio por año |  |
| 30 | Diverging Bar | NATIVO | FUNCIONAL | `Desviación externa + IntervalMark + transposed + LineAnnotation` | VARIANTE | DERIVADO: score medio del género − media de la muestra |  |
| 31 | Sparkline Line | VARIANTE | FUNCIONAL | `LineMark sin ejes ni padding` | VARIANTE | DERIVADO: obras por año |  |
| 32 | Candlestick | NATIVO | FUNCIONAL | `CustomMark + CandlestickShape (velas semanales de Media.trends)` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera. Cada vela = 7 días de la variación diaria de popularidad (open = primer día, high = máximo, low = mínimo, close = último día). |
| 33 | HLOC | COMPOSICIÓN | FUNCIONAL | `CustomMark + HlocShape (Shape propio, velas semanales de Media.trends)` | ADAPTACIÓN | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → velas de 7 días | HLOC adaptado a tendencia de popularidad AniList (misma agrupación semanal que #32). No representa cotización financiera. |
| 34 | Box and Whisker | COMPOSICIÓN | FUNCIONAL | `Cuartiles externos + CustomMark + BoxPlotShape (Shape propio)` | COMPOSICIÓN | DERIVADO: cuartiles de averageScore por format |  |
| 35 | Error Bars | COMPOSICIÓN | FUNCIONAL | `Media ± σ externas + CustomMark + ErrorBarShape (Shape propio)` | COMPOSICIÓN | DERIVADO: media ± σ de averageScore por género |  |
| 36 | Combined Column + Line | NATIVO | FUNCIONAL | `IntervalMark + LineMark en un Chart` | NATIVO | DERIVADO: obras por año + averageScore medio por año |  |
| 37 | Dual Y Axis | NATIVO | FUNCIONAL | `AxisGuide(variable, position: 1, flip)` | NATIVO | DIRECTO: popularity y averageScore de las 10 más populares |  |
| 38 | Pan & Zoom | NATIVO | FUNCIONAL | `RectCoord(horizontalRangeUpdater: Defaults.horizontalRangeEvent)` | NATIVO | DIRECTO: popularity de cada obra por fecha de inicio |  |
| 39 | Crosshair | NATIVO | FUNCIONAL | `PointSelection + CrosshairGuide` | NATIVO | DIRECTO: popularity × averageScore |  |
| 40 | Trackball | VARIANTE | FUNCIONAL | `PointSelection(dim x) + TooltipGuide(multiTuples) + CrosshairGuide + updaters` | VARIANTE | DERIVADO: obras por año × format |  |
| 41 | SMA | VARIANTE | FUNCIONAL | `SMA externa + LineMark por serie` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → SMA de 7 días | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 42 | Bollinger Bands | VARIANTE | FUNCIONAL | `Bandas externas + AreaMark [lower, upper] + LineMark` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → bandas de Bollinger (20, ±2σ) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 43 | RSI | VARIANTE | FUNCIONAL | `RSI externo + LineMark + RegionAnnotation + gestureStream compartido` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → RSI de Wilder (14) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 44 | MACD | VARIANTE | FUNCIONAL | `MACD externo + IntervalMark + LineMark` | VARIANTE | DERIVADO: Media.trends.popularity de la obra más popular → variación neta diaria → MACD (12, 26, 9) | Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero. |
| 45 | Trendline Regression | VARIANTE | FUNCIONAL | `Regresión externa + PointMark + LineMark` | VARIANTE | DERIVADO: regresión lineal de averageScore sobre popularity |  |
| 46 | Plot Bands / Strip Lines | NATIVO | FUNCIONAL | `RegionAnnotation + LineAnnotation + TagAnnotation` | NATIVO | DIRECTO: averageScore de las 10 más populares + media de la muestra |  |
| 47 | Cartesian Widget Annotations | COMPOSICIÓN | FUNCIONAL | `TagAnnotation (canvas) + Stack/Positioned con widget Flutter` | COMPOSICIÓN | DIRECTO: popularity de las 10 más populares |  |
| 48 | Multi-colored Line | VARIANTE | FUNCIONAL | `LineMark + GradientEncode con cortes duros` | VARIANTE | DERIVADO: averageScore medio por año vs media de la muestra |  |
| 49 | Palette Gradient Series | NATIVO | FUNCIONAL | `IntervalMark + GradientEncode` | NATIVO | DIRECTO: averageScore de las 10 mejor puntuadas |  |
| 50 | Break / Gapless DateTime Axis | VARIANTE | PARCIAL | `TimeScale vs OrdinalScale (sin axis break)` | VARIANTE | DIRECTO: startDate.year de las obras más populares | Graphic no dibuja ruptura de eje: se compara TimeScale (con huecos) y OrdinalScale (sin huecos). |
| 51 | Logarithmic Scale | VARIANTE | FUNCIONAL | `log10 en Variable + LinearScale(ticks, formatter)` | VARIANTE | DIRECTO: popularity (log10 en la Variable) |  |
| 52 | Infinite Scrolling / Lazy Loading | COMPOSICIÓN | FUNCIONAL | `Paginación real AniList (LazyLoadingHost) + IntervalMark` | COMPOSICIÓN | DIRECTO: popularity de páginas pedidas a AniList bajo demanda (Page, perPage 20) |  |
| 53 | Shaded Doughnut | VARIANTE | FUNCIONAL | `Doughnut + GradientEncode(SweepGradient) + ElevationEncode` | VARIANTE | DERIVADO: obras por format |  |
| 54 | Semi-Doughnut Progress | VARIANTE | FUNCIONAL | `IntervalMark + PolarCoord(startAngle π, endAngle 2π)` | VARIANTE | DIRECTO: averageScore de la obra más popular |  |
| 55 | Range Selection Data Filter | COMPOSICIÓN | FUNCIONAL | `IntervalSelection + selectionStream + estado Flutter + filtrado` | COMPOSICIÓN | DIRECTO: popularity por fecha de inicio |  |
| 56 | Exploding Radial Bar | COMPOSICIÓN | FUNCIONAL | `PointSelection + ElevationEncode.updaters + ExplodedRectShape (Shape propio)` | COMPOSICIÓN | DIRECTO: averageScore de las 10 mejor puntuadas |  |
| 57 | Sparkline Win-Loss | VARIANTE | FUNCIONAL | `±1 externo + IntervalMark sin ejes` | VARIANTE | DERIVADO: score medio del año por encima (+1) o por debajo (−1) de la media |  |
| 58 | Sparkline Area with Min/Max | VARIANTE | FUNCIONAL | `AreaMark + PointMark(SizeEncode encoder en extremos)` | VARIANTE | DERIVADO: obras por año |  |
| 59 | Multi-shape Categorical Scatter | NATIVO | FUNCIONAL | `PointMark + ShapeEncode(variable)` | NATIVO | DIRECTO: popularity × averageScore; forma = format |  |
| 60 | Fully Customized Widget Tooltip | COMPOSICIÓN | FUNCIONAL | `selectionStream + gestureStream + Card en Stack` | COMPOSICIÓN | DIRECTO: campos de las 10 más populares |  |
| 61 | Staggered Animation | VARIANTE | FUNCIONAL | `Mark.transition con curvas Interval por marca + recreación por Key` | COMPOSICIÓN | DIRECTO: popularity y averageScore de las 10 más populares |  |
| 62 | Inverted / Opposed Axis | NATIVO | FUNCIONAL | `RectCoord(verticalRange: [1, 0]) + AxisGuide(position: 1, flip)` | VARIANTE | DIRECTO: rankings "highest rated all time" de AniList |  |
| 63 | Real-time Streaming | NATIVO | FUNCIONAL | `Sondeo periódico AniList → Chart.changeDataStream + ChangeDataEvent` | NATIVO | DIRECTO: popularity actual de las 5 obras más populares, consultada periódicamente |  |

## Casos especiales

- **#32 Candlestick y #33 HLOC.** *Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera.* Cada vela agrupa 7 días de la variación diaria de popularidad: open = primer día, high = máximo, low = mínimo, close = último día. HLOC usa la misma agrupación.
- **#41 SMA, #42 Bollinger Bands, #43 RSI, #44 MACD.** Se calculan con sus fórmulas habituales (SMA 7; Bollinger 20 días ± 2σ; RSI de Wilder 14; MACD 12-26-9) sobre la variación diaria real de popularidad. No son indicadores bursátiles.
- **#52 Infinite Scrolling / Lazy Loading.** Paginación real: al llegar al final del scroll (o con el botón "Siguiente página") se pide la página siguiente a AniList y el gráfico crece.
- **#63 Real-time Streaming.** Actualización periódica real desde AniList (polling, no WebSocket): Timer → GraphQL → comparar con la lectura anterior → `ChangeNotifier` → gráfico.

## 10. Conclusión

Graphic muestra los **63/63** casos. Su gramática cubre casi toda la matriz combinando marcas, coordenadas y modificadores; el precio es pensar el gráfico por capas y calcular fuera la estadística. Solo #50 queda PARCIAL.
