import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';


final playlistsProvider = NotifierProvider<PlaylistNotifier, List<Playlist>>(
  () => PlaylistNotifier(),
);

class PlaylistNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() => [];

  void setPlaylists(List<Playlist> playlists) {
    state = playlists;
  }

  void updatePlaylist(Playlist playlist) {
    for (final (index, e) in state.indexed) {
      if (e.id == playlist.id) {
        state[index] = playlist;
      }
    }
    state = state.toList();
  }

  void addPlaylist(Playlist playlist) {
    state = [
      ...state,
      playlist,
    ];
  }

  void addTrack(Playlist playlist, Track track) {
    playlist.tracks.add(track);
    updatePlaylist(playlist);
  }

  void removeTrack(Playlist playlist, Track track) {
    playlist.tracks.removeWhere((t) => t.id == track.id);
    updatePlaylist(playlist);
  }
}
