import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';


final playerControllerProvider = NotifierProvider<PlayerControllerNotifier, PlayerController>(
  PlayerControllerNotifier.new,
);

class PlayerControllerNotifier extends Notifier<PlayerController> {
  @override
  PlayerController build() => PlayerController();

  Future<void> play() async {
    final optimistic = state.clone();
    optimistic.state = PlayerState.playing;
    state = optimistic;

    try {
      await optimistic.play();
      state = optimistic.clone();
    } catch (e) {
      log("Couldn't play", error: e);
      state = state.clone();
      rethrow;
    }
  }

  Future<void> pause() async {
    final optimistic = state.clone();
    optimistic.state = PlayerState.paused;
    state = optimistic;

    try {
      await optimistic.pause();
      state = optimistic.clone();
    } catch (e) {
      log("Couldn't pause", error: e);
      state = state.clone();
      rethrow;
    }
  }

  Future<void> next(Map<String, Track> tracks) async {
    final player = state.clone();
    await player.next(true, tracks);
    state = player.clone();
  }

  Future<void> prev(Map<String, Track> tracks) async {
    final player = state.clone();
    await player.prev(tracks);
    state = player.clone();
  }

  Future<void> stop() async {
    final optimistic = state.clone();
    optimistic.state = PlayerState.stopped;
    state = optimistic;

    try {
      await optimistic.stop();
      state = optimistic.clone();
    } catch (e) {
      log("Couldn't stop", error: e);
      state = state.clone();
      rethrow;
    }
  }

  Future<void> seek(Duration duration) async {
    final optimistic = state.clone();
    await optimistic.seek(duration);
    state = optimistic;
  }

  Future<void> setTrackPlayer(PlayerBackend trackPlayer) async {
    final optimistic = state.clone();
    await optimistic.setTrackPlayer(trackPlayer);
    state = optimistic;
  }

  Future<void> setCurrentTrack(Track track) async {
    final optimistic = state.clone();
    await optimistic.setCurrentTrack(track);
    state = optimistic;
  }

  Future<void> setPlaylist(Playlist playlist, Map<String, Track> tracks) async {
    final optimistic = state.clone();
    await optimistic.setPlaylist(playlist, tracks);
    state = optimistic;
  }

  Future<void> handleTracksAddedToPlaylist(List<Map<String, String>> playlistTrackMapping) async {
    final optimistic = state.clone();
    await optimistic.handleTracksAddedToPlaylist(playlistTrackMapping);
    state = optimistic;
  }

  Future<LoopMode> toggleLoopMode() async {
    final optimistic = state.clone();
    final newLoopMode = await optimistic.toggleLoopMode();
    state = optimistic;
    return newLoopMode;
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    final optimistic = state.clone();
    final newShuffleMode = await optimistic.toggleShuffleMode();
    state = optimistic;
    return newShuffleMode;
  }

  Future<void> handleNextAutomatically(Map<String, Track> tracks) async {
    final optimistic = state.clone();
    await optimistic.handleNextAutomatically(tracks);
    state = optimistic;
  }

  PlayerController getPlayerController() {
    return state.clone();
  }

  Future<void> setSpeed(double value) async {
    final optimistic = state.clone();
    await optimistic.setSpeed(value);
    state = optimistic;
  }

  Future<void> setPlayerController(PlayerController playerController, Map<String, Track> tracks) async {
    await playerController.setSpeed(playerController.speed);
    final currentTrack = tracks[playerController.currentTrackId];
    if (currentTrack != null) {
      await playerController.setCurrentTrack(currentTrack);
    }
    state = playerController;
  }

  Future<void> setTrackQueueDisplayMode(TrackQueueDisplayMode mode) async {
    final optimistic = state.clone();
    await optimistic.setTrackQueueDisplayMode(mode);
    state = optimistic;
  }

  Future<void> reloadPlaylist(Playlist playlist, Map<String, Track> tracks) async {
    final optimistic = state.clone();
    await optimistic.reloadPlaylist(playlist, tracks);
    state = optimistic;
  }
}
