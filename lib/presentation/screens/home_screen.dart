import 'package:anilist_data_viz/presentation/screens/media_list_screen.dart';
import 'package:anilist_data_viz/presentation/screens/charts_gallery_screen.dart';
import 'package:anilist_data_viz/presentation/screens/syncfusion_charts_gallery_screen.dart';
import 'package:anilist_data_viz/charts/graphic/graphic_charts_gallery_screen.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AniList Data Viz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido al Visualizador de Datos de AniList',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta aplicación obtiene información real de AniList mediante GraphQL y la prepara para ser visualizada mediante múltiples librerías de gráficos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.tv),
              label: const Text('Explorar Anime'),
              onPressed: () {
                context.read<MediaProvider>().updateFilters(type: 'ANIME');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MediaListScreen(title: 'Anime'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text('Explorar Manga'),
              onPressed: () {
                context.read<MediaProvider>().updateFilters(type: 'MANGA');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MediaListScreen(title: 'Manga'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Personajes (Próximamente)'),
              onPressed: null, // Disabled for now as per requirements
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Gráficas (FL Chart)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChartsGalleryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.pie_chart),
              label: const Text('Gráficas (Syncfusion)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SyncfusionChartsGalleryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.show_chart),
              label: const Text('Gráficas (Graphic)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GraphicChartsGalleryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
