import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/core/utils/sort_utils.dart';

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
  TrackQueueDisplayMode trackQueueDisplayMode = TrackQueueDisplayMode.image;
  PlayerBackend? playerBackend;

  PlayerController();
  static Future<PlayerController> fromLastState(
    LastPlayerControllerState lastState,
  ) async {
    return PlayerController._clone(
      currentTrackId: lastState.currentTrackId,
      currentPlaylistId: lastState.currentPlaylistId,
      currentTrackIndex: lastState.currentTrackIndex >= 0 ? lastState.currentTrackIndex : 0,
      speed: lastState.speed,
      trackQueueIds: lastState.trackQueueIds,
      shuffledTrackQueueIds: lastState.shuffledTrackQueueIds,
      state: PlayerState.stopped,
      loopMode: lastState.loopMode,
      shuffleMode: lastState.shuffleMode,
      trackQueueDisplayMode: lastState.trackQueueDisplayMode,
      playerBackend:
          await getPlayerBackend(), // TODO: store this in sqlite as well
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
    required this.trackQueueDisplayMode,
    required this.playerBackend,
  });

  Future<void> play() async {
    state = PlayerState.playing;
    if (playerBackend != null) {
      await playerBackend!.play();
    }
  }

  Future<void> pause() async {
    state = PlayerState.paused;
    if (playerBackend != null) {
      await playerBackend!.pause();
    }
  }

  Future<void> stop() async {
    state = PlayerState.stopped;
    if (playerBackend != null) {
      await playerBackend!.seek(Duration.zero);
      await playerBackend!.stop();
    }
  }

  Future<void> _updateCurrentTrackFromIndex(Map<String, Track> tracks) async {
    if (shuffledTrackQueueIds.isEmpty) {
      return;
    }
    final nextTrackId = shuffledTrackQueueIds[currentTrackIndex];
    final nextTrack = tracks[nextTrackId];
    if (nextTrack != null) {
      await setCurrentTrack(nextTrack);
    }
  }

  Future<void> next(bool forceNext, Map<String, Track> tracks) async {
    await stop();
    if (currentTrackIndex <= -1) {
      currentTrackIndex = 0;
    }
    if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex < shuffledTrackQueueIds.length - 1) {
        currentTrackIndex++;
        await _updateCurrentTrackFromIndex(tracks);
        await play();
      } else {
        await seek(Duration.zero);
      }
    } else if (loopMode == LoopMode.infinite || forceNext) {
      currentTrackIndex++;
      if (shuffledTrackQueueIds.isNotEmpty && currentTrackIndex >= shuffledTrackQueueIds.length) {
        currentTrackIndex = 0;
      }
      await _updateCurrentTrackFromIndex(tracks);
      await play();
    } else if (loopMode == LoopMode.singleTrack) {
      await play();
    }
    await handlePersistPlayerControllerState(this);
  }

  Future<void> prev(Map<String, Track> tracks) async {
    await stop();
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
    } else {
      currentTrackIndex = 0;
      if (shuffledTrackQueueIds.isNotEmpty && (loopMode == LoopMode.infinite || loopMode == LoopMode.startToEnd)) {
        currentTrackIndex = shuffledTrackQueueIds.length - 1;
      }
    }
    await _updateCurrentTrackFromIndex(tracks);
    await play();
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

  Future<void> setCurrentTrack(Track track) async {
    if (playerBackend == null) {
      return;
    }
    await stop();
    await playerBackend?.setTrack(track);
    currentTrackId = track.id;
    if (shuffledTrackQueueIds.isNotEmpty) {
      currentTrackIndex = shuffledTrackQueueIds.indexWhere(
        (e) => e == currentTrackId,
      );
      if (currentTrackIndex <= -1) {
        currentTrackIndex = 0;
      }
    }
    await handlePersistPlayerControllerState(this);
  }

  PlayerController clone() {
    return PlayerController._clone(
      currentTrackId: currentTrackId,
      currentPlaylistId: currentPlaylistId,
      currentTrackIndex: currentTrackIndex,
      speed: speed,
      trackQueueIds: List.from(trackQueueIds),
      shuffledTrackQueueIds: List.from(shuffledTrackQueueIds),
      state: state,
      loopMode: loopMode,
      shuffleMode: shuffleMode,
      trackQueueDisplayMode: trackQueueDisplayMode,
      playerBackend: playerBackend,
    );
  }

  bool hasTrackFinishedPlaying() {
    if (playerBackend == null) return true;
    return playerBackend!.hasTrackFinishedPlaying();
  }

  Future<Duration> getCurrentPosition() async {
    if (playerBackend != null) {
      return await playerBackend!.getCurrentPosition();
    }
    return Duration.zero;
  }

  Duration getCurrentTrackDuration() {
    if (playerBackend != null) {
      return playerBackend!.getCurrentTrackDuration();
    }
    return Duration.zero;
  }

  Future<void> handleTracksAddedToPlaylist(List<Map<String, String>> playlistTrackMapping) async {
    for (final row in playlistTrackMapping) {
      final playlistId = row["playlist_id"] ?? "";
      if (playlistId != currentPlaylistId) {
        continue;
      }
      final trackId = row["track_id"];
      if (trackId != null) {
        trackQueueIds.add(trackId);
        shuffledTrackQueueIds.add(trackId);
      }
    }

    await handlePersistPlayerControllerState(this);
  }

  Future<void> setPlaylist(Playlist playlist, Map<String, Track> tracks) async {
    if (currentPlaylistId == playlist.id) {
      return;
    }
    currentPlaylistId = playlist.id;

    // Get sorted track IDs based on playlist's sort mode
    final sortedTracks = playlist.trackIds.map((e) => tracks[e]).whereType<Track>().toList();
    sortTracks(sortedTracks, playlist.sortMode);
    trackQueueIds = sortedTracks.map((e) => e.id).toList();

    shuffledTrackQueueIds = trackQueueIds;
    await suffleTrackQueue();
  }

  Future<void> reloadPlaylist(Playlist playlist, Map<String, Track> tracks) async {
    if (currentPlaylistId != playlist.id) {
      return;
    }

    // Get sorted track IDs based on playlist's sort mode
    final sortedTracks = playlist.trackIds.map((e) => tracks[e]).whereType<Track>().toList();
    sortTracks(sortedTracks, playlist.sortMode);
    trackQueueIds = sortedTracks.map((e) => e.id).toList();

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

  Future<LoopMode> toggleLoopMode() async {
    final nextLoopModeMap = {
      LoopMode.singleTrack: LoopMode.infinite,
      LoopMode.infinite: LoopMode.startToEnd,
      LoopMode.startToEnd: LoopMode.none,
      LoopMode.none: LoopMode.singleTrack,
    };
    loopMode = nextLoopModeMap[loopMode]!;
    await handlePersistPlayerControllerState(this);
    return loopMode;
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    final shuffleModeMap = {
      ShuffleMode.sequential: ShuffleMode.random,
      ShuffleMode.random: ShuffleMode.randomBasedOnHistory,
      ShuffleMode.randomBasedOnHistory: ShuffleMode.sequential,
    };
    shuffleMode = shuffleModeMap[shuffleMode]!;
    await handlePersistPlayerControllerState(this);
    return shuffleMode;
  }

  Future<void> handleNextAutomatically(Map<String, Track> tracks) async {
    if (state != PlayerState.playing) {
      return;
    }
    final nextHandlerMap = {
      LoopMode.singleTrack: () async {
        await stop();
        await play();
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

  Track? getPreviousTrack(Map<String, Track> tracks) {
    if (shuffledTrackQueueIds.length <= 1) {
      return null;
    }

    String? prevTrackId;
    if (loopMode == LoopMode.infinite) {
      if (currentTrackIndex == 0) {
        prevTrackId = shuffledTrackQueueIds.last;
      } else {
        prevTrackId = shuffledTrackQueueIds[currentTrackIndex - 1];
      }
    } else if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex > 0) {
        prevTrackId = shuffledTrackQueueIds[currentTrackIndex - 1];
      }
    }

    return tracks[prevTrackId];
  }

  Track? getNextTrack(Map<String, Track> tracks) {
    if (shuffledTrackQueueIds.length <= 1) {
      return null;
    }

    String? nextTrackId;
    if (loopMode == LoopMode.infinite) {
      if (currentTrackIndex == shuffledTrackQueueIds.length - 1) {
        nextTrackId = shuffledTrackQueueIds.first;
      } else {
        nextTrackId = shuffledTrackQueueIds[currentTrackIndex + 1];
      }
    } else if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex < shuffledTrackQueueIds.length - 1) {
        nextTrackId = shuffledTrackQueueIds[currentTrackIndex + 1];
      }
    }

    return tracks[nextTrackId];
  }

  Future<void> setTrackQueueDisplayMode(TrackQueueDisplayMode mode) async {
    trackQueueDisplayMode = mode;
    await handlePersistPlayerControllerState(this);
  }
}
