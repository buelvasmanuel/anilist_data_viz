import 'package:anilist_data_viz/presentation/screens/media_detail_screen.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaListScreen extends StatefulWidget {
  final String title;

  const MediaListScreen({super.key, required this.title});

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MediaProvider>().fetchMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: _FilterDrawer(),
      body: Consumer<MediaProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProviderState.loading && provider.mediaList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == ProviderState.error && provider.mediaList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchMedia(refresh: true),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.state == ProviderState.empty) {
            return const Center(child: Text('No se encontraron resultados.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMedia(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.mediaList.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.mediaList.length) {
                  if (provider.loadMoreError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Error cargando más resultados: ${provider.errorMessage}'),
                          ElevatedButton(
                            onPressed: () => provider.fetchMedia(isRetry: true),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  } else if (provider.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return const SizedBox.shrink(); 
                  }
                }

                final media = provider.mediaList[index];
                return ListTile(
                  leading: media.coverImageMedium != null && media.coverImageMedium!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: media.coverImageMedium!,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
                          errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(media.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${media.format ?? "Unknown"} • ${media.status ?? "Unknown"}\nScore: ${media.averageScore ?? "N/A"}'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaDetailScreen(mediaId: media.id, title: media.title),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FilterDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MediaProvider>();
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tipo'),
              initialValue: provider.currentType,
              items: ['ANIME', 'MANGA'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) context.read<MediaProvider>().updateFilters(type: val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Formato'),
              initialValue: provider.currentFormat,
              items: ['TV', 'MOVIE', 'OVA', 'ONA', 'MANGA'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => context.read<MediaProvider>().updateFilters(format: val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Estado'),
              initialValue: provider.currentStatus,
              items: ['FINISHED', 'RELEASING', 'NOT_YET_RELEASED', 'CANCELLED'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => context.read<MediaProvider>().updateFilters(status: val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Género'),
              initialValue: provider.currentGenre,
              items: ['Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => context.read<MediaProvider>().updateFilters(genre: val),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar Filtros'),
              onPressed: () {
                context.read<MediaProvider>().clearFilters();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
