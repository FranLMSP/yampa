import 'package:flutter/material.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';

void removePlaylistsModal(
  BuildContext context,
  List<Playlist> playlists,
  PlaylistNotifier playlistsNotifier,
  Function? onDeleteCallback,
) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: playlists.length == 1
            ? const Text('Delete this playlist?')
            : const Text('Delete these playlists?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              for (final playlist in playlists) {
                await handlePlaylistRemoved(playlist, playlistsNotifier);
              }
              Navigator.of(context).pop();
              if (onDeleteCallback != null) {
                onDeleteCallback();
              }
              // TODO: show snackbar with "undo" button
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
