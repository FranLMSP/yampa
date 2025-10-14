import 'package:flutter/material.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/providers/selected_playlists_provider.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_item_list.dart';

void addToPlaylistsModal(
  BuildContext context,
  List<Playlist> playlists,
  SelectedPlaylistNotifier selectedPlaylistsNotifier,
) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        scrollable: true,
        title: const Text('Playlists'),
        content: Column(
          children: playlists.map(
            (playlist) => PlaylistItemList(
              playlist: playlist,
              onTap: (playlist) {
                if (selectedPlaylistsNotifier.getPlaylists().contains(playlist.id)) {
                  selectedPlaylistsNotifier.unselectPlaylist(playlist);
                } else {
                  selectedPlaylistsNotifier.selectPlaylist(playlist);
                }
              },
            )
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              selectedPlaylistsNotifier.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              // TODO: handle tracks added to playlist (add to notifiers, store in sqlite, etc)
              Navigator.of(context).pop();
            },
            child: const Text('Add')
          ),
        ],
      );
    },
  );
}