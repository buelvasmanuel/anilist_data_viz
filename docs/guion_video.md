# Guion del video — AniList Data Viz

## 1. Estructura general del video

El video sigue el mismo camino que recorren los datos dentro de la app: desde que se pide información a AniList hasta que aparece dibujada en un gráfico de cada una de las cuatro librerías (FL Chart, Syncfusion, d_chart y Graphic).

| Bloque | Integrante | Tema | Termina en |
|---|---|---|---|
| 1 | Persona 1 | Cómo está organizado el proyecto | El recorrido completo de un dato |
| 2 | Persona 2 | Cómo hablamos con AniList y cómo convertimos la respuesta | Los datos listos para usarse en la app |
| 3 | Persona 3 | Cómo se guarda el estado y cómo los datos llegan a los gráficos | Un mismo caso dibujado por las cuatro librerías |
| 4 | Persona 4 | Qué significa 252, cómo lo resolvimos y los casos especiales | Cierre |

Cada bloque tiene una cantidad parecida de texto hablado (entre 720 y 800 palabras aproximadamente), así que la participación queda equilibrada.

**Cómo leer este documento**

- El texto en bloque de cita (`>`) es lo que se dice, tal cual.
- Lo que va entre corchetes y en cursiva, *[así]*, es lo que se ve en pantalla. No se lee.
- El código se muestra como evidencia. Quien habla explica la idea, no lee el código.

**Nota de verificación**

- `docs/contexto.md` no existe en el repositorio, así que el guion está basado directamente en el código actual, los tests y los demás documentos de `docs/`.
- Algunos comentarios de `graphic_view_models.dart` describen un paso por `DataTransformations`. En el código actual ese paso no existe: el provider construye el dataset directamente con `GraphicAdapters` y `GraphicDataset`. `DataTransformations` solo se usa en los tests. El guion cuenta el flujo real.
- La capa de dominio tiene entidades y el contrato del repositorio, pero no casos de uso. El guion no los menciona.

---

# PERSONA 1 — ARQUITECTURA Y ESTRUCTURA

## Objetivo de esta parte

Mostrar que sabemos por qué el proyecto está dividido como está, qué problema resuelve cada capa y cómo viaja un dato desde AniList hasta la pantalla.

## Qué mostrar en pantalla

1. La app en la pantalla de inicio, con los botones de explorar y las cuatro galerías.
2. El árbol de `lib/` con las cinco carpetas principales desplegadas un nivel.
3. `lib/main.dart`.
4. Una galería abierta (por ejemplo, Syncfusion) mostrando dos o tres tarjetas.
5. Al final, el mapa del proyecto (la última sección de este documento).

## GUION HABLADO

*[Pantalla: la app en la pantalla de inicio.]*

> Hola, somos el equipo de AniList Data Viz. En este video vamos a explicar cómo funciona el proyecto por dentro. La idea era tomar datos reales de AniList, que es una base de datos de anime y manga, y representarlos con 63 tipos de gráfico distintos en cuatro librerías diferentes de Flutter.
>
> Desde la pantalla principal hay dos caminos. Uno es explorar anime o manga como un listado normal, con filtros y una pantalla de detalle. El otro son las cuatro galerías de gráficas, una por librería. Las cuatro muestran los mismos 63 casos, con los mismos datos, y así se pueden comparar entre sí.
>
> El reto principal no era hacer un gráfico, sino hacer 252 sin que el proyecto se volviera inmanejable. Por eso le dimos tanta importancia a la organización.

*[Pantalla: árbol de `lib/`.]*

> Dividimos el código en capas, y cada una tiene una sola preocupación.
>
> La capa de datos es la única que sabe que AniList existe. Es la que arma las consultas, hace las peticiones y lee el JSON que vuelve. Si mañana AniList cambiara un campo, solo tendríamos que tocar esta parte.
>
> La capa de dominio es el centro. Aquí están las entidades con las que trabaja el resto de la app, como una obra o un punto de la serie de tendencias, y el contrato del repositorio, que dice qué datos puede pedir la aplicación sin decir cómo se consiguen. Estas clases no saben nada de HTTP ni de JSON.
>
> La capa de presentación tiene las pantallas y el estado. Aquí están los providers, que piden datos al repositorio y avisan a la interfaz cuando algo cambia.
>
> Luego está `core`, con lo que comparten todos: la dirección de AniList y los tipos de error. Y por último `charts`, que es la parte más grande del proyecto, donde vive todo lo relacionado con gráficos: el catálogo de los 63 casos, el conjunto de datos común y una carpeta por librería.
>
> Una decisión importante fue separar los errores en dos niveles. Abajo, en la capa de datos, un fallo es una excepción técnica, por ejemplo un timeout o una respuesta mal formada. Al subir por el repositorio se convierte en un fallo de la aplicación, que es lo único que ven las pantallas. Así la interfaz puede mostrar “sin conexión” o “error del servidor” sin saber nada de HTTP.

