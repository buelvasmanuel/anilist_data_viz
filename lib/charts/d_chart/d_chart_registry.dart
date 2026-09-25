import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:anilist_data_viz/charts/d_chart/charts/d_chart_basic_charts.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:flutter/material.dart';

typedef DChartBuilder = Widget Function(List<Media> media);

class DChartSpec {
  final int number;
  final String name;
  final ChartClassification classification;
  final ChartState state;
  final DChartBuilder builder;

  const DChartSpec({
    required this.number,
    required this.name,
    required this.classification,
    required this.state,
    required this.builder,
  });
}

Widget _notSupported(List<Media> d) => const Center(
      child: Text('NO SOPORTADO o NO VERIFICADO en DChart', textAlign: TextAlign.center),
    );

final List<DChartSpec> dChartRegistry = masterChartRegistry.map((master) {
  final support = master.getFor(ChartLibrary.dChart);
  
  DChartBuilder builder = _notSupported;
  
  if (master.number == 1) builder = dChartL1;
  else if (master.number == 2) builder = dChartC2;
  else if (master.number == 3) builder = dChartB3;
  else if (master.number == 7) builder = dChartP7;
  else if (master.number == 8) builder = dChartD8;
  
  return DChartSpec(
    number: master.number,
    name: master.name,
    classification: support.classification,
    state: support.state,
    builder: builder,
  );
}).toList();
