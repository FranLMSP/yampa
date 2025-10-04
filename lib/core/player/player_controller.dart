import 'package:music_player/models/track.dart';
import 'package:music_player/core/player/player_state.dart';

class PlayerController {
  Track? currentTrack;
  Duration currentPosition = Duration.zero;
  PlayerState state = PlayerState.stopped;

  PlayerController();

  void play() {
    // TODO: uncomment this once we have a way to load a track
    // if (currentTrack != null) {
    //   state = PlayerState.playing;
    // }
    state = PlayerState.playing;
  }

  void pause() {
    // if (currentTrack != null && state != PlayerState.playing) {
    //   state = PlayerState.paused;
    // }
    state = PlayerState.paused;
  }

  void stop() {
    state = PlayerState.stopped;
  }

  void seek(Duration position) {
    // Implement seek logic
  }
}