*[Pantalla: `lib/main.dart`.]*

> Todo esto se conecta en un solo lugar, el `main`. Ahí creamos el cliente HTTP, el DataSource y el repositorio, y registramos tres providers. Los tres reciben el mismo repositorio, pero lo conocen solo por su contrato, no por su implementación concreta. Gracias a eso, en los tests reemplazamos el repositorio por uno falso y podemos probar providers y gráficos sin llamar a AniList. Es la parte del proyecto que más nos ayudó cuando empezamos a tener cientos de gráficos: podíamos verificar que todos se dibujaban sin depender de la red.

*[Pantalla: una galería abierta, recorrer dos o tres tarjetas.]*

> Para los gráficos aplicamos la misma idea. Las cuatro galerías usan una única pantalla común. Lo único que cambia entre una y otra es el conjunto de 63 implementaciones que se le pasa. Por eso todas tienen la misma estructura, el mismo orden y los mismos filtros. Cada tarjeta muestra el número del caso, qué ofrece la librería para ese gráfico, cómo lo resolvimos nosotros, de dónde salen los datos y el gráfico en sí.
>
> Si cada galería hubiera sido una pantalla distinta, cada una con su propia lógica, comparar las cuatro librerías habría sido casi imposible. Con una estructura común, la diferencia entre librerías queda solo en cómo se dibuja cada caso.

*[Pantalla: el mapa del proyecto.]*

> Con esto ya podemos contar el recorrido completo de un dato. Empieza en AniList, que es una API GraphQL. El DataSource manda la consulta y recibe JSON. Ese JSON se convierte en modelos, y el repositorio los entrega al resto de la app como entidades del dominio. El provider pide esos datos y guarda el estado. En el caso de los gráficos, el provider transforma una sola vez las obras en un conjunto de datos común, ya calculado. La galería le pasa ese conjunto a cada caso, cada caso tiene un builder, y el builder usa la librería correspondiente para dibujar lo que se ve en pantalla.
>
> La regla que seguimos es que ningún gráfico hace peticiones ni calcula estadísticas por su cuenta. Solo dibuja lo que recibe. Eso es lo que nos permitió llegar a 252 implementaciones sin repetir lógica.

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

Qué comentar: la cadena se arma una sola vez aquí, y los tres providers comparten el mismo repositorio.

**`lib/charts/common/library_cases.dart`**

```dart
Map<int, CaseImpl> casesFor(ChartLibrary library) => switch (library) {
      ChartLibrary.flChart => flChartCases,
      ChartLibrary.syncfusion => syncfusionCases,
      ChartLibrary.dChart => dChartCases,
      ChartLibrary.graphic => graphicCases,
    };
```

Qué comentar: cuatro colecciones de 63 casos. Es lo único que diferencia una galería de otra.

## Transición

> Ya sabemos dónde vive cada cosa. Ahora mi compañero va a explicar cómo es realmente la conversación con AniList y cómo convertimos lo que responde en datos que la app puede usar.

---

# PERSONA 2 — API, GRAPHQL Y DATOS

## Objetivo de esta parte

Mostrar que entendemos qué le pedimos a AniList, cómo lo pedimos, qué hacemos cuando algo falla y cómo la respuesta se convierte en datos de la app. Incluye la paginación y la serie de tendencias.

## Qué mostrar en pantalla

1. `anilist_remote_datasource.dart`, el método `_performQuery`.
2. `media_queries.dart`, la consulta del listado.
3. `media_model.dart`, el `fromJson`.
4. La app en el listado de anime, haciendo scroll hasta que cargue otra página.
5. `media_queries.dart`, la consulta de tendencias.

