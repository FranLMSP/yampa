import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/core/track_players/interface.dart';
import 'package:music_player/models/track.dart';


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

  void setTrackPlayer(TrackPlayer trackPlayer) {
    state.setTrackPlayer(trackPlayer);
    state = state.clone();
  }

  void setCurrentTrack(Track track) {
    state.setCurrentTrack(track);
    state = state.clone();
  }
}
