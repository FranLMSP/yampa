import 'package:yampa/core/track_players/interface.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/utils.dart';

class PlayerController {
  Track? currentTrack;
  int currentTrackIndex = 0;
  double speed = 1;
  List<Track> trackQueue = []; // TODO change this to a list of IDs
  List<Track> shuffledTrackQueue = [];  // TODO change this to a list of IDs
  PlayerState state = PlayerState.stopped;
  LoopMode loopMode = LoopMode.infinite;
  ShuffleMode shuffleMode = ShuffleMode.sequential;
  TrackPlayer? trackPlayer;

  PlayerController();
  factory PlayerController.fromLastState(LastPlayerControllerState lastState, List<Track> tracks) {
    final existingTrackIds = tracks.map((e) => e.id).toList();
    return PlayerController._clone(
      currentTrack: lastState.currentTrackId != null && existingTrackIds.contains(lastState.currentTrackId) ? tracks.firstWhere((e) => e.id == lastState.currentTrackId) : null,
      currentTrackIndex: lastState.currentTrackIndex,
      speed: lastState.speed,
      trackQueue: tracks.where((e) => lastState.trackQueueIds.contains(e.id)).toList(), // TODO: optimize this, maybe with a map of tracks
      shuffledTrackQueue: tracks.where((e) => lastState.shuffledTrackQueueIds.contains(e.id)).toList(), // TODO: optimize this, maybe with a map of tracks
      state: PlayerState.stopped,
      loopMode: lastState.loopMode,
      shuffleMode: lastState.shuffleMode,
      trackPlayer: JustAudioProvider(), // TODO: store this in sqlite as well
    );
  }
  PlayerController._clone({
    required this.currentTrack,
    required this.currentTrackIndex,
    required this.speed,
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
      await setSpeed(speed);
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

  Future<void> next(bool forceNext) async {
    await stop();
    if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex < shuffledTrackQueue.length - 1) {
        currentTrackIndex++;
        currentTrack = shuffledTrackQueue[currentTrackIndex];
        await play();
      } else {
        await seek(Duration.zero);
      }
    } else if (loopMode == LoopMode.infinite || forceNext) {
      currentTrackIndex++;
      if (currentTrackIndex >= shuffledTrackQueue.length) {
        currentTrackIndex = 0;
      }
      if (shuffledTrackQueue.isNotEmpty) {
        currentTrack = shuffledTrackQueue[currentTrackIndex];
      }
      await play();
    }
    await handlePersistPlayerControllerState(this);
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
    await handlePersistPlayerControllerState(this);
  }

  Future<void> suffleTrackQueue() async {
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
    await handlePersistPlayerControllerState(this);
  }

  Future<void> seek(Duration position) async {
    if (trackPlayer != null && currentTrack != null) {
      await trackPlayer!.seek(position);
    }
  }

  Future<void> setTrackPlayer(TrackPlayer trackPlayer) async {
    await stop();
    this.trackPlayer = trackPlayer;
    await handlePersistPlayerControllerState(this);
  }

  Future<void> setCurrentTrack(Track track) async {
    currentTrack = track;
    if (shuffledTrackQueue.isNotEmpty) {
      currentTrackIndex = shuffledTrackQueue.indexWhere((e) => e.id == currentTrack?.id);
    }
    await handlePersistPlayerControllerState(this);
  }

  PlayerController clone() {
    return PlayerController._clone(
      currentTrack: currentTrack,
      currentTrackIndex: currentTrackIndex,
      speed: speed,
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

  Future<void> setQueue(List<Track> tracks) async {
    trackQueue = tracks;
    shuffledTrackQueue = tracks;
    await suffleTrackQueue();
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    if (trackPlayer != null) {
      await trackPlayer!.setSpeed(speed);
    }
    await handlePersistPlayerControllerState(this);
  }

  Future<void> toggleLoopMode() async {
    final nextLoopModeMap = {
      LoopMode.singleTrack: LoopMode.infinite,
      LoopMode.infinite: LoopMode.startToEnd,
      LoopMode.startToEnd: LoopMode.none,
      LoopMode.none: LoopMode.singleTrack,
    };
    loopMode = nextLoopModeMap[loopMode]!;
    await handlePersistPlayerControllerState(this);
  }

  Future<void> toggleShuffleMode() async {
    final shuffleModeMap = {
      ShuffleMode.sequential: ShuffleMode.random,
      ShuffleMode.random: ShuffleMode.randomBasedOnHistory,
      ShuffleMode.randomBasedOnHistory: ShuffleMode.sequential,
    };
    shuffleMode = shuffleModeMap[shuffleMode]!;
    await handlePersistPlayerControllerState(this);
  }

  Future<void> handleNextAutomatically() async {
    final nextHandlerMap = {
      LoopMode.singleTrack: () async {
        await stop();
        await play();
      },
      LoopMode.infinite: () async {
        await next(false);
      },
      LoopMode.startToEnd: () async {
        await next(false);
      },
      LoopMode.none: () async {
        await stop();
      },
    };
    final nextHandler = nextHandlerMap[loopMode]!;
    await nextHandler();
    await handlePersistPlayerControllerState(this);
  }
}
