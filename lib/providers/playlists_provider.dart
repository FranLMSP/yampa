import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/core/player/enums.dart';

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
    state = [...state, playlist];
  }

  void removePlaylist(Playlist playlist) {
    state = state.where((e) => e.id != playlist.id).toList();
  }

  void addTrack(Playlist playlist, String trackId) {
    final foundPlaylist = state.firstWhere((e) => e.id == playlist.id);
    if (foundPlaylist.trackIds.indexWhere((e) => e == trackId) != -1) {
      return;
    }
    foundPlaylist.trackIds.add(trackId);
    updatePlaylist(foundPlaylist);
  }

  void removeTracks(Playlist playlist, List<String> trackIds) {
    final foundPlaylist = state.firstWhere((e) => e.id == playlist.id);
    foundPlaylist.trackIds.removeWhere((t) => trackIds.contains(t));
    updatePlaylist(foundPlaylist);
  }

  void setSortMode(Playlist playlist, SortMode sortMode) {
    final foundPlaylist = state.firstWhere((e) => e.id == playlist.id);
    final newPlaylist = Playlist(
      id: foundPlaylist.id,
      name: foundPlaylist.name,
      description: foundPlaylist.description,
      trackIds: foundPlaylist.trackIds,
      imagePath: foundPlaylist.imagePath,
      sortMode: sortMode,
    );
    updatePlaylist(newPlaylist);
  }
}
