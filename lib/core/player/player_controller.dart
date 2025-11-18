import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/utils.dart';

class PlayerController {
  // TODO: consider holding all the tracks here instead of a separate provider
  String? currentTrackId;
  String? currentPlaylistId;
  int currentTrackIndex = 0;
  double speed = 1;
  List<String> trackQueueIds = [];
  List<String> shuffledTrackQueueIds = [];
  PlayerState state = PlayerState.stopped;
  LoopMode loopMode = LoopMode.infinite;
  ShuffleMode shuffleMode = ShuffleMode.sequential;
  PlayerBackend? playerBackend;

  PlayerController();
  factory PlayerController.fromLastState(LastPlayerControllerState lastState, List<Track> tracks) {
    return PlayerController._clone(
      currentTrackId: lastState.currentTrackId,
      currentPlaylistId: lastState.currentPlaylistId,
      currentTrackIndex: lastState.currentTrackIndex,
      speed: lastState.speed,
      trackQueueIds: lastState.trackQueueIds,
      shuffledTrackQueueIds: lastState.shuffledTrackQueueIds,
      state: PlayerState.stopped,
      loopMode: lastState.loopMode,
      shuffleMode: lastState.shuffleMode,
      playerBackend: getPlayerBackend(), // TODO: store this in sqlite as well
    );
  }

  PlayerController._clone({
    required this.currentTrackId,
    required this.currentPlaylistId,
    required this.currentTrackIndex,
    required this.speed,
    required this.trackQueueIds,
    required this.shuffledTrackQueueIds,
    required this.state,
    required this.loopMode,
    required this.shuffleMode,
    required this.playerBackend,
  });

  Future<void> play(List<Track> tracks) async {
    if (tracks.indexWhere((e) => e.id == currentTrackId) == -1) {
      return;
    }
    if (state != PlayerState.playing && playerBackend != null) {
      if (state == PlayerState.stopped && currentTrackId != null) {
        await playerBackend!.setTrack(tracks.firstWhere((e) => e.id == currentTrackId));
      }
      await setSpeed(speed);
      await playerBackend!.play();
      state = PlayerState.playing;
    }
  }

  Future<void> pause() async {
    if (state != PlayerState.paused && playerBackend != null) {
      await playerBackend!.pause();
      state = PlayerState.paused;
    }
  }

  Future<void> stop() async {
    if (playerBackend != null) {
      await playerBackend!.seek(Duration.zero);
      await playerBackend!.stop();
      state = PlayerState.stopped;
    }
  }

  Future<void> next(bool forceNext, List<Track> tracks) async {
    await stop();
    if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex < shuffledTrackQueueIds.length - 1) {
        currentTrackIndex++;
        await setCurrentTrack(shuffledTrackQueueIds[currentTrackIndex]);
        await play(tracks);
      } else {
        await seek(Duration.zero);
      }
    } else if (loopMode == LoopMode.infinite || forceNext) {
      currentTrackIndex++;
      if (currentTrackIndex >= shuffledTrackQueueIds.length) {
        currentTrackIndex = 0;
      }
      if (shuffledTrackQueueIds.isNotEmpty) {
        await setCurrentTrack(shuffledTrackQueueIds[currentTrackIndex]);
      }
      await play(tracks);
    }
    await handlePersistPlayerControllerState(this);
  }

  Future<void> prev(List<Track> tracks) async {
    await stop();
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
      if (shuffledTrackQueueIds.isNotEmpty) {
        await setCurrentTrack(shuffledTrackQueueIds[currentTrackIndex]);
      }
    } else {
      currentTrackIndex = 0;
    }
    await play(tracks);
    await handlePersistPlayerControllerState(this);
  }

  Future<void> suffleTrackQueue() async {
    final shuffleHandler = {
      ShuffleMode.sequential: () {
        shuffledTrackQueueIds = trackQueueIds;
      },
      ShuffleMode.random: () {
        shuffledTrackQueueIds = trackQueueIds;
        shuffledTrackQueueIds.shuffle();
      },
      ShuffleMode.randomBasedOnHistory: () {
        // TODO: implement this in the future after collecting statistics of each track
        shuffledTrackQueueIds = trackQueueIds;
        shuffledTrackQueueIds.shuffle();
      },
    };
    final handler = shuffleHandler[shuffleMode]!;
    handler();
    await handlePersistPlayerControllerState(this);
  }

  Future<void> seek(Duration position) async {
    if (playerBackend != null && currentTrackId != null) {
      await playerBackend!.seek(position);
    }
  }

  Future<void> setTrackPlayer(PlayerBackend playerBackend) async {
    await stop();
    this.playerBackend = playerBackend;
    await handlePersistPlayerControllerState(this);
  }

  Future<void> setCurrentTrack(String trackId) async {
    currentTrackId = trackId;
    if (shuffledTrackQueueIds.isNotEmpty) {
      currentTrackIndex = shuffledTrackQueueIds.indexWhere((e) => e == currentTrackId);
    }
    await handlePersistPlayerControllerState(this);
  }

  PlayerController clone() {
    return PlayerController._clone(
      currentTrackId: currentTrackId,
      currentPlaylistId: currentPlaylistId,
      currentTrackIndex: currentTrackIndex,
      speed: speed,
      trackQueueIds: trackQueueIds,
      shuffledTrackQueueIds: trackQueueIds,
      state: state,
      loopMode: loopMode,
      shuffleMode: shuffleMode,
      playerBackend: playerBackend,
    );
  }

  bool hasTrackFinishedPlaying() {
    if (playerBackend == null) return false;
    return playerBackend!.hasTrackFinishedPlaying();
  }

  Future<Duration> getCurrentPosition() async {
    if (playerBackend != null) {
      return await playerBackend!.getCurrentPosition();
    }
    return Duration.zero;
  }

  Future<void> setPlaylist(Playlist playlist) async {
    currentPlaylistId = playlist.id;
    trackQueueIds = playlist.trackIds;
    shuffledTrackQueueIds = trackQueueIds;
    await suffleTrackQueue();
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    if (playerBackend != null) {
      await playerBackend!.setSpeed(speed);
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

  Future<void> handleNextAutomatically(List<Track> tracks) async {
    final nextHandlerMap = {
      LoopMode.singleTrack: () async {
        await stop();
        await play(tracks);
      },
      LoopMode.infinite: () async {
        await next(false, tracks);
      },
      LoopMode.startToEnd: () async {
        await next(false, tracks);
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
