# Reporte de integración — Matriz 63×4

> Los conteos se calculan desde el código: `master_chart_registry.dart` (capacidad y estado) y los mapas `CaseImpl` de cada librería (implementación). No existe un `matrix.txt` en el repositorio.

## 1. Objetivo y resultado

Objetivo de esta fase: que la app muestre **63 visualizaciones reales en cada una de las 4 librerías (252)**, con datos reales de AniList, sin `Random`, sin listas fijas y sin fallbacks como estado final.

**Resultado: 252/252 casos tienen builder y se dibujan con un gráfico de su librería.** Lo comprueba `test/case_builders_test.dart`, que monta cada uno de los 252 builders y verifica que aparece un widget de gráfico de esa librería (`LineChart`/`BarChart`/…, `SfCartesianChart`/…, `DChart*`, `Chart` de Graphic) y ningún aviso técnico.

## 2. Documentación por librería

- [FL Chart](FL_CHART.md)
- [Syncfusion Flutter Charts](SYNCFUSION.md)
- [d_chart](DCHART.md)
- [Graphic](GRAPHIC.md)

## 3. Versiones

| Librería | Versión (`pubspec.lock`) |
|---|---|
| fl_chart | 1.2.0 |
| syncfusion_flutter_charts | 34.2.9 |
| d_chart | 3.0.0 |
| graphic | 2.7.0 |

## 4. Tres ejes separados

- **Capacidad** (matriz): lo que la librería ofrece — NATIVO, VARIANTE, COMPOSICIÓN, NO SOPORTADO. No cambió en esta fase.
- **Implementación** (`CaseImpl.strategy`): cómo lo dibuja el proyecto — NATIVO, VARIANTE, COMPOSICIÓN o ADAPTACIÓN.
- **Estado** (matriz): FUNCIONAL o PARCIAL. Ya no quedan casos NO VERIFICADO ni NO DISPONIBLE.

Ejemplo: d_chart #32 Candlestick tiene capacidad NO SOPORTADO y se implementa como ADAPTACIÓN (dos `DChartBarO` superpuestos). Se ve un gráfico real, pero no se afirma que d_chart tenga velas.

## 5. Resumen por librería

| Librería | Con gráfico | FUNCIONAL | PARCIAL | Impl. NATIVO | Impl. VARIANTE | Impl. COMPOSICIÓN | Impl. ADAPTACIÓN | Capacidad NATIVO | Capacidad NO SOPORTADO |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| FL Chart | 63/63 | 62 | 1 | 10 | 35 | 13 | 5 | 23 | 0 |
| Syncfusion | 63/63 | 63 | 0 | 54 | 3 | 4 | 2 | 61 | 0 |
| d_chart | 63/63 | 61 | 2 | 19 | 24 | 13 | 7 | 20 | 3 |
| Graphic | 63/63 | 62 | 1 | 35 | 18 | 8 | 2 | 38 | 0 |

## 6. Casos PARCIAL

- FL Chart: #50 — sin marca de ruptura de eje.
- Syncfusion: ninguno.
- d_chart: #46, #50 — #46 marca las bandas con líneas límite (d_chart no sombrea regiones); #50 sin marca de ruptura de eje.
- Graphic: #50 — sin marca de ruptura de eje.

## 7. Adaptaciones

- FL Chart: #14, #15, #32, #33, #34
- Syncfusion: #32, #33
- d_chart: #4, #6, #14, #15, #27, #32, #33
- Graphic: #32, #33

Todas llevan una nota visible en su tarjeta que explica qué se adaptó.

## 8. Casos que antes estaban bloqueados

| Caso | Antes | Ahora |
|---|---|---|
| #32 Candlestick, #33 HLOC | NO DISPONIBLE | Velas semanales sobre la variación diaria de `Media.trends.popularity`. *Candlestick adaptado a tendencia de popularidad AniList. No representa cotización financiera.* |
| #41 SMA, #42 Bollinger, #43 RSI, #44 MACD | NO DISPONIBLE | Fórmulas estándar sobre la misma serie real. |
| #52 Infinite Scrolling | Paginación local o sin implementar | Paginación real: `Page(page, perPage: 20)` al llegar al final del scroll. |
| #63 Real-time Streaming | `Stream.periodic` sobre datos cargados (DEMO) | Sondeo real cada 30 s: Timer → GraphQL → comparar → `ChangeNotifier` → gráfico. |
| Graphic #62 | NO DISPONIBLE (sin rankings) | `rankings` añadido a la consulta. |

Comprobado contra la API real durante el desarrollo: la paginación trajo 2 páginas reales (40 obras de manga) y el sondeo hizo lecturas reales de `popularity`. En ~30 s AniList no había cambiado esos contadores (Δ = 0), y la UI lo muestra así.

## 9. Matriz completa 63×4

Formato: `capacidad → implementación / estado`. N = nativo, V = variante, C = composición, A = adaptación, NS = no soportado; F = funcional, P = parcial.

