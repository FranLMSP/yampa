import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/player_controller_provider.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/selected_playlists_provider.dart';
import 'package:music_player/providers/selected_tracks_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/widgets/main_browser/playlists/add_to_playlist_modal.dart';

class PlaylistButton extends ConsumerWidget {
  const PlaylistButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsNotifier = ref.read(playlistsProvider.notifier);
    final playerController = ref.watch(playerControllerProvider);
    final selectedPlaylistsNotifier = ref.read(selectedPlaylistsProvider.notifier);
    final selectedTracksNotifier = ref.read(selectedTracksProvider.notifier);
    final tracks = ref.watch(tracksProvider);
    final playlists = ref.watch(playlistsProvider);
    return IconButton(
      icon: const Icon(Icons.playlist_add),
      tooltip: 'Save to playlist',
      onPressed: () async {
        if (playerController.currentTrack == null) {
          return;
        }
        selectedTracksNotifier.clear();
        selectedTracksNotifier.selectTrack(playerController.currentTrack!);
        addToPlaylistsModal(context, tracks, playlists, playlistsNotifier, selectedPlaylistsNotifier, selectedTracksNotifier);
      },
    );
  }
}
