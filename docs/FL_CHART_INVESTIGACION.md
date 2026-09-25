# Investigación técnica: FL Chart

> Estado: investigación verificada con documentación oficial, pub.dev y repositorio oficial.
> Fecha de verificación: 2026-09-24.
>
> **Importante:** este documento investiga las capacidades reales de FL Chart. No inventa todavía cuáles son las 31 gráficas básicas y 32 avanzadas de la Parte B. Esa clasificación se hará cuando tengamos la lista/requisito exacto.

## 1. Identificación

### Librería
**FL Chart**

Paquete Dart/Flutter:

```yaml
fl_chart: ^1.2.0
```

Versión estable verificada: **1.2.0**.

La versión 1.2.0 declara Dart SDK mínimo **3.6**. El changelog del paquete indica que desde la serie 1.0.0 el mínimo de Flutter es **3.27.4**.

Plataformas publicadas en pub.dev: Android, iOS, Linux, macOS, Web y Windows.

Licencia: **MIT**.

Fuentes oficiales:
- https://pub.dev/packages/fl_chart
- https://pub.dev/packages/fl_chart/versions
- https://pub.dev/documentation/fl_chart/latest/
- https://github.com/imaNNeo/fl_chart
- https://github.com/imaNNeo/fl_chart/tree/main/repo_files/documentations

## 2. Instalación

```bash
flutter pub add fl_chart
```

O en `pubspec.yaml`:

```yaml
dependencies:
  fl_chart: ^1.2.0
```

Después:

```bash
flutter pub get
```

## 3. Import

```dart
import 'package:fl_chart/fl_chart.dart';
```

## 4. Tipos de gráficos nativos

La documentación oficial actual expone seis familias:

1. `LineChart`
2. `BarChart`
3. `PieChart`
4. `ScatterChart`
5. `RadarChart`
6. `CandlestickChart`

**FL Chart no tiene 63 widgets distintos.** Las 63 implementaciones del trabajo, si incluyen variantes como barras agrupadas, apiladas, horizontales, áreas, etc., se construirán reutilizando estas familias, su configuración y composición con Flutter cuando corresponda.

## 5. Capacidades generales confirmadas

Según la documentación/changelog oficial, FL Chart ofrece, según el gráfico:
- animaciones implícitas;
- tooltips;
- interacción táctil;
- callbacks;
- mouse/hover en plataformas compatibles;
- títulos de ejes;
- cuadrículas;
- líneas extra;
- anotaciones de rangos;
- gradientes;
- colores y estilos personalizados;
- bordes;
- rotación;
- valores negativos;
- múltiples series;
- zoom/pan en gráficos basados en ejes;
- indicadores de error en gráficos compatibles.

## 6. LineChart

**Widget:** `LineChart`

**Modelo:** `LineChartData`

**Datos principales:** `LineChartBarData`, `FlSpot`.

Ejemplo mínimo:

```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(1, 10),
          FlSpot(2, 20),
          FlSpot(3, 15),
        ],
      ),
    ],
  ),
)
```

Parámetros importantes de `LineChartData`:
- `lineBarsData`
- `betweenBarsData`
- `titlesData`
- `extraLinesData`
- `lineTouchData`
- `rangeAnnotations`
- `showingTooltipIndicators`
- `gridData`
- `borderData`
- `minX`, `maxX`, `minY`, `maxY`
- `baselineX`, `baselineY`
- `clipData`
- `backgroundColor`
- `rotationQuarterTurns`

Variantes que pueden construirse:
- línea simple;
- multiserie;
- línea con puntos;
- línea con área;
- línea minimalista;
- relleno entre dos líneas;
- líneas de referencia;
- rangos/anotaciones.

Interacción: **sí**, mediante `LineTouchData`.

Animación: **sí**, implícita.

Limitaciones: no existe `AreaChart` ni `HistogramChart` como widget independiente; fechas normalmente deben transformarse a un eje numérico.

## 7. BarChart

**Widget:** `BarChart`

**Modelo:** `BarChartData`

**Datos:** `BarChartGroupData`, `BarChartRodData`.

Ejemplo:

```dart
BarChart(
  BarChartData(
    barGroups: [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: 10)],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: 25)],
      ),
    ],
  ),
)
```

Parámetros importantes:
- `barGroups`
- `groupsSpace`
- `alignment`
- `titlesData`
- `axisTitleData`
- `rangeAnnotations`
- `backgroundColor`
- `barTouchData`
- `gridData`
- `borderData`
- `maxY`, `minY`
- `baselineY`
- `extraLinesData`
- `rotationQuarterTurns`
- `errorIndicatorData`

