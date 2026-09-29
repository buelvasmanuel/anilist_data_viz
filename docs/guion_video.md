# Guion del video — AniList Data Viz

## 1. Estructura general del video

El profesor va a ver cómo funciona el proyecto por dentro, siguiendo el mismo camino que recorren los datos: desde la petición a AniList hasta el gráfico dibujado por cada una de las cuatro librerías (FL Chart, Syncfusion, d_chart y Graphic).

| Bloque | Integrante | Tema | Termina en |
|---|---|---|---|
| 1 | Persona 1 | Arquitectura y estructura de carpetas | La cadena completa AniList → UI |
| 2 | Persona 2 | API, GraphQL, modelos, paginación y trends | Los datos ya convertidos en entidades |
| 3 | Persona 3 | Providers, dataset común y cómo cada librería lo dibuja | Un caso dibujado por las cuatro librerías |
| 4 | Persona 4 | 63 × 4 = 252, estrategias y casos #2, #52 y #63 | Cierre del video |

El texto hablado de cada bloque está equilibrado en extensión (entre 1 000 y 1 100 palabras aproximadamente por persona). No se indica una duración exacta porque depende del ritmo de cada uno; leído a ritmo normal y con las pausas para mostrar código, cada bloque debería durar lo mismo que los demás.

**Convenciones del documento**

- Lo que está en bloque de cita (`>`) es el **texto literal** que se dice.
- Lo que está entre corchetes y en cursiva, *[así]*, es una **indicación de pantalla**: no se lee.
- Todos los archivos, clases y métodos citados existen en el repositorio actual.

**Nota sobre las fuentes (verificación)**

- `docs/contexto.md` **no existe** en el repositorio (ni en `main`, ni en `final-integration`, ni en el historial). El guion se construyó leyendo directamente el código de `lib/`, `pubspec.yaml`, los tests de `test/` y los documentos que sí existen (`docs/AUDIT_252_CURRENT.md`, `docs/integration_report.md`, `docs/*.md` por librería).
- Diferencia detectada entre comentarios y código: `lib/charts/graphic/data/graphic_view_models.dart` describe el flujo como `Provider → DataTransformations → Chart Models → adapters`. En el código actual, `ChartsDatasetProvider` llama directamente a `GraphicAdapters.animeFrom<Media>(...)` y a `GraphicDataset.fromAnime(...)`, que usa `GraphicTransformations`. La clase `DataTransformations` (`lib/charts/transformations/data_transformations.dart`) sigue existiendo y tiene tests, pero ningún archivo de `lib/` la importa. En el guion se explica el flujo real.
- La capa `domain` solo tiene entidades y el contrato del repositorio: no hay casos de uso. El guion no los menciona.

---

# PERSONA 1 — ARQUITECTURA Y ESTRUCTURA

## Objetivo de esta parte

Demostrar que entendemos cómo está organizado el proyecto, qué responsabilidad tiene cada carpeta y por qué las dependencias van en la dirección en que van. Al final debe quedar clara la cadena completa por la que pasan los datos.

## Qué mostrar en pantalla

1. La app abierta en `HomeScreen` (botones *Explorar Anime*, *Explorar Manga* y las cuatro galerías de gráficas).
2. El árbol de `lib/` en el editor, con las carpetas `core`, `data`, `domain`, `presentation` y `charts` desplegadas un nivel.
3. `lib/main.dart` completo (es corto).
4. `lib/domain/repositories/anilist_repository.dart` (solo la firma de la clase).
5. `lib/charts/common/library_cases.dart`.
6. Al final, el diagrama de la cadena (puede ser una diapositiva o el diagrama del final de este documento).

## GUION HABLADO

*[Pantalla: la app en HomeScreen.]*

> Hola, somos el equipo de AniList Data Viz. En este video vamos a explicar cómo funciona el proyecto por dentro. No vamos a hablar de Flutter en general, sino de cómo resolvimos nosotros el problema: consumir datos reales de AniList y representarlos con 63 tipos de gráfico en cuatro librerías distintas.
>
> Desde la pantalla principal hay dos caminos. Uno es explorar anime o manga como listado, con filtros y una pantalla de detalle. El otro son las cuatro galerías de gráficas: FL Chart, Syncfusion, Graphic y d_chart. Cada galería muestra los mismos 63 casos, así que al final tenemos 252 implementaciones. Eso lo va a explicar al detalle el cuarto integrante; yo voy a explicar cómo está organizado el código para que eso sea posible.

*[Pantalla: árbol de `lib/`.]*

> El código está dentro de `lib` y lo dividimos en cinco carpetas principales, cada una con una responsabilidad concreta.
>
> `core` es lo que comparte todo el proyecto y no depende de nada. Aquí está `ApiConstants`, que guarda el endpoint de AniList, y la carpeta `errors`. En `errors` separamos dos cosas: las excepciones, `ServerException` y `NetworkException`, que se lanzan en la capa de datos, y los `Failure`, que son `ServerFailure`, `NetworkFailure` y `ParsingFailure`, y que son lo que ve la capa de presentación. Esa separación es intencional: la pantalla nunca recibe una excepción de HTTP directamente.
>
> `data` es la única capa que sabe que AniList existe. Dentro tiene tres partes. `datasources/anilist` contiene `AniListRemoteDataSourceImpl`, que hace las peticiones HTTP, y la carpeta `queries` con las consultas GraphQL. `models` tiene las clases que saben leer JSON, como `MediaModel`, `PageInfoModel` y `MediaTrendModel`. Y `repositories` tiene `AniListRepositoryImpl`, que es la implementación concreta del repositorio.
>
> `domain` es el centro de la aplicación. Tiene las entidades, `Media`, `MediaTrend`, `PageInfo` y `FuzzyDate`, que son clases de Dart puras, sin JSON y sin HTTP. Y tiene el contrato `AniListRepository`, que es una clase abstracta. En nuestro caso el dominio no tiene casos de uso: los providers llaman directamente al contrato del repositorio.

*[Pantalla: `lib/domain/repositories/anilist_repository.dart`.]*

> Esto es importante para entender la dirección de las dependencias. Los providers no conocen `AniListRepositoryImpl`, conocen `AniListRepository`, la abstracción que vive en el dominio. Gracias a eso, en los tests podemos inyectar un repositorio falso, el `FakeRepository` de `test/support`, y probar los providers y los 252 builders sin hacer peticiones reales.
>
> `presentation` tiene dos carpetas. `state`, con los tres providers de la aplicación, y `screens`, con la pantalla principal, el listado, el detalle y dos de las galerías.
>
> Y por último está `charts`, que es la parte más grande del proyecto. Aquí está todo lo relacionado con gráficos. En `charts/models` está `master_chart_registry.dart`, que es la matriz de los 63 casos con la capacidad de cada librería. En `charts/graphic/data` está el dataset común, `GraphicDataset`, junto con los adaptadores y las transformaciones. Aunque la carpeta se llama `graphic`, ese dataset lo usan las cuatro librerías, no solo Graphic. Luego hay una carpeta por librería: `fl_chart`, `syncfusion`, `d_chart` y `graphic`, y cada una tiene su archivo de builders con sus 63 casos. Y en `charts/common` están las piezas compartidas: `CaseData`, `CaseImpl`, la galería común y los contenedores de los casos en vivo, `LazyLoadingHost` y `LiveStreamingHost`.
>
> Fuera de `lib` también hay una carpeta que refleja esta misma división: `test`. Tenemos tests del DataSource, del modelo, del `MediaProvider`, de las transformaciones, de la galería, de los casos en vivo y de los 252 builders. Ninguno llama a AniList de verdad: el del DataSource usa un cliente HTTP simulado, y los de providers y gráficos usan el `FakeRepository`, así que no dependen de que AniList responda en ese momento.

