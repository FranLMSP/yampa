import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/widgets/main_browser/playlists/form.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_item_big.dart';

class PlaylistList extends ConsumerStatefulWidget {
  const PlaylistList({super.key});

  @override
  ConsumerState<PlaylistList> createState() => _PlaylistListState();
}

class _PlaylistListState extends ConsumerState<PlaylistList> {

  bool _isBeingEdited = false;
  bool _isNew = false;
  Playlist? _curentlyEditedPlaylist;

  Widget _buildList(List<Playlist> playlists) {
    return ListView(
      children: playlists.map((playlist) => PlaylistItemBig(
        playlist: playlist,
        onSelect: () => setState(() {
          _isBeingEdited = true;
          _curentlyEditedPlaylist = playlist;
        }),
      )).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_isBeingEdited)
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => setState(() {
                _curentlyEditedPlaylist = Playlist(
                  id: "temp-id",
                  name: "New playlist",
                  description: "",
                  tracks: [],
                );
                _isBeingEdited = true;
                _isNew = true;
              }),
            ),
        ]
      ),
      body: _isBeingEdited && _curentlyEditedPlaylist != null
        ? PlaylistEditForm(
            playlist: _curentlyEditedPlaylist!,
            isNew: _isNew,
            onSaveNew: (Playlist newPlaylist) {
              _isNew = false;
              _curentlyEditedPlaylist = newPlaylist;
            },
            onEdit: (Playlist editedPlaylist) {
              _curentlyEditedPlaylist = editedPlaylist;
            },
            onGoBack: () {
              _isBeingEdited = false;
              _curentlyEditedPlaylist = null;
            },
          )
        : _buildList(playlists),
    );
  }
}
