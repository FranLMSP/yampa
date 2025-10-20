import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';


final tracksProvider = NotifierProvider<TracksNotifier, List<Track>>(
  () => TracksNotifier(),
);

class TracksNotifier extends Notifier<List<Track>> {
  @override
  List<Track> build() => [];

  void setTracks(List<Track> tracks) {
    state = tracks;
  }

  List<Track> getTracks() {
    return state;
  }

  void addTracks(List<Track> tracks) {
    state = [
      ...state,
      ...tracks,
    ];
  }
}