| # | Caso maestro | FL Chart | Syncfusion | d_chart | Graphic |
|---:|---|---|---|---|---|
| 1 | Línea Simple | N → N / F | N → N / F | N → N / F | N → N / F |
| 2 | Columna Vertical | N → N / F | N → N / F | N → N / F | N → N / F |
| 3 | Barra Horizontal | N → V / F | N → N / F | N → N / F | N → N / F |
| 4 | Línea Curva / Spline | N → V / F | N → N / F | V → A / F | N → N / F |
| 5 | Área | N → V / F | N → N / F | N → V / F | N → N / F |
| 6 | Spline Area | N → V / F | N → N / F | V → A / F | N → N / F |
| 7 | Pie | N → N / F | N → N / F | N → N / F | N → N / F |
| 8 | Doughnut | N → V / F | N → N / F | N → N / F | N → N / F |
| 9 | Radial Bar | C → C / F | N → N / F | C → C / F | N → N / F |
| 10 | Scatter | N → N / F | N → N / F | N → N / F | N → N / F |
| 11 | Bubble | V → V / F | N → N / F | V → V / F | N → N / F |
| 12 | Step Line | N → V / F | N → N / F | V → V / F | N → N / F |
| 13 | Step Area | N → V / F | N → N / F | V → V / F | N → N / F |
| 14 | Pyramid | V → A / F | N → N / F | V → A / F | N → N / F |
| 15 | Funnel | V → A / F | N → N / F | V → A / F | N → N / F |
| 16 | Histogram | V → V / F | N → N / F | V → V / F | V → V / F |
| 17 | Stacked Column | N → V / F | N → N / F | N → N / F | N → N / F |
| 18 | Stacked Bar | N → V / F | N → N / F | N → N / F | N → N / F |
| 19 | Stacked Area | V → V / F | N → N / F | N → N / F | N → N / F |
| 20 | Stacked Line | V → V / F | N → N / F | N → N / F | N → N / F |
| 21 | 100% Stacked Column | V → V / F | N → N / F | V → V / F | N → N / F |
| 22 | 100% Stacked Bar | V → V / F | N → N / F | V → V / F | N → N / F |
| 23 | 100% Stacked Area | V → V / F | N → N / F | V → V / F | N → N / F |
| 24 | 100% Stacked Line | V → V / F | N → N / F | V → V / F | N → N / F |
| 25 | Range Column | N → V / F | N → N / F | V → V / F | N → N / F |
| 26 | Range Area | V → V / F | N → N / F | V → V / F | N → N / F |
| 27 | Spline Range Area | V → V / F | N → N / F | V → A / F | N → N / F |
| 28 | Waterfall | V → V / F | N → N / F | V → V / F | V → V / F |
| 29 | Line with markers | N → V / F | N → N / F | N → N / F | N → N / F |
| 30 | Diverging Bar | N → V / F | N → N / F | N → N / F | N → V / F |
| 31 | Sparkline Line | V → V / F | N → N / F | V → V / F | V → V / F |
| 32 | Candlestick | N → A / F | N → A / F | NS → A / F | N → A / F |
| 33 | HLOC | C → A / F | N → A / F | NS → A / F | C → A / F |
| 34 | Box and Whisker | V → A / F | N → N / F | NS → C / F | C → C / F |
| 35 | Error Bars | N → N / F | N → V / F | V → C / F | C → C / F |
| 36 | Combined Column + Line | C → C / F | N → N / F | N → N / F | N → N / F |
| 37 | Dual Y Axis | V → C / F | N → N / F | N → N / F | N → N / F |
| 38 | Pan & Zoom | N → N / F | N → N / F | N → N / F | N → N / F |
| 39 | Crosshair | C → C / F | N → N / F | C → C / F | N → N / F |
| 40 | Trackball | V → V / F | N → N / F | C → C / F | V → V / F |
| 41 | SMA | V → V / F | N → N / F | V → V / F | V → V / F |
| 42 | Bollinger Bands | V → V / F | N → N / F | V → V / F | V → V / F |
| 43 | RSI | V → V / F | N → N / F | V → V / F | V → V / F |
| 44 | MACD | C → C / F | N → N / F | V → V / F | V → V / F |
| 45 | Trendline Regression | V → V / F | N → N / F | V → V / F | V → V / F |
| 46 | Plot Bands / Strip Lines | N → N / F | N → N / F | V → V / P | N → N / F |
| 47 | Cartesian Widget Annotations | C → C / F | N → N / F | C → C / F | C → C / F |
| 48 | Multi-colored Line | V → V / F | N → N / F | N → N / F | V → V / F |
| 49 | Palette Gradient Series | N → N / F | N → N / F | N → N / F | N → N / F |
| 50 | Break / Gapless DateTime Axis | V → V / P | N → N / F | V → V / P | V → V / P |
| 51 | Logarithmic Scale | V → V / F | N → N / F | V → V / F | V → V / F |
| 52 | Infinite Scrolling / Lazy Loading | C → C / F | N → C / F | C → C / F | C → C / F |
| 53 | Shaded Doughnut | N → N / F | N → N / F | N → N / F | V → V / F |
| 54 | Semi-Doughnut Progress | C → C / F | N → V / F | V → V / F | V → V / F |
| 55 | Range Selection Data Filter | C → C / F | C → C / F | C → C / F | C → C / F |
| 56 | Exploding Radial Bar | C → C / F | C → C / F | C → C / F | C → C / F |
| 57 | Sparkline Win-Loss | V → V / F | N → N / F | V → V / F | V → V / F |
| 58 | Sparkline Area with Min/Max | V → V / F | N → N / F | V → V / F | V → V / F |
| 59 | Multi-shape Categorical Scatter | N → N / F | N → N / F | V → C / F | N → N / F |
| 60 | Fully Customized Widget Tooltip | C → C / F | N → N / F | C → C / F | C → C / F |
| 61 | Staggered Animation | C → C / F | N → V / F | C → C / F | V → C / F |
| 62 | Inverted / Opposed Axis | V → V / F | N → N / F | N → N / F | N → V / F |
| 63 | Real-time Streaming | C → C / F | N → C / F | C → C / F | N → N / F |

