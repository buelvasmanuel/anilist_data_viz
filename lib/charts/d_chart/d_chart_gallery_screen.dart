import 'package:anilist_data_viz/charts/common/master_case_gallery.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:flutter/material.dart';

import 'd_chart_case_builders.dart';

/// Galería d_chart: los 63 casos de la matriz maestra.
class DChartGalleryScreen extends StatelessWidget {
  const DChartGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => MasterCaseGallery(
        library: ChartLibrary.dChart,
        title: 'd_chart 3.0.0 · 63 casos',
        cases: dChartCases,
      );
}