## GUION HABLADO

*[Pantalla: `_performQuery`.]*

> Mi parte es cómo hablamos con AniList. AniList tiene una API GraphQL, así que no hay una dirección distinta para cada cosa. Todo va a la misma URL y lo que cambia es la consulta que mandamos.
>
> Por eso concentramos toda la comunicación en un único método del DataSource, `_performQuery`. Recibe la consulta y sus variables, las manda con un POST en formato JSON y espera como máximo 15 segundos. Todas las peticiones de la app pasan por aquí, así que el manejo de errores está escrito una sola vez.
>
> Algo que aprendimos durante el proyecto es que AniList puede devolver un error de GraphQL con un código HTTP 200 o con un 400. Si solo miráramos el código HTTP, perderíamos el mensaje real. Por eso primero revisamos si la respuesta trae errores y, si los trae, usamos el mensaje de AniList. Los problemas de conexión, como un timeout o no tener internet, se tratan aparte como errores de red. Luego el repositorio convierte cualquiera de estos errores en el tipo de fallo que entienden las pantallas.

*[Pantalla: consulta del listado en `media_queries.dart`.]*

> Las consultas están escritas en GraphQL. Tenemos una parte compartida, un fragmento, con los campos que usa la app: títulos, formato, estado, fechas, puntuación, popularidad, rankings, géneros, estudios e imágenes. Lo reutilizamos en la consulta del listado y en la del detalle. La ventaja de GraphQL aquí es que pedimos exactamente lo que vamos a mostrar, ni más ni menos.
>
> La consulta del listado trabaja por páginas. Le decimos qué página queremos y cuántos elementos, y además los filtros: tipo, formato, estado, temporada, año o género. Solo mandamos los filtros que el usuario eligió, así que la misma consulta sirve para “todo el anime” o para “anime de invierno de 2024 de acción”. Los resultados vienen ordenados por popularidad, y ese orden es importante: gracias a él, la muestra de las galerías siempre son las obras más populares.
>
> Para el caso de tiempo real tenemos una consulta aparte, mucho más ligera, que solo pide la popularidad de unas pocas obras. Como se repite cada 30 segundos, no tenía sentido traer descripciones e imágenes cada vez.

*[Pantalla: `MediaModel.fromJson`.]*

> Cuando llega la respuesta, cada obra se convierte en un modelo. El JSON de AniList no siempre viene completo ni con la forma que nos conviene, y aquí es donde lo resolvemos. Por ejemplo, una obra puede no tener título en inglés, así que elegimos el primero disponible en un orden de preferencia. Los rankings vienen como una lista, y de ahí extraemos el puesto histórico de popularidad y de puntuación. Y las fechas pueden venir incompletas, con solo el año.
>
> El modelo hereda de la entidad del dominio. Es decir, el modelo sabe leer JSON, pero al mismo tiempo es una obra válida para el resto de la app. Por eso el repositorio puede entregarlo directamente sin copiar datos.

*[Pantalla: la app, scroll en el listado hasta que cargue más.]*

> La paginación se basa en la información de página que devuelve AniList. En cada respuesta viene la página actual y si existe una siguiente. Cuando el usuario llega casi al final de la lista, pedimos la página siguiente. Si AniList dice que no hay más, ya no se hace la petición. En el listado, cada página trae 20 obras. Las obras que ya estaban en la lista no se repiten. Y si el usuario cambia un filtro mientras una página todavía está cargando, esa respuesta vieja se descarta para que no se mezcle con la nueva.

*[Pantalla: consulta de tendencias en `media_queries.dart`.]*

> Por último, las tendencias. Algunos gráficos necesitan una serie en el tiempo, como el candlestick o las medias móviles. AniList tiene un campo llamado `trends` que da estadísticas diarias de una obra, pero solo devuelve 25 días por página. Por eso pedimos cuatro páginas en paralelo para la obra más popular de la muestra, juntamos los días sin duplicarlos y los ordenamos del más antiguo al más reciente.
>
> Aquí hubo un detalle importante: la popularidad de esa serie es acumulada, es el número total de usuarios que tienen la obra en su lista, y casi nunca baja. Graficarla tal cual daba una línea casi plana. Por eso calculamos cuánto cambia de un día a otro, y esa variación diaria es la serie que usan esos gráficos. Si las tendencias fallan, esos casos muestran el error, pero el resto de la galería sigue funcionando con normalidad.

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

