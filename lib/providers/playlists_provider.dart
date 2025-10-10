import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/playlist.dart';


final playlistsProvider = NotifierProvider<PlaylistNotifier, List<Playlist>>(
  () => PlaylistNotifier(),
);

class PlaylistNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() => [];

  void setTracks(List<Playlist> playlists) {
    state = playlists;
  }
}
