import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/repositories/playlists/factory.dart';
import 'package:music_player/core/repositories/stored_paths/factory.dart';
import 'package:music_player/core/track_players/factory.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/widgets/main_browser/all_tracks/main.dart';
import 'package:music_player/widgets/main_browser/local_path_picker/main.dart';
import 'package:music_player/widgets/main_browser/playlists/main.dart';

class MainBrowser extends ConsumerWidget {

  const MainBrowser({
    super.key,
  });

  Future<void> _loadInitialPaths(WidgetRef ref) async {
    final initialLoadDone = ref.read(localPathsProvider.notifier).initialLoadDone();
    if (initialLoadDone) {
      return;
    }
    final storedPathsRepository = getStoredPathsRepository();
    final storedPaths = await storedPathsRepository.getStoredPaths();
    ref.read(localPathsProvider.notifier).setPaths(storedPaths);
    final tracksPlayer = getTrackPlayer();
    final tracks = await tracksPlayer.fetchTracks(storedPaths);
    ref.read(tracksProvider.notifier).setTracks(tracks);
    final playlistsRepo = getPlaylistRepository();
    final playlists = await playlistsRepo.getPlaylists(tracks);
    ref.read(playlistsProvider.notifier).setPlaylists(playlists);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _loadInitialPaths(ref);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.music_note), text: "All tracks"),
            Tab(icon: Icon(Icons.playlist_add), text: "Playlists"),
            Tab(icon: Icon(Icons.folder), text: "Added paths"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ]
        ),
        body: TabBarView(
          children: [
            AllTracksPicker(),
            Playlists(),
            LocalPathPicker(),
            Icon(Icons.settings),
          ],
        ),
      ),
    );
  }
}


