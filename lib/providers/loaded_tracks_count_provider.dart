import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart' as format_utils;


final loadedTracksCountProvider = NotifierProvider<LoadedTracksCountProviderNotifier, (int, int)>(
  () => LoadedTracksCountProviderNotifier(),
);

class LoadedTracksCountProviderNotifier extends Notifier<(int, int)> {
  @override
  (int, int) build() => (0, 0);

  void reset() {
    state = (0, 0);
  }

  void setTotalTracks(int totalTracks) {
    state = (state.$1, totalTracks);
  }

  void setLoadedTracks(int loadedTracks) {
    state = (loadedTracks, state.$2);
  }

  void incrementLoadedTrack() {
    state = (state.$1 + 1, state.$2);
  }

  bool isLoading() {
    if (state.$2 <= 0) {
      return false;
    }
    if (state.$1 >= state.$2) {
      return false;
    }
    return true;
  }

  double getPercentage() {
    return format_utils.getPercentage(state.$1.toDouble(), state.$2.toDouble());
  }
}
