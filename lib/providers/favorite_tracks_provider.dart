import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';


final favoriteTracksProvider = NotifierProvider<FavoriteTracksNotifier, List<String>>(
  () => FavoriteTracksNotifier(),
);

class FavoriteTracksNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void selectTracks(List<Track> tracks) {
    state = [
      ...state,
      ...tracks.map((e) => e.id),
    ];
  }

  void unselectTracks(List<Track> tracks) {
    final ids = state;
    final removedTrackIds = tracks.map((e) => e.id).toList();
    ids.removeWhere((e) => removedTrackIds.contains(e));
    state = ids.toList();
  }
}
