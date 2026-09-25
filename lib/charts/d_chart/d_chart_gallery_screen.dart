import 'package:anilist_data_viz/charts/d_chart/d_chart_registry.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DChartGalleryScreen extends StatefulWidget {
  const DChartGalleryScreen({super.key});

  @override
  State<DChartGalleryScreen> createState() => _DChartGalleryScreenState();
}

class _DChartGalleryScreenState extends State<DChartGalleryScreen> {
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
        title: const Text('Galería DChart'),
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
          if (provider.state == ProviderState.initial || provider.state == ProviderState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == ProviderState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.errorMessage}'),
                  TextButton(onPressed: provider.load, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          final media = provider.media;
          if (media.isEmpty) return const Center(child: Text('Sin datos disponibles'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dChartRegistry.length,
            itemBuilder: (context, index) {
              final spec = dChartRegistry[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${spec.number} ${spec.name}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Tag(spec.classification.name.toUpperCase(), Colors.blue),
                          const SizedBox(width: 8),
                          _Tag(spec.state.name.toUpperCase(), spec.state == ChartState.funcional ? Colors.green : Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: spec.builder(media),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
