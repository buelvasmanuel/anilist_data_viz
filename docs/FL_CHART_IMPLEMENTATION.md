# Implementación de FL Chart 1.2.0 — Casos básicos 1–31

Los números y nombres de los casos siguen la **LISTA_CANDIDATA_63**: una lista provisional de trabajo (31 básicas + 32 avanzadas) extraída de material de trabajo. **No es una lista oficial del profesor.**

- Clasificación según la matriz FL Chart del proyecto:
  - **NATIVO:** el widget de FL Chart usado directamente.
  - **VARIANTE:** configuración de un widget nativo.
  - **COMPOSICIÓN:** FL Chart combinado con widgets o estado de Flutter.
- **Familia principal:** el gráfico de FL Chart que sirve de base.
- **Estado:** los casos 1–31 están implementados y se ven en `ChartsGalleryScreen`. Los casos 32–63 **no se han empezado**.

## Datos

- **Origen:** la galería usa `ChartsDatasetProvider` (`lib/presentation/state/`).
  - Carga 4 páginas × 50 obras del tipo elegido (Anime o Manga), en paralelo.
  - Usa la consulta GraphQL existente (`sort: POPULARITY_DESC`).
  - Es independiente de `MediaProvider`: no hereda sus filtros ni modifica su estado.
- **Alcance:** las gráficas describen **solo esta muestra** (las 200 obras más populares del tipo elegido), no toda la base de AniList.
- **Transformaciones:** están en `DataTransformations` y no generan valores que no salgan de la muestra.
- **Qué no se modificó:** `lib/core`, `lib/data` y `lib/domain`.

### Transformaciones

| Código | Método | Salida | Notas |
|---|---|---|---|
| T1 | `mediaToGenreCount` | `ChartDataCategory` | Una obra cuenta en cada uno de sus géneros (existente). |
| T2 | `mediaToAverageScorePerYear` | `ChartDataXY` | Media de `averageScore` por año de inicio (existente). |
| N1 | `mediaToCountPerYear` | `ChartDataXY` | Obras por año. Los años intermedios sin obras aparecen con conteo 0 real. |
| N2 | `mediaToNumericBins` + `binsToCategories` | `ChartDataXY` / `ChartDataCategory` | Bins de ancho fijo con bin final abierto opcional ("≥72"). Omite las obras sin valor. |
| N3 | `mediaToAverageScoreByGenre` | `ChartDataCategory` | `minCount` descarta géneros con pocas obras puntuadas (la galería usa 5). |
| N3b | `mediaToGenreScoreDeviation` | `ChartDataCategory` | Score medio del género − media de la muestra. Los negativos son legítimos. |
| N4 | `mediaToCategoryCount(selector)` + `topNWithOthers` | `ChartDataCategory` | Campo univaluado: cada obra cuenta una vez. "Otros" es la suma real del resto. |
| N7 | `mediaToSummaryKpis` | `ChartDataSummary` | Total, obras puntuadas, score medio, FINISHED / obras con estado. Si falta el dato, el valor es `null`. |

**Campos categóricos por tipo (N4).** En la muestra de anime, `format` (185 de 200 son TV) y `status` (199 de 200 FINISHED) casi no varían, y en manga no existe `season`. Por eso la galería usa:

| Uso | Anime | Manga |
|---|---|---|
| Pie principal | `source` (top 5 + Otros) | `status` |
| Pie alternativo | `season` | `countryOfOrigin` |
| Comparativa binaria (30) | `source`: Manga vs Original | `status`: Finished vs Releasing |

## Wrappers

| Archivo | Widget | Tipo |
|---|---|---|
| `fl_bar_charts.dart` | `BasicBarChart` | Wrapper sobre `BarChart`. Opciones: `rotationQuarterTurns`, `barWidth`, `groupsSpace` (con alineación center), `BarColorMode` (único, por categoría, por signo), `minY`/`maxY`/`baselineY`, línea base con `ExtraLinesData`, cuadrícula horizontal, `backDrawRodData`, `borderSide`, etiquetas de valor con tooltip fijo y animación desactivable. |
| `fl_line_charts.dart` | `BasicLineChart` | Wrapper sobre `LineChart`. Opciones: ejes, cuadrícula y borde desactivables, puntos, área, `isCurved` + `curveSmoothness`, formato de ejes y animación. |
| `fl_pie_charts.dart` | `BasicPieChart` | Wrapper sobre `PieChart`. Opciones: donut, anillo delgado, `sectionsSpace`, `borderSide`, tonos HSL, modo de título y animación. Tiene `highlightedIndex` y `onSectionTapped` preparados para la selección futura (caso 54). |
| `fl_progress_charts.dart` | `ProgressBarChart` | Wrapper propio sobre `BarChart` (no es un widget de FL Chart). |
| `fl_gauge_charts.dart` | `SemiCircleGauge` | Composición propia: `PieChart` + `ClipRect`/`OverflowBox` + `Stack`. FL Chart no tiene un widget de gauge. |
| `fl_summary_cards.dart` | `CompactSummaryCard` | Composición: `Card` + KPI + gráfico existente. |
| `chart_palette.dart` | `ChartPalette` | Paleta con contraste en tema oscuro. No se usa `ThemeData.primaryColor`, que en Material 3 oscuro equivale al color de superficie. |

