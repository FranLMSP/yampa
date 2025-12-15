import 'package:flutter/material.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';

void removePlaylistModal(
    BuildContext context,
    Playlist playlist,
    PlaylistNotifier playlistsNotifier,
    Function? onDeleteCallback,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete this playlist?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                handlePlaylistRemoved(playlist, playlistsNotifier);
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

