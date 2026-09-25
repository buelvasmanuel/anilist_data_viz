// Galería de las 63 gráficas de Graphic.
//
// Recibe un GraphicDataset ya construido por el Provider (la pantalla NO
// consulta AniList). Cada tarjeta muestra número, nombre, clasificación,
// origen de datos y la gráfica.

import 'package:flutter/material.dart';

import 'common/graphic_common.dart';
import 'data/graphic_dataset.dart';
import 'graphic_chart_registry.dart';

import 'package:provider/provider.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';

class GraphicChartsGalleryScreen extends StatefulWidget {
  const GraphicChartsGalleryScreen({super.key});

  @override
  State<GraphicChartsGalleryScreen> createState() => _GraphicChartsGalleryScreenState();
}

class _GraphicChartsGalleryScreenState extends State<GraphicChartsGalleryScreen> {
  GraphicClassification? _filter;

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
        title: const Text('Graphic 2.7.0 · 63 gráficas'),
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
              (provider.state == ProviderState.loading && provider.graphicDataset == null)) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Cargando muestra de AniList… (${provider.loadedPages}/${provider.pages} páginas)'),
                ],
              ),
            );
          }
          if (provider.graphicDataset == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.state == ProviderState.error
                      ? 'Error: ${provider.errorMessage}'
                      : 'AniList no devolvió obras.'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => provider.load(), child: const Text('Reintentar')),
                ],
              ),
            );
          }

          final dataset = provider.graphicDataset!;
          final specs = _filter == null
              ? graphicChartRegistry
              : graphicChartRegistry.where((s) => s.classification == _filter).toList();
          final counts = {
            for (final c in GraphicClassification.values)
              c: graphicChartRegistry.where((s) => s.classification == c).length,
          };

          return Column(children: [
            if (provider.isLoading) const LinearProgressIndicator(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                ChoiceChip(
                  label: Text('Todas (${graphicChartRegistry.length})'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final c in GraphicClassification.values) ...[
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text('${c.label} (${counts[c]})'),
                    selected: _filter == c,
                    onSelected: (_) => setState(() => _filter = c),
                  ),
                ],
              ]),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: specs.length,
                itemBuilder: (context, i) => GraphicChartCard(spec: specs[i], dataset: dataset),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

/// Tarjeta de un caso: cabecera + gráfica.
class GraphicChartCard extends StatelessWidget {
  const GraphicChartCard({super.key, required this.spec, required this.dataset});

  final GraphicChartSpec spec;
  final GraphicDataset dataset;

  @override
  Widget build(BuildContext context) {
    final origin = spec.originFor(dataset);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                '${spec.number.toString().padLeft(2, '0')}. ${spec.name}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            _Tag(spec.classification.label, spec.classification.color),
          ]),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _Tag('Datos: ${origin.label}', Colors.blueGrey),
          ]),
          const SizedBox(height: 4),
          Text(spec.construction, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
          const SizedBox(height: 8),
          SizedBox(height: 280, child: spec.builder(dataset)),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      );
}
