import 'package:anilist_data_viz/data/datasources/anilist/anilist_remote_datasource.dart';
import 'package:anilist_data_viz/data/repositories/anilist_repository_impl.dart';
import 'package:anilist_data_viz/presentation/screens/home_screen.dart';
import 'package:anilist_data_viz/presentation/state/charts_dataset_provider.dart';
import 'package:anilist_data_viz/presentation/state/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  final client = http.Client();
  final remoteDataSource = AniListRemoteDataSourceImpl(client: client);
  final repository = AniListRepositoryImpl(remoteDataSource: remoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => ChartsDatasetProvider(repository: repository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniList Data Viz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
