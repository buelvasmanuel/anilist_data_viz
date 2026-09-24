import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_bar_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_multi_bar_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_multi_line_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_scatter_trend_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_gauge_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_line_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_pie_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_progress_charts.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_summary_cards.dart';
import 'package:anilist_data_viz/charts/models/chart_data.dart';
import 'package:anilist_data_viz/charts/transformations/data_transformations.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Galería FL Chart de los casos básicos 1–31 de la LISTA_CANDIDATA_63
/// (lista provisional de trabajo, no oficial).
class ChartsGalleryScreen extends StatefulWidget {
  const ChartsGalleryScreen({super.key});

  @override
  State<ChartsGalleryScreen> createState() => _ChartsGalleryScreenState();
}

class _ChartsGalleryScreenState extends State<ChartsGalleryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChartsDatasetProvider>();
      if (provider.state == ProviderState.initial) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería FL Chart · Casos 1–31'),
        actions: [
          Consumer<ChartsDatasetProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'ANIME', label: Text('Anime')),
                  ButtonSegment(value: 'MANGA', label: Text('Manga')),
                ],
                selected: {provider.type},
                onSelectionChanged: provider.isLoading
                    ? null
                    : (selection) => provider.load(type: selection.first),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChartsDatasetProvider>(
        builder: (context, provider, _) {
          if (provider.state == ProviderState.initial ||
              (provider.state == ProviderState.loading && provider.media.isEmpty)) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Cargando muestra de AniList… '
                      '(${provider.loadedPages}/${provider.pages} páginas)'),
                ],
              ),
            );
          }
          if (provider.media.isEmpty) {
            return _ErrorView(
              message: provider.state == ProviderState.error
                  ? 'Error: ${provider.errorMessage}'
                  : 'AniList no devolvió obras.',
              onRetry: () => provider.load(),
            );
          }

          final data = _GalleryData.from(provider.media, provider.loadedType);
          final cases = _buildCases(context, data);

          return Column(
            children: [
              if (provider.isLoading) const LinearProgressIndicator(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DatasetHeader(provider: provider, data: data),
                    const _SectionTitle(title: 'GRÁFICAS BÁSICAS (1–31)'),
                    ...cases.map((c) => _ChartCard(spec: c)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Datos derivados de la muestra
// -----------------------------------------------------------------------------

/// Todas las series de la galería, calculadas una vez por muestra con las
/// transformaciones de `DataTransformations`.
class _GalleryData {
  final String type;
  final int total;
  final List<ChartDataCategory> allGenres; // T1
  final List<ChartDataCategory> genreTop10; // T1
  final List<ChartDataCategory> genreTop8; // T1
  final List<ChartDataCategory> genreTop6; // T1
  final List<ChartDataXY> scorePerYear; // T2
  final List<ChartDataXY> countPerYear; // N1
  final List<ChartDataCategory> countPerYearCategories; // N1
  final List<ChartDataCategory> lengthBins; // N2 (episodios o capítulos)
  final String lengthField;
  final List<ChartDataXY> scoreBins5; // N2
  final List<ChartDataCategory> scoreBins10; // N2
  final List<ChartDataCategory> scoreByGenre; // N3
  final List<ChartDataCategory> scoreDeviation; // N3b
  final double? meanScore;
  final _Categorical pieMain; // N4
  final _Categorical pieAlt; // N4
  final _Categorical binary; // N4
  final ChartDataSummary summary; // N7
  final List<ChartSeries<ChartDataCategory>> seriesByCategory; // N5
  final List<ChartDataXY> countPerYearMonth; // N6
  final List<ChartDataXY> scatterPoints; // N8
  final List<double> scatterRegression; // N8
  final List<ChartSeries<ChartDataXY>> yearMetricsNormalized; // N9
  final List<ChartSeries<ChartDataXY>> seriesPerYear; // N10

  _GalleryData._({
    required this.type,
    required this.total,
    required this.allGenres,
    required this.genreTop10,
    required this.genreTop8,
    required this.genreTop6,
    required this.scorePerYear,
    required this.countPerYear,
    required this.countPerYearCategories,
    required this.lengthBins,
    required this.lengthField,
    required this.scoreBins5,
    required this.scoreBins10,
    required this.scoreByGenre,
    required this.scoreDeviation,
    required this.meanScore,
    required this.pieMain,
    required this.pieAlt,
    required this.binary,
    required this.summary,
    required this.seriesByCategory,
    required this.countPerYearMonth,
    required this.scatterPoints,
    required this.scatterRegression,
    required this.yearMetricsNormalized,
    required this.seriesPerYear,
  });

  /// Mínimo de obras puntuadas para incluir un género en N3/N3b.
  static const int minGenreCount = 5;

  factory _GalleryData.from(List<Media> media, String type) {
    final isAnime = type == 'ANIME';
    final genres = DataTransformations.mediaToGenreCount(media);
    final countPerYear = DataTransformations.mediaToCountPerYear(media);

    List<ChartDataCategory> pretty(List<ChartDataCategory> list) => list
        .map((e) => ChartDataCategory(category: _prettyEnum(e.category), value: e.value, color: e.color))
        .toList();

    List<ChartDataCategory> countBy(String? Function(Media m) selector) =>
        pretty(DataTransformations.mediaToCategoryCount(media, selector: selector));

    /// Dos categorías concretas de un campo. Si una no aparece en la muestra,
    /// su conteo real es 0.
    List<ChartDataCategory> pair(List<ChartDataCategory> counts, String a, String b) => [
          for (final key in [a, b])
            ChartDataCategory(
              category: _prettyEnum(key),
              value: counts
                  .where((e) => e.category == _prettyEnum(key))
                  .fold<num>(0, (sum, e) => sum + e.value),
            ),
        ];

    // Campos categóricos univaluados elegidos por tipo, porque en la muestra
    // de anime "format" (casi todo TV) y "status" (casi todo FINISHED) apenas
    // varían, mientras que en manga no existe "season".
    final source = countBy((m) => m.source);
    final status = countBy((m) => m.status);
    final _Categorical pieMain;
    final _Categorical pieAlt;
    final _Categorical binary;
    if (isAnime) {
      pieMain = _Categorical('source', DataTransformations.topNWithOthers(source, 5));
      pieAlt = _Categorical('season', countBy((m) => m.season));
      binary = _Categorical('source: Manga vs Original', pair(source, 'MANGA', 'ORIGINAL'));
    } else {
      pieMain = _Categorical('status', status);
      pieAlt = _Categorical('countryOfOrigin', countBy((m) => m.countryOfOrigin));
      binary = _Categorical('status: Finished vs Releasing', pair(status, 'FINISHED', 'RELEASING'));
    }

    final seriesByCategory = DataTransformations.mediaToSeriesByCategory(
      media,
      categorySelector: (m) => m.source,
      seriesSelector: (m) => m.status,
      topCategories: 4,
    );

    final scatterPoints = DataTransformations.mediaToScatterPoints(
      media,
      xSelector: (m) => m.popularity,
      ySelector: (m) => m.averageScore,
    );
    final scatterRegression = DataTransformations.linearRegression(scatterPoints);

    return _GalleryData._(
      type: type,
      total: media.length,
      allGenres: genres,
      genreTop10: genres.take(10).toList(),
      genreTop8: genres.take(8).toList(),
      genreTop6: genres.take(6).toList(),
      scorePerYear: DataTransformations.mediaToAverageScorePerYear(media),
      countPerYear: countPerYear,
      countPerYearCategories: countPerYear
          .map((e) => ChartDataCategory(category: '${e.x}', value: e.y))
          .toList(),
      lengthBins: DataTransformations.binsToCategories(
        isAnime
            ? DataTransformations.mediaToNumericBins(media,
                valueOf: (m) => m.episodes, binSize: 12, start: 0, openEndFrom: 72)
            : DataTransformations.mediaToNumericBins(media,
                valueOf: (m) => m.chapters, binSize: 50, start: 0, openEndFrom: 300),
        dropEmpty: false,
      ),
      lengthField: isAnime ? 'episodes (bins de 12, último ≥72)' : 'chapters (bins de 50, último ≥300)',
      scoreBins5: DataTransformations.mediaToNumericBins(media, valueOf: (m) => m.averageScore, binSize: 5),
      scoreBins10: DataTransformations.binsToCategories(
        DataTransformations.mediaToNumericBins(media, valueOf: (m) => m.averageScore, binSize: 10),
      ),
      scoreByGenre: DataTransformations.mediaToAverageScoreByGenre(media, minCount: minGenreCount),
      scoreDeviation: DataTransformations.mediaToGenreScoreDeviation(media, minCount: minGenreCount),
      meanScore: DataTransformations.meanAverageScore(media),
      pieMain: pieMain,
      pieAlt: pieAlt,
      binary: binary,
      summary: DataTransformations.mediaToSummaryKpis(media),
      seriesByCategory: seriesByCategory,
      countPerYearMonth: DataTransformations.mediaToCountPerYearMonth(media),
      scatterPoints: scatterPoints,
      scatterRegression: scatterRegression,
      yearMetricsNormalized: DataTransformations.mediaToYearMetricsNormalized(media),
      seriesPerYear: DataTransformations.mediaToSeriesPerYear(media, seriesSelector: (m) => m.source),
    );
  }
}

/// Serie categórica (N4) junto con el campo de AniList del que procede.
class _Categorical {
  final String field;
  final List<ChartDataCategory> data;
  const _Categorical(this.field, this.data);
}

/// `TV_SHORT` -> `TV Short`, `LIGHT_NOVEL` -> `Light Novel`.
String _prettyEnum(String value) => value
    .split('_')
    .map((w) => w.length <= 3 ? w : '${w[0]}${w.substring(1).toLowerCase()}')
    .join(' ');

String _signed(num v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}';

// -----------------------------------------------------------------------------
// Casos 1–31
// -----------------------------------------------------------------------------

enum _Classification { nativo, variante, composicion }

class _CaseSpec {
  final int number;
  final String name;
  final String family;
  final _Classification classification;
  final String dataUsed;
  final double height;
  final Widget chart;

  const _CaseSpec({
    required this.number,
    required this.name,
    required this.family,
    required this.classification,
    required this.dataUsed,
    required this.chart,
    this.height = 260,
  });
}

const _t1 = 'T1 mediaToGenreCount: obras por género (una obra cuenta en cada uno de sus géneros)';
const _t2 = 'T2 mediaToAverageScorePerYear: media de averageScore por año de inicio';
const _n1 = 'N1 mediaToCountPerYear: obras por año de inicio (años sin obras = 0)';

List<_CaseSpec> _buildCases(BuildContext context, _GalleryData d) {
  const v = _Classification.variante;
  const n = _Classification.nativo;
  const c = _Classification.composicion;
  final summary = d.summary;

  return [
    _CaseSpec(
      number: 1, name: 'Barra Vertical Ordinal Estándar', family: 'BarChart', classification: n,
      dataUsed: '$_t1 · top 10',
      chart: BasicBarChart(data: d.genreTop10, showBorder: true),
    ),
    _CaseSpec(
      number: 2, name: 'Barra Horizontal Ordinal', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · rotationQuarterTurns: 1',
      height: 320,
      chart: BasicBarChart(data: d.genreTop10, isHorizontal: true, showBorder: true),
    ),
    _CaseSpec(
      number: 3, name: 'Barra Numérica (Eje X Continuo)', family: 'BarChart', classification: v,
      dataUsed: 'N2 mediaToNumericBins: obras por ${d.lengthField}. '
          'Limitación: BarChart usa x entero y barras equiespaciadas; los bins tienen el mismo ancho.',
      chart: BasicBarChart(data: d.lengthBins, showBorder: true, showGrid: true, barWidth: 22),
    ),
    _CaseSpec(
      number: 4, name: 'Barra Temporal Simple', family: 'BarChart', classification: v,
      dataUsed: _n1,
      chart: BasicBarChart(
        data: d.countPerYearCategories, barWidth: 6, categoryLabelEvery: 5, showBorder: true, showGrid: true,
      ),
    ),
    _CaseSpec(
      number: 5, name: 'Barra Personalizada Ligera (Custom Bar)', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 8 · width 8, borderSide, backDrawRodData',
      chart: BasicBarChart(
        data: d.genreTop8,
        barWidth: 8,
        rounded: true,
        cornerRadius: 4,
        staticColor: ChartPalette.categorical[6],
        rodBorderSide: const BorderSide(color: Colors.white70, width: 1),
        backgroundRodToY: d.genreTop8.isEmpty ? null : d.genreTop8.first.value.toDouble(),
      ),
    ),
    _CaseSpec(
      number: 6, name: 'Barras con Color Estático Único', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · un solo color',
      chart: BasicBarChart(data: d.genreTop10, staticColor: ChartPalette.categorical[1], showBorder: true),
    ),
    _CaseSpec(
      number: 7, name: 'Barras con Color por Categoría', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · un color de la paleta por categoría',
      chart: BasicBarChart(data: d.genreTop10, colorMode: BarColorMode.byCategory, showBorder: true),
    ),
    _CaseSpec(
      number: 8, name: 'Barras con Esquinas Redondeadas', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · borderRadius superior 8',
      chart: BasicBarChart(data: d.genreTop10, barWidth: 22, rounded: true, cornerRadius: 8, showBorder: true),
    ),
    _CaseSpec(
      number: 9, name: 'Barras sin Ejes (Estilo Sparkline)', family: 'BarChart', classification: v,
      dataUsed: '$_n1 · sin títulos, cuadrícula ni borde',
      height: 110,
      chart: BasicBarChart(
        data: d.countPerYearCategories, barWidth: 4, showTitles: false, showGrid: false, showBorder: false,
      ),
    ),
    _CaseSpec(
      number: 10, name: 'Barras con Línea Base Cero Fija', family: 'BarChart', classification: v,
      dataUsed: 'N3 mediaToAverageScoreByGenre (géneros con ≥${_GalleryData.minGenreCount} obras puntuadas) · '
          'minY: 0, baselineY: 0 y línea base con ExtraLinesData',
      chart: BasicBarChart(
        data: d.scoreByGenre.take(8).toList(),
        minY: 0, baselineY: 0, showBaselineLine: true, showGrid: true, gridInterval: 20,
      ),
    ),
    _CaseSpec(
      number: 11, name: 'Barras con Valores Negativos', family: 'BarChart', classification: v,
      dataUsed: 'N3b mediaToGenreScoreDeviation: score medio del género − media de la muestra '
          '(${d.meanScore?.toStringAsFixed(1) ?? 's/d'}). Géneros con ≥${_GalleryData.minGenreCount} obras puntuadas. '
          'Horizontal para leer las etiquetas.',
      height: 360,
      chart: BasicBarChart(
        data: d.scoreDeviation,
        isHorizontal: true,
        barWidth: 12,
        colorMode: BarColorMode.bySign,
        baselineY: 0,
        showBaselineLine: true,
        showGrid: true,
        valueFormatter: _signed,
      ),
    ),
    _CaseSpec(
      number: 12, name: 'Línea Numérica Simple', family: 'LineChart', classification: n,
      dataUsed: 'N2 mediaToNumericBins: obras por averageScore en bins de 5 (x = inicio del bin)',
      chart: BasicLineChart(points: d.scoreBins5, xLabelInterval: 5),
    ),
    _CaseSpec(
      number: 13, name: 'Línea Temporal Básica', family: 'LineChart', classification: v,
      dataUsed: _t2,
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5),
    ),
    _CaseSpec(
      number: 14, name: 'Línea con Puntos Marcadores', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · FlDotData',
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5, showDots: true),
    ),
    _CaseSpec(
      number: 15, name: 'Área Bajo la Curva Simple', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · belowBarData',
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5, showArea: true),
    ),
    _CaseSpec(
      number: 16, name: 'Línea sin Puntos ni Relleno (Minimalista)', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · sin puntos, área, ejes, cuadrícula ni borde',
      chart: BasicLineChart(
        points: d.scorePerYear, showTitles: false, showGrid: false, showBorder: false,
      ),
    ),
    _CaseSpec(
      number: 17, name: 'Torta / Pie Estándar Ordinal', family: 'PieChart', classification: n,
      dataUsed: 'N4 mediaToCategoryCount(${d.pieMain.field}) · cada obra cuenta una vez',
      chart: BasicPieChart(data: d.pieMain.data),
    ),
    _CaseSpec(
      number: 18, name: 'Torta con Datos Numéricos', family: 'PieChart', classification: v,
      dataUsed: 'N2 mediaToNumericBins: averageScore en bins de 10 (obras sin score excluidas)',
      chart: BasicPieChart(data: d.scoreBins10),
    ),
    _CaseSpec(
      number: 19, name: 'Dona / Donut Chart Clásica', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount(${d.pieAlt.field}) · centerSpaceRadius',
      chart: BasicPieChart(data: d.pieAlt.data, isDonut: true),
    ),
    _CaseSpec(
      number: 20, name: 'Dona con Anillo Delgado', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount(${d.pieMain.field}) · centerSpaceRadius grande + radius pequeño',
      chart: BasicPieChart(data: d.pieMain.data, isThinDonut: true),
    ),
    _CaseSpec(
      number: 21, name: 'Gráfica de Torta Monocromática (Gama de Tonos)', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount(${d.pieAlt.field}) · tonos HSL de un solo color',
      chart: BasicPieChart(data: d.pieAlt.data, monochromatic: true, baseColor: ChartPalette.categorical[6]),
    ),
    _CaseSpec(
      number: 22, name: 'Gráfica de Progreso Semi-Circular (Gauge Base)', family: 'PieChart + Flutter', classification: c,
      dataUsed: 'N7 mediaToSummaryKpis: media de averageScore de ${summary.scoredMedia} obras puntuadas (escala 0–100)',
      height: 180,
      chart: summary.meanAverageScore == null
          ? const Center(child: Text('Sin obras con score en la muestra'))
          : SemiCircleGauge(
              value: summary.meanAverageScore!,
              valueLabel: summary.meanAverageScore!.toStringAsFixed(1),
              caption: 'score medio / 100',
            ),
    ),
    _CaseSpec(
      number: 23, name: 'Barras con Espaciado Entre Elementos', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 6 · width 16 + groupsSpace 36 (alignment center)',
      chart: BasicBarChart(data: d.genreTop6, barWidth: 16, groupsSpace: 36, showBorder: true),
    ),
    _CaseSpec(
      number: 24, name: 'Barras con Líneas de Cuadrícula Activas', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · FlGridData horizontal',
      chart: BasicBarChart(data: d.genreTop10, showGrid: true, showBorder: true),
    ),
    _CaseSpec(
      number: 25, name: 'Barras con Animación Desactivada', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · duration: Duration.zero',
      chart: BasicBarChart(data: d.genreTop10, animated: false, showBorder: true),
    ),
    _CaseSpec(
      number: 26, name: 'Línea con Animación Desactivada', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · duration: Duration.zero',
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5, animated: false),
    ),
    _CaseSpec(
      number: 27, name: 'Torta sin Animación', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount(${d.pieMain.field}) · duration: Duration.zero',
      chart: BasicPieChart(data: d.pieMain.data, animated: false),
    ),
    _CaseSpec(
      number: 28, name: 'Barra de Progreso Simple (KPI Lineal)', family: 'BarChart', classification: v,
      dataUsed: 'N7 mediaToSummaryKpis: obras FINISHED / obras con estado = '
          '${summary.finishedCount}/${summary.withStatusCount}'
          '${summary.finishedPercent == null ? '' : ' (${summary.finishedPercent!.toStringAsFixed(1)} %)'}',
      height: 50,
      chart: summary.finishedPercent == null
          ? const Center(child: Text('Sin obras con estado en la muestra'))
          : ProgressBarChart(value: summary.finishedPercent!, color: ChartPalette.positive),
    ),
    _CaseSpec(
      number: 29, name: 'Torta con Borde de Separación entre Porciones', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount(${d.pieAlt.field}) · sectionsSpace 3 + borderSide',
      chart: Builder(
        builder: (context) => BasicPieChart(
          data: d.pieAlt.data,
          spacing: 3,
          sectionBorder: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2),
        ),
      ),
    ),
    _CaseSpec(
      number: 30, name: 'Comparativa Binaria (Doble Barra Simple)', family: 'BarChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount(${d.binary.field}). '
          'No se compara Anime vs Manga porque la muestra carga un solo tipo. Valores con tooltip fijo.',
      chart: BasicBarChart(
        data: d.binary.data, barWidth: 48, colorMode: BarColorMode.byCategory, showValueLabels: true, showBorder: true,
      ),
    ),
    _CaseSpec(
      number: 31, name: 'Gráfica para Tarjeta de Resumen (Compact Card)', family: 'LineChart + Flutter', classification: c,
      dataUsed: 'N7 (total y score medio) + N1 como sparkline (BasicLineChart minimalista)',
      height: 240,
      chart: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 320,
          child: CompactSummaryCard(
            title: 'Obras en la muestra (${_prettyEnum(d.type)})',
            value: '${summary.totalMedia}',
            caption: summary.meanAverageScore == null
                ? 'Sin score disponible'
                : 'Score medio ${summary.meanAverageScore!.toStringAsFixed(1)} · obras por año de inicio',
            chart: BasicLineChart(
              points: d.countPerYear, showTitles: false, showGrid: false, showBorder: false, showArea: true,
              enableTouch: false,
            ),
          ),
        ),
      ),
    ),
    _CaseSpec(
      number: 32, name: 'Barras Agrupadas Multiserie', family: 'BarChart', classification: v,
      dataUsed: 'N5 mediaToSeriesByCategory (status vs source)',
      chart: MultiSeriesBarChart(seriesList: d.seriesByCategory, barWidth: 8),
    ),
    _CaseSpec(
      number: 33, name: 'Barras Apiladas', family: 'BarChart', classification: v,
      dataUsed: 'N5 mediaToSeriesByCategory (status vs source) · isStacked',
      chart: MultiSeriesBarChart(seriesList: d.seriesByCategory, isStacked: true, barWidth: 20),
    ),
    _CaseSpec(
      number: 34, name: 'Líneas Multiserie Comparativas', family: 'LineChart', classification: v,
      dataUsed: 'N10 mediaToSeriesPerYear (source)',
      chart: MultiLineChart(seriesList: d.seriesPerYear, showGrid: true),
    ),
    _CaseSpec(
      number: 35, name: 'Línea con Relleno Semitransparente Personalizado', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · showArea con color personalizado',
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5, showArea: true, lineColor: Colors.deepPurpleAccent),
    ),
    _CaseSpec(
      number: 36, name: 'Donut con Widget Central Superpuesto', family: 'PieChart + Flutter', classification: c,
      dataUsed: 'N4 mediaToCategoryCount · Stack(PieChart, KPI)',
      chart: Stack(
        alignment: Alignment.center,
        children: [
          BasicPieChart(data: d.pieMain.data, isDonut: true, showTitles: false),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${d.total}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Obras', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
    _CaseSpec(
      number: 37, name: 'Donut con Etiquetas de Porcentaje Externas', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount · titlePositionPercentageOffset: 1.5',
      chart: BasicPieChart(data: d.pieMain.data, isDonut: true, titlePositionPercentageOffset: 1.5, minPercentForTitle: 0),
    ),
    _CaseSpec(
      number: 38, name: 'Donut con Etiquetas de Porcentaje Internas', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount · titlePositionPercentageOffset: 0.5',
      chart: BasicPieChart(data: d.pieMain.data, isDonut: true, titlePositionPercentageOffset: 0.5, minPercentForTitle: 0),
    ),
    _CaseSpec(
      number: 39, name: 'Serie Temporal Multivariable', family: 'LineChart', classification: v,
      dataUsed: 'N9 mediaToYearMetricsNormalized (conteo vs score normalizados a 0-1)',
      chart: MultiLineChart(seriesList: d.yearMetricsNormalized, isCurved: true),
    ),
    _CaseSpec(
      number: 40, name: 'Gráfica de Barras con Etiquetas Numéricas Superiores', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 8 · showRodLabels',
      chart: BasicBarChart(data: d.genreTop8, showRodLabels: true, maxY: d.genreTop8.isEmpty ? null : d.genreTop8.first.value * 1.2),
    ),
    _CaseSpec(
      number: 41, name: 'Gráfica de Líneas con Ejes Rotados', family: 'LineChart', classification: c,
      dataUsed: '$_t2 · RotatedBox(quarterTurns: 1)',
      height: 360,
      chart: RotatedBox(
        quarterTurns: 1,
        child: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5),
      ),
    ),
    _CaseSpec(
      number: 42, name: 'Barras con Línea de Meta o Target Line', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · showBaselineLine',
      chart: BasicBarChart(
        data: d.genreTop10,
        baselineY: d.genreTop10.isEmpty ? 0 : d.genreTop10.map((e)=>e.value).reduce((a,b)=>a+b)/d.genreTop10.length,
        showBaselineLine: true,
      ),
    ),
    _CaseSpec(
      number: 43, name: 'Barras con Desplazamiento Horizontal', family: 'BarChart', classification: c,
      dataUsed: 'T1 mediaToGenreCount (todos los géneros) · SingleChildScrollView horizontal',
      chart: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: d.allGenres.length * 40.0,
          child: BasicBarChart(data: d.allGenres, barWidth: 16),
        ),
      ),
    ),
    _CaseSpec(
      number: 44, name: 'Gráfica Reactiva en Tiempo Real con Streams', family: 'LineChart + Flutter', classification: c,
      dataUsed: '$_t2 · Simulación progresiva con StreamBuilder',
      chart: StreamBuilder<List<ChartDataXY>>(
        stream: Stream.periodic(const Duration(milliseconds: 500), (i) => d.scorePerYear.take(i + 1).toList()).take(d.scorePerYear.length),
        builder: (context, snapshot) {
          final data = snapshot.data ?? (d.scorePerYear.isEmpty ? [] : [d.scorePerYear.first]);
          return BasicLineChart(points: data, animated: false);
        },
      ),
    ),
    _CaseSpec(
      number: 45, name: 'Medidor Gauge de Tres Segmentos', family: 'PieChart + Flutter', classification: c,
      dataUsed: 'N4 (status divido en 3) · PieChart semicircular',
      chart: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.5,
              child: BasicPieChart(data: d.pieMain.data.take(3).toList(), isDonut: true, showTitles: false),
            ),
          ),
          const Text('Gauge Multinivel', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    _CaseSpec(
      number: 46, name: 'Gráfica de Líneas con Selección de Punto', family: 'LineChart', classification: n,
      dataUsed: '$_t2 · Touch Interaction (enableTouch: true)',
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5, enableTouch: true, showDots: true),
    ),
    _CaseSpec(
      number: 47, name: 'Barras con Rango de Eje Y Forzado', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · top 10 · minY: 0, maxY: 100',
      chart: BasicBarChart(data: d.genreTop10, minY: 0, maxY: 100),
    ),
    _CaseSpec(
      number: 48, name: 'Barras Horizontales con Agrupamiento Multiserie', family: 'BarChart', classification: v,
      dataUsed: 'N5 mediaToSeriesByCategory · isHorizontal',
      height: 400,
      chart: MultiSeriesBarChart(seriesList: d.seriesByCategory, isHorizontal: true, barWidth: 8),
    ),
    _CaseSpec(
      number: 49, name: 'Gráfica con Formato Monetario en Eje Y', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · valueFormatter con \$ (simulación)',
      chart: BasicBarChart(data: d.genreTop10, valueFormatter: (v) => '\$${v.toInt()}'),
    ),
    _CaseSpec(
      number: 50, name: 'Gráfica con Formato de Fecha Personalizado en Eje X', family: 'LineChart', classification: v,
      dataUsed: 'N6 conteo por año-mes · xLabelFormatter',
      chart: BasicLineChart(
        points: d.countPerYearMonth,
        xLabelFormatter: (x) => '${(x ~/ 100).toInt()}-${(x % 100).toInt().toString().padLeft(2, '0')}',
        xLabelInterval: 100, // Roughly one tick per year (YYYYMM)
      ),
    ),
    _CaseSpec(
      number: 51, name: 'Barras con Gradiente Vertical Manual', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · barGradient',
      chart: BasicBarChart(
        data: d.genreTop10,
        barGradient: const LinearGradient(colors: [Colors.purple, Colors.blue], begin: Alignment.bottomCenter, end: Alignment.topCenter),
      ),
    ),
    _CaseSpec(
      number: 52, name: 'Gráfica Filtrable por Estado Dinámico', family: 'BarChart + Flutter', classification: c,
      dataUsed: '$_t1 · Filtro simulado (> 10 obras)',
      chart: Column(
        children: [
          const Text('Filtrar > 10 obras'),
          const SizedBox(height: 8),
          Expanded(child: BasicBarChart(data: d.genreTop10.where((e) => e.value > 10).toList())),
        ],
      ),
    ),
    _CaseSpec(
      number: 53, name: 'Gráfica de Líneas con Curvas Suavizadas', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · isCurved: true',
      chart: BasicLineChart(points: d.scorePerYear, isCurved: true, xLabelInterval: 5),
    ),
    _CaseSpec(
      number: 54, name: 'Dona con Porción Resaltada', family: 'PieChart', classification: v,
      dataUsed: 'N4 mediaToCategoryCount · highlightedIndex = 0',
      chart: BasicPieChart(data: d.pieMain.data, isDonut: true, highlightedIndex: 0),
    ),
    _CaseSpec(
      number: 55, name: 'Gráfica de Distribución de Frecuencias (Histograma)', family: 'BarChart', classification: v,
      dataUsed: 'N2 numericBins · groupsSpace: 0',
      chart: BasicBarChart(data: d.scoreBins10, groupsSpace: 0, showBorder: true),
    ),
    _CaseSpec(
      number: 56, name: 'Gráfica con Doble Línea de Tendencia y Dispersión', family: 'Composición Flutter', classification: c,
      dataUsed: 'N8 mediaToScatterPoints (popularity vs score) + regresión',
      chart: ScatterTrendChart(
        points: d.scatterPoints,
        regressionLine: d.scatterRegression,
        xAxisLabel: 'Popularidad',
        yAxisLabel: 'Score',
      ),
    ),
    _CaseSpec(
      number: 57, name: 'Tarjeta Dashboard de Alto Rendimiento', family: 'Composición Flutter', classification: c,
      dataUsed: 'N7 summaryKpis + BasicLineChart',
      chart: CompactSummaryCard(
        title: 'Dashboard KPI',
        value: summary.finishedCount.toString(),
        caption: 'Obras finalizadas',
        chart: BasicLineChart(points: d.countPerYear, showTitles: false, showGrid: false, showBorder: false, showArea: true, enableTouch: false),
      ),
    ),
    _CaseSpec(
      number: 58, name: 'Gráfica Exportable a Imagen', family: 'Composición Flutter', classification: c,
      dataUsed: 'RepaintBoundary alrededor del gráfico',
      chart: RepaintBoundary(
        child: Container(
          color: Colors.black12,
          padding: const EdgeInsets.all(8),
          child: BasicBarChart(data: d.genreTop6),
        ),
      ),
    ),
    _CaseSpec(
      number: 59, name: 'Donut Multianillo', family: 'PieChart + Flutter', classification: c,
      dataUsed: 'Stack de 2 DonutCharts con distintos radios',
      chart: Stack(
        alignment: Alignment.center,
        children: [
          BasicPieChart(data: d.pieMain.data, isDonut: true, isThinDonut: true, showTitles: false),
          Padding(
            padding: const EdgeInsets.all(40),
            child: BasicPieChart(data: d.pieAlt.data, isDonut: true, isThinDonut: true, showTitles: false),
          ),
        ],
      ),
    ),
    _CaseSpec(
      number: 60, name: 'Barras con Líneas de Cuadrícula Secundarias', family: 'BarChart', classification: v,
      dataUsed: '$_t1 · gridInterval reducido',
      chart: BasicBarChart(data: d.genreTop10, showGrid: true, gridInterval: 5),
    ),
    _CaseSpec(
      number: 61, name: 'Gráfica de Progreso Multinivel', family: 'BarChart', classification: v,
      dataUsed: 'N7 · MultiSeriesBarChart con isStacked y horizontal',
      height: 100,
      chart: MultiSeriesBarChart(
        seriesList: [
          ChartSeries(seriesName: 'Finished', data: [ChartDataCategory(category: 'Status', value: summary.finishedCount)]),
          ChartSeries(seriesName: 'Remaining', data: [ChartDataCategory(category: 'Status', value: summary.withStatusCount - summary.finishedCount)]),
        ],
        isHorizontal: true,
        isStacked: true,
        showGrid: false,
        showTitles: false,
        barWidth: 32,
      ),
    ),
    _CaseSpec(
      number: 62, name: 'Gráfica con Fondo de Área Condicional', family: 'LineChart', classification: v,
      dataUsed: '$_t2 · belowBarData',
      chart: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5, showArea: true, minY: 50),
    ),
    _CaseSpec(
      number: 63, name: 'Dashboard Multi-Gráfica Sincronizado', family: 'Composición Flutter', classification: c,
      dataUsed: 'Múltiples gráficas en una vista',
      height: 400,
      chart: Column(
        children: [
          Expanded(child: BasicLineChart(points: d.scorePerYear, xLabelInterval: 5)),
          const SizedBox(height: 16),
          Expanded(child: BasicBarChart(data: d.countPerYearCategories, categoryLabelEvery: 5)),
        ],
      ),
    ),
  ];
}