*[Pantalla: `lib/main.dart`.]*

> Todo esto se conecta en `main.dart`. Aquí creamos un solo `http.Client`, se lo pasamos a `AniListRemoteDataSourceImpl`, y ese DataSource se lo pasamos a `AniListRepositoryImpl`. Después registramos tres `ChangeNotifierProvider` dentro de un `MultiProvider`: `MediaProvider`, `ChartsDatasetProvider` y `AniListLiveProvider`. Los tres reciben la misma instancia del repositorio. O sea que `main.dart` es el único sitio donde se decide qué implementación concreta se usa; el resto del código trabaja contra abstracciones.

*[Pantalla: `lib/charts/common/library_cases.dart`.]*

> Del lado de los gráficos, el punto de entrada es `library_cases.dart`. La función `casesFor` recibe una librería y devuelve su mapa de 63 casos: `flChartCases`, `syncfusionCases`, `dChartCases` o `graphicCases`. Las cuatro pantallas de galería usan el mismo widget, `MasterCaseGallery`, y lo único que cambia es el mapa de casos que le pasan. Por ejemplo, `DChartGalleryScreen` es solo un `MasterCaseGallery` con `library: ChartLibrary.dChart` y `cases: dChartCases`. Por eso las cuatro galerías tienen la misma estructura, el mismo orden y los mismos filtros: uno por estrategia de implementación y otro por categoría, que agrupa los 63 casos en básicos, apilados y rangos, interacción, escalas, estadísticos y especiales. Así se pueden comparar las cuatro librerías caso por caso.
>
> Hay una decisión de organización que conviene aclarar. Las galerías de FL Chart y Syncfusion tienen su pantalla en `presentation/screens`, mientras que las de Graphic y d_chart la tienen dentro de su propia carpeta en `charts`. Es una diferencia de ubicación que viene de cómo se fue integrando cada librería, pero las cuatro pantallas hacen exactamente lo mismo: delegan en `MasterCaseGallery`.

*[Pantalla: diagrama de la cadena.]*

> Con todo esto ya podemos describir el recorrido completo de un dato. Empieza en AniList, que es una API GraphQL. El DataSource arma la consulta, hace un POST y recibe JSON. Ese JSON se convierte en modelos con `fromJson`. El Repository recibe esos modelos, traduce los errores a `Failure` y los entrega al resto de la app como entidades del dominio. El Provider pide los datos al repositorio y guarda el estado. En el caso de las gráficas, el `ChartsDatasetProvider` transforma una sola vez esas entidades en un `GraphicDataset`, que es un conjunto de listas ya calculadas. La galería empaqueta ese dataset en un `CaseData`, se lo pasa al builder del caso, y el builder usa la API de su librería para dibujar el widget que aparece en pantalla.
>
> La razón de separarlo así es que cada capa se puede cambiar sin tocar las otras. Si AniList cambia un campo, se toca el modelo. Si queremos otra librería de gráficos, se agrega otro mapa de casos. Y ningún widget de gráfico hace peticiones ni calcula estadísticas: solo dibuja.

## Código que conviene mostrar

**`lib/main.dart`**

```dart
final client = http.Client();
final remoteDataSource = AniListRemoteDataSourceImpl(client: client);
final repository = AniListRepositoryImpl(remoteDataSource: remoteDataSource);

runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MediaProvider(repository: repository)),
      ChangeNotifierProvider(create: (_) => ChartsDatasetProvider(repository: repository)),
      ChangeNotifierProvider(create: (_) => AniListLiveProvider(repository: repository)),
    ],
    child: const MyApp(),
  ),
);
```

Qué decir: “Aquí se arma toda la cadena una sola vez. Los tres providers comparten el mismo repositorio y ninguno sabe que por debajo hay HTTP.”

**`lib/domain/repositories/anilist_repository.dart`**

```dart
abstract class AniListRepository {
  Future<({List<Media> mediaList, PageInfo pageInfo})> getMediaList({ ... });
  Future<Media> getMediaById(int id);
  Future<({List<MediaTrend> trends, PageInfo pageInfo})> getMediaTrends({ ... });
  Future<List<Media>> getMediaSnapshots(List<int> ids);
}
```

Qué decir: “Estas cuatro operaciones son todo lo que la app necesita de AniList: listado paginado, detalle, la serie de trends y los contadores para el sondeo del caso 63.”

**`lib/charts/common/library_cases.dart`**

```dart
Map<int, CaseImpl> casesFor(ChartLibrary library) => switch (library) {
      ChartLibrary.flChart => flChartCases,
      ChartLibrary.syncfusion => syncfusionCases,
      ChartLibrary.dChart => dChartCases,
      ChartLibrary.graphic => graphicCases,
    };
```

Qué decir: “Cuatro mapas de 63 entradas. Este es el punto único de acceso a las 252 implementaciones.”

## Transición

> Con esta estructura ya sabemos dónde vive cada cosa. Ahora mi compañero va a entrar en la capa de datos y explicar cómo hacemos realmente la comunicación con AniList.

---

# PERSONA 2 — API, GRAPHQL Y DATOS

## Objetivo de esta parte

Demostrar que entendemos cómo se habla con AniList: qué se envía, qué se recibe, cómo se manejan los errores, cómo el JSON se convierte en entidades, y cómo funcionan la paginación y la serie de trends.

## Qué mostrar en pantalla

1. `lib/core/constants/api_constants.dart` (una línea).
2. `lib/data/datasources/anilist/anilist_remote_datasource.dart` → método `_performQuery`, luego `getMediaList`.
3. `lib/data/datasources/anilist/queries/media_queries.dart` → `getMediaList`, luego `getMediaTrends`.
4. `lib/data/models/media_model.dart` → `MediaModel.fromJson`.
5. `lib/data/repositories/anilist_repository_impl.dart` → método `_guard`.
6. `lib/presentation/state/media_provider.dart` → `fetchMedia` (solo la parte de la página).
7. Opcional: la app en el listado de anime, haciendo scroll hasta que cargue más.

## GUION HABLADO

*[Pantalla: `api_constants.dart`.]*

