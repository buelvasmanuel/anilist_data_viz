# Auditoría técnica 252 — estado actual

> Fecha: 2026-09-25 · Flutter 3.47.2 / Dart 3.13.2 · Proyecto `anilist_data_viz`.
> Fase de **solo auditoría**: no se modificó código, documentación, matriz ni git. El único archivo creado en el repositorio es este.
>
> Etiquetas de evidencia:
> - **VERIFICADO**: leído en el código (archivo:línea) o ejecutado con resultado reproducible.
> - **OBSERVADO**: visto al ejecutar la app en entorno de test (render a PNG con datos reales de AniList, pruebas de scroll/hover).
> - **INFERIDO**: conclusión razonada a partir del código, sin ejecución que la confirme.

## Resumen ejecutivo

1. **Los 252 casos existen y dibujan un gráfico real** (VERIFICADO + OBSERVADO): 63 claves por librería, sin duplicados ni huecos; los 252 builders renderizaron con la muestra **real** de AniList a 328, 480 y 900 px de ancho sin ninguna excepción.
2. **Nada de lo anterior está commiteado.** `HEAD` (= `origin/main`, 342a5cd) contiene todavía las galerías antiguas, el bug de scroll y la documentación anterior. Todo el trabajo 63×4 vive en el working tree (27 archivos modificados, 2 borrados staged, 16 rutas sin seguimiento). Es el riesgo n.º 1.
3. **Bug de scroll: causa raíz encontrada y reproducida en HEAD**: un `StreamBuilder` con `Stream.periodic(...)` (single-subscription) construido una sola vez dentro de un `ListView(children: …)`. Al volver a montar la tarjeta, el nuevo `State` escucha el mismo `Stream` → `Bad state: Stream has already been listened to` → cascada `_dependents.isEmpty` / `_lifecycleState == active`. **En el working tree el bug no se reproduce** (0 errores en 4 galerías × 3 ciclos de scroll + hover).
4. **Defectos que los tests no detectan** (OBSERVADO): Syncfusion #35 no dibuja las barras de error; Syncfusion #28 (waterfall) baja a valores negativos imposibles; leyendas de DChart #33 y #44 con colores que no corresponden; DChart #62 no pone el eje X arriba aunque su API lo dice; tooltips de FL Chart que muestran valores transformados (value/2, año+0.3, log10).
5. **Hover**: la diferencia de UX es real y tiene causa de librería. d_chart 3.0.0 **no tiene tooltip ni hover** (y `defaultInteractions` es `false` por defecto); Graphic sí soporta hover pero solo 9 de 63 builders declaran `TooltipGuide`. Syncfusion y FL tampoco cubren los 63 (25 casos de Syncfusion sin `TooltipBehavior`; FL muestra solo el número en la mayoría).
6. **Documentación vigente = código** (VERIFICADO): las tablas de `FL_CHART.md`, `SYNCFUSION.md`, `DCHART.md`, `GRAPHIC.md` e `integration_report.md` coinciden celda por celda con el código (0 diferencias en 315 filas). Pero no documentan los defectos anteriores, y los documentos históricos no llevan aviso de "histórico".
7. `flutter test test/`: **457 tests OK**. `flutter analyze`: 3 `info` (sale con código 1). `flutter build web`: **OK**.

---

## 1. Estado del repositorio

VERIFICADO (`git status`, `git branch -vv`, `git log --oneline -5`):

| Dato | Valor |
|---|---|
| Rama actual | `main`, al día con `origin/main` |
| Commit actual | `342a5cd Clean project structure and documentation` |
| Commits anteriores | `c2104ad Merge final 63x4 chart integration` · `aa1c60e Finalize 63x4 chart integration reconciliation` · `79acf5c Integrate Graphic package to main architecture` · `ad90d6a Revert "Sync current project state"` |
| Otras ramas | `final-integration` (aa1c60e), `graphic-integration` (79acf5c) |
| Staged | 2 borrados: `lib/charts/d_chart/charts/d_chart_basic_charts.dart`, `lib/charts/d_chart/d_chart_registry.dart` |
| Modificados sin stage | 27 archivos (README, `docs/integration_report.md`, 4 pantallas de galería, provider, datasource, queries, modelos, registry maestro, Graphic, 3 tests) — `git diff --stat`: +891 / −2707 |
| Sin seguimiento | `docs/DCHART.md`, `docs/FL_CHART.md`, `docs/GRAPHIC.md`, `docs/SYNCFUSION.md`, `lib/charts/common/`, `d_chart_case_builders.dart`, `fl_case_builders.dart`, `graphic_cases.dart`, `master_case_presentation.dart`, `syncfusion_case_builders.dart`, `media_trend_model.dart`, `media_trend.dart`, `anilist_live_provider.dart`, `test/case_builders_test.dart`, `test/live_and_trends_test.dart`, `test/support/` |

**Consecuencia** (VERIFICADO): quien clone `origin/main` recibe las galerías antiguas (`charts_gallery_screen.dart` de 951 líneas con numeración propia "Casos 1–31"), el bug del scroll y una documentación que no corresponde a este informe. Todo lo auditado abajo es el **working tree**.

Efecto colateral de esta auditoría: `flutter build web` regeneró `build/web` (ignorado por `.gitignore:33`). Las pruebas de reproducción y render se ejecutaron en **copias** en un directorio temporal, no en el repositorio.

## 2. Arquitectura encontrada

VERIFICADO.

```text
AniList GraphQL (https://graphql.anilist.co)
 └ AniListRemoteDataSourceImpl        lib/data/datasources/anilist/anilist_remote_datasource.dart
     getMediaList · getMediaById · getMediaTrends (:135) · getMediaSnapshots (:155)
 └ AniListRepositoryImpl              lib/data/repositories/anilist_repository_impl.dart (excepciones → Failure)
 └ Dominio: Media (+popularAllTimeRank, ratedAllTimeRank), MediaTrend, PageInfo
 └ Providers (lib/main.dart:18-22)
     MediaProvider                    pantallas de listado/detalle (no lo usan las galerías)
     ChartsDatasetProvider            muestra fija 4×50 + Media.trends → GraphicDataset
     AniListLiveProvider              #52 paginación · #63 sondeo
 └ Dataset común: GraphicDataset.fromAnime + GraphicTransformations (lib/charts/graphic/data/)
 └ Implementaciones: Map<int, CaseImpl> por librería
     flChartCases       lib/charts/fl_chart/fl_case_builders.dart:31
     syncfusionCases    lib/charts/syncfusion/syncfusion_case_builders.dart:27
     dChartCases        lib/charts/d_chart/d_chart_case_builders.dart:27
     graphicCases       lib/charts/graphic/graphic_cases.dart:100  (envuelve graphicChartRegistry)
 └ Galería común: MasterCaseGallery   lib/charts/common/master_case_gallery.dart
     4 pantallas de 17 líneas que solo le pasan (library, title, cases)
```

