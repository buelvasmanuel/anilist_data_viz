// Punto único de acceso a los 63 casos de cada librería (252 en total).

import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/d_chart/d_chart_case_builders.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_case_builders.dart';
import 'package:anilist_data_viz/charts/graphic/graphic_cases.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_case_builders.dart';

Map<int, CaseImpl> casesFor(ChartLibrary library) => switch (library) {
      ChartLibrary.flChart => flChartCases,
      ChartLibrary.syncfusion => syncfusionCases,
      ChartLibrary.dChart => dChartCases,
      ChartLibrary.graphic => graphicCases,
    };