> Mi parte es la comunicación con AniList. AniList expone una sola URL, `https://graphql.anilist.co`, que tenemos en `ApiConstants.anilistGraphqlUrl`. No hay un endpoint por recurso como en REST: todas las consultas van a la misma dirección y lo que cambia es el cuerpo de la petición.

*[Pantalla: `_performQuery` en `anilist_remote_datasource.dart`.]*

> Toda la comunicación pasa por un único método privado del DataSource, `_performQuery`. Recibe dos cosas: el texto de la consulta GraphQL y un mapa de variables. Con eso hace un `client.post` a la URL de AniList, con los headers `Content-Type` y `Accept` en `application/json`, y en el cuerpo manda un JSON con dos claves: `query` y `variables`. Además le ponemos un `timeout` de 15 segundos.
>
> Cuando llega la respuesta, primero intentamos decodificar el cuerpo. Después revisamos si viene la clave `errors`. Esto lo hacemos antes de mirar el código HTTP, porque AniList puede devolver errores de GraphQL tanto con 200 como con 400, y en los dos casos el mensaje útil está dentro de `errors`. Si hay errores, lanzamos una `ServerException` con el mensaje del primero. Si el status es 200 y existe `data`, devolvemos solo `data`, que es lo que interesa. Si no, lanzamos `ServerException` con el código HTTP.
>
> Los problemas de conexión se tratan aparte: un `TimeoutException`, un `SocketException` o un `ClientException` se convierten en `NetworkException`. Esa distinción entre error del servidor y error de red la probamos en `test/datasource_test.dart`, incluido el caso de error GraphQL con 200 y con 400.

*[Pantalla: `media_queries.dart`, consulta `getMediaList`.]*

> Las consultas están en la clase `MediaQueries`. Todas las que devuelven obras completas reutilizan un fragmento, `MediaFields`, donde pedimos exactamente los campos que usa la app: título en sus variantes, formato, estado, fechas, episodios, capítulos, `averageScore`, `popularity`, `trending`, `favourites`, `rankings`, géneros, estudios, personajes, relaciones e imágenes. Esa es la ventaja de GraphQL en este proyecto: no recibimos campos que no vamos a usar.
>
> La consulta del listado, `getMediaList`, declara las variables con su tipo de AniList, por ejemplo `$type: MediaType` o `$season: MediaSeason`, y las usa dentro de `Page(page: $page, perPage: $perPage)`. Dentro de `Page` pedimos dos cosas: `pageInfo`, con `currentPage`, `hasNextPage`, `lastPage`, `perPage` y `total`, y la lista `media` filtrada y ordenada por `POPULARITY_DESC`.

*[Pantalla: método `getMediaList` del DataSource.]*

> En el método `getMediaList` del DataSource se arma el mapa de variables. `page` y `perPage` siempre van, y los filtros solo se agregan si no son nulos ni vacíos. Así la misma consulta sirve para “todo el anime” o para “anime de invierno de 2024 del género Action”. Con la respuesta, el `pageInfo` pasa por `PageInfoModel.fromJson` y cada elemento de `media` pasa por `MediaModel.fromJson`. El resultado es un `PaginatedMediaModel`.
>
> Los otros tres métodos siguen el mismo patrón. `getMediaById` usa la consulta `getMediaDetail`, que es `Media(id: $id)` con el mismo fragmento, y es la que alimenta la pantalla de detalle. `getMediaTrends` la explico al final. Y `getMediaSnapshots` es una consulta mucho más ligera que se usa para el caso 63: filtra con `id_in` y solo pide `id`, título, `popularity`, `trending` y `favourites`, porque se ejecuta cada 30 segundos y no tiene sentido traer descripciones, personajes e imágenes cada vez.

*[Pantalla: `MediaModel.fromJson`.]*

> `MediaModel.fromJson` es donde el JSON de AniList se adapta a lo que necesita nuestra app. Algunos ejemplos concretos: el título se resuelve con prioridad `userPreferred`, luego `english`, luego `romaji`, luego `native`, y si no hay ninguno se usa `'Unknown Title'`. Los estudios vienen anidados en `studios.nodes` y los personajes en `characters.edges`, así que se recorren y se convierten con `StudioModel` y `CharacterModel`. Y `rankings` es una lista: con la función interna `allTimeRank` buscamos el ranking de tipo `POPULAR` o `RATED` que tenga `allTime` en `true`, y lo guardamos como `popularAllTimeRank` y `ratedAllTimeRank`. Ese último es el que usa el caso 62. Las fechas de inicio y fin llegan como objetos con año, mes y día que pueden venir incompletos, por eso pasan por `FuzzyDateModel`; de ahí sale el año de inicio que usan varios gráficos cuando la obra no tiene `seasonYear`.
>
> La relación entre modelo y entidad es de herencia: `MediaModel extends Media`. El modelo añade el `fromJson`, pero es una `Media` válida. Por eso el repositorio puede devolver la lista de modelos como lista de entidades sin copiar nada.

*[Pantalla: `_guard` en `anilist_repository_impl.dart`.]*

> El repositorio tiene una responsabilidad concreta: traducir errores. Con el método `_guard`, una `NetworkException` se convierte en `NetworkFailure`, una `ServerException` en `ServerFailure` y cualquier otra cosa, por ejemplo un JSON con una forma inesperada, en `ParsingFailure`. Los providers solo capturan `Failure`, así que nunca dependen de detalles de HTTP.

*[Pantalla: `fetchMedia` en `media_provider.dart`; opcional, la app haciendo scroll en el listado.]*

> La paginación funciona con `pageInfo`. En el listado, `MediaProvider.fetchMedia` calcula la página a pedir como `currentPage + 1`, siempre con `perPage` 20. Antes de pedir, comprueba `hasNextPage`: si AniList dijo que no hay más, no hace la petición. La pantalla `MediaListScreen` tiene un `ScrollController` que llama a `fetchMedia` cuando faltan 200 píxeles para el final. Cuando llega la página nueva, se descartan las obras cuyo `id` ya estaba en la lista. Y si mientras tanto el usuario cambió un filtro, la respuesta vieja se ignora gracias a un contador `_currentRequestId`.

*[Pantalla: consulta `getMediaTrends` en `media_queries.dart`.]*

> Por último, los trends. Para los casos que necesitan una serie temporal, como el candlestick o los indicadores del 41 al 44, usamos el campo `Media.trends` de AniList. La consulta `getMediaTrends` pide, para una obra, `trends(sort: DATE_DESC, page, perPage)` con su propio `pageInfo` y nodos con `mediaId`, `date`, `popularity` y `trending`. AniList devuelve como máximo 25 nodos por página en este campo, así que `ChartsDatasetProvider` pide cuatro páginas en paralelo de la obra más popular de la muestra, junta los nodos por fecha para no duplicar días y los ordena de más antiguo a más reciente. `MediaTrendModel.fromJson` convierte `date`, que llega como timestamp Unix en segundos, a un `DateTime` en UTC.
>
> Hay un detalle que tuvimos en cuenta: la `popularity` de trends es acumulada, es el número de usuarios que tienen la obra en su lista, y casi nunca baja. Por eso no se grafica tal cual. `GraphicTransformations.dailyGains` calcula la variación neta por día, y esa es la serie que se usa en los casos financieros adaptados. Y si trends falla, el error se guarda en `trendsError`, pero la muestra principal sigue siendo válida y el resto de gráficos se dibuja igual.