| Pieza | Archivo | Rol |
|---|---|---|
| Registry maestro | `lib/charts/models/master_chart_registry.dart` | 63 `MasterChartSpec`: nombre + capacidad + estado × 4 librerías (`const`) |
| Presentación de etiquetas | `lib/charts/models/master_case_presentation.dart` | labels/colores de capacidad y estado, `MasterBadge` |
| Modelo de caso | `lib/charts/common/case_support.dart` | `ImplementationStrategy`, `CaseCategory`, `CaseData`, `CaseImpl`, orígenes compartidos (`sharedCaseOrigins`), notas |
| Casos vivos | `lib/charts/common/live_case_hosts.dart` | `LazyLoadingHost` (#52), `LiveStreamingHost` (#63) |
| Índice | `lib/charts/common/library_cases.dart` | `casesFor(library)` — **solo lo usan los tests** |
| Registry paralelo Graphic | `lib/charts/graphic/graphic_chart_registry.dart` | 63 `GraphicChartSpec` con su propia clasificación (ver §13) |
| Registries FL / Syncfusion / DChart propios | — | **No existen** ya. `d_chart_registry.dart` está borrado (staged). |
| `legacyGalleryCaseFor` | — | **No existe** ni en el working tree ni en ningún commit de ninguna rama (`git grep` sobre `git rev-list --all`). |
| Transformaciones antiguas | `lib/charts/transformations/data_transformations.dart` | solo la usan tests y wrappers sin uso |

**Código muerto** (VERIFICADO: no los importa ningún archivo de `lib/`): `fl_multi_line_charts.dart`, `fl_progress_charts.dart`, `fl_scatter_trend_charts.dart`, `fl_summary_cards.dart`, y los 8 wrappers de Syncfusion `syncfusion_{bar,line,multi_bar,multi_line,pie,progress,scatter_trend,summary}_charts.dart`. `fl_progress_charts.dart` y `data_transformations.dart` solo los usan tests.

## 3. Fuente de verdad

VERIFICADO.

- `matrix.txt` **no existe** (ni en el proyecto ni en la carpeta padre; `git log --all -- matrix.txt` vacío).
- **Capacidad y estado**: `masterChartRegistry` (`master_chart_registry.dart:36`). Es la fuente que leen las tarjetas (`master_case_gallery.dart:218`, `support = master.getFor(library)`).
- **Implementación, origen, API, nota y builder**: los cuatro mapas `CaseImpl`. Para Graphic la estrategia se **deriva** de `graphicChartRegistry.classification` con una excepción manual para #32/#33 (`graphic_cases.dart:90-97`).
- **Nombres**: los de `masterChartRegistry`. Los 63 nombres de `graphicChartRegistry` son idénticos (VERIFICADO por script, 0 diferencias).
- Registry vs galerías: la galería itera `masterChartRegistry` y busca `widget.cases[m.number]!` (`master_case_gallery.dart:92-97, 109`); si faltara una clave habría un null-check en runtime. Las 4 × 63 claves existen.
- Registry vs documentación: 0 diferencias (ver §14).

**Discrepancia registrada**: hay **dos** clasificaciones de Graphic que no coinciden entre sí — ver §13, punto 2.

## 4. Estado de las 252 celdas

### 4.1 Comprobaciones comunes a las 252 celdas

| Comprobación | Resultado | Evidencia |
|---|---|---|
| ¿Existe builder? | 252/252 | VERIFICADO: 63 claves por mapa, clave == número pasado a `_impl(n, …)` en FL/SF/DC (script), Graphic construido desde el registry por `spec.number` |
| ¿Ruta de render? | 252/252 | `MasterCaseCard` → `impl.builder(context, data)` (`master_case_gallery.dart:249`) |
| ¿Devuelve un gráfico de su librería? | 252/252 | VERIFICADO `test/case_builders_test.dart:86` (fixture). OBSERVADO: render de los 252 con datos **reales** a 328/480/900 px, **0 excepciones**; 96 tarjetas (24 casos × 4) inspeccionadas visualmente |
| ¿Placeholder? | 0 | No hay widgets de relleno; `TechnicalIssue`/`GraphicEmptyState` solo aparecen si faltan datos |
| ¿Fallback? | Condicional | `withTrends` (#32, #33, #41–#44 en las 4) si `trendValues.length < 30` (`graphic_dataset.dart:283`); `guard(...)` en casi todos los builders de Graphic; `TechnicalIssue` en FL #25/#34/#55/#62, SF #55/#62, DC #25/#34/#35/#39/#55/#59/#62. Con la muestra real **no se activó ninguno** (OBSERVADO) |
| ¿Datos sintéticos en runtime? | 0 | VERIFICADO: sin `Random`, sin listas de ejemplo; las constantes son umbrales (80/60/70/30) o parámetros de indicadores |
| ¿`Random`? | 0 en `lib/` | `grep -rn Random lib` vacío |
| ¿Stream/Timer? | Solo donde toca | `Timer.periodic` en `anilist_live_provider.dart:131` (#63); `StreamController.broadcast()` en Graphic #43, #55, #60, #63 |
| ¿Requiere datos que no existen? | No | Todo sale de campos pedidos en `media_queries.dart` |

### 4.2 Tabla 63 × 4

Formato de celda: `capacidad→**implementación**` + marcas.
N = NATIVO, V = VARIANTE, C = COMPOSICIÓN, A = ADAPTACIÓN, NS = NO SOPORTADO.
Marcas: **T** = usa `Media.trends` · **L** = petición viva a AniList (#52 paginación, #63 sondeo) · **P** = estado PARCIAL en la matriz · **!** = problema visual o semántico OBSERVADO (detalle en §11).

| # | Caso | FL Chart | Syncfusion | DChart | Graphic |
|---:|---|---|---|---|---|
| 1 | Línea Simple | N→**N** | N→**N** | N→**N** | N→**N** |
| 2 | Columna Vertical | N→**N** | N→**N** | N→**N** | N→**N** |
| 3 | Barra Horizontal | N→**V** | N→**N** | N→**N** | N→**N** |
| 4 | Línea Curva / Spline | N→**V** | N→**N** | V→**A** | N→**N** |
| 5 | Área | N→**V** | N→**N** | N→**V** | N→**N** |
| 6 | Spline Area | N→**V** | N→**N** | V→**A** | N→**N** |
| 7 | Pie | N→**N** | N→**N** | N→**N** | N→**N** |
| 8 | Doughnut | N→**V** | N→**N** | N→**N** | N→**N** |
| 9 | Radial Bar | C→**C** | N→**N** | C→**C** | N→**N** |
| 10 | Scatter | N→**N** | N→**N** | N→**N** | N→**N** |
| 11 | Bubble | V→**V** | N→**N** | V→**V** | N→**N** |
| 12 | Step Line | N→**V** | N→**N** | V→**V** | N→**N** |
| 13 | Step Area | N→**V** | N→**N** | V→**V** | N→**N** |
| 14 | Pyramid | V→**A** ! | N→**N** | V→**A** | N→**N** ! |
| 15 | Funnel | V→**A** ! | N→**N** | V→**A** | N→**N** |
| 16 | Histogram | V→**V** | N→**N** | V→**V** | V→**V** |
| 17 | Stacked Column | N→**V** | N→**N** | N→**N** | N→**N** |
| 18 | Stacked Bar | N→**V** | N→**N** | N→**N** | N→**N** |
| 19 | Stacked Area | V→**V** | N→**N** | N→**N** | N→**N** |
| 20 | Stacked Line | V→**V** | N→**N** | N→**N** | N→**N** |
| 21 | 100% Stacked Column | V→**V** | N→**N** | V→**V** | N→**N** |
| 22 | 100% Stacked Bar | V→**V** | N→**N** | V→**V** | N→**N** |
| 23 | 100% Stacked Area | V→**V** | N→**N** | V→**V** | N→**N** |
| 24 | 100% Stacked Line | V→**V** | N→**N** | V→**V** | N→**N** |
| 25 | Range Column | N→**V** ! | N→**N** | V→**V** | N→**N** |
| 26 | Range Area | V→**V** | N→**N** | V→**V** | N→**N** |
| 27 | Spline Range Area | V→**V** | N→**N** | V→**A** | N→**N** |
| 28 | Waterfall | V→**V** ! | N→**N** ! | V→**V** | V→**V** |
| 29 | Line with markers | N→**V** | N→**N** | N→**N** | N→**N** |
| 30 | Diverging Bar | N→**V** | N→**N** | N→**N** | N→**V** |
| 31 | Sparkline Line | V→**V** | N→**N** ! | V→**V** | V→**V** ! |
| 32 | Candlestick | N→**A** T | N→**A** T | NS→**A** T | N→**A** T |
| 33 | HLOC | C→**A** T | N→**A** T | NS→**A** T ! | C→**A** T |
| 34 | Box and Whisker | V→**A** | N→**N** | NS→**C** ! | C→**C** ! |
| 35 | Error Bars | N→**N** | N→**V** ! | V→**C** | C→**C** |
| 36 | Combined Column + Line | C→**C** | N→**N** | N→**N** | N→**N** |
| 37 | Dual Y Axis | V→**C** | N→**N** | N→**N** | N→**N** |
| 38 | Pan & Zoom | N→**N** | N→**N** | N→**N** | N→**N** |
| 39 | Crosshair | C→**C** | N→**N** | C→**C** | N→**N** |
| 40 | Trackball | V→**V** | N→**N** | C→**C** | V→**V** |
| 41 | SMA | V→**V** T | N→**N** T | V→**V** T | V→**V** T ! |
| 42 | Bollinger Bands | V→**V** T | N→**N** T | V→**V** T | V→**V** T |
| 43 | RSI | V→**V** T | N→**N** T | V→**V** T | V→**V** T ! |
| 44 | MACD | C→**C** T | N→**N** T | V→**V** T ! | V→**V** T |
| 45 | Trendline Regression | V→**V** | N→**N** | V→**V** | V→**V** |
| 46 | Plot Bands / Strip Lines | N→**N** | N→**N** | V→**V** P | N→**N** |
| 47 | Cartesian Widget Annotations | C→**C** | N→**N** | C→**C** | C→**C** |
| 48 | Multi-colored Line | V→**V** | N→**N** | N→**N** | V→**V** |
| 49 | Palette Gradient Series | N→**N** | N→**N** | N→**N** | N→**N** |
| 50 | Break / Gapless DateTime Axis | V→**V** P | N→**N** | V→**V** P | V→**V** P ! |
| 51 | Logarithmic Scale | V→**V** ! | N→**N** | V→**V** | V→**V** |
| 52 | Infinite Scrolling / Lazy Loading | C→**C** L | N→**C** L | C→**C** L | C→**C** L ! |
| 53 | Shaded Doughnut | N→**N** | N→**N** ! | N→**N** | V→**V** |
| 54 | Semi-Doughnut Progress | C→**C** | N→**V** | V→**V** | V→**V** |
| 55 | Range Selection Data Filter | C→**C** | C→**C** | C→**C** | C→**C** |
| 56 | Exploding Radial Bar | C→**C** | C→**C** | C→**C** | C→**C** |
| 57 | Sparkline Win-Loss | V→**V** | N→**N** ! | V→**V** | V→**V** ! |
| 58 | Sparkline Area with Min/Max | V→**V** | N→**N** ! | V→**V** | V→**V** ! |
| 59 | Multi-shape Categorical Scatter | N→**N** | N→**N** | V→**C** | N→**N** |
| 60 | Fully Customized Widget Tooltip | C→**C** | N→**N** | C→**C** | C→**C** |
| 61 | Staggered Animation | C→**C** | N→**V** | C→**C** | V→**C** ! |
| 62 | Inverted / Opposed Axis | V→**V** ! | N→**N** | N→**N** ! | N→**V** ! |
| 63 | Real-time Streaming | C→**C** L ! | N→**C** L ! | C→**C** L ! | N→**N** L ! |

Todas las celdas: builder ✓ · render ✓ · datos reales ✓ · sin Random ✓.

## 5. Clasificaciones actuales

### A) Clasificación de capacidad

VERIFICADO. `ChartClassification { nativo, variante, composicion, noSoportado }` (`master_chart_registry.dart:11`), valores **almacenados** (`const`) en `masterChartRegistry`. Describe lo que ofrece la librería. Es el badge "Capacidad: …" de cada tarjeta (`master_case_gallery.dart:237`). **Sí sigue existiendo "NO SOPORTADO"**: DChart #32, #33, #34, que la UI muestra junto a "FUNCIONAL" y a un gráfico real.

### B) Clasificación de implementación

VERIFICADO. `ImplementationStrategy { nativo, variante, composicion, adaptacion }` (`case_support.dart:16-34`), almacenada en cada `CaseImpl.strategy`. Describe cómo lo dibuja el proyecto. Es el badge "Implementación: …" y la base de los filtros. En Graphic se deriva de `GraphicClassification` (3 valores) + override 32/33 → ADAPTACIÓN (`graphic_cases.dart:90-97`).

### C) Números de la UI

VERIFICADO. Se **calculan en cada build**: `countOf(s) => cases.values.where((c) => c.strategy == s).length` (`master_case_gallery.dart:139`); categorías con `caseCategoryOf` (`:140`). No hay contadores guardados.

### Conteos por librería

Implementación (lo que muestran los chips de filtro):

| Librería | Nativo | Variante | Composición | Adaptación | Total |
|---|---:|---:|---:|---:|---:|
| FL Chart | 10 | 35 | 13 | 5 | **63** |
| Syncfusion | 54 | 3 | 4 | 2 | **63** |
| DChart | 19 | 24 | 13 | 7 | **63** |
| Graphic | 35 | 18 | 8 | 2 | **63** |

Capacidad (badge de la matriz):

| Librería | Nativo | Variante | Composición | No soportado | Total |
|---|---:|---:|---:|---:|---:|
| FL Chart | 23 | 27 | 13 | 0 | 63 |
| Syncfusion | 61 | 0 | 2 | 0 | 63 |
| DChart | 20 | 30 | 10 | 3 | 63 |
| Graphic | 38 | 17 | 8 | 0 | 63 |

Estado: FL 62 F + 1 P (#50) · Syncfusion 63 F · DChart 61 F + 2 P (#46, #50) · Graphic 62 F + 1 P (#50) = 248 F + 4 P.

Adaptaciones: FL #14, #15, #32, #33, #34 · Syncfusion #32, #33 · DChart #4, #6, #14, #15, #27, #32, #33 · Graphic #32, #33.

## 6. Datos reales

### Qué se pide a AniList

VERIFICADO (`media_queries.dart`):

- **Muestra**: `getMediaList` (`:89-121`), `Page(page, perPage)` + `media(type, sort: POPULARITY_DESC)`. `ChartsDatasetProvider` pide **4 páginas × 50** en paralelo (`charts_dataset_provider.dart:26-27, 93-104`) → hasta 200 obras del tipo elegido, deduplicadas por id.
- Campos del fragmento (`:2-87`): id, títulos, type, format, status, description, startDate, endDate, season, seasonYear, episodes, duration, chapters, volumes, countryOfOrigin, isAdult, source, averageScore, meanScore, popularity, trending, favourites, **rankings {rank type allTime}**, genres, tags, studios (isMain), characters (5), relations, coverImage, bannerImage.
- **Rankings**: `MediaModel` extrae `POPULAR` y `RATED` all-time (`media_model.dart`, diff +12 líneas); las gráficas usan `ratedAllTimeRank` (`charts_dataset_provider.dart:136`).
- **Trends**: `getMediaTrends` (`:125-145`), `Media(id).trends(sort: DATE_DESC, page, perPage: 25)`; el provider pide **4 páginas** de la obra más popular (`charts_dataset_provider.dart:115-116, 162-178`) → ~100 días.
- **Sondeo**: `getMediaSnapshots` (`:148-163`), `Page(perPage: n) { media(id_in: ids) { id title popularity trending favourites } }`.

### Qué llega realmente (OBSERVADO con la API real, 2026-09-25)

| | ANIME | MANGA |
|---|---|---|
| Obras | 200 | 200 |
| Obra de trends | Shingeki no Kyojin (id 16498) | Chainsaw Man (id 105778) |
| Nodos trends / nulos en `popularity` | 100 / 0 | 100 / 0 |
| Variaciones diarias | 99 (mín 0, máx 1234; 7 días con 0) | 99 (mín 0, máx 233; 3 días con 0) |
| Velas / SMA / Bollinger / RSI / MACD | 14 / 93 / 80 / 85 / 73 | 14 / 93 / 80 / 85 / 73 |
| Años usados (últimos 10) | 2017–2026, obras/año `[9,16,17,11,18,15,9,4,2,1]` | 2014–2023 |
| Formatos principales | TV, MOVIE, ONA, TV_SHORT (**TV = 185 de 200**) | MANGA, ONE_SHOT, NOVEL |
| Status | **FINISHED 199 · RELEASING 1** | FINISHED 130 · RELEASING 69 · CANCELLED 1 |
| Con `averageScore` | 200 | 200 |
| Con episodes/chapters | 199 | 131 |
| Rankings "rated" | 15 usados | 15 usados |

Consecuencias de los datos reales (OBSERVADO en los renders): en ANIME, los casos por **status** (#8, #15, #18, #22) y por **format** (#7, #14, #53) quedan dominados por una sola categoría; #15 Funnel con dos niveles (199/1) no comunica nada. En #50 los 10 años son consecutivos: el texto dice "0 años sin obras", así que el eje sin huecos **no demuestra nada** con esta muestra. Solo ~la mitad de la muestra (102 de 200 en ANIME) cae en los "últimos 10 años" que usan los casos por año.

### Datos inventados

VERIFICADO: **ninguno en runtime**. No hay `Random`, `Stream.periodic`, OHLC ni precios ficticios en `lib/`. `HEAD` sí tenía `Stream.periodic` que reproducía datos cargados como si fueran en vivo (`HEAD:lib/presentation/screens/charts_gallery_screen.dart:642`, `HEAD:…/syncfusion_charts_gallery_screen.dart:645`) y un replay con `Timer` en Graphic #63 (`HEAD:…/graphic_interactive_charts.dart:560`); ya no existen en el working tree.

### TEST FIXTURE vs RUNTIME DATA

| Tipo | Dónde | Uso |
|---|---|---|
| TEST FIXTURE (sintético, correcto) | `test/support/fake_repository.dart` (obras `T0…`, trends generados), `test/graphic/graphic_fixture.dart` | Solo tests. Comentado como tal (`fake_repository.dart:62-63`) |
| RUNTIME DATA | `ChartsDatasetProvider` + `AniListLiveProvider` contra `graphql.anilist.co` | Las 4 galerías |

Nota: `case_builders_test.dart` verifica los 252 builders **solo con el fixture**; ningún test del repo usa datos reales.

## 7. Casos especiales (#32–#34, #41–#44, #52, #55, #60–#63)

### #32 Candlestick / #33 HLOC

- **Datos**: `Media.trends.popularity` de la obra más popular → `dailyGains` (`graphic_transformations.dart:171-184`: `(pop[i] − pop[i−1]) / días`) → `ohlc` en ventanas completas de 7 puntos (`:193-206`: open = primer día, high = máx, low = mín, close = último). 99 variaciones → 14 velas (se descartan los 1 sobrantes).
- **Por librería**: FL `CandlestickChart` (#32) y segmentos de `LineChart` (#33); Syncfusion `CandleSeries` / `HiloOpenCloseSeries`; DChart dos `DChartBarO` superpuestos (#32) y `DChartComboO` bar + scatter (#33); Graphic `CustomMark` + `CandlestickShape` nativo / `HlocShape` propio.
- **Clasificación**: implementación ADAPTACIÓN en las 4 (por los datos). Capacidad: FL N / C, Syncfusion N / N, DChart **NS / NS**, Graphic N / C.
- **¿Semánticamente correcto?** Como visualización de "resumen semanal de una serie" sí; como candlestick financiero no, y la nota visible lo dice (`case_support.dart:114-119`). Limitación: son velas de la **variación** diaria, no de la popularidad; "open/close" no tienen significado de mercado.
- **Problemas OBSERVADOS**: DChart #33 — leyenda "high-low azul · open rojo · close verde" pero se dibuja high-low **gris**, open **naranja**, close **azul** (`d_chart_case_builders.dart:617, 622, 625`: `_withLegend` usa `casePalette` por posición). FL #32/#33: etiqueta superior del eje Y superpuesta ("1.2k/1.4k").

### #34 Box and Whisker

- **Datos**: cuartiles R-7 de `averageScore` por format con ≥2 obras (`graphic_dataset.dart:154-158`).
- **Por librería**: FL segmentos de `LineChart` (ADAPTACIÓN); Syncfusion `BoxAndWhiskerSeries` nativo (calcula sus propios cuartiles con los valores crudos, muestra outliers y media); DChart 3 `DChartBarO` superpuestos (COMPOSICIÓN, capacidad NS); Graphic `CustomMark` + `BoxPlotShape` propio (COMPOSICIÓN).
- **Semántica**: correcta. Syncfusion usa los valores crudos (no el resumen precalculado) → puede diferir en bigotes (outliers).
- **OBSERVADO**: DChart y Graphic fijan escala 0–100 con scores 75–90 → cajas diminutas. FL ajusta el eje (51–90) y se lee mejor.

### #41 SMA · #42 Bollinger · #43 RSI · #44 MACD — ver §8.

### #52 Infinite Scrolling — ver §9.

### #55 Range Selection Data Filter

- FL / Syncfusion / DChart: `RangeSlider` de Flutter + gráfico resumen + gráfico filtrado, sobre `countByYear` (COMPOSICIÓN). Nota correcta en Syncfusion: `SfRangeSelector` está en `syncfusion_flutter_sliders`, no instalado.
- Graphic: `IntervalSelection` nativa → `selectionStream` broadcast → `setState` → segundo `Chart` con los puntos filtrados, sobre `datedTitles` (popularidad por fecha) — **datos distintos** a las otras tres.
- Limitación (INFERIDO): `_RangeFilterState`, `_SfRangeFilterState`, `_DcRangeFilterState` inicializan `_range` una sola vez (`fl_case_builders.dart:1031`, `syncfusion_case_builders.dart:492`, `d_chart_case_builders.dart:945`) y no tienen `didUpdateWidget`. Si al cambiar Anime/Manga cambiara el número de años, `RangeSlider` recibiría valores fuera de rango y `sublist` lanzaría `RangeError`. Con los datos reales actuales ambos tipos tienen 10 años, por eso no se ve.

### #60 Fully Customized Widget Tooltip

- FL: `BarTouchData.touchCallback` + `Card` fija en esquina (COMPOSICIÓN). Syncfusion: `TooltipBehavior.builder` nativo (widget que sigue al puntero). DChart: `onChangedListener` + `Card` fija, **solo al hacer clic** (d_chart no tiene hover). Graphic: `selectionStream` + `gestureStream` → `Card` posicionada en el punto tocado, **solo con tapDown** (`graphic_interactive_charts.dart:337`), datos: scatter popularity × score (distinto de las otras tres, que usan barras de popularity).
- Semántica: correcta en las 4; solo Syncfusion es un tooltip "flotante" real.

### #61 Staggered Animation

- FL y DChart: `AnimationController` propio + `Interval` por barra (COMPOSICIÓN real, escalonado por barra). Syncfusion: una serie por barra con `animationDelay` creciente (VARIANTE). Graphic: `Mark.transition` con `Interval` distinto por **marca** (barras → línea → puntos), no por barra; se reinicia recreando el `Chart` con `ValueKey`.
- OBSERVADO: Syncfusion capturado a los ~3 s en test muestra solo la primera barra (posible artefacto de temporización del entorno de test; requiere comprobación manual). Graphic: etiquetas X rotadas se montan sobre el botón "Repetir animación". FL usa `Curves.easeOutBack`, que sobrepasa 1 → las barras superan `maxY` un instante (INFERIDO).

### #62 Inverted / Opposed Axis

- Datos: `rankings` "highest rated all time" (top 10 por puesto).
- FL: valores negados + títulos a la derecha/arriba (VARIANTE). Syncfusion: `isInversed` + `opposedPosition` nativos. DChart: `flipVerticalAxis: true`. Graphic: `RectCoord(verticalRange: [1, 0])` + `AxisGuide(position: 1)`.
- **DChart**: la API dice "ranking invertido, eje X arriba" (`d_chart_case_builders.dart:167`) pero `flipVerticalAxis` solo invierte el rango de salida del eje vertical (`community_charts_common2-1.0.7/…/cartesian_chart.dart:421`); el eje X queda **abajo** (OBSERVADO). Cubre "inverted", no "opposed", y la matriz lo marca NATIVO/FUNCIONAL.
- OBSERVADO: FL recorta la primera etiqueta superior ("so…") y "#15" abajo; Graphic dibuja las etiquetas rotadas encima del área del gráfico.

### #63 Real-time Streaming — ver §10.

## 8. #41–#44 y `Media.trends`

VERIFICADO — `Media.trends` **sí se consulta**:

1. Query `getMediaTrends` (`media_queries.dart:125-145`).
2. DataSource `getMediaTrends` (`anilist_remote_datasource.dart:135-152`) → `MediaTrendModel.fromJson` (fecha Unix en segundos, `media_trend_model.dart:7-13`).
3. Repository (`anilist_repository_impl.dart:54-62`) → entidad `MediaTrend` (`domain/entities/media_trend.dart`, comentada como "no es un precio").
4. Provider `_loadTrends` (`charts_dataset_provider.dart:162-178`): 4 páginas en paralelo, dedupe por fecha, orden cronológico; un fallo no invalida la muestra (`trendsError`).
5. `GraphicAdapters.trendsFrom` descarta nodos con `popularity` null (`graphic_adapters.dart:67-79`).
6. `GraphicDataset.fromAnime` (`graphic_dataset.dart:186-191, 221-234`): `dailyGains` → `trendValues`; `sma(7)`, `bollinger(20, 2σ)`, `rsi(14, Wilder)`, `macd(12, 26, 9)`.
7. Cada librería lee `d.g.trendSma`, `bollingerPoints`, `rsiPoints`, `macdPoints` (FL, DChart, Graphic) o **recalcula** con sus indicadores nativos sobre `trendValues` (Syncfusion, `syncfusion_case_builders.dart:461-477`).

**¿Calculado sobre la serie real?** Sí (VERIFICADO + OBSERVADO con 99 variaciones reales).

**Cómo se presenta**: nota visible "Indicador calculado sobre la variación diaria de popularidad (Media.trends de AniList). No es un dato financiero." (`case_support.dart:121-122`). La palabra "financiero" solo aparece para **negarlo**. Correcto.

**Limitaciones y hallazgos**:

- La serie base es la **variación diaria** (primera diferencia). El RSI mide cambios de esa serie → es un indicador de **aceleración** de la popularidad; con datos reales oscila 32–64 alrededor de 50 (OBSERVADO). No es incorrecto, pero conviene explicarlo.
- **Los valores difieren entre librerías** (OBSERVADO): Syncfusion calcula RSI, Bollinger y MACD con sus propios algoritmos (`RsiIndicator`, `BollingerBandIndicator`, `MacdIndicator`); p. ej. su MACD llega a −80 y el del proyecto a −51; su RSI ronda 40 y el del proyecto 50. Las cuatro celdas de un mismo caso no muestran los mismos números.
- DChart #44: leyenda "Histograma azul · MACD rojo · Señal verde" pero se dibuja histograma verde/rojo, MACD azul y señal naranja (`d_chart_case_builders.dart:659-662`). OBSERVADO.
- Graphic #41 no tiene leyenda (dos colores sin explicar). Graphic #43 (panel superior) dibuja líneas verticales en cada categoría (OBSERVADO; causa no determinada).
- `hasTrends` exige ≥30 variaciones (`graphic_dataset.dart:283`); con menos, las 24 celdas T muestran `TechnicalIssue`.

## 9. #52 Lazy Loading

VERIFICADO: **es paginación de red real**, no scroll local.

| Paso | Código |
|---|---|
| Arranque | `LazyLoadingHost.initState` → post-frame → `ensureLazyStarted(loadedType)` (`live_case_hosts.dart:32-40`) → `loadNextPage()` si página 0 (`anilist_live_provider.dart:72-81`) |
| Final del scroll | `_onScroll`: si `pixels >= maxScrollExtent − 40` → `loadNextPage()` (`live_case_hosts.dart:42-45`) |
| Petición | `repository.getMediaList(page: _lazyPage + 1, perPage: 20, type)` (`anilist_live_provider.dart:91`) |
| Datos | se **añaden** a `_lazyItems` con dedupe por id; `hasNextPage` de AniList decide el fin (`:93-96`) |
| Provider | `_notify()` → `context.watch` en el host (`live_case_hosts.dart:55`) |
| Gráfico | se reconstruye con más obras y **crece en ancho** (`items.length × itemWidth`, `:85`) |
| Alternativa | botón "Siguiente página" (`:75-78`) |

Cubierto por `test/live_and_trends_test.dart:57` (a nivel de provider). **No hay test de widget** que dispare la carga por scroll.

Limitaciones:

- **Cambio Anime/Manga** (INFERIDO de código): `ensureLazyStarted` solo se llama en `initState`. Al cambiar el tipo, la tarjeta #52 sigue montada (la galería conserva el dataset anterior mientras carga, `master_case_gallery.dart:65-66`), su `State` se reutiliza y la paginación **sigue con el tipo anterior** hasta que la tarjeta sale de pantalla y vuelve.
- Escritorio/web: el `SingleChildScrollView` horizontal está dentro de un `ListView` vertical; la rueda del ratón mueve la lista vertical y el arrastre con ratón no desplaza en Flutter desktop/web por defecto (no hay `scrollBehavior` propio en `main.dart`). Hay que usar la barra, Shift+rueda o el botón.
- Graphic #52 no tiene eje X (solo `Defaults.verticalAxis`) y etiqueta con el id; OBSERVADO: líneas verticales finas sobre las barras.

## 10. #63 Streaming

VERIFICADO: **sondeo periódico real a AniList**, no reproducción de datos cargados.

Cadena común: `LiveStreamingHost.initState` toma los ids de las 5 primeras obras (`live_case_hosts.dart:122`) → `acquirePolling` (`anilist_live_provider.dart:124-134`) → `Timer.periodic(30 s)` + lectura inmediata → `pollNow` (`:145-169`) → `getMediaSnapshots` (GraphQL `id_in`) → suma de `popularity`, `delta` con la lectura anterior, máximo 30 lecturas → `notifyListeners`. `dispose` del host → `releasePolling` (contador de consumidores; el `Timer` se cancela al llegar a 0).

| Librería | Mecanismo de actualización del gráfico | Timer / Stream |
|---|---|---|
| FL Chart | `ChangeNotifier` → rebuild de `LineChart` con la lista (`fl_case_builders.dart:113-117`) | Timer del provider |
| Syncfusion | `_SfLive.didUpdateWidget` → `ChartSeriesController.updateDataSource(addedDataIndexes)` (`syncfusion_case_builders.dart:601-609`) | Timer del provider |
| DChart | `ChangeNotifier` → rebuild de `DChartLineN` (`d_chart_case_builders.dart:184-194`) | Timer del provider |
| Graphic | `_G63LiveState.didUpdateWidget` → `StreamController.broadcast` → `Chart.changeDataStream` + `ChangeDataEvent` (`graphic_interactive_charts.dart:482-516`); cerrado en `dispose` | Timer del provider + stream broadcast |

¿Vuelve a pedir a AniList? **Sí** en las cuatro (mismo provider). No hay `Stream.periodic`, ni replay.

Limitaciones:

- AniList no ofrece push: es polling y la UI lo dice ("Actualización periódica… cada 30 s").
- `popularity` cambia por lotes: la mayoría de lecturas tienen Δ = 0 (documentado).
- OBSERVADO: durante los primeros 30 s el gráfico tiene **un solo punto** (FL lo dibuja en la esquina inferior con "4.9M").
- Syncfusion `_data` crece sin límite (`syncfusion_case_builders.dart:598, 607`), mientras el provider recorta a 30 lecturas → las otras tres librerías muestran ventana de 30 y Syncfusion todo el historial.
- Ids fijos en `initState`: al cambiar Anime/Manga la tarjeta sigue vigilando las obras del tipo anterior (INFERIDO, mismo patrón que #52).

## 11. Bug del scroll

### Diagnóstico

**Reproducido** (OBSERVADO) sobre una copia exacta de `HEAD` 342a5cd con un test que arrastra la lista 40 veces hacia abajo y 40 hacia arriba:

```text
CAPTURADO #1: Bad state: Stream has already been listened to.
CAPTURADO #2: 'package:flutter/src/widgets/framework.dart': Failed assertion: line 6281 pos 12: '_dependents.isEmpty': is not true.
… 'element._lifecycleState == _ElementLifecycle.active': is not true.
```

Aparece en la galería FL Chart y en la de Syncfusion de `HEAD`. Es exactamente la secuencia reportada.

| Pregunta | Respuesta |
|---|---|
| 1. ¿Qué stream se escucha dos veces? | `Stream.periodic(500 ms, …).take(n)` — single-subscription |
| 2. ¿Quién lo crea? | `_buildCases(context, data)` al construir el `_CaseSpec` del caso "Gráfica Reactiva en Tiempo Real con Streams": `HEAD:lib/presentation/screens/charts_gallery_screen.dart:640-647` y `HEAD:lib/presentation/screens/syncfusion_charts_gallery_screen.dart:642-649` |
| 3. ¿Quién lo escucha? | `StreamBuilder` → `_StreamBuilderBaseState.initState` → `_subscribe()` |
| 4. ¿Quién lo vuelve a escuchar? | Un **nuevo** `_StreamBuilderBaseState` sobre el **mismo** widget `StreamBuilder` (misma instancia de `Stream`) cuando la tarjeta vuelve a entrar en pantalla |
| 5. ¿Quién debería cancelar? | La suscripción anterior sí se cancela en `dispose`, pero un `Stream` single-subscription **no admite una segunda escucha aunque la primera se haya cancelado** |
| 6. ¿Se reutiliza un single-subscription Stream? | **Sí**: la lista de casos se construye una vez en el `Consumer` y se pasa como `ListView(children: [...cases.map(_ChartCard.new)])` (`HEAD:…/charts_gallery_screen.dart:85-99`). El `SliverChildListDelegate` re-infla el mismo widget |
| 7. ¿Aparece por rebuild al hacer scroll? | Por **re-montaje** al hacer scroll: el elemento se descarta al salir del viewport + cacheExtent y se crea de nuevo al volver; el scroll no reconstruye el `Consumer`, así que no se crea un Stream nuevo |
| 8. ¿Estado mantenido en un builder? | Sí: el `Stream` (estado) vive dentro del widget de configuración `_CaseSpec.chart` |
| 9. ¿Suscripciones en `build()`? | El `Stream` se crea en `build()` del `Consumer` (vía `_buildCases`) y se consume en un `initState` posterior |
| 10. ¿Suscripción conservada tras desmontar? | No; el fallo ocurre en el **montaje**. La excepción en `initState` deja el subárbol a medio montar y la desactivación posterior dispara las aserciones `_dependents.isEmpty`, `child._parent == this` y `_lifecycleState == active` |

### Estado en el working tree

VERIFICADO: esos archivos ahora tienen 17 líneas y delegan en `MasterCaseGallery`, que usa `ListView.builder` y llama `impl.builder(context, data)` en cada montaje (`master_case_gallery.dart:105-115, 249`). No queda ningún `Stream` single-subscription en `lib/`: los únicos `StreamController` son `broadcast()` y se cierran en `dispose` (`graphic_interactive_charts.dart:213/229-233`, `291-292/313-321`, `483/497-500`; `graphic_financial_stat_charts.dart:205` + su `dispose`). Graphic 2.7.0 crea sus controladores internos por vista y cancela sus suscripciones en `Dataflow.dispose` (`graphic-2.7.0/lib/src/dataflow/dataflow.dart:96-100`); fl_chart, d_chart, community_charts y syncfusion no usan `StreamController`.

OBSERVADO: el mismo test (3 ciclos × 45 arrastres arriba/abajo + movimiento de ratón en 3 puntos tras cada arrastre) sobre una copia del working tree → **0 excepciones en las 4 galerías**.

**Riesgo**: la corrección existe solo en cambios **no commiteados**. Un `git checkout .`/`git stash` devuelve el bug.

Riesgo residual (INFERIDO, no reproducido): cada rebuild del padre recrea la vista de Graphic porque `equalSpecTo` compara closures (`graphic-2.7.0/lib/src/chart/chart.dart:225-231`); entre `didUpdateWidget` y el siguiente layout `view` es `null`, y los callbacks de gestos y ratón hacen `view!.gesture(...)` sin comprobar null (`chart.dart:253`, `:724` hover, `:750`, `:762`, entre otros). Un evento de ratón en esa ventana lanzaría un null-check. No apareció en 540 movimientos de ratón del test.

## 12. Hover / tooltip

| Librería | A) Qué trae la librería | B) Qué usa el proyecto | C) Qué falta |
|---|---|---|---|
| FL Chart 1.2.0 | Touch/hover por defecto en Line/Bar/Scatter/Candlestick; en escritorio y web el hover muestra el tooltip (`fl_touch_event.dart:18-30`). Tooltip por defecto de barras = `rod.toY.toString()` (`bar_chart_data.dart:874`). Pie sin tooltip | Tooltip con categoría + valor en `BasicBarChart` (`fl_bar_charts.dart:338-346`) y `MultiSeriesBarChart`; multiserie en #40; resto: tooltip por defecto (solo número) | Nombres en `_barChart`/`_lineChart`; **valores erróneos**: #14/#15 muestran value/2 (barras centradas `fromY/toY`), #25 año+0.3, #28 el acumulado, #51 el log10. Touch desactivado en #33, #34, #36 (barras), #37, #44, #47, #57, #58, #61, #62 y en los pie (#7, #8, #9, #54, #56) |
| Syncfusion 34.2.9 | `TooltipBehavior` responde a hover si `activationMode == singleTap` (default) (`chart_series.dart:2017-2030`); Trackball, Crosshair, builder de tooltip | `TooltipBehavior(enable: true)` en `_cartesian`, `_numeric` y `_multi` (`syncfusion_case_builders.dart:422, 430, 455`) | Sin tooltip en 25 casos: #7, #8, #9, #14, #15, #31, #38, #39, #41–#44, #46–#48, #50, #51, #53, #55 (resumen), #56, #57, #58, #61, #62, #63 |
| d_chart 3.0.0 | **Sin tooltip.** `defaultInteractions` es `false` por defecto (`d_chart-3.0.0/lib/base/base_d_chart.dart:24`); si se activa, añade `SelectNearest` con `SelectionTrigger.tap` (`community_charts_flutter2/…/base_chart.dart:181-187`). `SelectionTrigger.hover` existe en el enum pero la capa Flutter no tiene `MouseRegion` ni `PointerHoverEvent` (grep vacío). d_chart no expone `behaviors` salvo `SlidingViewport`/`PanAndZoom` | `defaultInteractions: true` + `onChangedListener` solo en #39, #40, #60 (clic, texto o `Card` fija) | Todo lo demás: 60 casos sin información al pasar el ratón ni al hacer clic |
| Graphic 2.7.0 | `PointSelection(on: {GestureType.hover, …})` + `TooltipGuide` + `CrosshairGuide` (canvas); `MouseRegion` interno | `TooltipGuide` en 9 builders: #1, #2, #9, #10, #11, #17 (sin hover), #39, #40, #51; selección en #55, #56, #60 | 54 casos sin tooltip. Existen helpers sin usar de forma general: `tapSelection()` (`graphic_common.dart:113-119`) y `xSelection()` (`graphic_chart_helpers.dart:67-73`) |

**D) Solución mínima sin rehacer builders** (propuesta, no implementada):

1. **Graphic**: añadir `selections: xSelection()` (o `tapSelection()`) y `tooltip: TooltipGuide(...)` a cada `Chart` — 2 líneas por builder, sin cambiar datos ni marcas. Los helpers ya existen.
2. **DChart**: en los constructores compartidos (`_bars`, `_line`, `_combo`, `_timeLines`, `_pie`, `_scatter`) pasar `defaultInteractions: true` + `onChangedListener` a un `ValueNotifier` común y mostrar una franja de información (dominio · serie · valor) sobre el gráfico. Es clic, no hover (la librería no lo permite). Hover real exigiría `MouseRegion` + conversión píxel→dato manual.
3. **FL Chart**: dar `getTooltipItem`/`getTooltipItems` con etiqueta a `_barChart` y `_lineChart` (`fl_case_builders.dart:210-285`) y pasar el valor **original** en los casos que dibujan valores transformados.
4. **Syncfusion**: `tooltipBehavior: TooltipBehavior(enable: true)` en `_circular`, `SfPyramidChart`, `SfFunnelChart`, `_indicatorChart` y los `SfCartesianChart` escritos a mano; las sparklines tienen `trackball` propio.

## 13. Problemas visuales (OBSERVADO en render con datos reales)

Método: los 252 builders dentro de la `MasterCaseCard` real, tema oscuro, datos reales de AniList (ANIME), 480 px; 24 casos especiales también a 328 px. Fuente Roboto. Limitación del entorno: el texto que dibuja Graphic en canvas aparece como rectángulos grises (artefacto de fuentes del test, no de la app); no se evalúan esos textos.

| Caso | Librería | Problema |
|---|---|---|
| #35 Error Bars | Syncfusion | **No se ven las barras de error** y las 5 categorías aparecen fundidas en la primera etiqueta ("ction, Drama, Comedy, Supernatural, Fantasy"). Causa probable: una `ErrorBarSeries` por género con un solo punto (`syncfusion_case_builders.dart:171-177`). Marcado FUNCIONAL |
| #28 Waterfall | Syncfusion | **Semántica incorrecta**: el primer paso es `isTotal` y `totalSumPredicate` lo trata como suma de lo anterior (0); la cascada baja hasta −8 y el "Total" es −8, cuando FL/DChart/Graphic terminan en 1 obra (`syncfusion_case_builders.dart:123-129`). Un conteo negativo es imposible |
| #33, #44 | DChart | Colores de la leyenda que no coinciden con las series (ver §7 y §8) |
| #62 | DChart | Eje X abajo; la API dice "eje X arriba" |
| #53 Shaded Doughnut | Syncfusion | `onCreateShader` aplica un único `SweepGradient` a todo el anillo: las categorías pierden su color y los 4 iconos de la leyenda son iguales |
| #53 | DChart | Etiquetas de datos negras sobre fondo oscuro |
| #14 Pyramid | Graphic | Forma de rombo (ancho en el centro), no pirámide |
| #14, #15, #8, #7 | Todas | Datos reales degenerados en ANIME (TV 185/200; FINISHED 199/200) |
| #25 Range Column | FL | La mayoría de rangos son de 0 años (inicio = fin) → puntos en vez de barras |
| #31, #57, #58 | Graphic | Sparkline dibujada muy pequeña en el centro de la tarjeta (casi vacía) |
| #31, #57, #58 | Syncfusion | Alto fijo 90/70 px centrado en 280 px (`syncfusion_case_builders.dart:139, 316, 320`) |
| #34 | DChart, Graphic | Escala 0–100 con scores 75–90: cajas diminutas |
| #50 | Graphic | Dos gráficos apilados en ~100 px cada uno; etiquetas rotadas ilegibles. Con datos reales no hay huecos que eliminar (todas las librerías) |
| #52 | Graphic | Sin eje X; líneas verticales finas sobre las barras |
| #43 | Graphic | Líneas verticales en cada categoría del panel superior |
| #61, #62 | Graphic | Etiquetas rotadas encima del botón / del área del gráfico |
| #62 | FL | Primera etiqueta superior y "#15" recortados |
| #63 | FL, DChart, Graphic | Primeros 30 s: un solo punto |
| #28, #32, #33 | FL | Etiqueta superior del eje Y recortada o superpuesta |
| #61 | Syncfusion | Solo la primera barra visible a los 3 s en el entorno de test (ver §7) |

## 14. Responsividad

- OBSERVADO: los 252 builders dentro de la tarjeta real a **328 px** (móvil 360 − márgenes), **480 px** y **900 px** de ancho, con alto ilimitado como en el `ListView` → **0 excepciones, 0 `RenderFlex overflow`**.
- Nota de método: una primera pasada con alto fijo de 520 px dio 48 overflows en tarjetas con notas largas; eran del arnés (alto limitado), no de la app. Se repitió con alto ilimitado.
- VERIFICADO: el gráfico tiene **alto fijo 280 px** (`master_case_gallery.dart:249`) en todas las tarjetas, con `ClipRect` para etiquetas rotadas. Los casos que apilan dos gráficos (#50 Graphic, #55, #43 Graphic) o llevan leyenda larga quedan comprimidos (ver §13).
- Filtros: dos filas con scroll horizontal (`master_case_gallery.dart:146-160`), no desbordan.
- INFERIDO (no probado): en anchos muy estrechos el título del `AppBar` ("Syncfusion 34.2.9 · 63 casos") compite con el `SegmentedButton` Anime/Manga y se truncará.
- Web: `flutter build web` OK. **No se ejecutó la app en un navegador** en esta auditoría (tampoco en la fase anterior, según `integration_report.md:174`).

## 15. Incongruencias de código

1. **Capacidad ≠ implementación en 41 celdas** (VERIFICADO por script). Algunas son coherentes (capacidad teórica vs camino elegido), otras contradicen las definiciones: FL #3/#4/#5/#6/#8/#12/#13/#17/#18/#25/#29/#30 capacidad NATIVO pero implementación VARIANTE; Syncfusion #35/#54/#61 NATIVO → VARIANTE; DChart #5 NATIVO → VARIANTE; Graphic #30/#62 NATIVO → VARIANTE, #61 VARIANTE → COMPOSICIÓN.
2. **Clasificación paralela de Graphic**: `graphicChartRegistry` (36/18/9, validada por `test/graphic/graphic_registry_test.dart:11`) difiere de la capacidad de la matriz en #30 (V vs N), #61 (C vs V) y #62 (V vs N).
3. **"NO SOPORTADO" + "FUNCIONAL"** en DChart #32–#34: la tarjeta muestra a la vez que la librería no lo soporta y que funciona.
4. **Restos de la fase anterior**: `GraphicDataOrigin.noDisponible` y `originFor` (`graphic_common.dart:19-26`, `graphic_chart_registry.dart:45-56`) solo los usan tests; comentario truncado en `graphic_dataset.dart:10-11` ("…y viven en"); comentario obsoleto "quedan como NO DISPONIBLE" en `graphic_dataset.dart:51-52`; "Clasificación auditada (Sección C del prompt: 36 / 18 / 9)" en `graphic_common.dart:7`.
5. **Nota falsa** en FL #11: "AniList no lo informa para manga" (`fl_case_builders.dart:46`), pero el provider usa `chapters` para manga (`charts_dataset_provider.dart:131`) y Syncfusion/DChart lo dicen bien.
6. **Graphic no usa los mismos datos** que las otras tres en #39 (scatter popularity × score vs score por año), #50 (top populares por año de inicio vs obras por año), #55 (popularidad por fecha vs obras por año), #56 (top 10 vs top 5) y #60/#61 (otros campos). Contradice `CaseData.g` "para que cada caso muestre los mismos datos" (`case_support.dart:61-62`).
7. **Estado que no reacciona a cambios de datos**: `LazyLoadingHost` y `LiveStreamingHost` (tipo Anime/Manga), `_RangeFilter`/`_SfRangeFilter`/`_DcRangeFilter` (`_range`), `_SfLive._data` (crece sin límite), `_G63LiveState._initial` (`late final`).
8. **Syncfusion recalcula indicadores** (#41–#44) con sus algoritmos → números distintos a los del proyecto.
9. **Código muerto**: 12 wrappers (§2); `casesFor` solo en tests.
10. `flutter analyze` devuelve código 1 por 3 `info` (`graphic_common.dart:80`, `graphic_charts.dart:1`, `graphic_custom_shapes.dart:205`).

## 16. Incongruencias de documentación

### Documentos vigentes

VERIFICADO por script: las tablas de 63 filas de `docs/FL_CHART.md`, `docs/SYNCFUSION.md`, `docs/DCHART.md`, `docs/GRAPHIC.md` (capacidad, estado, API, implementación) y la matriz 63×4 de `docs/integration_report.md` §9 coinciden **al 100 %** con el código. Los resúmenes de conteo (§5 de este informe) también. `README.md` ("248 FUNCIONAL y 4 PARCIAL", 4 páginas × 50, polling 30 s) es correcto.

Búsqueda explícita de cifras antiguas en README + docs vigentes: "98 de 252", "21 casos", "5 implementaciones DChart", "33/63", "38/63" → **no aparecen**. "NO DISPONIBLE" / "NO VERIFICADO" aparecen solo como definición, como conteo 0 o en la columna "Antes" de `integration_report.md:62-68`.

Problemas:

1. **Los documentos vigentes no están commiteados** (4 de ellos sin seguimiento) y describen un código que no está en `origin/main`.
2. "Las tablas se generan desde el código, no a mano" (`FL_CHART.md:3`, `SYNCFUSION.md:3`, idem DCHART/GRAPHIC) — **no hay script generador en el repositorio**. Hoy coinciden, pero nada lo garantiza.
3. No documentan los defectos de §13 (Syncfusion #28 y #35, leyendas de DChart, DChart #62), la falta de hover en DChart/Graphic, ni los tooltips con valores transformados de FL.
4. `integration_report.md:150` afirma que la revisión visual corrigió "las barras de error negras … en Graphic, Syncfusion y d_chart", pero en Syncfusion las barras de error no se ven (OBSERVADO).
5. `integration_report.md:166` dice que las 4 galerías "recorren sus 63 tarjetas sin excepciones": cierto, pero el test solo baja una vez; no cubre el escenario del bug de scroll.
6. Descripción de #62 DChart ("eje X arriba") inexacta (§7).

## 17. Documentación histórica

VERIFICADO:

| Documento | Contenido | ¿Aviso de histórico dentro? |
|---|---|---|
| `docs/FL_CHART_INVESTIGACION.md` (581 l.) | Investigación de capacidades; "31 básicas y 32 avanzadas" sin lista | No |
| `docs/FL_CHART_IMPLEMENTATION.md` (154 l.) | "Casos básicos 1–31", "LISTA_CANDIDATA_63", "Los casos 32–63 no se han empezado" (l. 10) y luego "63 casos implementados" (l. 123): se contradice | No |
| `docs/SYNCFUSION_INVESTIGACION.md` (112 l.) | Matriz provisional, versión Flutter 3.47.5 (el entorno es 3.47.2) | Parcial: "lista provisional de trabajo" (l. 41) |
| `docs/SYNCFUSION_IMPLEMENTATION.md` (40 l.) | Wrappers `syncfusion_*_charts.dart` (hoy código muerto), numeración antigua ("Case 28 y 61") | No |

Solo `README.md:45` los señala como "historial de trabajo". **Deben conservarse** como historial, pero **hay riesgo real** de que se lean como vigentes: comparten carpeta y nombre de librería con los vigentes, y ninguno tiene un aviso en su primera línea. Recomendación: banner "HISTÓRICO — no refleja el código actual; ver `FL_CHART.md`" al inicio de cada uno, o moverlos a `docs/historico/`.

## 18. Tests y build

VERIFICADO (ejecutado el 2026-09-25 en el working tree):

| Comando | Resultado |
|---|---|
| `flutter test test/` | **All tests passed! — 457 tests** |
| `flutter analyze` | 3 issues **info** (`prefer_initializing_formals`, `dangling_library_doc_comments`, `use_super_parameters`); 0 errores, 0 warnings; código de salida 1 |
| `flutter build web` | **✓ Built build/web** (139,1 s). Aviso: faltan fuentes de `CupertinoIcons` en el árbol |

Cobertura:

| Tema | ¿Cubierto? | Dónde |
|---|---|---|
| 63 casos / registry | Sí | `master_registry_test.dart`, `case_builders_test.dart:23-45`, `graphic_registry_test.dart` |
| 252 builders | Sí, con fixture sintético; solo comprueba que exista un widget de la librería | `case_builders_test.dart:47-94` |
| 4 galerías | Sí, un recorrido hacia abajo | `charts_gallery_test.dart:150-191` |
| Trends / indicadores | Sí (fórmulas y provider) | `live_and_trends_test.dart:10-54`, `graphic_transformations_test.dart` |
| Paginación | Provider sí; scroll del widget no | `live_and_trends_test.dart:57` |
| Sondeo / dispose del provider | Sí | `live_and_trends_test.dart:69-83` |
| Hover | **No** | — |
| Scroll repetido (bug) | **No** | — |
| Streams de Graphic / dispose de widgets | **No** | — |
| Cambio Anime/Manga con tarjetas vivas | **No** | — |
| Corrección visual/semántica (p. ej. SF #28, #35) | **No**: los tests no pueden detectarla | — |

Pruebas ejecutadas por esta auditoría **fuera del repositorio** (copias temporales, no añadidas al proyecto):

1. `scroll_repro_head_test.dart` sobre `HEAD`: reproduce el bug (§11).
2. `scroll_repro_current_test.dart` sobre el working tree: 4 galerías × 3 ciclos × 90 arrastres + 3 movimientos de ratón por arrastre → 0 errores.
3. `render_audit_test.dart`: muestra real de AniList (8 consultas guardadas en JSON: 4 páginas × 50 y 4 páginas de trends por tipo), 252 builders × 3 anchos, PNG de 348 tarjetas.

Esqueleto de la prueba de scroll (para convertirla en test del repo en la fase de corrección):

```dart
final list = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
for (var round = 0; round < 3; round++) {
  for (final dy in [-600.0, 600.0]) {
    for (var i = 0; i < 45; i++) {
      await tester.drag(list, Offset(0, dy), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 60));
      final e = tester.takeException();
      if (e != null) errors.add('$e');
    }
  }
}
expect(errors, isEmpty);
```

## 19. Lista priorizada de correcciones

**P0 — integridad del entregable**

1. Commitear el working tree (con los borrados staged). Hoy `origin/main` = galerías antiguas + bug de scroll + documentación anterior.
2. Añadir al repo el test de scroll repetido (§18) para que el bug no vuelva.

**P1 — gráficos incorrectos marcados FUNCIONAL**

3. Syncfusion #35: barras de error invisibles y etiquetas fundidas (`syncfusion_case_builders.dart:167-179`).
4. Syncfusion #28: waterfall con conteos negativos (primer paso como total, `:123-129`).
5. DChart #33 y #44: leyendas con colores que no corresponden.
6. DChart #62: o poner el eje X arriba o dejar de afirmarlo (y revisar su clasificación).
7. FL: tooltips con valores transformados en #14, #15, #25, #28, #51.

**P2 — UX de hover (paridad entre galerías)**

8. Graphic: `xSelection()`/`tapSelection()` + `TooltipGuide` en los 54 builders que no lo tienen.
9. DChart: franja de información por clic en los constructores compartidos (la librería no ofrece hover ni tooltip).
10. Syncfusion: `TooltipBehavior` en los 25 casos sin él. FL: etiquetas en los tooltips de `_barChart`/`_lineChart`.

**P3 — estado y datos**

11. `LazyLoadingHost`/`LiveStreamingHost`: reaccionar al cambio Anime/Manga (`didUpdateWidget` o escuchar `loadedType`).
12. `_RangeFilter` ×3: ajustar `_range` en `didUpdateWidget`. `_SfLive`: recortar a `maxSamples`.
13. Casos con datos degenerados en ANIME (#8, #15, #18, #22 por status; #50 sin huecos): elegir otro campo o documentar la limitación.
14. Alinear los datos de Graphic en #39, #50, #55, #56, #60, #61 con las otras tres librerías, o documentar la diferencia.
15. Indicadores #41–#44: decidir si Syncfusion usa los valores precalculados (mismos números en las 4) o documentar que usa sus propios algoritmos. Explicar que el RSI se aplica a la variación diaria.

**P4 — matriz y presentación**

16. Revisar las 41 celdas capacidad ≠ implementación; unificar la clasificación de `graphicChartRegistry` con la matriz (#30, #61, #62).
17. Decidir cómo presentar DChart #32–#34 (NO SOPORTADO + FUNCIONAL).
18. Ajustes visuales: sparklines pequeñas (#31, #57, #58 en Graphic y Syncfusion), #50 Graphic, #34 DChart/Graphic, etiquetas rotadas #61/#62 Graphic, #53 Syncfusion/DChart, pirámide de Graphic #14, líneas verticales Graphic #43/#52.

**P5 — documentación y limpieza**

19. Banner "HISTÓRICO" en `*_INVESTIGACION.md` / `*_IMPLEMENTATION.md` (o moverlos a `docs/historico/`).
20. Quitar la frase "las tablas se generan desde el código" o añadir el script generador.
21. Documentar límites de hover por librería y los defectos que queden abiertos.
22. Corregir la nota de FL #11, los comentarios obsoletos de `graphic_dataset.dart` y `graphic_common.dart`; eliminar `GraphicDataOrigin.noDisponible` si ya no aplica.
23. Borrar los 12 wrappers sin uso; resolver los 3 `info` de `flutter analyze`.