Qué comentar: un único POST para todo, y los errores de GraphQL se revisan antes que el código HTTP.

**Consulta del listado (fragmento)**

```graphql
Page(page: $page, perPage: $perPage) {
  pageInfo { currentPage hasNextPage lastPage perPage total }
  media(type: $type, format: $format, status: $status, season: $season,
        seasonYear: $seasonYear, genre: $genre, sort: POPULARITY_DESC) {
    ...MediaFields
  }
}
```

Qué comentar: `pageInfo` es lo que permite paginar, y `MediaFields` es el fragmento compartido.

**`MediaModel.fromJson` (fragmento)**

```dart
final parsedTitle = userPreferred ?? english ?? romaji ?? native ?? 'Unknown Title';
```

Qué comentar: el modelo decide qué hacer cuando AniList no manda un dato.

## Transición

> Con esto los datos ya salieron de AniList y llegaron a la app como obras. Falta ver quién los guarda, cómo se entera la interfaz de que cambiaron y cómo se preparan para los gráficos. Eso lo explica mi compañero.

---

# PERSONA 3 — ESTADO Y FLUJO DE LOS GRÁFICOS

## Objetivo de esta parte

Mostrar que entendemos cómo usamos Provider, por qué hay tres providers, cómo preparamos un único conjunto de datos para todos los gráficos y cómo cada librería dibuja ese mismo conjunto a su manera.

## Qué mostrar en pantalla

1. `main.dart`, solo el bloque de los tres providers.
2. `charts_dataset_provider.dart`, el método `load`.
3. `graphic_dataset.dart`, el inicio de `fromAnime`.
4. `master_case_gallery.dart`, el `Consumer` que construye `CaseData`.
5. El caso #5 “Área” en la app, cambiando entre las cuatro galerías.
6. La app: el selector Anime/Manga en una galería.

## GUION HABLADO

*[Pantalla: los tres providers en `main.dart`.]*

> Mi parte es cómo manejamos el estado y cómo los datos llegan a los gráficos. Usamos Provider para centralizar el estado de todo lo que llega de AniList, y lo repartimos en tres providers.
>
> El primero se encarga del listado y del detalle: guarda los filtros, la lista y la obra seleccionada. El segundo se encarga de las galerías: carga una muestra de obras y prepara los datos de los gráficos. El tercero guarda lo que cambia en vivo, que son los casos de carga infinita y de tiempo real.
>
> La razón de separarlos es práctica. Cuando un provider avisa que cambió, se vuelve a dibujar todo lo que depende de él. El caso de tiempo real se actualiza cada 30 segundos, y si ese estado estuviera junto con la muestra de las galerías, cada 30 segundos se volverían a dibujar las 63 tarjetas. Separándolos, solo se actualiza la tarjeta que realmente cambió.
>
> Los tres funcionan igual: cambian sus datos internos y luego llaman a `notifyListeners`, y los widgets que los escuchan se reconstruyen con la información nueva.

*[Pantalla: el método `load` del provider de las galerías.]*

> El provider de las galerías pide cuatro páginas de 50 obras en paralelo, así que la muestra son las 200 obras más populares del tipo elegido. A medida que llegan las páginas va avisando, y por eso la galería puede mostrar el progreso de la carga. Cuando están todas, junta las obras, quita duplicados y descarga las tendencias de la más popular.
>
> Si el usuario cambia de anime a manga en plena carga, la respuesta anterior se ignora. Y si una recarga falla pero ya había datos, se conservan los anteriores y solo se muestra el error, en vez de dejar la pantalla vacía.

*[Pantalla: `GraphicDataset.fromAnime`.]*

