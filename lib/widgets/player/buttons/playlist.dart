import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/widgets/main_browser/playlists/add_to_playlist_modal.dart';

class PlaylistButton extends ConsumerWidget {
  const PlaylistButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsNotifier = ref.read(playlistsProvider.notifier);
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final selectedPlaylistsNotifier = ref.read(
      selectedPlaylistsProvider.notifier,
    );
    final selectedTracksNotifier = ref.read(selectedTracksProvider.notifier);
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final tracks = ref.watch(playerControllerProvider.select((p) => p.tracks));
    return IconButton(
      icon: const Icon(Icons.playlist_add),
      tooltip: 'Save to playlist',
      onPressed: () async {
        if (currentTrackId == null) {
          return;
        }
        final track = tracks[currentTrackId];
        if (track == null) {
          return;
        }
        selectedTracksNotifier.clear();
        selectedTracksNotifier.selectTrack(track);
        addToPlaylistsModal(
          context,
          selectedTracksNotifier.getTrackIds(),
          playlistsNotifier,
          selectedPlaylistsNotifier,
          selectedTracksNotifier,
          playerControllerNotifier,
        );
      },
    );
  }
}