// -----------------------------------------------------------------------------
// Widgets de la galería
// -----------------------------------------------------------------------------

class _DatasetHeader extends StatelessWidget {
  final ChartsDatasetProvider provider;
  final _GalleryData data;
  const _DatasetHeader({required this.provider, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Muestra: ${data.total} obras ${_prettyEnum(data.type)} más populares de AniList',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Consulta GraphQL existente (sort: POPULARITY_DESC), ${provider.pages} páginas × ${provider.perPage}. '
              'Las estadísticas describen solo esta muestra, no toda la base de AniList. '
              'Casos según la LISTA_CANDIDATA_63 (lista provisional de trabajo, no oficial). '
              'Cambia Anime/Manga para ver las transiciones animadas (los casos 25–27 no animan).',
              style: theme.textTheme.bodySmall,
            ),
            if (provider.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Último error al recargar: ${provider.errorMessage}',
                  style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final _CaseSpec spec;
  const _ChartCard({required this.spec});

  static (String, Color) _badge(_Classification c) => switch (c) {
        _Classification.nativo => ('NATIVO', Colors.green.shade700),
        _Classification.variante => ('VARIANTE', Colors.blue.shade700),
        _Classification.composicion => ('COMPOSICIÓN', Colors.orange.shade800),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = _badge(spec.classification);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${spec.number}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(spec.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(label,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Librería: FL Chart 1.2.0 · Familia: ${spec.family}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            SizedBox(height: spec.height, child: spec.chart),
            const SizedBox(height: 12),
            Text('Datos: ${spec.dataUsed}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