> Con la muestra lista viene la decisión más importante de esta parte. Una vez tenemos los datos, no hacemos que cada gráfico calcule lo suyo por separado. Primero construimos un conjunto de datos común, y luego cada implementación solo toma lo que necesita.
>
> Primero un adaptador convierte cada obra en un modelo pequeño con solo los campos que usan los gráficos. Después se calcula todo de una vez: el top 10 por popularidad, el top por puntuación, cuántas obras hay por año y por formato, la puntuación media por año, los cuartiles para el box plot, la regresión, y sobre la serie de tendencias, las velas semanales y los indicadores como la media móvil o el RSI.
>
> Esto tiene dos ventajas. La primera es que los 252 gráficos muestran exactamente los mismos números, así que la comparación entre librerías es justa. La segunda es que el cálculo se hace una sola vez y no dentro de cada widget. Aunque este conjunto se llama `GraphicDataset` porque nació con la librería Graphic, lo usan las cuatro.

*[Pantalla: el `Consumer` en `master_case_gallery.dart`.]*

> Para leer el estado usamos dos formas distintas según lo que se necesita. Cuando solo queremos pedir algo, por ejemplo iniciar la carga al abrir la galería o cambiar a manga, usamos `context.read`, que llama al provider sin quedarse escuchando. Cuando queremos dibujar algo que depende del estado, usamos `Consumer` o `context.watch`, que sí se suscriben y reconstruyen el widget cuando hay cambios.
>
> En la galería, el `Consumer` recibe el conjunto de datos y lo empaqueta en un objeto que llamamos `CaseData`. Ese mismo objeto se entrega a las 63 tarjetas. Cada tarjeta tiene su implementación, que llamamos `CaseImpl`: dice cómo se resolvió el caso, de dónde salen los datos, qué parte de la librería se usó, y tiene la función que dibuja el gráfico, el builder.