Variantes:
- vertical;
- horizontal mediante `rotationQuarterTurns`;
- agrupada mediante varios rods/groups;
- apilada mediante `BarChartRodStackItem`;
- negativa;
- con errores;
- con gradientes.

Interacción: **sí**, mediante `BarTouchData`.

Animación: **sí**.

Limitaciones: no hay histogram, funnel, waterfall, treemap o boxplot nativos.

## 8. PieChart

**Widget:** `PieChart`

**Modelo:** `PieChartData`

**Datos:** `PieChartSectionData`.

Ejemplo:

```dart
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(value: 40, title: 'A'),
      PieChartSectionData(value: 60, title: 'B'),
    ],
  ),
)
```

Parámetros importantes:
- `sections`
- `centerSpaceRadius`
- `centerSpaceColor`
- `sectionsSpace`
- `startDegreeOffset`
- `pieTouchData`
- `borderData`
- `titleSunbeamLayout`

`PieChartSectionData`:
- `value`
- `color`
- `gradient`
- `radius`
- `showTitle`
- `title`
- `titleStyle`
- `borderSide`
- `cornerRadius`
- `badgeWidget`
- posiciones de título/badge.

Donut: se obtiene configurando `centerSpaceRadius`; no existe un widget separado `DonutChart`.

Interacción: **sí**, mediante `PieTouchData`.

Animación: **sí**.

Limitaciones: gauge no es un widget nativo; contenido central requiere composición con Flutter; muchos sectores reducen legibilidad.

## 9. ScatterChart

**Widget:** `ScatterChart`

**Modelo:** `ScatterChartData`

**Datos:** `ScatterSpot`.

Ejemplo:

```dart
ScatterChart(
  ScatterChartData(
    scatterSpots: [
      ScatterSpot(1, 10),
      ScatterSpot(2, 20),
      ScatterSpot(3, 15),
    ],
  ),
)
```

Parámetros principales:
- `scatterSpots`
- `titlesData`
- `scatterTouchData`
- `showingTooltipIndicators`
- `rotationQuarterTurns`
- `errorIndicatorData`

`ScatterSpot` permite:
- `x`, `y`;
- `radius`;
- `color`;
- `show`;
- `renderPriority`;
- `xError`, `yError`.

Interacción: **sí**.

Animación: **sí**.

Limitaciones: no existe un `BubbleChart` dedicado ni una tercera dimensión Z; el tamaño puede representarse mediante `radius`, pero la lógica debe manejarse en la aplicación.

## 10. RadarChart

**Widget:** `RadarChart`

**Modelo:** `RadarChartData`

**Datos:** `RadarDataSet`, `RadarEntry`.

Ejemplo:

```dart
RadarChart(
  RadarChartData(
    dataSets: [
      RadarDataSet(
        dataEntries: [
          RadarEntry(value: 80),
          RadarEntry(value: 60),
          RadarEntry(value: 90),
        ],
      ),
    ],
  ),
)
```

Parámetros principales:
- `dataSets`
- `radarBackgroundColor`
- `radarShape`
- `radarBorderData`
- `getTitle`
- `titleTextStyle`
- `titlePositionPercentageOffset`
- `tickCount`
- `ticksTextStyle`
- `tickBorderData`
- `gridBorderData`
- `radarTouchData`
- `isMinValueAtCenter`

Interacción: **sí**.

Animación: **sí**.

Multiserie: **sí**, mediante varios `RadarDataSet`.

## 11. CandlestickChart

**Widget:** `CandlestickChart`

Fue incorporado en la serie 1.0.0.

**Modelo:** `CandlestickChartData`

**Datos:** `CandlestickSpot`.

Ejemplo:

```dart
CandlestickChart(
  CandlestickChartData(
    candlestickSpots: [
      CandlestickSpot(
        x: 1,
        open: 80,
        high: 100,
        low: 70,
        close: 95,
      ),
    ],
  ),
)
```

Cada vela requiere OHLC:
- `open`
- `high`
- `low`
- `close`

Parámetros importantes:
- `candlestickSpots`
- `candlestickPainter`
- `titlesData`
- `candlestickTouchData`
- `showingTooltipIndicators`
- `gridData`
- `borderData`
- `minX`, `maxX`, `minY`, `maxY`
- `rangeAnnotations`
- `clipData`
- `backgroundColor`
- `rotationQuarterTurns`
- `touchedPointIndicator`

Interacción: **sí**.

Animación: **sí**.

**Limitación crítica para AniList:** AniList no entrega datos OHLC. Si la Parte B exige un candlestick usando AniList, habría que definir y documentar una transformación matemática válida. No se deben inventar datos financieros.