## Casos 1–31 implementados

| # | Caso | Familia | Clasif. | Wrapper / técnica | Datos |
|---|---|---|---|---|---|
| 1 | Barra Vertical Ordinal Estándar | BarChart | NATIVO | `BasicBarChart` | T1 top 10 |
| 2 | Barra Horizontal Ordinal | BarChart | VARIANTE | `rotationQuarterTurns: 1` | T1 top 10 |
| 3 | Barra Numérica (Eje X Continuo) | BarChart | VARIANTE | bins como grupos equiespaciados | N2: episodes (bins de 12, ≥72) / chapters (bins de 50, ≥300) |
| 4 | Barra Temporal Simple | BarChart | VARIANTE | una etiqueta cada 5 años | N1 |
| 5 | Barra Personalizada Ligera | BarChart | VARIANTE | `width` 8, `borderSide`, `backDrawRodData` | T1 top 8 |
| 6 | Barras con Color Estático Único | BarChart | VARIANTE | `BarColorMode.single` | T1 top 10 |
| 7 | Barras con Color por Categoría | BarChart | VARIANTE | `BarColorMode.byCategory` | T1 top 10 |
| 8 | Barras con Esquinas Redondeadas | BarChart | VARIANTE | `borderRadius` | T1 top 10 |
| 9 | Barras sin Ejes (Sparkline) | BarChart | VARIANTE | sin títulos, cuadrícula ni borde | N1 |
| 10 | Barras con Línea Base Cero Fija | BarChart | VARIANTE | `minY: 0`, `baselineY: 0` + `ExtraLinesData` | N3 |
| 11 | Barras con Valores Negativos | BarChart | VARIANTE | `BarColorMode.bySign`, horizontal | N3b |
| 12 | Línea Numérica Simple | LineChart | NATIVO | `BasicLineChart` | N2 averageScore (bins de 5) |
| 13 | Línea Temporal Básica | LineChart | VARIANTE | eje X de años | T2 |
| 14 | Línea con Puntos Marcadores | LineChart | VARIANTE | `FlDotData` | T2 |
| 15 | Área Bajo la Curva Simple | LineChart | VARIANTE | `belowBarData` | T2 |
| 16 | Línea Minimalista | LineChart | VARIANTE | sin puntos, área, ejes, cuadrícula ni borde | T2 |
| 17 | Torta / Pie Estándar Ordinal | PieChart | NATIVO | `BasicPieChart` | N4 (pie principal) |
| 18 | Torta con Datos Numéricos | PieChart | VARIANTE | secciones = bins | N2 averageScore (bins de 10) |
| 19 | Dona Clásica | PieChart | VARIANTE | `centerSpaceRadius` | N4 (pie alternativo) |
| 20 | Dona con Anillo Delgado | PieChart | VARIANTE | `centerSpaceRadius` grande + `radius` pequeño | N4 (pie principal) |
| 21 | Torta Monocromática | PieChart | VARIANTE | tonos HSL de un color | N4 (pie alternativo) |
| 22 | Gauge Base Semicircular | PieChart + Flutter | COMPOSICIÓN | `SemiCircleGauge` | N7 score medio / 100 |
| 23 | Barras con Espaciado | BarChart | VARIANTE | `width` 16 + `groupsSpace` 36 | T1 top 6 |
| 24 | Barras con Cuadrícula Activa | BarChart | VARIANTE | `FlGridData` horizontal | T1 top 10 |
| 25 | Barras sin Animación | BarChart | VARIANTE | `duration: Duration.zero` | T1 top 10 |
| 26 | Línea sin Animación | LineChart | VARIANTE | `duration: Duration.zero` | T2 |
| 27 | Torta sin Animación | PieChart | VARIANTE | `duration: Duration.zero` | N4 (pie principal) |
| 28 | Barra de Progreso KPI | BarChart | VARIANTE | `ProgressBarChart` | N7 % FINISHED |
| 29 | Torta con Borde de Separación | PieChart | VARIANTE | `sectionsSpace` + `borderSide` | N4 (pie alternativo) |
| 30 | Comparativa Binaria | BarChart | VARIANTE | 2 categorías + etiquetas con tooltip fijo | N4 (binaria según el tipo) |
| 31 | Tarjeta de Resumen | LineChart + Flutter | COMPOSICIÓN | `CompactSummaryCard` + `BasicLineChart` | N7 + N1 |
| 32 | Barras Agrupadas Multiserie | BarChart | VARIANTE | `MultiSeriesBarChart` | N5 (status vs source) |
| 33 | Barras Apiladas | BarChart | VARIANTE | `MultiSeriesBarChart` + `isStacked` | N5 (status vs source) |
| 34 | Líneas Multiserie Comparativas | LineChart | VARIANTE | `MultiLineChart` | N10 (source) |
| 35 | Línea con Relleno Semitransparente | LineChart | VARIANTE | `showArea` con color | T2 |
| 36 | Donut con Widget Central | PieChart + Flutter | COMPOSICIÓN | `Stack(PieChart, Column)` | N4 + total |
| 37 | Donut con Etiquetas Externas | PieChart | VARIANTE | `titlePositionPercentageOffset: 1.5` | N4 |
| 38 | Donut con Etiquetas Internas | PieChart | VARIANTE | `titlePositionPercentageOffset: 0.5` | N4 |
| 39 | Serie Temporal Multivariable | LineChart | VARIANTE | `MultiLineChart` | N9 (conteo relativo vs score relativo) |
| 40 | Barras con Etiquetas Numéricas | BarChart | VARIANTE | `showRodLabels` nativo | T1 top 8 |
| 41 | Líneas con Ejes Rotados | LineChart | COMPOSICIÓN | `RotatedBox` | T2 |
| 42 | Barras con Línea de Meta | BarChart | VARIANTE | `showBaselineLine` | T1 top 10 |
| 43 | Barras con Desplazamiento Horizontal| BarChart | COMPOSICIÓN | `SingleChildScrollView` horizontal | T1 (todos los géneros) |
| 44 | Gráfica Reactiva en Tiempo Real | LineChart + Flutter | COMPOSICIÓN | `StreamBuilder` simulación | T2 (carga reactiva simulada mediante Stream.periodic) |
| 45 | Medidor Gauge de Tres Segmentos | PieChart + Flutter | COMPOSICIÓN | `ClipRect` + `BasicPieChart` semicircular | N4 (3 categorías) |
| 46 | Líneas con Selección de Punto | LineChart | NATIVO | `enableTouch: true` | T2 |
| 47 | Barras con Rango Y Forzado | BarChart | VARIANTE | `minY: 0, maxY: 100` | T1 top 10 |
| 48 | Barras Horizontales Multiserie | BarChart | VARIANTE | `MultiSeriesBarChart` horizontal | N5 |
| 49 | Formato Monetario en Eje Y | BarChart | VARIANTE | `valueFormatter` con \$ | T1 (adaptación técnica del eje, sin inventar ingresos) |
| 50 | Formato de Fecha Personalizado | LineChart | VARIANTE | `xLabelFormatter` año-mes | N6 |
| 51 | Barras con Gradiente Vertical | BarChart | VARIANTE | `barGradient` | T1 top 10 |
| 52 | Gráfica Filtrable por Estado | BarChart + Flutter | COMPOSICIÓN | Simulación de filtro dinámico | T1 > 10 |
| 53 | Líneas Suavizadas (Spline) | LineChart | VARIANTE | `isCurved: true` | T2 |
| 54 | Dona con Porción Resaltada | PieChart | VARIANTE | `highlightedIndex` | N4 |
| 55 | Distribución de Frecuencias | BarChart | VARIANTE | `groupsSpace: 0` (Histograma) | N2 |
| 56 | Tendencia y Dispersión | ScatterChart | COMPOSICIÓN | `ScatterTrendChart` (Scatter + Line) | N8 (popularity vs score) |
| 57 | Tarjeta Dashboard KPI Avanzada | LineChart + Flutter | COMPOSICIÓN | `CompactSummaryCard` | N7 + N1 |
| 58 | Gráfica Exportable a Imagen | Flutter | COMPOSICIÓN | `RepaintBoundary` | T1 top 6 (limitación web documentada) |
| 59 | Donut Multianillo | PieChart + Flutter | COMPOSICIÓN | `Stack` de 2 DonutCharts finos | N4 (main + alt) |
| 60 | Barras con Cuadrícula Secundaria | BarChart | VARIANTE | `gridInterval: 5` | T1 top 10 |
| 61 | Progreso Multinivel | BarChart | VARIANTE | `MultiSeriesBarChart` apilado horizontal | N7 |
| 62 | Fondo de Área Condicional | LineChart | VARIANTE | `showArea` con `minY` condicional | T2 |
| 63 | Dashboard Sincronizado | Composición | COMPOSICIÓN | `Column` con Line y Bar sincronizadas | T2 + T1 |