*[Pantalla: caso #5 “Área” en las cuatro galerías, una tras otra.]*

> Para ver cómo cambia cada librería, tomemos el caso 5, un gráfico de área con la cantidad de obras por año. Las cuatro implementaciones reciben exactamente la misma lista. Lo que cambia es cómo cada librería entiende esos datos.
>
> Syncfusion tiene una serie de área propia, y basta con decirle qué valor va en cada eje. Graphic funciona de forma más declarativa: se definen las variables y se dibuja una “marca” de área sobre ellas. FL Chart no tiene un gráfico de área como tal, así que usamos su gráfico de línea y activamos el relleno debajo de la línea. Y en d_chart pasa algo parecido: es su gráfico de línea con la opción de incluir el área.
>
> Por eso en la tarjeta Syncfusion y Graphic aparecen como implementaciones nativas, y FL Chart y d_chart como variantes. El dato es el mismo, pero la forma de llegar al gráfico depende de lo que ofrece cada librería.

*[Pantalla: la galería, cambiar de Anime a Manga.]*

> Y si cambiamos a manga, se repite el ciclo completo: el provider carga la nueva muestra, recalcula el conjunto de datos y avisa. El `Consumer` crea un `CaseData` nuevo y los 63 gráficos se vuelven a dibujar con los datos de manga.

## Código que conviene mostrar

**Construcción del dataset en `ChartsDatasetProvider.load` (fragmento)**

```dart
_graphicDataset = GraphicDataset.fromAnime(
  GraphicAdapters.animeFrom<Media>(
    collected,
    title: (m) => m.title,
    popularity: (m) => m.popularity ?? 0,
    score: (m) => m.averageScore,
    ...
  ),
  trends: GraphicAdapters.trendsFrom<MediaTrend>(trends, ...),
);
```

Qué comentar: es el único lugar donde se calcula. Los gráficos solo leen.

**La galería reparte el mismo `CaseData` a todos los casos**

```dart
body: Consumer<ChartsDatasetProvider>(
  builder: (context, provider, _) {
    final data = CaseData(
      g: provider.graphicDataset!,
      media: provider.media,
      type: provider.loadedType,
      ...
    );
```

Qué comentar: cada vez que el provider avisa, se crea un `CaseData` nuevo para las 63 tarjetas.

**Caso #5 en las cuatro librerías**

```dart
// Syncfusion — NATIVO
AreaSeries<GCategory, String>(dataSource: d.g.countByYear, ...)
// Graphic — NATIVO
Chart(data: d.countByYear, marks: [AreaMark(...), LineMark(...)], ...)
// FL Chart — VARIANTE (LineChart + belowBarData)
_line(_spots(d.g.countByYear), casePalette[2], area: true)
// d_chart — VARIANTE (DChartLineN + includeArea)
_line([_yearGroup('Obras', d.g.countByYear)], area: true)
```

Qué comentar: la misma lista de entrada en las cuatro.

## Transición

> Ya vimos que cada librería recibe los mismos datos y los dibuja a su manera. Ahora mi compañero va a explicar qué significa realmente tener 252 implementaciones y cómo funcionan los casos que se actualizan en vivo.

---

# PERSONA 4 — 252 IMPLEMENTACIONES Y CASOS ESPECIALES

## Objetivo de esta parte

Explicar con claridad qué significa 63 × 4 = 252, distinguir lo que ofrece una librería de cómo lo resolvimos nosotros, y mostrar tres casos concretos: el recorrido completo del #2, la carga infinita del #52 y el tiempo real del #63.

## Qué mostrar en pantalla

1. Una galería con los filtros de estrategia visibles (NATIVO, VARIANTE, COMPOSICIÓN, ADAPTACIÓN).
2. La tarjeta #32 Candlestick en d_chart y después en Syncfusion.
3. `d_chart_case_builders.dart`, la línea del caso 32.
4. La tarjeta #2 en las cuatro galerías.
5. La tarjeta #52 haciendo scroll horizontal.
6. La tarjeta #63 recibiendo una nueva lectura.
7. `anilist_live_provider.dart`, el método `pollNow`.

## GUION HABLADO

*[Pantalla: una galería con los filtros de estrategia.]*

> Mi parte es explicar el número 252. Definimos un catálogo de 63 casos de gráfico, desde una línea simple hasta un gráfico en tiempo real. Cada una de las cuatro librerías tiene su propia implementación de esos 63 casos, así que 63 por 4 da 252. Tenemos un test que comprueba que están los 252 y que cada uno se dibuja sin errores.
>
> Pero 252 implementaciones no son 252 gráficos completamente diferentes. Son 63 tipos de gráfico, cada uno resuelto cuatro veces. Y para entenderlos hay que separar dos ideas.
>
> La primera es la capacidad: qué ofrece la librería para ese gráfico. Puede traerlo listo, permitirlo configurando otro gráfico, obligarte a combinar piezas o directamente no tenerlo.
>
> La segunda es la implementación: cómo lo resolvimos nosotros. Ahí usamos cuatro estrategias. Nativo es usar el gráfico que la librería ya trae. Variante es configurar un gráfico existente para que se comporte como el que buscamos, como el área de FL Chart que explicó mi compañero. Composición es combinar la librería con elementos de Flutter, por ejemplo un control deslizante que filtra un gráfico o dos gráficos superpuestos. Y adaptación es cuando la librería no tiene el gráfico, o los datos no son del tipo que el gráfico espera, y construimos una representación equivalente. Cada adaptación tiene una nota en la tarjeta que explica qué se hizo.

*[Pantalla: tarjeta #32 en d_chart.]*

> El mejor ejemplo es el candlestick, el caso 32. d_chart no tiene gráfico de velas, y en nuestro catálogo aparece como “no soportado”. Aun así lo implementamos. Superponemos dos gráficos de barras: uno muy fino que va del mínimo al máximo de la semana, que funciona como la mecha, y otro más grueso que va de la apertura al cierre, que es el cuerpo. La barra es verde si el valor subió y roja si bajó.
>
> Además, hay una segunda adaptación que afecta a las cuatro librerías. AniList no tiene precios. Lo que usamos es la variación diaria de popularidad que explicó mi compañero, agrupada en semanas: el primer día es la apertura, el último es el cierre, y el máximo y el mínimo de la semana son los extremos.

*[Pantalla: tarjeta #32 en Syncfusion.]*

> Por eso en Syncfusion, aunque la librería sí tiene un gráfico de velas, lo marcamos también como adaptación: el gráfico es nativo, pero el dato no. La nota lo deja claro: no es una cotización financiera. No queríamos presentar como nativo algo que en realidad está adaptado.

*[Pantalla: tarjeta #2 en las cuatro galerías.]*

> Ahora el recorrido completo de un caso, el número 2, columna vertical, que muestra las diez obras más populares. La consulta a AniList pide la popularidad de cada obra, ordenada de mayor a menor. La respuesta se convierte en modelos, el repositorio los entrega como obras, y el provider de las galerías junta las 200 obras de la muestra. Al construir el conjunto de datos común se toman las diez más populares. La galería entrega ese conjunto al caso 2, y cada librería dibuja sus columnas. En las cuatro es nativo, porque todas tienen gráfico de barras vertical; lo único que cambia es la forma de pedírselo a cada una.

*[Pantalla: tarjeta #52 haciendo scroll.]*

> Los casos 52 y 63 son distintos porque no usan la muestra fija: piden datos a AniList mientras la tarjeta está en pantalla. Esa lógica está en un contenedor común, y cada librería solo aporta cómo dibujar.
>
> El 52 es carga infinita. El gráfico empieza con una página de 20 obras. Cuando el usuario llega al final del scroll horizontal, se pide la siguiente página a AniList y el gráfico se hace más ancho. Igual que en el listado, se usa la información de página para saber cuándo parar. En las cuatro librerías lo resolvimos como composición, porque combina el gráfico con el scroll y el estado de Flutter.

*[Pantalla: tarjeta #63 y después `pollNow`.]*

> El 63 es tiempo real, y aquí hay que ser precisos. AniList no ofrece WebSocket ni notificaciones push, así que no usamos WebSocket. Lo que hacemos es polling: preguntar cada cierto tiempo.
>
> Cuando la tarjeta aparece, se toman las cinco obras más populares y se inicia un temporizador de 30 segundos, con una primera consulta inmediata. En cada consulta se pide la popularidad actual de esas cinco obras con la consulta ligera, se suma, se compara con la lectura anterior y se calcula la diferencia. Esa lectura se guarda y el provider avisa del cambio. La tarjeta, que está escuchando, se vuelve a dibujar con el punto nuevo, y además muestra cuántas veces cambió el valor.
>
> Cada librería lo actualiza a su manera. Graphic tiene un mecanismo propio para recibir datos nuevos, por eso ahí es nativo. Syncfusion agrega solo los puntos nuevos a la serie. FL Chart y d_chart vuelven a dibujar la línea completa. Y cuando la tarjeta sale de pantalla, el temporizador se detiene, para no hacer peticiones que nadie está viendo.
>
> Con esto cerramos. Gracias por su atención.

## Código que conviene mostrar

**Capacidad vs. implementación del caso #32**

```dart
// master_chart_registry.dart — capacidad
ChartLibrary.dChart: LibrarySupport(ChartClassification.noSoportado, ChartState.funcional),

// d_chart_case_builders.dart — implementación
32: _impl(32, _a, 'Dos DChartBarO superpuestos (mecha y cuerpo) con measureOffset',
    (_, d) => withTrends(d, () => _candles(d.g.trendOhlc)), note: ohlcNote),
```

Qué comentar: el primero dice lo que ofrece la librería y el segundo cómo lo resolvimos. `_a` es adaptación.

**Una lectura del caso #63 (`pollNow`, fragmento)**

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

Qué comentar: consultar, sumar, comparar con la anterior y guardar. Después el provider avisa.

**Temporizador del #63**

```dart
_timer = Timer.periodic(pollInterval, (_) => pollNow());   // pollInterval = 30 s
```

Qué comentar: esto es polling, no WebSocket.

## Transición

Es el cierre del video. Si se quiere, cada integrante dice su nombre al final.

---

# REPASO FINAL PARA LOS 4

## 10 ideas que todos deben conocer

1. Toda la comunicación con AniList pasa por un único método que manda un POST con la consulta GraphQL y sus variables.
2. El modelo sabe leer JSON y a la vez es una entidad del dominio: hereda de ella.
3. Abajo los errores son excepciones técnicas. El repositorio los convierte en fallos de la aplicación, que es lo que ven las pantallas.
4. Hay tres providers: listado y detalle, muestra de las galerías, y datos en vivo (#52 y #63).
5. La muestra de las galerías son las 200 obras más populares (4 páginas de 50), más las tendencias diarias de la más popular.
6. El conjunto de datos común se calcula una sola vez y lo usan las cuatro librerías.
7. Cada caso tiene una implementación con su estrategia, el origen de sus datos y la función que dibuja.
8. 63 casos × 4 librerías = 252, y un test lo comprueba.
9. Capacidad (qué ofrece la librería) e implementación (cómo lo hicimos) son dos cosas distintas.
10. El #63 consulta cada 30 segundos: es polling, no WebSocket. El #52 pide páginas reales hasta que AniList dice que no hay más.

## 10 conceptos que no deben confundirse

| No confundir… | …con | En este proyecto |
|---|---|---|
| Excepción | Fallo (Failure) | La excepción nace en la capa de datos. El fallo es lo que recibe el provider. |
| Modelo | Entidad | El modelo lee JSON. La entidad es la obra que usa el resto de la app. |
| Capacidad | Implementación | Una dice qué trae la librería. La otra, cómo lo resolvimos. |
| Variante | Composición | La variante configura un gráfico existente. La composición lo combina con elementos de Flutter. |
| Adaptación | No soportado | “No soportado” describe a la librería. “Adaptación” describe nuestra solución. |
| `read` | `watch` / `Consumer` | `read` sirve para disparar acciones. `watch` y `Consumer` sirven para dibujar y reconstruir. |
| Popularidad actual | Popularidad de trends | La de trends es acumulada. Graficamos su variación diaria. |
| Nuestro candlestick | Un gráfico financiero | Son semanas de variación de popularidad, no precios. |
| Polling | WebSocket | Preguntamos cada 30 segundos. AniList no nos envía datos por su cuenta. |
| `GraphicDataset` | Algo exclusivo de Graphic | Se llama así por su origen, pero lo usan las cuatro librerías. |

## 10 preguntas que cualquiera de los cuatro podría recibir

1. **¿Para qué sirve el repositorio si ya existe el DataSource?**
   El DataSource habla HTTP y JSON. El repositorio entrega entidades y traduce los errores. Los providers solo conocen el contrato del repositorio.

2. **¿Qué pasa si AniList devuelve un error de GraphQL?**
   Se revisa antes que el código HTTP y se usa el mensaje de AniList. Llega a la pantalla como un error del servidor.

3. **¿Cómo sabe la app que no hay más páginas?**
   AniList indica en cada respuesta si hay una página siguiente. Si no la hay, no se vuelve a pedir.

4. **¿Por qué cada gráfico no calcula sus propios datos?**
   Para que los 252 muestren los mismos números y para calcularlo una sola vez.

5. **¿Por qué hay tres providers y no uno?**
   Para que el caso en tiempo real no obligue a redibujar las 63 tarjetas cada 30 segundos.

6. **¿Qué significa que el candlestick de d_chart sea una adaptación?**
   d_chart no tiene velas. Las dibujamos superponiendo dos gráficos de barras: uno fino para la mecha y otro grueso para el cuerpo.

7. **¿De dónde salen las velas si AniList no tiene precios?**
   De la variación diaria de popularidad de una obra, agrupada en semanas.

8. **¿Por qué el candlestick de Syncfusion es una adaptación si la librería lo trae?**
   El gráfico es nativo, pero el dato está adaptado, y preferimos decirlo.

9. **¿El caso 63 sigue consultando si salgo de la galería?**
   No. Cuando la tarjeta desaparece, el temporizador se detiene.

10. **¿Cómo saben que los 252 funcionan?**
    Hay un test que comprueba los 63 casos de cada librería y dibuja cada uno con un repositorio falso.

---

# MAPA GENERAL DEL PROYECTO

Este mapa sigue el código real. Hay dos diferencias con un esquema genérico: entre el provider y el conjunto de datos hay un paso de adaptación, y los casos #52 y #63 no usan la muestra fija, sino que piden datos a AniList mientras están en pantalla.

```text
AniList (API GraphQL)
   ↓
HTTP POST + consulta GraphQL
   ↓
DataSource            envía la consulta y convierte el JSON en modelos
   ↓
Repository            entrega entidades y traduce errores
   ↓
Domain                obras, tendencias, información de página
   ↓
Provider              listado/detalle · muestra de galerías · datos en vivo (#52, #63)
   ↓
Adaptadores           obra → modelo pequeño para gráficos
   ↓
Dataset común         todos los cálculos, una sola vez
   ↓
CaseData / CaseImpl   la galería reparte los datos a los 63 casos
   ↓
Builder               cada caso dibuja con su librería
   ↓
Librería              FL Chart · Syncfusion · d_chart · Graphic
   ↓
UI                    tarjeta con estrategia, origen de datos y gráfico
```
