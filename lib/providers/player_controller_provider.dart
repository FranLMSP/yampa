import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/track_players/interface.dart';
import 'package:yampa/models/track.dart';


final playerControllerProvider = NotifierProvider<PlayerControllerNotifier, PlayerController>(
  PlayerControllerNotifier.new,
);

class PlayerControllerNotifier extends Notifier<PlayerController> {
  @override
  PlayerController build() => PlayerController();

  Future<void> play() async {
    await state.play();
    state = state.clone();
  }

  Future<void> pause() async {
    await state.pause();
    state = state.clone();
  }

  Future<void> next() async {
    await state.next();
    state = state.clone();
  }

  Future<void> prev() async {
    await state.prev();
    state = state.clone();
  }

  Future<void> stop() async {
    await state.stop();
    state = state.clone();
  }

  Future<void> seek(Duration duration) async {
    await state.seek(duration);
    state = state.clone();
  }

  void setTrackPlayer(TrackPlayer trackPlayer) {
    state.setTrackPlayer(trackPlayer);
    state = state.clone();
  }

  void setCurrentTrack(Track track) {
    state.setCurrentTrack(track);
    state = state.clone();
  }

  void setQueue(List<Track> tracks) {
    state.setQueue(tracks);
    state = state.clone();
  }

  void toggleLoopMode() {
    state.toggleLoopMode();
    state = state.clone();
  }

  void toggleShuffleMode() {
    state.toggleShuffleMode();
    state = state.clone();
  }

  Future<void> handleNextAutomatically() async {
    await state.handleNextAutomatically();
    state = state.clone();
  }

  PlayerController getPlayerController() {
    return state.clone();
  }

  Future<void> setSpeed (double value) async {
    await state.setSpeed(value);
    state = state.clone();
  }
}