**Totales Fase 2:** 63 casos implementados. Nuevas transformaciones N5, N6, N8, N9, N10 para soportar requerimientos avanzados. Esta lista de casos es candidata y demostrativa, no una clasificación oficial. Los datos mostrados provienen de la muestra extraída de la API de AniList en tiempo de ejecución y **no representan la totalidad de la base de datos de AniList**. AniList no posee datos de ventas monetarias ni proyecciones; cualquier adaptación de este tipo en la lista es estrictamente representativa a nivel técnico.

## Limitaciones conocidas

- **Caso 3:** `BarChartGroupData.x` es `int` y las barras quedan equiespaciadas. Es una aproximación de eje continuo: bins del mismo ancho, con el último abierto.
- **Casos 10 y 11:** usan medias por género de la muestra. Los géneros con menos de 5 obras puntuadas se excluyen.
- **Casos 25–27:** la animación de FL Chart solo se ve cuando cambian los datos. Al alternar Anime/Manga, los demás casos animan y estos no.
- **Pies:** las porciones de menos del 5 % no muestran título, para evitar solapamientos.
- **Caso 28 (Anime):** en la muestra de anime el KPI sale 199/200 (99,5 %). Es el valor real, no un error.
- **Caso 30:** no compara Anime con Manga porque la galería carga un solo tipo por muestra.
- **Caso 39 (Adaptación):** Al no existir métricas de ventas reales, se graficaron dos métricas reales de AniList (conteo de obras y puntuación media anual) normalizadas de 0 a 1 para demostrar el soporte de ejes con valores diametralmente distintos sin aplastar el gráfico.
- **Caso 40:** Usa `BarChartRodData.label` que introdujo FL Chart 1.2.0.
- **Caso 44 (Adaptación):** Carga reactiva simulada mediante `Stream.periodic`. AniList no proporciona WebSocket en esta arquitectura para estas métricas.
- **Caso 49 (Adaptación):** AniList no proporciona datos monetarios reales. Se demuestra el formato monetario en el eje Y aplicándolo sobre los conteos de obras mediante una función técnica, sin afirmar que sean ingresos.
- **Caso 56 (Adaptación):** ScatterChart con LineChart superpuesto usando Stack de Flutter para simular la línea de tendencia de Popularidad vs Puntuación.
- **Caso 58:** La exportación a imagen se basa en empaquetar el gráfico dentro de un widget `RepaintBoundary`. En Flutter Web (CanvasKit), esto funciona; pero en web render con HTML se requiere CORS configurado si se intentan cargar imágenes de red (aunque aquí dibujamos vectores, la exportación puede verse limitada por restricciones del navegador).
- **Caso 63:** Problema de layout en orientación apaisada (landscape). Al ser un dashboard anidado dentro de un `GridView` con altura controlada y `Expanded`, la compresión horizontal/vertical extrema en redimensiones severas puede romper el layout. Requiere un refactor del `ChartsGalleryScreen` completo hacia listados adaptativos, por lo que se mantiene la limitación en esta fase técnica.

## Hallazgo sobre la API (pendiente de revisar en la matriz del caso 40)

FL Chart 1.2.0 añadió `BarChartRodData.label` (`BarChartRodLabel`) para mostrar una etiqueta encima de cada barra (changelog 1.2.0, #2071). En esta fase, las etiquetas de valor de `BasicBarChart` (caso 30) usan el **tooltip fijo**, como se pidió. Hay que decidir si el caso 40 debe documentar también esta API nativa.

## Validación

- `flutter analyze`: sin problemas (0 errors).
- `flutter test`: 45 tests pasados exitosamente.
  - Transformaciones ampliadas: N5, N6, N8, N9, N10.
  - La galería completa con los 63 casos de FL Chart se renderiza sin errores.
- Revisión de Flutter Web Edge (`flutter run -d edge`): 
  - Validado funcionalmente la interfaz interactiva. No se reportan crashes.
  - Las nuevas wrappers multi-series y multi-line aplican la paleta de manera correcta.
  - Los gradientes y tooltip offsets respetan el diseño moderno.