## Código que conviene mostrar

**`_performQuery` (fragmento)**

```dart
final response = await client.post(
  Uri.parse(ApiConstants.anilistGraphqlUrl),
  headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  body: jsonEncode({'query': query, 'variables': variables}),
).timeout(const Duration(seconds: 15));

// Extract GraphQL errors even if HTTP status is 4xx
if (jsonResponse != null && jsonResponse['errors'] != null && (jsonResponse['errors'] as List).isNotEmpty) {
  final errorMessage = jsonResponse['errors'][0]['message'] ?? 'Unknown GraphQL Error';
  throw ServerException(errorMessage);
}
```

Qué decir: “Un solo POST para todas las consultas. Revisamos `errors` antes que el status porque AniList puede devolver errores GraphQL con 200 o con 400.”

**`MediaQueries.getMediaList` (fragmento)**

```graphql
Page(page: $page, perPage: $perPage) {
  pageInfo { currentPage hasNextPage lastPage perPage total }
  media(type: $type, format: $format, status: $status, season: $season,
        seasonYear: $seasonYear, genre: $genre, sort: POPULARITY_DESC) {
    ...MediaFields
  }
}
```

Qué decir: “`pageInfo` es lo que nos permite paginar; `MediaFields` es el fragmento compartido con la consulta de detalle.”

**`MediaModel.fromJson` (fragmento)**

```dart
final parsedTitle = userPreferred ?? english ?? romaji ?? native ?? 'Unknown Title';

int? allTimeRank(String type) {
  final rankings = json['rankings'] as List<dynamic>? ?? const [];
  for (final r in rankings) {
    if (r['type'] == type && r['allTime'] == true) return r['rank'] as int?;
  }
  return null;
}
```

Qué decir: “El modelo es donde decidimos qué hacer cuando AniList no manda un campo, y donde aplanamos estructuras anidadas como `rankings`.”

**`AniListRepositoryImpl._guard`**

```dart
Future<T> _guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on NetworkException catch (e) {
    throw NetworkFailure(e.message);
  } on ServerException catch (e) {
    throw ServerFailure(e.message);
  } catch (e) {
    throw ParsingFailure(e.toString());
  }
}
```

Qué decir: “Aquí termina la capa de datos: hacia arriba solo salen entidades o `Failure`.”

## Transición

> Hasta aquí los datos ya salieron de AniList y llegaron como entidades del dominio. Ahora falta ver quién los guarda, cómo se enteran las pantallas de que cambiaron y cómo se convierten en algo que una librería de gráficos puede dibujar. Eso lo explica mi compañero.

---

# PERSONA 3 — ESTADO Y FLUJO DE LOS GRÁFICOS

## Objetivo de esta parte

Demostrar que entendemos cómo se maneja el estado con Provider en este proyecto, cómo se construye una sola vez el dataset común y cómo ese mismo dataset llega a las cuatro librerías y se convierte en cuatro widgets diferentes.

## Qué mostrar en pantalla

1. `lib/presentation/state/charts_dataset_provider.dart` → método `load`.
2. `lib/charts/graphic/data/graphic_adapters.dart` → `animeFrom` (solo la firma).
3. `lib/charts/graphic/data/graphic_dataset.dart` → `GraphicDataset.fromAnime`, sección “Top N” y “Por año”.
4. `lib/charts/common/master_case_gallery.dart` → `initState`, el `Consumer` y la creación de `CaseData`, luego `MasterCaseCard.build`.
5. `lib/charts/common/case_support.dart` → clases `CaseData` y `CaseImpl`.
6. El caso #5 “Área” en los cuatro archivos de builders (una línea de cada uno).
7. En la app: la galería de Syncfusion, cambiando entre Anime y Manga.

## GUION HABLADO

*[Pantalla: `main.dart` con los tres providers, un momento.]*

> Mi parte es el estado y cómo los datos llegan a los gráficos. En el proyecto usamos Provider para centralizar el estado de todo lo que llega de AniList, y tenemos tres providers, cada uno con una responsabilidad separada.
>
> `MediaProvider` es el de las pantallas de listado y detalle: guarda los filtros, la lista paginada y la obra seleccionada. `ChartsDatasetProvider` es el de las galerías: carga una muestra fija de obras y calcula el dataset de los gráficos. Y `AniListLiveProvider` guarda el estado que cambia en vivo, que es la paginación del caso 52 y el sondeo del caso 63. Los separamos a propósito: por ejemplo, cada 30 segundos el sondeo del 63 notifica cambios, y si ese estado estuviera en `ChartsDatasetProvider`, se reconstruirían las 63 tarjetas en lugar de solo la del caso en vivo.
>
> Los tres extienden `ChangeNotifier`. El patrón es siempre el mismo: el provider modifica sus campos privados, llama a `notifyListeners`, y los widgets que están escuchando se reconstruyen con los datos nuevos.

*[Pantalla: `ChartsDatasetProvider.load`.]*

> Veamos el más importante para los gráficos, `ChartsDatasetProvider`, en su método `load`. Por defecto pide 4 páginas de 50 obras del tipo seleccionado, anime o manga. Las cuatro peticiones se lanzan en paralelo con `Future.wait`, y cada vez que llega una página se incrementa `_loadedPages` y se notifica; por eso la galería muestra “Cargando muestra de AniList, 2 de 4 páginas”. Cuando llegan todas, se juntan quitando duplicados por `id`, se toma la primera obra, que es la más popular, y se descargan sus trends.
>
> También usamos un `_requestId`. Si el usuario cambia de Anime a Manga mientras todavía se está cargando, la respuesta vieja se descarta y no pisa a la nueva. Y si una recarga falla pero ya había datos, se conserva la muestra anterior y solo se informa el error. Eso está probado en `test/charts_gallery_test.dart`.

*[Pantalla: la llamada a `GraphicAdapters.animeFrom` dentro de `load`, y luego `graphic_adapters.dart`.]*

> Con la muestra lista, el provider construye el dataset. Primero pasa por `GraphicAdapters.animeFrom`. Este adaptador no conoce los nombres de campos de nuestro dominio: recibe funciones accessor. El provider le dice “el título es `m.title`”, “la popularidad es `m.popularity`, o 0 si es nula”, “el tamaño de burbuja son los episodios si es anime o los capítulos si es manga”, “el ranking es `ratedAllTimeRank`”. El resultado es una lista de `GAnime`, que es un modelo de vista pequeño con solo los campos que usan los gráficos.

*[Pantalla: `GraphicDataset.fromAnime`.]*

