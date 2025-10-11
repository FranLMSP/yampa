import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/repositories/playlists/factory.dart';
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
          key: Key(playlist.id),
          playlist: playlist,
          onTap: () {
            setState(() {
              _curentlyEditedPlaylist = playlist;
              _isBeingEdited = true;
              _isNew = false;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    final playlistsNotifier = ref.watch(playlistsProvider.notifier);
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
            isNew: _isNew,
            playlist: _curentlyEditedPlaylist!,
            onSaveNew: (Playlist newPlaylist) async {
              final playlistRepo = getPlaylistRepository();
              final id = await playlistRepo.addPlaylist(newPlaylist);
              playlistsNotifier.addPlaylist(
                Playlist(
                  id: id,
                  name: newPlaylist.name,
                  description: newPlaylist.description,
                  imagePath: newPlaylist.imagePath,
                  tracks: newPlaylist.tracks,
                )
              );
              setState(() {
                _isBeingEdited = false;
                _isNew = false;
                _curentlyEditedPlaylist = null;
              });
            },
            onEdit: (Playlist editedPlaylist) {
              setState(() {
                _curentlyEditedPlaylist = editedPlaylist;
              });
              final playlistRepo = getPlaylistRepository();
              playlistRepo.updatePlaylist(editedPlaylist);
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
