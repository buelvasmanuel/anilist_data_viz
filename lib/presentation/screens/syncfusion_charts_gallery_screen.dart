import 'package:anilist_data_viz/charts/common/master_case_gallery.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:flutter/material.dart';

import 'package:anilist_data_viz/charts/syncfusion/syncfusion_case_builders.dart';

/// Galería Syncfusion: los 63 casos de la matriz maestra.
class SyncfusionChartsGalleryScreen extends StatelessWidget {
  const SyncfusionChartsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => MasterCaseGallery(
        library: ChartLibrary.syncfusion,
        title: 'Syncfusion 34.2.9 · 63 casos',
        cases: syncfusionCases,
      );
}