> Después viene `GraphicDataset.fromAnime`. Aquí está la decisión principal de esta parte: una vez tenemos los datos, no hacemos que cada librería calcule todo por separado. Se calcula todo una sola vez en el provider, y cada gráfico solo lee la lista que necesita. Por ejemplo, `topByPopularity` son las 10 obras más populares; `countByYear` y `scoreByYear` agrupan por año de temporada o de inicio y se quedan con los últimos 10 años; `countByFormat` cuenta obras por formato y lo deja ordenado, que es lo que necesitan el funnel y la pirámide; `yearFormatSeries` es una serie año por formato que pasa por `alignSeries` para que todas las series tengan las mismas x, porque los gráficos apilados lo exigen.
>
> Las operaciones estadísticas están en `GraphicTransformations`: media, cuantiles para el box plot, bins del histograma, acumulado, cascada, regresión lineal, y sobre la serie de trends la variación diaria, velas de 7 días, SMA, Bollinger, RSI y MACD. Ningún widget de gráfico hace estos cálculos.

*[Pantalla: `master_case_gallery.dart`, `initState` y el `Consumer`.]*

> Ahora, ¿cómo llega esto a la pantalla? Todas las galerías usan `MasterCaseGallery`. En su `initState`, después del primer frame, hace `context.read<ChartsDatasetProvider>()` y llama a `load` si el estado todavía es inicial. Usamos `read` porque aquí solo queremos disparar una acción, no suscribirnos.
>
> Para dibujar usamos `Consumer<ChartsDatasetProvider>`. Hay dos: uno en la AppBar, con el selector Anime o Manga que llama a `provider.load(type: ...)`, y otro en el cuerpo. Cuando el provider notifica, el `Consumer` se reconstruye, toma el `graphicDataset` y lo empaqueta en un `CaseData`, junto con la lista de `Media`, el tipo cargado, el título de la obra de trends y el error de trends si lo hubo. En otras partes usamos `context.watch`, por ejemplo en `MediaListScreen` o en los contenedores de los casos 52 y 63; el efecto es el mismo que el `Consumer`, el widget se reconstruye cuando el provider notifica. La regla que seguimos es: `read` para acciones, `watch` o `Consumer` para lo que se dibuja.

*[Pantalla: `CaseData` y `CaseImpl` en `case_support.dart`.]*

> `CaseData` es lo que recibe cada builder, y es igual para las cuatro librerías. `CaseImpl` describe una implementación: la estrategia, que puede ser nativo, variante, composición o adaptación; el origen de los datos, la API de la librería que se usa, una nota opcional y el `builder`, que es una función que recibe el `BuildContext` y el `CaseData` y devuelve un widget. La tarjeta `MasterCaseCard` muestra esos metadatos como etiquetas y luego llama a `impl.builder(context, data)` dentro de un `SizedBox` de 280 de alto.

