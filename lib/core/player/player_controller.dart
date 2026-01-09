import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/core/repositories/statistics/factory.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/models/track_statistics.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/core/utils/sort_utils.dart';

class PlayerController {
  static final PlayerController _instance = PlayerController._();
  static PlayerController get instance => _instance;

  final _updateController = StreamController<void>.broadcast();
  Stream<void> get onUpdate => _updateController.stream;

  void notifyListeners() {
    _updateController.add(null);
  }

  String? currentTrackId;
  String? currentPlaylistId;
  double speed = 1;
  List<String> trackQueueIds = [];
  List<String> shuffledTrackQueueIds = [];
  PlayerState state = PlayerState.stopped;
  LoopMode loopMode = LoopMode.infinite;
  ShuffleMode shuffleMode = ShuffleMode.random;
  TrackQueueDisplayMode trackQueueDisplayMode = TrackQueueDisplayMode.image;
  PlayerBackend? playerBackend;
  Duration lastTrackDuration = Duration.zero;
  double volume = 1.0;
  List<double> equalizerGains = [];
  Map<String, Track> tracks = {};

  Track? lastLoadedTrack;
  DateTime? sessionStartTime;
  DateTime? lastPlayStartTime;

  PlayerController._();

  static Future<void> initFromLastState(
    LastPlayerControllerState lastState,
  ) async {
    final pc = instance;
    pc.currentTrackId = lastState.currentTrackId;
    pc.currentPlaylistId = lastState.currentPlaylistId;
    pc.speed = lastState.speed;
    pc.trackQueueIds = lastState.trackQueueIds;
    pc.shuffledTrackQueueIds = lastState.shuffledTrackQueueIds;
    pc.state = PlayerState.stopped;
    pc.loopMode = lastState.loopMode;
    pc.shuffleMode = lastState.shuffleMode;
    pc.trackQueueDisplayMode = lastState.trackQueueDisplayMode;
    pc.lastTrackDuration = Duration.zero;
    pc.playerBackend = await getPlayerBackend();
    pc.sessionStartTime = DateTime.now();
    pc.lastPlayStartTime = null;
    pc.volume = lastState.volume;
    pc.equalizerGains = lastState.equalizerGains;
    pc.tracks = {};
    pc.notifyListeners();
  }

  PlayerController._internal({
    required this.currentTrackId,
    required this.currentPlaylistId,
    required this.speed,
    required this.trackQueueIds,
    required this.shuffledTrackQueueIds,
    required this.state,
    required this.loopMode,
    required this.shuffleMode,
    required this.trackQueueDisplayMode,
    required this.playerBackend,
    required this.lastTrackDuration,
    required this.sessionStartTime,
    required this.lastPlayStartTime,
    required this.volume,
    required this.equalizerGains,
    required this.tracks,
  });

