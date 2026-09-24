# AniList Data Viz

## 1. Nombre del proyecto
AniList Data Viz - Base Académica para Visualización de Datos

## 2. Objetivo
Construir una aplicación Flutter que consuma datos reales de AniList utilizando GraphQL y que tenga una arquitectura limpia, modular y fácil de explicar. Esta fase deja preparada la base funcional, corrigiendo errores de concurrencia, paginación, abstracción de modelos de gráficas y ampliando la cantidad de métricas disponibles para dar paso a la implementación de múltiples librerías gráficas.

## 3. Arquitectura
Se ha implementado una **Clean Architecture**:
*   **Presentation**: Pantallas (`screens`) y manejo de estado (`state` usando Provider).
*   **Domain**: Reglas de negocio, contratos (`repositories`) y entidades puras independientes (`Media`, `FuzzyDate`, `PageInfo`).
*   **Data**: Datasources remotos (manejo HTTP robusto), modelos de deserialización (`MediaModel`, `PaginatedMediaModel`) e implementación del Repositorio (`AniListRepositoryImpl`).
*   **Core**: Constantes, manejo de Excepciones y clases `Failure` para un puente limpio entre Data y Presentation.
*   **Charts**: Capa totalmente independiente de AniList con modelos de datos neutrales (`ChartDataCategory`, `ChartDataXY`, `ChartDataMatrix`, etc.) y transformaciones lógicas.

## 4. API utilizada
*   **Endpoint**: `https://graphql.anilist.co`
*   **Tecnología**: GraphQL consumido mediante peticiones HTTP POST.

## 5. Límite de Datos de AniList (NOTA IMPORTANTE)
Los datos consumidos por esta aplicación provienen de solicitudes paginadas en tiempo real. **El dataset visualizado estará limitado al conjunto de resultados que la API devuelva según los filtros aplicados (máximo unas 5000 entradas para peticiones no autenticadas continuas).** Las futuras gráficas representarán *estadísticas del conjunto de datos cargado*, no del 100% de la base de datos total de AniList.

## 6. Paginación y Errores
El DataSource captura errores HTTP (400, 404, 429), fallas de conexión (`SocketException`), y extrae directamente los mensajes de error GraphQL (`errors[].message`). La paginación incluye un estado de `loadMoreError` que permite a la aplicación recuperarse de fallos de red sin perder la información ya cargada y evita peticiones en avalancha provocadas por el Scroll.

## 7. Filtros
Se ha implementado una infraestructura limpia de filtros (UI -> Provider -> Repo -> DataSource -> GraphQL). Permite cambiar Tipo, Formato, Estado y Género, limpiando automáticamente la caché y pidiendo los nuevos resultados de manera concurrente-segura.

## 8. Modelos de Gráficas (Chart Data)
La arquitectura de visualización es agnóstica. Existen los siguientes modelos abstractos con sus respectivas transformaciones genéricas ya implementadas y testeadas:
*   `ChartDataCategory` (Categorías simples: Ej. Cantidad por género)
*   `ChartDataXY` (Temporal/numérico: Ej. Score por Año)
*   `ChartSeries` (Agrupaciones múltiples: Ej. Comparativa Anime/Manga a través del tiempo)
*   `ChartDataMatrix` (Heatmaps: Ej. Género cruzado con Años)
*   `ChartDataRange` (Cajas/BoxPlots: Ej. Distribución de scores por formato)
*   `ChartDataHierarchy` (Treemaps: Ej. Jerarquía Género -> Títulos)

## 9. Instrucciones de ejecución
1. Ejecuta `flutter pub get`.
2. Ejecuta `flutter test` para validar la lógica.
3. Ejecuta `flutter run` para compilar.
