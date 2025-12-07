import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';

final selectedTracksProvider =
    NotifierProvider<SelectedTracksNotifier, List<String>>(
      () => SelectedTracksNotifier(),
    );

class SelectedTracksNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void clear() {
    state = [];
  }

  void selectTrack(Track track) {
    state = [...state, track.id];
  }

  void unselectTrack(Track track) {
    final stateCopy = state.toList();
    stateCopy.removeWhere((element) => element == track.id);
    state = stateCopy.toList();
  }

  List<String> getTrackIds() {
    return state.toList();
  }
}