  Future<void> play() async {
    lastPlayStartTime = DateTime.now();
    if (playerBackend != null) {
      try {
        if (lastLoadedTrack == null) {
          final trackIndex = _getCurrentTrackIndex();
          if (trackIndex != -1) {
            await _setCurrentTrackFromIndex(trackIndex);
          }
        }
        state = PlayerState.playing;
        await playerBackend!.play();
      } catch (e) {
        log("Couldn't play track", error: e);
      }
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await updatePlaybackStatistics();
    state = PlayerState.paused;
    if (playerBackend != null) {
      await playerBackend!.pause();
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await updatePlaybackStatistics();
    state = PlayerState.stopped;
    if (playerBackend != null) {
      await playerBackend!.seek(Duration.zero);
      await playerBackend!.stop();
    }
    notifyListeners();
  }

  int _getCurrentTrackIndex() {
    return shuffledTrackQueueIds.indexWhere((e) => e == currentTrackId);
  }

  Future<void> _setCurrentTrackFromIndex(int index) async {
    if (shuffledTrackQueueIds.isEmpty) {
      return;
    }
    final nextTrackId = shuffledTrackQueueIds[index];
    final nextTrack = tracks[nextTrackId];
    if (nextTrack != null) {
      await setCurrentTrack(nextTrack);
    }
  }

  Future<void> _trackSkipAndCompletionEvents(bool forceNext) async {
    if (currentTrackId != null) {
      final trackSkippedManually = forceNext;
      if (trackSkippedManually) {
        await _trackSkipEvent(currentTrackId!);
      }
      final trackSkippedNaturally = !forceNext;
      if (trackSkippedNaturally) {
        await _trackCompletionEvent(currentTrackId!);
      }
    }
  }

  Future<void> next(bool forceNext) async {
    await _trackSkipAndCompletionEvents(forceNext);
    await stop();
    int currentTrackIndex = _getCurrentTrackIndex();
    if (currentTrackIndex <= -1) {
      currentTrackIndex = 0;
    }

    if (forceNext || loopMode == LoopMode.infinite) {
      currentTrackIndex++;
      if (currentTrackIndex >= shuffledTrackQueueIds.length) {
        currentTrackIndex = 0;
      }
    } else {
      if (loopMode == LoopMode.startToEnd) {
        if (currentTrackIndex < shuffledTrackQueueIds.length - 1) {
          currentTrackIndex++;
        } else {
          await seek(Duration.zero);
          return;
        }
      }
    }
    await _setCurrentTrackFromIndex(currentTrackIndex);
    await play();
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<void> prev() async {
    if (currentTrackId != null) {
      await _trackSkipEvent(currentTrackId!);
    }
    int currentTrackIndex = _getCurrentTrackIndex();

    await stop();
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
    } else {
      currentTrackIndex = 0;
      if (shuffledTrackQueueIds.isNotEmpty &&
          (loopMode == LoopMode.infinite || loopMode == LoopMode.startToEnd)) {
        currentTrackIndex = shuffledTrackQueueIds.length - 1;
      }
    }
    await _setCurrentTrackFromIndex(currentTrackIndex);
    await play();
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<void> shuffleTrackQueue() async {
    final shuffleHandler = {
      ShuffleMode.sequential: () async {
        shuffledTrackQueueIds = List.from(trackQueueIds);
      },
      ShuffleMode.random: () async {
        shuffledTrackQueueIds = List.from(trackQueueIds);
        shuffledTrackQueueIds.shuffle();
      },
      ShuffleMode.randomBasedOnHistory: () async {
        final allStats = await _getAllTrackStatistics();
        shuffledTrackQueueIds = _weightedShuffle(trackQueueIds, allStats);
      },
    };
    final handler = shuffleHandler[shuffleMode]!;
    await handler();

    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  List<String> _weightedShuffle(
    List<String> ids,
    Map<String, TrackStatistics> allStats,
  ) {
    if (ids.isEmpty) return [];
    final random = Random();
    final items = List.from(ids);

    // Create a map of weights for quick lookup
    final weights = <String, double>{};
    for (final id in ids) {
      final stats = allStats[id];
      if (stats == null) {
        weights[id] = 1.0; // Default weight for tracks with no stats
      } else {
        // Higher plays and completions increase weight
        // More skips decrease weight significantly
        final playWeight = stats.timesPlayed * 0.5;
        final completionWeight = stats.completionCount * 1.5;
        final skipPenalty = stats.timesSkipped * 2.0;
        weights[id] =
            (playWeight + completionWeight + 1.0) / (skipPenalty + 1.0);
      }
    }

    // Weighted Random Sampling (A-Res)
    // For each item, calculate a priority: r^(1/w) where r ~ U(0,1)
    // Sorting by priority gives a weighted shuffle
    final priorities = <String, double>{};
    for (final id in items) {
      final weight = weights[id] ?? 1.0;
      final r = random.nextDouble();
      // Using r^(1/weight) for weighted random sampling.
      priorities[id] = pow(r, 1.0 / weight).toDouble();
    }

    items.sort((a, b) => priorities[b]!.compareTo(priorities[a]!));
    return List<String>.from(items);
  }

  Future<void> seek(Duration position) async {
    if (playerBackend != null && currentTrackId != null) {
      await playerBackend!.seek(position);
    }
    notifyListeners();
  }

  Future<void> setPlayerBackend(PlayerBackend playerBackend) async {
    await stop();
    this.playerBackend = playerBackend;
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<void> setCurrentTrack(Track track) async {
    if (playerBackend == null) {
      return;
    }
    await stop();
    await _trackPlayEvent(track.id);
    currentTrackId = track.id;
    // Most likely the user clicked on a track in the "all tracks" list and not a playlist
    if (_getCurrentTrackIndex() <= -1) {
      final allTrackIds = tracks.values.map((e) => e.id).toList();
      trackQueueIds = allTrackIds;
      shuffledTrackQueueIds = allTrackIds;
      currentPlaylistId = null;
      await shuffleTrackQueue();
    }
    lastTrackDuration = Duration.zero;
    try {
      lastTrackDuration = await playerBackend!.setTrack(track);
      lastLoadedTrack = track;
    } catch (e) {
      log("Couldn't set the current track", error: e);
    }
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  PlayerController clone() {
    return PlayerController._internal(
      currentTrackId: currentTrackId,
      currentPlaylistId: currentPlaylistId,
      speed: speed,
      trackQueueIds: List.from(trackQueueIds),
      shuffledTrackQueueIds: List.from(shuffledTrackQueueIds),
      state: state,
      loopMode: loopMode,
      shuffleMode: shuffleMode,
      trackQueueDisplayMode: trackQueueDisplayMode,
      playerBackend: playerBackend,
      lastTrackDuration: lastTrackDuration,
      sessionStartTime: sessionStartTime,
      lastPlayStartTime: lastPlayStartTime,
      volume: volume,
      equalizerGains: List.from(equalizerGains),
      tracks: Map.from(tracks),
    );
  }

  bool hasTrackFinishedPlaying() {
    if (playerBackend == null) return true;
    return playerBackend!.hasTrackFinishedPlaying();
  }

  Future<Duration> getCurrentPosition() async {
    if (playerBackend != null) {
      try {
        return await playerBackend!.getCurrentPosition();
      } catch (e) {
        log("Couldn't get current track position", error: e);
      }
    }
    return Duration.zero;
  }

  Duration getCurrentTrackDuration() {
    return lastTrackDuration;
  }

  Future<void> handleTracksAddedToPlaylist(
    List<Map<String, String>> playlistTrackMapping,
  ) async {
    for (final row in playlistTrackMapping) {
      final playlistId = row["playlist_id"] ?? "";
      if (playlistId != currentPlaylistId) {
        continue;
      }
      final trackId = row["track_id"];
      if (trackId != null && !trackQueueIds.contains(trackId)) {
        trackQueueIds.add(trackId);
        shuffledTrackQueueIds.add(trackId);
      }
    }
    notifyListeners();

    await handlePersistPlayerControllerState(this);
  }

  Future<void> handleTracksRemovedFromPlaylist(
    Playlist playlist,
    List<String> trackIds,
  ) async {
    if (playlist.id != currentPlaylistId) {
      return;
    }
    trackQueueIds.removeWhere((e) => trackIds.contains(e));
    shuffledTrackQueueIds.removeWhere((e) => trackIds.contains(e));
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<void> setPlaylist(Playlist playlist) async {
    await reloadPlaylist(playlist);
    notifyListeners();
  }

  Future<void> reloadPlaylist(Playlist playlist) async {
    currentPlaylistId = playlist.id;

    final allTrackStatistics = await _getAllTrackStatistics();
    // Get sorted track IDs based on playlist's sort mode
    final sortedTracks = sortTracks(
      playlist.trackIds.map((e) => tracks[e]).whereType<Track>().toList(),
      playlist.sortMode,
      allTrackStatistics,
    );
    trackQueueIds = sortedTracks.map((e) => e.id).toList();

    shuffledTrackQueueIds = trackQueueIds;
    await shuffleTrackQueue();
    notifyListeners();
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    if (playerBackend != null) {
      await playerBackend!.setSpeed(speed);
    }
    await handlePersistPlayerControllerState(this);
    notifyListeners();
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
    notifyListeners();
    return loopMode;
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    final shuffleModeMap = {
      ShuffleMode.sequential: ShuffleMode.random,
      ShuffleMode.random: ShuffleMode.randomBasedOnHistory,
      ShuffleMode.randomBasedOnHistory: ShuffleMode.sequential,
    };
    shuffleMode = shuffleModeMap[shuffleMode]!;
    await shuffleTrackQueue();
    notifyListeners();
    return shuffleMode;
  }

  Future<void> handleNextAutomatically() async {
    if (state != PlayerState.playing) {
      return;
    }
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
    notifyListeners();
  }

  Track? getPreviousTrack() {
    if (shuffledTrackQueueIds.length <= 1) {
      return null;
    }

    String? prevTrackId;
    int currentTrackIndex = _getCurrentTrackIndex();
    if (loopMode == LoopMode.infinite) {
      if (currentTrackIndex == 0) {
        prevTrackId = shuffledTrackQueueIds.last;
      } else {
        if (currentTrackIndex >= 0 &&
            shuffledTrackQueueIds.length - 1 >= currentTrackIndex) {
          prevTrackId = shuffledTrackQueueIds[currentTrackIndex];
        }
      }
    } else if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex > 0 &&
          shuffledTrackQueueIds.length - 1 >= currentTrackIndex) {
        prevTrackId = shuffledTrackQueueIds[currentTrackIndex];
      }
    }

    return tracks[prevTrackId];
  }

  Track? getNextTrack() {
    if (shuffledTrackQueueIds.length <= 1) {
      return null;
    }

    String? nextTrackId;
    int currentTrackIndex = _getCurrentTrackIndex();
    if (loopMode == LoopMode.infinite) {
      if (currentTrackIndex == shuffledTrackQueueIds.length - 1) {
        nextTrackId = shuffledTrackQueueIds.first;
      } else {
        if (shuffledTrackQueueIds.length - 1 >= currentTrackIndex - 1) {
          nextTrackId = shuffledTrackQueueIds[currentTrackIndex + 1];
        }
      }
    } else if (loopMode == LoopMode.startToEnd) {
      if (currentTrackIndex < shuffledTrackQueueIds.length - 1) {
        if (shuffledTrackQueueIds.length - 1 >= currentTrackIndex - 1) {
          nextTrackId = shuffledTrackQueueIds[currentTrackIndex + 1];
        }
      }
    }

    return tracks[nextTrackId];
  }

  Future<void> setTrackQueueDisplayMode(TrackQueueDisplayMode mode) async {
    trackQueueDisplayMode = mode;
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<Map<String, TrackStatistics>> _getAllTrackStatistics() async {
    try {
      final statsRepo = getStatisticsRepository();

      final result = await statsRepo.getAllTrackStatistics();
      await statsRepo.close();
      return result;
    } catch (e) {
      log('Error getting track statistics', error: e);
    }
    return {};
  }

  Future<void> _trackPlayEvent(String trackId) async {
    try {
      final statsRepo = getStatisticsRepository();

      await statsRepo.incrementTrackPlayCount(trackId);
      await statsRepo.recordTrackPlayed(trackId);
      await statsRepo.close();
    } catch (e) {
      log('Error tracking play event', error: e);
    }
  }

  Future<void> _trackSkipEvent(String trackId) async {
    try {
      final statsRepo = getStatisticsRepository();
      await statsRepo.incrementTrackSkipCount(trackId);
      await statsRepo.incrementTotalSkips();
      await statsRepo.close();
    } catch (e) {
      log('Error tracking skip event', error: e);
    }
  }

  Future<void> _trackCompletionEvent(String trackId) async {
    try {
      final statsRepo = getStatisticsRepository();
      await statsRepo.incrementTrackCompletionCount(trackId);
      await statsRepo.close();
    } catch (e) {
      log('Error tracking completion event', error: e);
    }
  }

  Future<void> updatePlaybackStatistics() async {
    if (lastPlayStartTime == null ||
        currentTrackId == null ||
        state != PlayerState.playing) {
      return;
    }

    try {
      final now = DateTime.now();
      final playbackDuration = now.difference(lastPlayStartTime!);
      final statsRepo = getStatisticsRepository();
      await statsRepo.addPlaybackTime(playbackDuration);
      await statsRepo.addTrackPlaybackTime(currentTrackId!, playbackDuration);
      await statsRepo.close();
      lastPlayStartTime = now;
    } catch (e) {
      log('Error updating playback statistics', error: e);
    }
  }

  Future<void> handleTrackUpdated(String oldId, String newId) async {
    try {
      final statsRepo = getStatisticsRepository();
      await statsRepo.updateTrackId(oldId, newId);
      await statsRepo.close();
    } catch (e) {
      log('Error updating track ID in statistics', error: e);
    }

    currentTrackId = newId;
    final queueIdIndex = trackQueueIds.indexOf(oldId);
    if (queueIdIndex != -1) {
      trackQueueIds[queueIdIndex] = newId;
    }
    final shuffledIdIndex = shuffledTrackQueueIds.indexOf(oldId);
    if (shuffledIdIndex != -1) {
      shuffledTrackQueueIds[shuffledIdIndex] = newId;
    }
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    volume = value;
    if (playerBackend != null) {
      await playerBackend!.setVolume(volume);
    }
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<void> setEqualizerGains(List<double> gains) async {
    equalizerGains = gains;
    if (playerBackend != null) {
      await playerBackend!.setEqualizerGains(equalizerGains);
    }
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  Future<void> restoreDefaults() async {
    volume = 1.0;
    equalizerGains = List.filled(equalizerGains.length, 0.0);
    if (playerBackend != null) {
      await playerBackend!.setVolume(volume);
      await playerBackend!.setEqualizerGains(equalizerGains);
    }
    await handlePersistPlayerControllerState(this);
    notifyListeners();
  }

  void setTracks(List<Track> tracks) {
    Map<String, Track> newState = HashMap();
    for (final track in tracks) {
      newState[track.id] = track;
    }
    this.tracks = newState;
    notifyListeners();
  }

  List<Track> getTracks() {
    return tracks.values.toList();
  }

  void addTracks(List<Track> tracks) {
    Map<String, Track> newState = HashMap.from(this.tracks);
    for (final track in tracks) {
      newState[track.id] = track;
    }
    this.tracks = newState;
    notifyListeners();
  }

  void removeTracks(List<String> trackIds) {
    Map<String, Track> newState = HashMap.from(tracks);
    for (final id in trackIds) {
      newState.remove(id);
    }
    tracks = newState;
    notifyListeners();
  }
}
