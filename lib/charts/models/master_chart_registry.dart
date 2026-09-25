// Fuente de verdad de la matriz 63x4

enum ChartLibrary { flChart, syncfusion, dChart, graphic }

enum ChartClassification { nativo, variante, composicion, noSoportado }

enum ChartState { funcional, parcial, demo, roto, noDisponible, noVerificado }

class LibrarySupport {
  final ChartClassification classification;
  final ChartState state;

  const LibrarySupport(this.classification, this.state);
}

class MasterChartSpec {
  final int number;
  final String name;
  final Map<ChartLibrary, LibrarySupport> support;

  const MasterChartSpec({
    required this.number,
    required this.name,
    required this.support,
  });
  
  LibrarySupport getFor(ChartLibrary library) => support[library]!;
}

const List<MasterChartSpec> masterChartRegistry = [
  MasterChartSpec(
    number: 1,
    name: 'Línea Simple',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 2,
    name: 'Columna Vertical',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 3,
    name: 'Barra Horizontal',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 4,
    name: 'Línea Curva / Spline',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 5,
    name: 'Área',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 6,
    name: 'Spline Area',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 7,
    name: 'Pie',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 8,
    name: 'Doughnut',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 9,
    name: 'Radial Bar',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 10,
    name: 'Scatter',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 11,
    name: 'Bubble',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
    },
  ),
  MasterChartSpec(
    number: 12,
    name: 'Step Line',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 13,
    name: 'Step Area',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 14,
    name: 'Pyramid',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 15,
    name: 'Funnel',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 16,
    name: 'Histogram',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 17,
    name: 'Stacked Column',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 18,
    name: 'Stacked Bar',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 19,
    name: 'Stacked Area',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 20,
    name: 'Stacked Line',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 21,
    name: '100% Stacked Column',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 22,
    name: '100% Stacked Bar',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 23,
    name: '100% Stacked Area',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 24,
    name: '100% Stacked Line',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 25,
    name: 'Range Column',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 26,
    name: 'Range Area',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 27,
    name: 'Spline Range Area',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 28,
    name: 'Waterfall',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 29,
    name: 'Line with markers',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 30,
    name: 'Diverging Bar',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 31,
    name: 'Sparkline Line',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 32,
    name: 'Candlestick',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.noSoportado, ChartState.noDisponible),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 33,
    name: 'HLOC',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noDisponible),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.noSoportado, ChartState.noDisponible),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 34,
    name: 'Box and Whisker',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.noSoportado, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 35,
    name: 'Error Bars',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 36,
    name: 'Combined Column + Line',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 37,
    name: 'Dual Y Axis',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.parcial),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 38,
    name: 'Pan & Zoom',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 39,
    name: 'Crosshair',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 40,
    name: 'Trackball',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 41,
    name: 'SMA',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 42,
    name: 'Bollinger Bands',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 43,
    name: 'RSI',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 44,
    name: 'MACD',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noDisponible),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 45,
    name: 'Trendline Regression',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 46,
    name: 'Plot Bands / Strip Lines',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 47,
    name: 'Cartesian Widget Annotations',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 48,
    name: 'Multi-colored Line',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 49,
    name: 'Palette Gradient Series',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 50,
    name: 'Break / Gapless DateTime Axis',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.parcial),
    },
  ),
  MasterChartSpec(
    number: 51,
    name: 'Logarithmic Scale',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 52,
    name: 'Infinite Scrolling / Lazy Loading',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.parcial),
    },
  ),
  MasterChartSpec(
    number: 53,
    name: 'Shaded Doughnut',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 54,
    name: 'Semi-Doughnut Progress',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 55,
    name: 'Range Selection Data Filter',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 56,
    name: 'Exploding Radial Bar',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 57,
    name: 'Sparkline Win-Loss',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 58,
    name: 'Sparkline Area with Min/Max',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 59,
    name: 'Multi-shape Categorical Scatter',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 60,
    name: 'Fully Customized Widget Tooltip',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.composicion, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 61,
    name: 'Staggered Animation',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.variante, ChartState.funcional),
    },
  ),
  MasterChartSpec(
    number: 62,
    name: 'Inverted / Opposed Axis',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.variante, ChartState.noVerificado),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.nativo, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.noDisponible),
    },
  ),
  MasterChartSpec(
    number: 63,
    name: 'Real-time Streaming',
    support: {
      ChartLibrary.flChart: LibrarySupport(ChartClassification.composicion, ChartState.demo),
      ChartLibrary.syncfusion: LibrarySupport(ChartClassification.nativo, ChartState.demo),
      ChartLibrary.dChart: LibrarySupport(ChartClassification.composicion, ChartState.noVerificado),
      ChartLibrary.graphic: LibrarySupport(ChartClassification.nativo, ChartState.parcial),
    },
  ),
];

MasterChartSpec getMasterChart(int number) {
  return masterChartRegistry.firstWhere((s) => s.number == number);
}
