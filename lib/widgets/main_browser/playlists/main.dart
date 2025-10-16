import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/utils.dart';
import 'package:music_player/widgets/main_browser/playlists/new_playlist_dialog.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_list_big.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_view_small.dart';

class Playlists extends ConsumerStatefulWidget {
  const Playlists({super.key});

  @override
  ConsumerState<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends ConsumerState<Playlists> {
  Playlist? _selectedPlaylist;

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
                    // optionally select the newly created playlist:
                    setState(() {
                      _selectedPlaylist = newPlaylist;
                    });
                  },
                );
              }
            );
          },
        ),
      ],
    );
  }

  void _handlePlaylistSelected(Playlist playlist) {
    setState(() {
      _selectedPlaylist = playlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(context, playlistNotifier),
      body: _selectedPlaylist != null
          ? PlaylistViewSmall(
              playlist: _selectedPlaylist!,
              onEdit: (Playlist editedPlaylist) {
                // TODO
              },
              onGoBack: () {
                setState(() {
                  _selectedPlaylist = null;
                });
              },
            )
          : PlaylistListBig(
              onTap: (Playlist playlist) {
                _handlePlaylistSelected(playlist);
              },
            ),
    );
  }
}
