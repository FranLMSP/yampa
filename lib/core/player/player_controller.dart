import 'package:music_player/core/track_players/interface.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/core/player/enums.dart';

class PlayerController {
  Track? currentTrack;
  List<Track> trackQueue = [];
  Duration currentPosition = Duration.zero;
  PlayerState state = PlayerState.stopped;
  LoopMode loopMode = LoopMode.startToEnd;
  NextTrackMode nextTrackMode = NextTrackMode.randomBasedOnHistory;
  TrackPlayer? trackPlayer;

  PlayerController();
  PlayerController._clone({
    required this.currentTrack,
    required this.trackQueue,
    required this.currentPosition,
    required this.state,
    required this.loopMode,
    required this.nextTrackMode,
    required this.trackPlayer,
  });

  Future<void> play() async {
    if (state != PlayerState.playing && trackPlayer != null) {
      if (state == PlayerState.stopped && currentTrack != null) {
        await trackPlayer!.setTrack(currentTrack!);
      }
      await trackPlayer!.play();
      state = PlayerState.playing;
    }
  }

  Future<void> pause() async {
    if (state != PlayerState.paused && trackPlayer != null) {
      await trackPlayer!.pause();
      state = PlayerState.paused;
    }
  }

  Future<void> stop() async {
    if (state != PlayerState.stopped && trackPlayer != null) {
      await trackPlayer!.stop();
      currentPosition = Duration.zero;
      state = PlayerState.stopped;
    }
  }

  Future<void> next() async {
  }

  Future<void> prev() async {
  }

  void suffleTrackQueue() {
  }

  Future<void> seek(Duration position) async {
    if (trackPlayer != null && currentTrack != null) {
      await trackPlayer!.seek(position);
    }
  }

  void setTrackPlayer(TrackPlayer trackPlayer) {
    stop();
    this.trackPlayer = trackPlayer;
  }

  void setCurrentTrack(Track track) {
    currentTrack = track;
  }

  PlayerController clone() {
    return PlayerController._clone(
      currentTrack: currentTrack,
      trackQueue: List<Track>.from(trackQueue),
      currentPosition: currentPosition,
      state: state,
      loopMode: loopMode,
      nextTrackMode: nextTrackMode,
      trackPlayer: trackPlayer,
    );
  }

  Future<Duration> getCurrentPosition() async {
    if (trackPlayer != null) {
      return await trackPlayer!.getCurrentPosition();
    }
    return Duration.zero;
  }

  void setQueue(List<Track> tracks) {
    trackQueue = tracks;
  }
}
