import 'package:flutter/material.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_item_list.dart';

void addToPlaylistsModal(BuildContext context, List<Playlist> playlists) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        scrollable: true,
        title: const Text('Playlists'),
        content: Column(
          children: playlists.map(
            (playlist) => PlaylistItemList(playlist: playlist)
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Add')
          ),
        ],
      );
    },
  );
}