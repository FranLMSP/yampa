import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/initial_load_provider.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/providers/utils.dart';
import 'package:music_player/widgets/main_browser/main.dart';
import 'package:music_player/widgets/main_page_loader.dart';
import 'package:music_player/widgets/player/big_player.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAMPA - Yet Another Music Player App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  Future<void> _load(
    bool initialLoadDone,
    InitialLoadNotifier initialLoadNotifier,
    LocalPathsNotifier localPathsNotifier,
    TracksNotifier tracksNotifier,
    PlaylistNotifier playlistNotifier,
  ) async {
    await doInitialLoad(
      initialLoadDone,
      initialLoadNotifier,
      localPathsNotifier,
      tracksNotifier,
      playlistNotifier,
    );
  }

  Widget _buildMainPageLoader() {
    return const MainPageLoader();
  }

  Widget _buildMainContent() {
    return const Scaffold(
      body: Center(
        child: Row(
          children: [
            SizedBox(
              width: 500,
              child: MainBrowser(),
            ),
            Expanded(
              child: Center(
                child: BigPlayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    if (!initialLoadDone) {
      final initialLoadNotifier = ref.read(initialLoadProvider.notifier);
      final localPathsNotifier = ref.read(localPathsProvider.notifier);
      final tracksNotifier = ref.read(tracksProvider.notifier);
      final playlistsNotifier = ref.read(playlistsProvider.notifier);
      _load(
        initialLoadDone,
        initialLoadNotifier,
        localPathsNotifier,
        tracksNotifier,
        playlistsNotifier,
      );
    }
    return initialLoadDone
        ? _buildMainContent()
        : _buildMainPageLoader();
  }
}
