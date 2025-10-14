import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/utils.dart';
import 'package:music_player/widgets/main_browser/playlists/new_playlist_dialog.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_list_big.dart';

class Playlists extends ConsumerWidget {
  const Playlists({super.key});

  Widget _buildFloatingActionButton(BuildContext context, PlaylistNotifier playlistNotifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return NewPlaylistDialog(
                  onSaved: (newPlaylist) {
                    handlePlaylistCreated(newPlaylist, playlistNotifier);
                  },
                );
              }
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(context, playlistNotifier),
      body: PlaylistListBig(),
    );
  }
}
