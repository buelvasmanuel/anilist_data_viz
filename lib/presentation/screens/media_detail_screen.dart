import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaDetailScreen extends StatefulWidget {
  final int mediaId;
  final String title;

  const MediaDetailScreen({super.key, required this.mediaId, required this.title});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().fetchMediaDetail(widget.mediaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<MediaProvider>(
        builder: (context, provider, child) {
          if (provider.detailState == ProviderState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailState == ProviderState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchMediaDetail(widget.mediaId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final media = provider.selectedMedia;
          if (media == null) {
            return const Center(child: Text('No data found.'));
          }

          final coverUrl = media.coverImageExtraLarge ?? media.coverImageLarge ?? media.coverImageMedium;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (media.bannerImage != null && media.bannerImage!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: media.bannerImage!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => const SizedBox(height: 150, child: Icon(Icons.error)),
                  ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (coverUrl != null && coverUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: coverUrl,
                        width: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(width: 120, height: 180, child: Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, error) => const SizedBox(width: 120, height: 180, child: Icon(Icons.error)),
                      )
                    else
                      const SizedBox(width: 120, height: 180, child: Icon(Icons.image_not_supported)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(media.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Formato: ${media.format ?? "N/A"}'),
                          Text('Estado: ${media.status ?? "N/A"}'),
                          Text('Año: ${media.seasonYear ?? "N/A"}'),
                          Text('Episodios: ${media.episodes ?? "N/A"}'),
                          Text('Capítulos: ${media.chapters ?? "N/A"}'),
                          Text('Volúmenes: ${media.volumes ?? "N/A"}'),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(title: 'Score', value: '${media.averageScore ?? "N/A"}'),
                    _StatBox(title: 'Mean Score', value: '${media.meanScore ?? "N/A"}'),
                    _StatBox(title: 'Popularidad', value: '${media.popularity ?? "N/A"}'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Géneros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: media.genres.map((g) => Chip(label: Text(g))).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(media.description?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'Sin descripción disponible.'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
