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

## Matriz 63x4

Existe una matriz maestra central (`master_chart_registry.dart` / `matrix.txt`) que define 63 casos requeridos y mapea cada uno a las 4 librerías mencionadas, totalizando 252 implementaciones evaluadas.

## Estados

Las clasificaciones de implementación para cada caso son:
- **Nativo**: Soportado inherentemente por la librería.
- **Variante**: Requiere ajuste en parámetros o configuración no estándar.
- **Composición**: Construido superponiendo widgets o gráficas múltiples.
- **No soportado**: La librería no cuenta con capacidad para renderizarlo.

Y los estados funcionales son:
- **Funcional**: Operativo con datos reales.
- **Parcial**: Presenta alguna limitación estética o funcional.
- **Demo**: *No utilizado en la versión final*.
- **Roto**: Falla en ejecución.
- **No Disponible**: Carece de datos de respaldo desde la API de AniList (ej. históricos de bolsa o valores OHLC).
- **No Verificado**: No fue probado o integrado activamente tras determinarse soporte.

## Datos

Los gráficos utilizan datos reales provenientes de AniList. Aquellos casos estadísticos o financieros complejos que requieren información no provista por AniList (como velas japonesas, MACD, RSI, etc.) se mantienen como **NO DISPONIBLES**. Se prohíbe explícitamente el uso de datos sintéticos o generados aleatoriamente (mocks) para forzar su funcionamiento visual.

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
