import 'package:flutter/material.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_item_list.dart';

void addToPlaylistsModal(
  BuildContext context,
  List<String> selectedTrackIds,
  List<Playlist> playlists,
  PlaylistNotifier playlistNotifier,
  SelectedPlaylistNotifier selectedPlaylistsNotifier,
  SelectedTracksNotifier selectedTracksNotifier,
  PlayerControllerNotifier playerNotifier,
) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        scrollable: true,
        title: const Text('Playlists'),
        content: Column(
          children: [
            ...playlists
              .map(
                (playlist) => PlaylistItemList(
                  playlist: playlist,
                  onTap: (playlist) {
                    if (selectedPlaylistsNotifier.getPlaylistIds().contains(
                      playlist.id,
                    )) {
                      selectedPlaylistsNotifier.unselectPlaylist(playlist);
                    } else {
                      selectedPlaylistsNotifier.selectPlaylist(playlist);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                },
                child: const Text('New playlist'),
              ),
            ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              selectedPlaylistsNotifier.clear();
              if (selectedTracksNotifier.getTrackIds().length == 1) {
                selectedTracksNotifier.clear();
              }
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await handleTracksAddedToPlaylist(
                selectedTracksNotifier.getTrackIds(),
                playlists
                    .where(
                      (e) => selectedPlaylistsNotifier
                          .getPlaylistIds()
                          .contains(e.id),
                    )
                    .toList(),
                playlistNotifier,
                playerNotifier,
              );
              selectedTracksNotifier.clear();
              selectedPlaylistsNotifier.clear();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
