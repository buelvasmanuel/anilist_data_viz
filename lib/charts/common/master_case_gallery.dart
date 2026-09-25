// Galería común de los 63 casos maestros. Cada librería solo aporta su mapa
// `Map<int, CaseImpl>`; la estructura, los filtros y las tarjetas son iguales
// para las cuatro, lo que permite comparar la matriz 63×4 caso a caso.

import 'package:anilist_data_viz/charts/common/case_support.dart';
import 'package:anilist_data_viz/charts/models/master_case_presentation.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterCaseGallery extends StatefulWidget {
  const MasterCaseGallery({
    super.key,
    required this.library,
    required this.title,
    required this.cases,
  });

  final ChartLibrary library;
  final String title;
  final Map<int, CaseImpl> cases;

  @override
  State<MasterCaseGallery> createState() => _MasterCaseGalleryState();
}

class _MasterCaseGalleryState extends State<MasterCaseGallery> {
  ImplementationStrategy? _strategy;
  CaseCategory? _category;

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
        title: Text(widget.title),
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
                onSelectionChanged: provider.isLoading ? null : (s) => provider.load(type: s.first),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChartsDatasetProvider>(
        builder: (context, provider, _) {
          final dataset = provider.graphicDataset;
          if (dataset == null) {
            if (provider.state == ProviderState.error || provider.state == ProviderState.empty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(provider.state == ProviderState.error ? 'Error: ${provider.errorMessage}' : 'AniList no devolvió obras.'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => provider.load(), child: const Text('Reintentar')),
                ]),
              );
            }
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Cargando muestra de AniList… (${provider.loadedPages}/${provider.pages} páginas)'),
              ]),
            );
          }

          final data = CaseData(
            g: dataset,
            media: provider.media,
            type: provider.loadedType,
            trendsTitle: provider.trendsMedia?.title,
            trendsError: provider.trendsError,
          );
          final specs = [
            for (final m in masterChartRegistry)
              if ((_strategy == null || widget.cases[m.number]!.strategy == _strategy) &&
                  (_category == null || caseCategoryOf(m.number) == _category))
                m,
          ];

          return Column(children: [
            if (provider.isLoading) const LinearProgressIndicator(),
            _Filters(
              cases: widget.cases,
              strategy: _strategy,
              category: _category,
              onStrategy: (s) => setState(() => _strategy = s),
              onCategory: (c) => setState(() => _category = c),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: specs.length + 1,
                itemBuilder: (context, i) => i == 0
                    ? _SampleHeader(provider: provider, shown: specs.length)
                    : MasterCaseCard(
                        master: specs[i - 1],
                        library: widget.library,
                        impl: widget.cases[specs[i - 1].number]!,
                        data: data,
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.cases,
    required this.strategy,
    required this.category,
    required this.onStrategy,
    required this.onCategory,
  });

  final Map<int, CaseImpl> cases;
  final ImplementationStrategy? strategy;
  final CaseCategory? category;
  final ValueChanged<ImplementationStrategy?> onStrategy;
  final ValueChanged<CaseCategory?> onCategory;

  @override
  Widget build(BuildContext context) {
    int countOf(ImplementationStrategy s) => cases.values.where((c) => c.strategy == s).length;
    int countIn(CaseCategory c) => masterChartRegistry.where((m) => caseCategoryOf(m.number) == c).length;
    Widget chip(String label, bool selected, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(label: Text(label, style: const TextStyle(fontSize: 12)), selected: selected, onSelected: (_) => onTap()),
        );
    return Column(children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Row(children: [
          chip('Todas (${masterChartRegistry.length})', strategy == null, () => onStrategy(null)),
          for (final s in ImplementationStrategy.values) chip('${s.label} (${countOf(s)})', strategy == s, () => onStrategy(s)),
        ]),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          chip('Todas las categorías', category == null, () => onCategory(null)),
          for (final c in CaseCategory.values) chip('${c.label} (${countIn(c)})', category == c, () => onCategory(c)),
        ]),
      ),
    ]);
  }
}

class _SampleHeader extends StatelessWidget {
  const _SampleHeader({required this.provider, required this.shown});
  final ChartsDatasetProvider provider;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trends = provider.trendsMedia == null
        ? ''
        : ' Serie Media.trends: ${provider.trendsMedia!.title} (${provider.trends.length} días).';
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Muestra real de AniList: ${provider.media.length} obras ${provider.loadedType == 'MANGA' ? 'Manga' : 'Anime'} '
          'más populares (${provider.pages} páginas × ${provider.perPage}, sort: POPULARITY_DESC). '
          'Describe solo esta muestra, no toda la base de AniList.$trends '
          'Mostrando $shown de ${masterChartRegistry.length} casos.'
          '${provider.trendsError.isEmpty ? '' : ' Error al cargar trends: ${provider.trendsError}'}',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// Tarjeta de un caso: número, nombre maestro, clasificación de capacidad
/// (matriz), estrategia de implementación, estado, origen de datos y gráfica.
class MasterCaseCard extends StatelessWidget {
  const MasterCaseCard({
    super.key,
    required this.master,
    required this.library,
    required this.impl,
    required this.data,
  });

  final MasterChartSpec master;
  final ChartLibrary library;
  final CaseImpl impl;
  final CaseData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final support = master.getFor(library);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text('${master.number}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          ]),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            MasterBadge('Capacidad: ${support.classification.label}', support.classification.color),
            MasterBadge('Implementación: ${impl.strategy.label}', impl.strategy.color),
            MasterBadge(support.state.label, support.state.color),
            MasterBadge(caseCategoryOf(master.number).label, Colors.blueGrey),
          ]),
          const SizedBox(height: 6),
          Text('Origen de datos: ${impl.origin}', style: muted),
          Text('API: ${impl.api}', style: muted),
          const SizedBox(height: 8),
          if (impl.note != null) CaseNote(impl.note!),
          // ClipRect: algunas etiquetas rotadas se dibujan fuera del área del gráfico.
          SizedBox(height: 280, child: ClipRect(child: impl.builder(context, data))),
        ]),
      ),
    );
  }
}
