import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/local_paths_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/main.dart';
import 'package:yampa/widgets/main_page_loader.dart';
import 'package:yampa/widgets/player/big_player.dart';
import 'package:yampa/widgets/utils.dart';

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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
      final playerController = ref.watch(playerControllerProvider);
      final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
      if (playerController.hasTrackFinishedPlaying()) {
        await playerControllerNotifier.handleNextAutomatically();
      }
    });
  }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewMode = getViewMode(constraints);
        if (viewMode == ViewMode.portrait) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: MainBrowser(viewMode: viewMode),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: 500,
                      child: MainBrowser(viewMode: viewMode),
                    ),
                    Expanded(
                      child: Center(
                        child: BigPlayer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