## 10. Cambios principales

- **Datos:** `rankings` en el fragmento GraphQL; nuevas consultas `getMediaTrends` y `getMediaSnapshots` (DataSource → Repository); entidad `MediaTrend`.
- **Estado:** `ChartsDatasetProvider` descarga `Media.trends` de la obra más popular; nuevo `AniListLiveProvider` (#52, #63), registrado en `main.dart`.
- **Dataset común:** `GraphicDataset` calcula la variación diaria y las velas (`dailyGains`, `ohlc`) y lo usan las cuatro librerías.
- **Casos:** `flChartCases`, `syncfusionCases`, `dChartCases`, `graphicCases` (63 cada uno).
- **Galerías:** las cuatro usan `MasterCaseGallery`, con filtros por implementación y por categoría. Se eliminaron el mapa heredado, los fallbacks como contenido y el código muerto de d_chart (`d_chart_registry.dart`, `d_chart_basic_charts.dart`).
- **Matriz:** estados actualizados: 248 FUNCIONAL y 4 PARCIAL.
- **Revisión visual:** se renderizaron los 252 casos a imagen con datos reales y se corrigieron los defectos que los tests no detectaban: la orientación de las barras en d_chart (la implementación anterior de #2/#3 estaba invertida); los ejes numéricos de d_chart que empezaban en 0; las etiquetas duplicadas; el degradado de d_chart; la pirámide y el funnel descentrados de Graphic; y las barras de error negras sobre fondo oscuro en Graphic, Syncfusion y d_chart.

## 11. Validación

Ejecutado el 2026-09-25 con Flutter 3.47.2 (stable).

| Comando | Resultado |
|---|---|
| `flutter test test/` | `All tests passed!` — 457 tests. |
| `flutter analyze` | 3 issues de nivel **info**, ya existentes en Graphic (`prefer_initializing_formals`, `dangling_library_doc_comments`, `use_super_parameters`). 0 errores, 0 warnings. |
| `flutter build web` | `✓ Built build/web`. |
| `git diff --check` | Sin problemas de espacios. |

Tests relevantes para la matriz:

- `test/case_builders_test.dart`: 252/252 builders. Declara los 63 casos por librería (con origen y API) y monta cada builder exigiendo un widget de gráfico de su librería y ningún aviso técnico. También comprueba que ningún caso quede NO VERIFICADO, NO DISPONIBLE ni ROTO en la matriz.
- `test/charts_gallery_test.dart`: las 4 galerías recorren sus 63 tarjetas sin excepciones.
- `test/live_and_trends_test.dart`: variación diaria, OHLC, carga de trends en el provider, tolerancia a fallos de trends, paginación y sondeo.
- `test/graphic/*`: humo de los 63 builders de Graphic con y sin trends.

Verificaciones manuales hechas durante el desarrollo (no automatizadas):

- Render de los 252 casos a imagen con la muestra real de AniList (anime) y revisión visual; los defectos encontrados se corrigieron (sección 10).
- Llamadas reales a AniList: paginación (2 páginas de manga, 40 obras) y sondeo de `popularity`.
- No se probó la app a mano en un navegador en esta fase.

## 12. Conclusión

La matriz 63×4 está completa como evaluación **y** como implementación: las cuatro galerías muestran 63 visualizaciones reales cada una (252). La capacidad teórica de cada librería sigue registrada por separado, así que la comparación sigue siendo honesta: Syncfusion lo resuelve casi todo con componentes nativos; Graphic, con su gramática; FL Chart, con variantes de seis familias; y d_chart necesita más composición y adaptación. Los datos financieros no existen en AniList; los casos que los pedían se resolvieron como adaptaciones sobre la popularidad real, documentadas como tales.
