import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/models/track.dart';
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

  void _setTimer(List<Track> tracks, PlayerController playerController, PlayerControllerNotifier playerControllerNotifier) {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
      if (playerController.hasTrackFinishedPlaying()) {
        await playerControllerNotifier.handleNextAutomatically(tracks);
      }
    });
  }

  Future<void> _load(
    bool initialLoadDone,
    InitialLoadNotifier initialLoadNotifier,
    LocalPathsNotifier localPathsNotifier,
    TracksNotifier tracksNotifier,
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerControllerNotifier,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.audio.request();
    }
    await doInitialLoad(
      initialLoadDone,
      initialLoadNotifier,
      localPathsNotifier,
      tracksNotifier,
      playlistNotifier,
      playerControllerNotifier,
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
      final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
      _load(
        initialLoadDone,
        initialLoadNotifier,
        localPathsNotifier,
        tracksNotifier,
        playlistsNotifier,
        playerControllerNotifier,
      );
    }
    final playerController = ref.read(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    final tracks = ref.watch(tracksProvider);
    _setTimer(tracks, playerController, playerControllerNotifier);
    return initialLoadDone
        ? _buildMainContent()
        : _buildMainPageLoader();
  }
}
