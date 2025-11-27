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
      state = state.clone();
      rethrow;
    }
  }

  Future<void> next(Map<String, Track> tracks) async {
    await state.next(true, tracks);
    state = state.clone();
  }

  Future<void> prev(Map<String, Track> tracks) async {
    await state.prev(tracks);
    state = state.clone();
  }

  Future<void> stop() async {
    final optimistic = state.clone();
    optimistic.state = PlayerState.stopped;
    state = optimistic;

    try {
      await optimistic.stop();
      state = optimistic.clone();
    } catch (e) {
      state = state.clone();
      rethrow;
    }
  }

  Future<void> seek(Duration duration) async {
    await state.seek(duration);
    state = state.clone();
  }

  Future<void> setTrackPlayer(PlayerBackend trackPlayer) async {
    await state.setTrackPlayer(trackPlayer);
    state = state.clone();
  }

  Future<void> setCurrentTrack(Track track) async {
    await state.setCurrentTrack(track);
    state = state.clone();
  }

  Future<void> setPlaylist(Playlist playlist) async {
    await state.setPlaylist(playlist);
    state = state.clone();
  }

  Future<void> toggleLoopMode() async {
    await state.toggleLoopMode();
    state = state.clone();
  }

  Future<void> toggleShuffleMode() async {
    await state.toggleShuffleMode();
    state = state.clone();
  }

  Future<void> handleNextAutomatically(Map<String, Track> tracks) async {
    await state.handleNextAutomatically(tracks);
    state = state.clone();
  }

  PlayerController getPlayerController() {
    return state.clone();
  }

  Future<void> setSpeed(double value) async {
    await state.setSpeed(value);
    state = state.clone();
  }

  Future<void> setPlayerController(PlayerController playerController, Map<String, Track> tracks) async {
    await playerController.setSpeed(playerController.speed);
    final currentTrack = tracks[playerController.currentTrackId];
    if (currentTrack != null) {
      await playerController.setCurrentTrack(currentTrack);
    }
    state = playerController;
  }
}
