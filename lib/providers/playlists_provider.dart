import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';


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
        break;
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

  void removePlaylist(Playlist playlist) {
    state = state.where((e) => e.id != playlist.id).toList();
  }

  void addTrack(Playlist playlist, Track track) {
    final foundPlaylist = state.firstWhere((e) => e.id == playlist.id);
    if (foundPlaylist.tracks.indexWhere((e) => e.id == track.id) != -1) {
      return;
    }
    foundPlaylist.tracks.add(track);
    updatePlaylist(foundPlaylist);
  }

  void removeTrack(Playlist playlist, Track track) {
    final foundPlaylist = state.firstWhere((e) => e.id == playlist.id);
    foundPlaylist.tracks.removeWhere((t) => t.id == track.id);
    updatePlaylist(foundPlaylist);
  }
}
