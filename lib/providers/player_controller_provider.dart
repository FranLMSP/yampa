import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';

final playerControllerProvider =
    AsyncNotifierProvider<PlayerControllerNotifier, PlayerController>(
      PlayerControllerNotifier.new,
    );

class PlayerControllerNotifier extends AsyncNotifier<PlayerController> {
  @override
  Future<PlayerController> build() async => PlayerController();

  Future<void> play() async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    optimistic.state = PlayerState.playing;
    state = AsyncData(optimistic);

    final result = await AsyncValue.guard(() async {
      await optimistic.play();
      return optimistic.clone();
    });
    state = result;
  }

  Future<void> pause() async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    optimistic.state = PlayerState.paused;
    state = AsyncData(optimistic);

    final result = await AsyncValue.guard(() async {
      await optimistic.pause();
      return optimistic.clone();
    });
    state = result;
  }

  Future<void> next(Map<String, Track> tracks) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final player = currentState.clone();
      await player.next(true, tracks);
      return player.clone();
    });
    state = result;
  }

  Future<void> prev(Map<String, Track> tracks) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final player = currentState.clone();
      await player.prev(tracks);
      return player.clone();
    });
    state = result;
  }

  Future<void> stop() async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    optimistic.state = PlayerState.stopped;
    state = AsyncData(optimistic);

    final result = await AsyncValue.guard(() async {
      await optimistic.stop();
      return optimistic.clone();
    });
    state = result;
  }

  Future<void> seek(Duration duration) async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    // Seek is usually fast enough that we might not need full async loading state,
    // but let's be safe or just update optimistically.
    // For seek, we often want immediate feedback if possible, but the backend seek is async.
    await optimistic.seek(duration);
    state = AsyncData(optimistic);
  }

  Future<void> setPlayerBackend(PlayerBackend trackPlayer) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final optimistic = currentState.clone();
      await optimistic.setPlayerBackend(trackPlayer);
      return optimistic;
    });
    state = result;
  }

  Future<void> setCurrentTrack(Track track, Map<String, Track> tracks) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final optimistic = currentState.clone();
      await optimistic.setCurrentTrack(track, tracks);
      return optimistic;
    });
    state = result;
  }

  Future<void> setPlaylist(Playlist playlist, Map<String, Track> tracks) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final optimistic = currentState.clone();
      await optimistic.setPlaylist(playlist, tracks);
      return optimistic;
    });
    state = result;
  }

  Future<void> handleTracksAddedToPlaylist(
    List<Map<String, String>> playlistTrackMapping,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    await optimistic.handleTracksAddedToPlaylist(playlistTrackMapping);
    state = AsyncData(optimistic);
  }

  Future<void> handleTracksRemovedFromPlaylist(
    Playlist playlist, List<String> trackIds,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    await optimistic.handleTracksRemovedFromPlaylist(playlist, trackIds);
    state = AsyncData(optimistic);
  }

  Future<LoopMode> toggleLoopMode() async {
    final currentState = state.value;
    if (currentState == null) return LoopMode.none;

    final optimistic = currentState.clone();
    final newLoopMode = await optimistic.toggleLoopMode();
    state = AsyncData(optimistic);
    return newLoopMode;
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    final currentState = state.value;
    if (currentState == null) return ShuffleMode.sequential;

    final optimistic = currentState.clone();
    final newShuffleMode = await optimistic.toggleShuffleMode();
    state = AsyncData(optimistic);
    return newShuffleMode;
  }

  Future<void> handleNextAutomatically(Map<String, Track> tracks) async {
    final currentState = state.value;
    if (currentState == null) return;

    // This is called automatically, maybe we don't want to show loading state to avoid flickering?
    // But if it takes time, we should probably know.
    // Let's stick to optimistic update pattern if possible or just await.
    final optimistic = currentState.clone();
    await optimistic.handleNextAutomatically(tracks);
    state = AsyncData(optimistic);
  }

  PlayerController? getPlayerController() {
    return state.value?.clone();
  }

  Future<void> setSpeed(double value) async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    await optimistic.setSpeed(value);
    state = AsyncData(optimistic);
  }

  Future<void> setPlayerController(
    PlayerController playerController,
    Map<String, Track> tracks,
  ) async {
    final result = await AsyncValue.guard(() async {
      await playerController.setSpeed(playerController.speed);
      final currentTrack = tracks[playerController.currentTrackId];
      if (currentTrack != null) {
        await playerController.setCurrentTrack(currentTrack, tracks);
      }
      return playerController;
    });
    state = result;
  }

  Future<void> setTrackQueueDisplayMode(TrackQueueDisplayMode mode) async {
    final currentState = state.value;
    if (currentState == null) return;

    final optimistic = currentState.clone();
    await optimistic.setTrackQueueDisplayMode(mode);
    state = AsyncData(optimistic);
  }

  Future<void> reloadPlaylist(
    Playlist playlist,
    Map<String, Track> tracks,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final optimistic = currentState.clone();
      await optimistic.reloadPlaylist(playlist, tracks);
      return optimistic;
    });
    state = result;
  }

  Future<void> updatePlaybackStatistics() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Don't update UI state, just update statistics in background
    await currentState.updatePlaybackStatistics();
  }

  Future<void> handleTrackUpdated(String oldId, String newId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await AsyncValue.guard(() async {
      final optimistic = currentState.clone();
      await optimistic.handleTrackUpdated(oldId, newId);
      return optimistic;
    });
    state = result;
  }
}
