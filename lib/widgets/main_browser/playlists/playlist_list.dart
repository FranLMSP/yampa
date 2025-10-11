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
  Playlist? _curentlyEditedPlaylist;

  Widget _buildList(List<Playlist> playlists) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return PlaylistItemBig(
          playlist: playlist,
          onTap: () {
            // Open playlist details
          },
        );
      },
    );
    /*
    return ListView(
      children: playlists.map((playlist) => PlaylistItemBig(
        playlist: playlist,
        onSelect: () => setState(() {
          _isBeingEdited = true;
          _curentlyEditedPlaylist = playlist;
        }),
      )).toList()
    );
    */
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
              }),
            ),
        ]
      ),
      body: _isBeingEdited && _curentlyEditedPlaylist != null
        ? PlaylistEditForm(
            playlist: _curentlyEditedPlaylist!,
            onSaveNew: (Playlist newPlaylist) {
              setState(() {
                _curentlyEditedPlaylist = newPlaylist;
              });
            },
            onEdit: (Playlist editedPlaylist) {
              setState(() {
                _curentlyEditedPlaylist = editedPlaylist;
              });
            },
            onGoBack: () {
              setState(() {
                _isBeingEdited = false;
                _curentlyEditedPlaylist = null;
              });
            },
          )
        : _buildList(playlists),
    );
  }
}
