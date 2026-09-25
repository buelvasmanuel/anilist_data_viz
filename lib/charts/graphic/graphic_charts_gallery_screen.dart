import 'package:anilist_data_viz/charts/common/master_case_gallery.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:flutter/material.dart';

import 'graphic_cases.dart';

/// Galería Graphic: los 63 casos de la matriz maestra.
class GraphicChartsGalleryScreen extends StatelessWidget {
  const GraphicChartsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => MasterCaseGallery(
        library: ChartLibrary.graphic,
        title: 'Graphic 2.7.0 · 63 casos',
        cases: graphicCases,
      );
}
