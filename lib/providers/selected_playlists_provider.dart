import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';


final selectedPlaylistsProvider = NotifierProvider<SelectedPlaylistNotifier, List<String>>(
  () => SelectedPlaylistNotifier(),
);

class SelectedPlaylistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void clear() {
    state = [];
  }

  void selectPlaylist(Playlist playlist) {
    state = [
      ...state,
      playlist.id,
    ];
  }

  void unselectPlaylist(Playlist playlist) {
    final stateCopy = state.toList();
    stateCopy.removeWhere((element) => element == playlist.id);
    state = stateCopy.toList();
  }

  List<String> getPlaylistIds() {
    return state.toList();
  }
}
