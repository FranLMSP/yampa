import 'package:yampa/core/track_players/interface.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player/enums.dart';

class PlayerController {
  Track? currentTrack;
  int currentTrackIndex = 0;
  List<Track> trackQueue = [];
  List<Track> shuffledTrackQueue = [];
  PlayerState state = PlayerState.stopped;
  LoopMode loopMode = LoopMode.infinite;
  ShuffleMode shuffleMode = ShuffleMode.randomBasedOnHistory;
  TrackPlayer? trackPlayer;

  PlayerController();
  PlayerController._clone({
    required this.currentTrack,
    required this.currentTrackIndex,
    required this.trackQueue,
    required this.shuffledTrackQueue,
    required this.state,
    required this.loopMode,
    required this.shuffleMode,
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
    await stop();
    if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex < shuffledTrackQueue.length - 1) {
        currentTrackIndex++;
        currentTrack = shuffledTrackQueue[currentTrackIndex];
        await play();
      } else {
        await seek(Duration.zero);
      }
    } else if (loopMode == LoopMode.infinite) {
      currentTrackIndex++;
      if (currentTrackIndex >= shuffledTrackQueue.length) {
        currentTrackIndex = 0;
      }
      if (shuffledTrackQueue.isNotEmpty) {
        currentTrack = shuffledTrackQueue[currentTrackIndex];
      }
      await play();
    }
  }

  Future<void> prev() async {
    await stop();
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
      if (shuffledTrackQueue.isNotEmpty) {
        currentTrack = shuffledTrackQueue[currentTrackIndex];
      }
    } else {
      currentTrackIndex = 0;
    }
    await play();
  }

  void suffleTrackQueue() {
    final shuffleHandler = {
      ShuffleMode.sequential: () {
        shuffledTrackQueue = trackQueue;
      },
      ShuffleMode.random: () {
        shuffledTrackQueue = trackQueue;
        shuffledTrackQueue.shuffle();
      },
      ShuffleMode.randomBasedOnHistory: () {
        // TODO: implement this in the future after collecting statistics of each track
        shuffledTrackQueue = trackQueue;
        shuffledTrackQueue.shuffle();
      },
    };
    final handler = shuffleHandler[shuffleMode]!;
    handler();
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
    if (shuffledTrackQueue.isNotEmpty) {
      currentTrackIndex = shuffledTrackQueue.indexWhere((e) => e.id == currentTrack?.id);
    }
  }

  PlayerController clone() {
    return PlayerController._clone(
      currentTrack: currentTrack,
      currentTrackIndex: currentTrackIndex,
      trackQueue: List<Track>.from(trackQueue),
      shuffledTrackQueue: List<Track>.from(shuffledTrackQueue),
      state: state,
      loopMode: loopMode,
      shuffleMode: shuffleMode,
      trackPlayer: trackPlayer,
    );
  }

  bool hasTrackFinishedPlaying() {
    if (trackPlayer == null) return false;
    return trackPlayer!.hasTrackFinishedPlaying();
  }

  Future<Duration> getCurrentPosition() async {
    if (trackPlayer != null) {
      return await trackPlayer!.getCurrentPosition();
    }
    return Duration.zero;
  }

  void setQueue(List<Track> tracks) {
    trackQueue = tracks;
    shuffledTrackQueue = tracks;
    suffleTrackQueue();
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

  void toggleShuffleMode() {
    final shuffleModeMap = {
      ShuffleMode.sequential: ShuffleMode.random,
      ShuffleMode.random: ShuffleMode.randomBasedOnHistory,
      ShuffleMode.randomBasedOnHistory: ShuffleMode.sequential,
    };
    shuffleMode = shuffleModeMap[shuffleMode]!;
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
