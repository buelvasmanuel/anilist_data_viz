# AniList Data Viz

## Descripción
Aplicación Flutter que consume AniList GraphQL y visualiza datos mediante cuatro librerías:
- FL Chart
- Syncfusion Flutter Charts
- d_chart
- Graphic

## Arquitectura

AniList GraphQL
↓
DataSource
↓
Repository
↓
Domain
↓
Provider
↓
DataTransformations
↓
Chart Models / Registry
↓
Librerías de gráficos

## Los 63 casos de evaluación

El proyecto compara las cuatro librerías sobre **los mismos 63 casos maestros** (Línea Simple, Columna Vertical, …, Real-time Streaming). La app muestra **63 visualizaciones reales por librería: 252 en total**.

- **Matriz 63×4:** `lib/charts/models/master_chart_registry.dart` guarda, para cada caso y librería, la **capacidad** de la librería (NATIVO, VARIANTE, COMPOSICIÓN, NO SOPORTADO) y el **estado** en el proyecto (hoy 248 FUNCIONAL y 4 PARCIAL).
- **Implementación:** cada librería tiene un mapa de 63 `CaseImpl` (`flChartCases`, `syncfusionCases`, `dChartCases`, `graphicCases`) con la estrategia usada (NATIVO, VARIANTE, COMPOSICIÓN o ADAPTACIÓN), el origen de datos, la API y el builder. Una ADAPTACIÓN no significa que la librería tenga ese gráfico: es una representación equivalente construida por el proyecto y se explica en la tarjeta.
- **Galerías:** las cuatro comparten `MasterCaseGallery`. Filtros por implementación (Todas, Nativo, Variante, Composición, Adaptación) y por categoría (Básicos, Apilados / Rangos, Interacción, Escalas, Estadísticos, Especiales). Cada tarjeta muestra número, nombre maestro, capacidad, implementación, estado, origen de datos y el gráfico.
- **Verificación:** `test/case_builders_test.dart` monta los 252 builders y exige un gráfico real de la librería correspondiente en cada uno.

### Documentación

- [FL Chart](docs/FL_CHART.md)
- [Syncfusion Flutter Charts](docs/SYNCFUSION.md)
- [d_chart](docs/DCHART.md)
- [Graphic](docs/GRAPHIC.md)
- [Reporte de integración 63×4](docs/integration_report.md)

Los archivos `docs/*_INVESTIGACION.md` y `docs/*_IMPLEMENTATION.md` son historial de trabajo: usan una lista provisional anterior y no son la matriz vigente.

## Datos

Todo sale de AniList, sin `Random` ni listas fijas:

- **Muestra:** las 200 obras más populares del tipo elegido (4 páginas × 50, `sort: POPULARITY_DESC`). No representa a toda la base de AniList.
- **`Media.trends`:** unos 100 días de la obra más popular. Como su `popularity` es un acumulado, los casos #32 Candlestick, #33 HLOC, #41 SMA, #42 Bollinger, #43 RSI y #44 MACD usan su **variación neta diaria**. Son adaptaciones sobre popularidad, **no** datos financieros; AniList no tiene precios ni OHLC.
- **#52:** paginación real contra AniList al llegar al final del scroll.
- **#63:** actualización periódica real desde AniList (polling cada 30 s; AniList no ofrece push).

## Ejecución

1. Resuelve las dependencias:
   ```bash
   flutter pub get
   ```
2. Ejecuta la aplicación (Desktop/Mobile):
   ```bash
   flutter run
   ```
3. Para ejecutar la versión web localmente:
   ```bash
   flutter run -d chrome
   ```

## Verificación

El entorno cuenta con una suite completa de validación que asegura la integridad del `MasterChartRegistry` y la compilación. Para corroborar la calidad:

1. Pruebas unitarias y de widgets:
   ```bash
   flutter test test/
   ```
2. Análisis estático:
   ```bash
   flutter analyze
   ```
3. Construcción Web:
   ```bash
   flutter build web
   ```
