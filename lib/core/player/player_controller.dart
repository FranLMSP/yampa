import 'package:music_player/core/track_players/interface.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/core/player/enums.dart';

class PlayerController {
  Track? currentTrack;
  int currentTrackIndex = 0;
  List<Track> trackQueue = [];
  PlayerState state = PlayerState.stopped;
  LoopMode loopMode = LoopMode.startToEnd;
  NextTrackMode nextTrackMode = NextTrackMode.randomBasedOnHistory;
  TrackPlayer? trackPlayer;

  PlayerController();
  PlayerController._clone({
    required this.currentTrack,
    required this.trackQueue,
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
    if (trackPlayer != null) {
      await trackPlayer!.seek(Duration.zero);
      await trackPlayer!.stop();
      state = PlayerState.stopped;
    }
  }

  Future<void> next() async {
    if (loopMode == LoopMode.infinite) {
      await stop();
    } else {
      await stop();
      if (trackQueue.isNotEmpty && currentTrackIndex < trackQueue.length) {
        currentTrackIndex++;
        currentTrack = trackQueue[currentTrackIndex];
        await play();
      }
    }
  }

  Future<void> prev() async {
    await stop();
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
      if (trackQueue.isNotEmpty) {
        currentTrack = trackQueue[currentTrackIndex];
      }
    } else {
      currentTrackIndex = 0;
    }
    await play();
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

  void toggleLoopMode() {
    final nextLoopModeMap = {
      LoopMode.singleTrack: LoopMode.infinite,
      LoopMode.infinite: LoopMode.startToEnd,
      LoopMode.startToEnd: LoopMode.none,
      LoopMode.none: LoopMode.singleTrack,
    };
    loopMode = nextLoopModeMap[loopMode]!;
  }

  Future<void> handleNextAutomatically() async {
    final nextHandlerMap = {
      LoopMode.singleTrack: () async {
        await stop();
        await play();
      },
      LoopMode.infinite: () async {
        await next();
      },
      LoopMode.startToEnd: () async {
        await next();
      },
      LoopMode.none: () async {
        await stop();
      },
    };
    final nextHandler = nextHandlerMap[loopMode]!;
    await nextHandler();
  }
}
