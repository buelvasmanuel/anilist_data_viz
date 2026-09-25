import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/syncfusion_charts_gallery_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll('ChartsGalleryScreen', 'SyncfusionChartsGalleryScreen');
  content = content.replaceAll('_SyncfusionChartsGalleryScreenState', '_SyncfusionChartsGalleryScreenState');
  content = content.replaceAll('BasicBarChart', 'SyncfusionBasicBarChart');
  content = content.replaceAll('BasicLineChart', 'SyncfusionBasicLineChart');
  content = content.replaceAll('BasicPieChart', 'SyncfusionBasicPieChart');
  content = content.replaceAll('ProgressBarChart', 'SyncfusionProgressBarChart');
  content = content.replaceAll('SemiCircleGauge', 'SyncfusionSemiCircleGauge');
  content = content.replaceAll('CompactSummaryCard', 'SyncfusionCompactSummaryCard');
  content = content.replaceAll('MultiSeriesBarChart', 'SyncfusionMultiSeriesBarChart');
  content = content.replaceAll('MultiLineChart', 'SyncfusionMultiLineChart');
  content = content.replaceAll('ScatterTrendChart', 'SyncfusionScatterTrendChart');

  content = content.replaceAll("'BarChart'", "'Cartesian (Bar/Column)'");
  content = content.replaceAll("'LineChart'", "'Cartesian (Line)'");
  content = content.replaceAll("'PieChart'", "'Circular (Pie/Doughnut)'");
  content = content.replaceAll("'ScatterChart'", "'Cartesian (Scatter)'");
  content = content.replaceAll("'FL Chart'", "'Syncfusion'");
  
  content = content.replaceAll(RegExp(r"import 'package:anilist_data_viz/charts/fl_chart/.*?';\r?\n"), '');

  final imports = '''import 'package:anilist_data_viz/charts/syncfusion/syncfusion_bar_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_line_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_pie_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_progress_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_gauge_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_summary_cards.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_multi_bar_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_multi_line_charts.dart';
import 'package:anilist_data_viz/charts/syncfusion/syncfusion_scatter_trend_charts.dart';
''';

  content = content.replaceAll("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports);

  file.writeAsStringSync(content);
}
