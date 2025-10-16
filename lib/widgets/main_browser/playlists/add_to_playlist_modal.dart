import 'package:flutter/material.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/selected_playlists_provider.dart';
import 'package:music_player/providers/selected_tracks_provider.dart';
import 'package:music_player/providers/utils.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_item_list.dart';

void addToPlaylistsModal(
  BuildContext context,
  List<Track> tracks,
  List<Playlist> playlists,
  PlaylistNotifier playlistNotifier,
  SelectedPlaylistNotifier selectedPlaylistsNotifier,
  SelectedTracksNotifier selectedTracksNotifier,
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
                if (selectedPlaylistsNotifier.getPlaylistIds().contains(playlist.id)) {
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
              if (selectedTracksNotifier.getTrackIds().length == 1) {
                selectedTracksNotifier.clear();
              }
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              handleTracksAddedToPlaylist(tracks, playlists, playlistNotifier, selectedPlaylistsNotifier, selectedTracksNotifier);
              Navigator.of(context).pop();
            },
            child: const Text('Add')
          ),
        ],
      );
    },
  );
}
