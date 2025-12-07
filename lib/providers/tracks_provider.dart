import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';

final tracksProvider = NotifierProvider<TracksNotifier, Map<String, Track>>(
  () => TracksNotifier(),
);

class TracksNotifier extends Notifier<Map<String, Track>> {
  @override
  Map<String, Track> build() => HashMap();

  void setTracks(List<Track> tracks) {
    Map<String, Track> newState = HashMap();
    for (final track in tracks) {
      newState[track.id] = track;
    }
    state = newState;
  }

  List<Track> getTracks() {
    return state.values.toList();
  }

  void addTracks(List<Track> tracks) {
    Map<String, Track> newState = HashMap.from(state);
    for (final track in tracks) {
      newState[track.id] = track;
    }
    state = newState;
  }

  void removeTracks(List<String> trackIds) {
    Map<String, Track> newState = HashMap.from(state);
    for (final id in trackIds) {
      newState.remove(id);
    }
    state = newState;
  }
}