## 12. Tipos que NO son widgets nativos de FL Chart

No aparecen como familias nativas en la documentación oficial:

- Histograma
- Box Plot
- Heatmap
- Treemap
- Sunburst
- Funnel
- Waterfall
- Gauge
- Sankey
- Bubble Chart dedicado
- Area Chart dedicado

Eso no significa que sean imposibles en Flutter. Significa que, para cumplir la Parte B, habría que clasificarlos como:

1. variante configurable de un chart existente;
2. composición con widgets Flutter;
3. `CustomPainter`/renderizado propio;
4. o no soportado de forma nativa.

## 13. Interacción y animación

Los sistemas de interacción específicos son:

- `LineTouchData`
- `BarTouchData`
- `PieTouchData`
- `ScatterTouchData`
- `RadarTouchData`
- `CandlestickTouchData`

Las familias documentan callbacks, tooltips y control de touch. Los gráficos principales también usan animaciones implícitas al cambiar sus datos.

## 14. Zoom y pan

El changelog oficial documenta soporte de transformaciones/zoom/pan para los gráficos basados en ejes, especialmente:

- `LineChart`
- `BarChart`
- `ScatterChart`

## 15. Datos de AniList que encajan especialmente bien

### BarChart
- obras por género;
- obras por formato;
- obras por estado;
- obras por año;
- popularidad promedio;
- favoritos por género.

### LineChart
- score promedio por año;
- popularidad por año;
- tendencia por año;
- comparación Anime/Manga.

### PieChart
- distribución por género;
- formato;
- estado;
- Anime/Manga.

### ScatterChart
- popularidad vs score;
- favoritos vs score;
- episodios vs score;
- capítulos vs popularidad;
- duración vs score.

### RadarChart
Puede comparar características normalizadas de una obra o grupo, por ejemplo:
- score;
- popularity;
- favourites;
- trending;
- episodios/capítulos normalizados.

### CandlestickChart
Es el caso menos natural para AniList por la ausencia de OHLC.

## 16. Arquitectura con nuestro proyecto

No conectar FL Chart directamente a AniList.

```text
AniList
   ↓
DataSource
   ↓
Repository
   ↓
Domain
   ↓
DataTransformations
   ↓
ChartData*
   ↓
Adaptador FL Chart
   ↓
Widget FL Chart
```

Ejemplo:

```text
Media[]
   ↓
mediaToGenreCount()
   ↓
ChartDataCategory[]
   ↓
BarChart
```

Y:

```text
Media[]
   ↓
mediaToAverageScorePerYear()
   ↓
ChartDataXY[]
   ↓
FlSpot[]
   ↓
LineChart
```

## 17. Regla para la matriz de 63 × 4

Para cada gráfica de la Parte B debemos marcar una de estas categorías:

- **NATIVO**: existe un widget/clase específica.
- **VARIANTE**: se consigue configurando un widget nativo.
- **COMPOSICIÓN**: requiere combinar FL Chart con Flutter.
- **NO NATIVO**: requiere una implementación adicional importante o no está soportado por la librería.

Esto evitará inventar capacidades de FL Chart.

## 18. Pendiente: 31 básicas + 32 avanzadas

Todavía no se debe inventar la clasificación B01-B31 / A01-A32.

El documento recibido del compañero corresponde a **d_chart**: utiliza clases como `DChartBarO`, `DChartLineN` y `DChartPieO`, y enumera sus 63 casos. Es útil como referencia de cómo se organizaron sus implementaciones, pero no demuestra que esos 63 nombres sean la lista oficial universal de la Parte B.

Cuando tengamos la lista oficial de la Parte B, para cada caso se documentará:

- nombre;
- básica/avanzada;
- soporte FL Chart;
- widget/clase;
- tipo de soporte (nativo/variante/composición/no nativo);
- datos necesarios;
- transformación desde AniList;
- código mínimo;
- parámetros principales;
- interacción;
- animación;
- limitaciones;
- ejemplo oficial, si existe.

## 19. Conclusión

FL Chart 1.2.0 proporciona seis familias nativas: Line, Bar, Pie, Scatter, Radar y Candlestick.

Su fuerte está en la personalización, interacción, animación y variantes configurables de esas familias.

Para las 252 implementaciones del proyecto, no debemos esperar 63 clases diferentes en FL Chart. Muchas de las 63 serán variantes o composiciones basadas en las seis familias.

La matriz de la Parte B debe conservar la diferencia entre soporte nativo, variante configurable, composición y ausencia de soporte nativo.
