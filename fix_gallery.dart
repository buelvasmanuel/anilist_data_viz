import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/syncfusion_charts_gallery_screen.dart');
  var content = file.readAsStringSync();

  // Re-add missing imports
  final missingImports = '''import 'package:anilist_data_viz/charts/fl_chart/chart_palette.dart';
import 'package:anilist_data_viz/charts/fl_chart/fl_bar_charts.dart' show BarColorMode;
''';

  content = content.replaceAll("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + missingImports);

  // Remove backgroundRodToY since SyncfusionBarChart doesn't support it (was a variant in FL Chart)
  content = content.replaceAll(RegExp(r'backgroundRodToY:\s*[^,]+,'), '');

  // Replace valueFormatter in line charts to yLabelFormatter
  content = content.replaceAll(RegExp(r'valueFormatter:'), 'yLabelFormatter:');

  // Replace animated in some charts that don't support it, or we can just remove it
  content = content.replaceAll(RegExp(r'animated:\s*(false|true)\s*,'), '');

  // showValueLabels was in BarChart? Actually it's showRodLabels in SyncfusionBasicBarChart
  content = content.replaceAll(RegExp(r'showValueLabels:\s*(false|true)\s*,'), 'showRodLabels: true,');

  file.writeAsStringSync(content);
}