*[Pantalla: el caso #5 en los cuatro archivos de builders.]*

> Para ver cómo las cuatro librerías convierten el mismo dataset, tomemos el caso 5, “Área”. Los cuatro builders leen exactamente la misma lista, `d.g.countByYear`, que son las obras por año. Lo que cambia es cómo se entrega a cada librería.
>
> En Syncfusion se usa `AreaSeries` y se le pasa la lista directamente como `dataSource`, con dos mappers que dicen qué es x y qué es y. En Graphic se crea un `Chart` con `data: d.countByYear`, se declaran las variables x e y, y se dibuja un `AreaMark`, más un `LineMark` para el borde porque el área no tiene propiedad de borde. En FL Chart, el builder convierte las categorías a `FlSpot` y construye un `LineChart` con `belowBarData`, es decir, un área que se consigue configurando el gráfico de línea. Y en d_chart se convierte a un grupo numérico por año y se usa `DChartLineN` con `includeArea`.
>
> Por eso en la tarjeta Syncfusion y Graphic aparecen como NATIVO y FL Chart y d_chart como VARIANTE: el dato es el mismo, pero la forma de llegar al gráfico depende de la API de cada librería.

*[Pantalla: la app, galería Syncfusion, cambiar Anime → Manga.]*

> Y si cambiamos a Manga, el `ChartsDatasetProvider` vuelve a cargar, recalcula el dataset y notifica. El `Consumer` crea un `CaseData` nuevo y los 63 builders se vuelven a ejecutar con los datos de manga. Mientras carga, se conservan los datos anteriores, para que los gráficos animen la transición en lugar de quedarse en blanco.

## Código que conviene mostrar

**`ChartsDatasetProvider.load` (fragmento)**

```dart
_graphicDataset = GraphicDataset.fromAnime(
  GraphicAdapters.animeFrom<Media>(
    collected,
    title: (m) => m.title,
    popularity: (m) => m.popularity ?? 0,
    format: (m) => m.format ?? 'UNKNOWN',
    status: (m) => m.status ?? 'UNKNOWN',
    score: (m) => m.averageScore,
    // Tamaño de burbuja (#11): episodios en anime, capítulos en manga.
    episodes: (m) => m.type == 'MANGA' ? m.chapters : m.episodes,
    ...
  ),
  trends: GraphicAdapters.trendsFrom<MediaTrend>(trends, ...),
);
```

Qué decir: “Aquí las entidades del dominio se convierten en el dataset común. Es el único lugar donde se calcula; los gráficos solo leen.”

**`MasterCaseGallery` (fragmento)**

```dart
body: Consumer<ChartsDatasetProvider>(
  builder: (context, provider, _) {
    final dataset = provider.graphicDataset;
    ...
    final data = CaseData(
      g: dataset,
      media: provider.media,
      type: provider.loadedType,
      trendsTitle: provider.trendsMedia?.title,
      trendsError: provider.trendsError,
    );
```

Qué decir: “Cada vez que el provider notifica, se construye un `CaseData` nuevo y se reparte a los 63 builders.”

**`CaseImpl` (fragmento de `case_support.dart`)**

```dart
typedef CaseBuilder = Widget Function(BuildContext context, CaseData data);

class CaseImpl {
  final ImplementationStrategy strategy;
  final String origin;
  final String api;
  final String? note;
  final CaseBuilder builder;
  ...
}
```

Qué decir: “Un caso no es solo un widget: también declara cómo está hecho y de dónde salen sus datos, y eso se muestra en la tarjeta.”

**Caso #5 en las cuatro librerías (una línea de cada archivo)**

```dart
// syncfusion_case_builders.dart — NATIVO
AreaSeries<GCategory, String>(dataSource: d.g.countByYear, xValueMapper: _x, yValueMapper: _y, ...)

// graphic_line_area_charts.dart (g05Area) — NATIVO
Chart(data: d.countByYear, variables: categoryVars(), marks: [AreaMark(...), LineMark(...)], ...)

// fl_case_builders.dart — VARIANTE
_lineChart([_line(_spots(d.g.countByYear), casePalette[2], area: true)], ...)   // LineChart + belowBarData

// d_chart_case_builders.dart — VARIANTE
_line([_yearGroup('Obras', d.g.countByYear)], area: true)                          // DChartLineN + includeArea
```

Qué decir: “Misma lista de entrada, cuatro APIs distintas.”

## Transición

> Ya vimos que los 63 casos de cada librería reciben el mismo `CaseData`. Ahora mi compañero va a explicar qué significa exactamente tener 252 implementaciones, por qué no todas son iguales y cómo funcionan los casos que dependen de datos en vivo.

---

# PERSONA 4 — 252 IMPLEMENTACIONES Y CASOS ESPECIALES

## Objetivo de esta parte

Demostrar que entendemos qué significa 63 × 4 = 252, la diferencia entre la capacidad de una librería y cómo lo implementamos nosotros, y explicar con código real el caso #2 de principio a fin y los dos casos que hacen peticiones vivas: #52 y #63.

## Qué mostrar en pantalla

1. `lib/charts/models/master_chart_registry.dart` → la entrada del caso 32.
2. `lib/charts/common/case_support.dart` → `enum ImplementationStrategy`.
3. En la app, galería d_chart → filtro ADAPTACIÓN → tarjeta #32 Candlestick. Después la misma tarjeta en Syncfusion.
4. `lib/charts/d_chart/d_chart_case_builders.dart` → función `_candles`.
5. Caso #2: la línea `2:` de cada archivo de builders y `g02Column` en `graphic_bar_charts.dart`.
6. `lib/charts/common/live_case_hosts.dart` → `LazyLoadingHost._onScroll` y `LiveStreamingHost.initState`.
7. `lib/presentation/state/anilist_live_provider.dart` → `loadNextPage`, `acquirePolling` y `pollNow`.
8. En la app: la tarjeta #52 haciendo scroll horizontal y la tarjeta #63 esperando una nueva lectura.

## GUION HABLADO

*[Pantalla: `master_chart_registry.dart`.]*

> Mi parte es explicar el número 252. El proyecto define 63 casos maestros en `masterChartRegistry`, desde línea simple hasta real-time streaming. Cada librería tiene un mapa con esos 63 casos, así que 63 por 4 da 252 implementaciones. En `test/case_builders_test.dart` un test comprueba que el total es 252 y además renderiza cada builder.
>
> Pero 252 implementaciones no son 252 tipos de gráfico diferentes: son 63 tipos, cada uno resuelto cuatro veces con cuatro APIs distintas. Y hay que separar dos conceptos que en el proyecto están en sitios distintos.
>
> El primero es la CAPACIDAD. Está en `masterChartRegistry`, y para cada caso y cada librería guarda un `LibrarySupport` con la clasificación: nativo, variante, composición o no soportado. Esto responde a la pregunta “¿la librería trae esto?”.
>
> El segundo es la IMPLEMENTACIÓN. Está en cada `CaseImpl`, en el campo `strategy`, y responde a “¿cómo lo dibujamos nosotros en este proyecto?”. Las estrategias están en el enum `ImplementationStrategy`. NATIVO es usar directamente el widget o la serie de la librería. VARIANTE es configurar un gráfico nativo, o prepararle los datos antes; por ejemplo, un área en FL Chart es un `LineChart` con `belowBarData`. COMPOSICIÓN es combinar la librería con widgets o estado de Flutter, por ejemplo un `RangeSlider` que filtra un gráfico, o dos gráficos superpuestos en un `Stack`. Y ADAPTACIÓN es cuando la librería no tiene el gráfico, o el dato no es del tipo que el gráfico espera, y construimos una representación equivalente. Cada adaptación lleva una nota visible en la tarjeta que lo explica.

*[Pantalla: la app, galería d_chart, filtro ADAPTACIÓN, tarjeta #32.]*

> El mejor ejemplo es el caso 32, Candlestick, en d_chart. En la matriz de capacidad, d_chart aparece como NO SOPORTADO, porque d_chart 3.0.0 no tiene gráfico de velas. d_chart solo tiene tres casos así: el 32, el 33 y el 34. Aun así lo implementamos, y está marcado como ADAPTACIÓN.

*[Pantalla: `_candles` en `d_chart_case_builders.dart`.]*

> La función `_candles` superpone dos `DChartBarO` en un `Stack`. La capa de abajo es una barra muy fina, de 2 píxeles, que va del mínimo al máximo de la semana: es la mecha. La capa de arriba es una barra de 12 píxeles, que va de la apertura al cierre: es el cuerpo. Para que una barra no empiece en cero sino en el valor mínimo usamos `measureOffset`. El color es verde si el cierre es mayor o igual que la apertura y rojo si no.
>
> Y hay una segunda adaptación, que afecta a las cuatro librerías: los datos. AniList no tiene precios. Lo que usamos es la variación diaria de popularidad que calculó `dailyGains` a partir de `Media.trends`, y `GraphicTransformations.ohlc` la agrupa en ventanas de 7 días: open es el primer día, high el máximo, low el mínimo y close el último día. Por eso en Syncfusion, aunque `CandleSeries` es nativo y la capacidad es NATIVO, la implementación también está marcada como ADAPTACIÓN: el widget es nativo, pero el dato es adaptado. Y la nota de la tarjeta lo dice: no representa una cotización financiera.
>
> En total hay 118 implementaciones nativas, 80 variantes, 38 composiciones y 16 adaptaciones. Syncfusion es la que más casos nativos tiene, 54.

*[Pantalla: la línea `2:` de los cuatro archivos de builders, y `g02Column`.]*

> Ahora recorramos un caso completo, el número 2, Columna Vertical: las 10 obras más populares de la muestra. La consulta `getMediaList` pide `popularity` en el fragmento `MediaFields`, ordenado por `POPULARITY_DESC`. `_performQuery` hace el POST, `MediaModel.fromJson` lee `json['popularity']` y el repositorio devuelve las obras como `Media`. `ChartsDatasetProvider` junta las 200 obras de las 4 páginas y las pasa por `GraphicAdapters.animeFrom`. `GraphicDataset.fromAnime` las ordena por popularidad y guarda las 10 primeras en `topByPopularity`. La galería mete el dataset en `CaseData` y llama al builder del caso 2.
>
> Desde ahí, en las cuatro librerías el caso es NATIVO. En FL Chart, `toCategories` convierte los datos a `ChartDataCategory` y se dibujan con nuestro wrapper `BasicBarChart`, que por dentro es un `BarChart`. En Syncfusion es un `ColumnSeries` con los mappers de x e y. En d_chart, `_og` los convierte a un `OrdinalGroup` para `DChartBarO`. Y en Graphic, `g02Column` crea un `Chart` con un `IntervalMark` de título por popularidad y un `RectShape`. La tarjeta indica “DIRECTO: popularity de las 10 obras más populares”, porque el campo viene tal cual de AniList.

*[Pantalla: `LazyLoadingHost` y `loadNextPage`; luego la tarjeta #52 en la app.]*

> Los casos 52 y 63 son diferentes, porque no usan la muestra fija: hacen peticiones reales mientras la tarjeta está en pantalla. Para no repetir esa lógica cuatro veces, está en `live_case_hosts.dart`, y cada librería solo aporta la función que dibuja.
>
> El 52 es Infinite Scrolling. `LazyLoadingHost` tiene un `ScrollController` horizontal. Al montarse, llama a `ensureLazyStarted` del `AniListLiveProvider` con el tipo cargado, que pide la primera página. Cuando el scroll llega a 40 píxeles del final, llama a `loadNextPage`, que pide a AniList `page` igual a la página actual más uno, con `perPage` 20, a través de `repository.getMediaList`. Las obras nuevas se añaden sin duplicados, se actualiza `hasNextPage` y, al notificar, el gráfico se ensancha 34 píxeles por obra. En las cuatro librerías es COMPOSICIÓN, porque combina el gráfico con scroll y estado de Flutter; incluso en Syncfusion, que tiene capacidad nativa.

*[Pantalla: `acquirePolling` y `pollNow` en `anilist_live_provider.dart`.]*

> El 63 es Real-time Streaming, y aquí hay que ser claros: AniList no ofrece WebSocket ni notificaciones push, así que en este proyecto no hay WebSocket. Lo que hacemos es polling, un sondeo periódico.
>
> Cuando la tarjeta se monta, `LiveStreamingHost` toma los `id` de las 5 obras más populares de la muestra y llama a `acquirePolling`. Eso crea un `Timer.periodic` de 30 segundos y hace una primera lectura inmediata. Cada lectura es `pollNow`: llama a `getMediaSnapshots`, la consulta ligera que explicó mi compañero, suma la popularidad de las 5 obras, la compara con la lectura anterior y calcula el delta. Guarda un `LiveSample` con la hora, el total, el delta y el valor por obra, conserva como máximo 30 lecturas y llama a `notifyListeners`. `changesDetected` cuenta en cuántas lecturas el delta fue distinto de cero.
>
> Como `LiveStreamingHost` hace `context.watch` del provider, cada notificación reconstruye la tarjeta con la lista de lecturas nueva. FL Chart y d_chart vuelven a dibujar el gráfico de línea completo. Syncfusion agrega solo los puntos nuevos con `ChartSeriesController.updateDataSource`. Y Graphic usa `changeDataStream` con un `ChangeDataEvent`, que es su mecanismo nativo para cambiar datos; por eso en Graphic este caso es NATIVO y en las otras tres es COMPOSICIÓN. Cuando la tarjeta sale de pantalla, `releasePolling` descuenta un consumidor y, si no queda ninguno, cancela el `Timer`, así que no se hacen peticiones si nadie está mirando.
>
> Y con esto cerramos. Recorrimos el proyecto desde la petición GraphQL a AniList hasta los 252 gráficos, pasando por el repositorio, los providers y el dataset común. Gracias.

## Código que conviene mostrar

**Capacidad del caso #32 (`master_chart_registry.dart`)**

```dart
MasterChartSpec(
  number: 32,
  name: 'Candlestick',
  support: {
    ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    ChartLibrary.dChart: LibrarySupport(ChartClassification.noSoportado, ChartState.funcional),
    ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
  },
),
```

Qué decir: “Esto es capacidad. d_chart no trae velas, y lo dejamos dicho así.”

**Implementación del caso #32 en d_chart y Syncfusion**

```dart
// d_chart_case_builders.dart
32: _impl(32, _a, 'Dos DChartBarO superpuestos (mecha y cuerpo) con measureOffset',
    (_, d) => withTrends(d, () => _candles(d.g.trendOhlc)), note: ohlcNote),

// syncfusion_case_builders.dart
32: _impl(32, _a, 'CandleSeries', (_, d) => withTrends(d, () => _cartesian([
      CandleSeries<GOhlc, String>(dataSource: d.g.trendOhlc, ...),
    ], yMin: null)), note: ohlcNote),
```

Qué decir: “Esto es implementación. Las dos son `_a`, adaptación, pero por motivos distintos: en d_chart por la librería, en Syncfusion por el dato.”

**`GraphicTransformations.ohlc`**

```dart
for (var start = 0; start + period <= values.length; start += period) {
  final w = values.sublist(start, start + period);
  out.add(GOhlc(labels[start], w.first,
      w.fold<num>(w.first, (a, b) => a > b ? a : b),
      w.fold<num>(w.first, (a, b) => a < b ? a : b),
      w.last));
}
```

Qué decir: “Velas de 7 días sobre la variación diaria de popularidad. No es un precio.”

**Caso #2 en las cuatro librerías**

```dart
// fl_case_builders.dart
2: _impl(2, _n, 'BarChart (BasicBarChart)', (_, d) => BasicBarChart(data: toCategories(_topPopularity(d)), ...)),
// syncfusion_case_builders.dart
2: _impl(2, _n, 'ColumnSeries', (_, d) => _cartesian([ColumnSeries<GCategory, String>(dataSource: _topPopularity(d), ...)])),
// d_chart_case_builders.dart
2: _impl(2, _n, 'DChartBarO (arrangeVertically: false)', (_, d) => _bars([_og('popularity', _topPopularity(d))], rotation: 45)),
// graphic_bar_charts.dart (g02Column)
Chart(data: d.topByPopularity, marks: [IntervalMark(position: Varset('title') * Varset('popularity'), ...)])
```

Qué decir: “El mismo `topByPopularity`, cuatro APIs, y en las cuatro el caso es nativo.”

**`AniListLiveProvider.pollNow` (fragmento)**

```dart
final snapshot = await repository.getMediaSnapshots(_pollIds);
final byTitle = {for (final m in snapshot) m.title: m.popularity ?? 0};
final total = byTitle.values.fold<int>(0, (a, b) => a + b);
final previous = _samples.isEmpty ? null : _samples.last.totalPopularity;
_samples.add(LiveSample(
  time: DateTime.now(),
  totalPopularity: total,
  delta: previous == null ? 0 : total - previous,
  byTitle: byTitle,
));
```

Qué decir: “Una lectura: consultar, sumar, comparar con la anterior, guardar y notificar.”

**`acquirePolling` / `releasePolling`**

```dart
_pollUsers++;
if (_timer == null && _pollIds.isNotEmpty) {
  _timer = Timer.periodic(pollInterval, (_) => pollNow());   // pollInterval = 30 s
  pollNow();
}
...
if (_pollUsers == 0) {
  _timer?.cancel();
  _timer = null;
}
```

Qué decir: “El `Timer` solo existe mientras la tarjeta del 63 está visible.”

## Transición

Es el cierre del video (ver la última frase del guion hablado). Si se quiere una despedida conjunta, cada integrante puede decir su nombre al final.

---

# REPASO FINAL PARA LOS 4

## 10 ideas que todos deben conocer

1. Toda la comunicación con AniList pasa por `_performQuery` de `AniListRemoteDataSourceImpl`: un POST a `https://graphql.anilist.co` con `query` y `variables`.
2. `MediaModel extends Media`: el modelo sabe leer JSON y a la vez es una entidad del dominio.
3. El repositorio traduce excepciones (`ServerException`, `NetworkException`) a `Failure` (`ServerFailure`, `NetworkFailure`, `ParsingFailure`).
4. Hay tres providers: `MediaProvider` (listado y detalle), `ChartsDatasetProvider` (muestra de las galerías) y `AniListLiveProvider` (#52 y #63).
5. La muestra de las galerías son 4 páginas × 50 obras, ordenadas por `POPULARITY_DESC`, más hasta 4 páginas de `Media.trends` de la obra más popular.
6. `GraphicDataset.fromAnime` calcula todo una vez; los builders solo leen listas. Lo usan las cuatro librerías.
7. Cada caso es un `CaseImpl` con `strategy`, `origin`, `api`, `note` y `builder`; el builder recibe un `CaseData`.
8. 63 casos maestros × 4 librerías = 252, verificado por `test/case_builders_test.dart`.
9. Capacidad (en `masterChartRegistry`) y estrategia de implementación (en cada `CaseImpl`) son cosas distintas.
10. El #63 es polling cada 30 segundos, no WebSocket; el #52 es paginación real con `pageInfo.hasNextPage`.

## 10 conceptos que no deben confundirse

| No confundir… | …con | Diferencia en este proyecto |
|---|---|---|
| Exception | Failure | Exception se lanza en `data`; Failure es lo que capturan los providers. |
| Model | Entity | `MediaModel` tiene `fromJson`; `Media` es Dart puro sin JSON. |
| Capacidad | Implementación | Capacidad = qué trae la librería (`ChartClassification`); implementación = cómo lo hicimos (`ImplementationStrategy`). |
| VARIANTE | COMPOSICIÓN | Variante configura un gráfico de la librería; composición lo combina con widgets o estado de Flutter. |
| ADAPTACIÓN | NO SOPORTADO | No soportado es una clasificación de capacidad; adaptación es cómo lo dibujamos igualmente. |
| `context.read` | `context.watch` / `Consumer` | `read` para acciones (no se suscribe); `watch`/`Consumer` reconstruyen al notificar. |
| `popularity` de `Media` | `popularity` de `Media.trends` | La primera es el valor actual; la segunda es una serie diaria acumulada que convertimos en variación diaria. |
| Candlestick del proyecto | Gráfico financiero | Las velas agrupan 7 días de variación de popularidad; no hay precios. |
| Polling | WebSocket / streaming push | Consultamos cada 30 s con un `Timer`; AniList no empuja datos. |
| `GraphicTransformations` | `DataTransformations` | La primera alimenta el dataset de las galerías; la segunda existe y tiene tests pero no la importa ningún archivo de `lib/`. |

## 10 preguntas que cualquiera de los cuatro podría recibir

1. **¿Por qué hay un DataSource y además un Repository?**
   El DataSource habla HTTP y JSON; el Repository expone entidades y traduce errores a `Failure`. Los providers dependen solo del contrato `AniListRepository`.

2. **¿Qué pasa si AniList responde 400 con un error de GraphQL?**
   `_performQuery` revisa `errors` antes del status y lanza `ServerException` con el mensaje de AniList; el repositorio lo convierte en `ServerFailure`.

3. **¿Cómo sabe la app que no hay más páginas?**
   Por `pageInfo.hasNextPage`. `MediaProvider.fetchMedia` y `AniListLiveProvider.loadNextPage` no piden más si es `false`.

4. **¿Por qué no calcula cada gráfico sus propios datos?**
   Porque así los 252 casos muestran exactamente los mismos datos y el cálculo se hace una sola vez en `ChartsDatasetProvider` con `GraphicDataset.fromAnime`.

5. **¿Por qué el dataset se llama `GraphicDataset` si lo usan las cuatro librerías?**
   Nació en la integración de Graphic y después se reutilizó como dataset común; `CaseData` lo documenta así.

6. **¿Por qué tres providers y no uno?**
   Para que cada notificación reconstruya solo lo necesario: el sondeo del #63 no debe reconstruir las 63 tarjetas.

7. **¿Qué significa que d_chart #32 sea ADAPTACIÓN?**
   d_chart no tiene velas (capacidad NO SOPORTADO); las dibujamos superponiendo dos `DChartBarO` con `measureOffset`: una fina para la mecha y otra gruesa para el cuerpo.

8. **¿De dónde salen los datos del candlestick si AniList no tiene precios?**
   De `Media.trends`: variación diaria de popularidad (`dailyGains`), agrupada en velas de 7 días (`ohlc`). La tarjeta lo aclara con `ohlcNote`.

9. **¿El #63 sigue consultando si salgo de la galería?**
   No. `LiveStreamingHost.dispose` llama a `releasePolling`; cuando no queda ningún consumidor se cancela el `Timer`.

10. **¿Cómo comprobaron que las 252 implementaciones funcionan?**
    `test/case_builders_test.dart` verifica las 63 claves por librería, origen y API no vacíos, total 252, y renderiza cada builder con un `FakeRepository`.

---

# MAPA GENERAL DEL PROYECTO

El diagrama sigue el código real. La única diferencia con el esquema genérico es que entre Provider y Dataset hay un paso de adaptadores (`GraphicAdapters`), y que los casos #52 y #63 salen del camino principal: piden datos a AniList a través de `AniListLiveProvider` en lugar de usar la muestra fija.

```text
AniList (https://graphql.anilist.co)
   ↓
HTTP POST + GraphQL  {query, variables}          MediaQueries (media_queries.dart)
   ↓
DataSource           AniListRemoteDataSourceImpl._performQuery
   ↓                 JSON → MediaModel / PageInfoModel / MediaTrendModel (fromJson)
Repository           AniListRepositoryImpl  (Exception → Failure)
   ↓
Domain               Media · MediaTrend · PageInfo  +  contrato AniListRepository
   ↓
Provider             MediaProvider          → listado / detalle (pantallas)
                     ChartsDatasetProvider  → muestra 4×50 + Media.trends
                     AniListLiveProvider    → #52 paginación · #63 polling 30 s
   ↓
Adaptadores          GraphicAdapters.animeFrom / trendsFrom  → GAnime, GTrendPoint
   ↓
Dataset              GraphicDataset.fromAnime + GraphicTransformations
   ↓
CaseData / CaseImpl  MasterCaseGallery (Consumer) → CaseData → casesFor(library)[n]
   ↓
Builder              impl.builder(context, data)   (#52/#63: LazyLoadingHost / LiveStreamingHost)
   ↓
Librería             FL Chart 1.2.0 · Syncfusion 34.2.9 · d_chart 3.0.0 · Graphic 2.7
   ↓
UI                   MasterCaseCard (etiquetas de capacidad/estrategia + gráfico)
```
