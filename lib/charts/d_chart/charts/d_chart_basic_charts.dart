import 'package:anilist_data_viz/charts/transformations/data_transformations.dart';
import 'package:anilist_data_viz/domain/entities/media.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';

Widget _buildOrdinalBar(List<Media> media, bool horizontal) {
  final byGenre = DataTransformations.mediaToGenreCount(media);
  if (byGenre.isEmpty) return const Center(child: Text('Sin datos'));
  
  final group = OrdinalGroup(
    id: 'genres',
    data: byGenre.map((e) => OrdinalData(domain: e.category, measure: e.value)).toList(),
  );
  
  return DChartBarO(
    groupList: [group],
    arrangeVertically: !horizontal,
  );
}

Widget dChartC2(List<Media> media) => _buildOrdinalBar(media, false);
Widget dChartB3(List<Media> media) => _buildOrdinalBar(media, true);

Widget dChartL1(List<Media> media) {
  final byGenre = DataTransformations.mediaToGenreCount(media);
  if (byGenre.isEmpty) return const Center(child: Text('Sin datos'));
  
  final group = OrdinalGroup(
    id: 'genres',
    data: byGenre.map((e) => OrdinalData(domain: e.category, measure: e.value)).toList(),
  );
  
  return DChartComboO(
    groupList: [group],
    renderType: (_) => RenderType.line,
  );
}

Widget _buildOrdinalPie(List<Media> media, bool doughnut) {
  final byFormat = DataTransformations.mediaToCategoryCount(media, selector: (m) => m.format);
  if (byFormat.isEmpty) return const Center(child: Text('Sin datos'));
  
  return DChartPieO(
    data: byFormat.map((e) => OrdinalData(domain: e.category, measure: e.value)).toList(),
    configSeriesPie: ConfigSeriesPieO(
      arcWidth: doughnut ? 30 : null,
    ),
  );
}

Widget dChartP7(List<Media> media) => _buildOrdinalPie(media, false);
Widget dChartD8(List<Media> media) => _buildOrdinalPie(media, true);
