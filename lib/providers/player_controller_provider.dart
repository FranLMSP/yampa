import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';

final playerControllerProvider =
    NotifierProvider<PlayerControllerNotifier, PlayerController>(
      PlayerControllerNotifier.new,
    );

class PlayerControllerNotifier extends Notifier<PlayerController> {
  @override
  PlayerController build() => PlayerController();

  Future<void> play() async {
    final currentState = state;
    await currentState.play();
    state = currentState.clone();
  }

  Future<void> pause() async {
    final currentState = state;
    await currentState.pause();
    state = currentState.clone();
  }

  Future<void> next() async {
    final currentState = state;
    await currentState.next(true);
    state = currentState.clone();
  }

  Future<void> prev() async {
    final currentState = state;
    await currentState.prev();
    state = currentState.clone();
  }

  Future<void> stop() async {
    final currentState = state;
    await currentState.stop();
    state = currentState.clone();
  }

  Future<void> seek(Duration duration) async {
    final currentState = state;
    await currentState.seek(duration);
    state = currentState.clone();
  }

  Future<void> setPlayerBackend(PlayerBackend playerBackend) async {
    final currentState = state;
    await currentState.setPlayerBackend(playerBackend);
    state = currentState.clone();
  }

  Future<void> setCurrentTrack(Track track) async {
    final currentState = state;
    await currentState.setCurrentTrack(track);
    state = currentState.clone();
  }

  Future<void> setPlaylist(Playlist playlist) async {
    final currentState = state;
    await currentState.setPlaylist(playlist);
    state = currentState.clone();
  }

  Future<void> handleTracksAddedToPlaylist(
    List<Map<String, String>> playlistTrackMapping,
  ) async {
    final currentState = state;
    await currentState.handleTracksAddedToPlaylist(playlistTrackMapping);
    state = currentState.clone();
  }

  Future<void> handleTracksRemovedFromPlaylist(
    Playlist playlist,
    List<String> trackIds,
  ) async {
    final currentState = state;
    await currentState.handleTracksRemovedFromPlaylist(playlist, trackIds);
    state = currentState.clone();
  }

  Future<LoopMode> toggleLoopMode() async {
    final currentState = state;
    await currentState.toggleLoopMode();
    state = currentState.clone();
    return currentState.loopMode;
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    final currentState = state;
    await currentState.toggleShuffleMode();
    state = currentState.clone();
    return currentState.shuffleMode;
  }

  Future<void> handleNextAutomatically() async {
    final currentState = state;
    await currentState.handleNextAutomatically();
    state = currentState.clone();
  }

  PlayerController getPlayerController() {
    return state.clone();
  }

  Future<void> setSpeed(double value) async {
    final currentState = state;
    await currentState.setSpeed(value);
    state = currentState.clone();
  }

  Future<void> playTrack(Track track) async {
    final player = state;
    if (player.playerBackend == null) {
      // TODO: here we want to set the track player type depending on the source type of the track
      await player.setPlayerBackend(await getPlayerBackend());
    }
    await player.stop();
    await player.setCurrentTrack(track);
    await player.play();
    state = player.clone();
  }

  Future<void> setPlayerController(PlayerController playerController) async {
    final currentState = playerController.clone();
    await currentState.setSpeed(playerController.speed);
    await currentState.setVolume(playerController.volume);
    await currentState.setEqualizerGains(playerController.equalizerGains);
    final currentTrack = currentState.tracks[playerController.currentTrackId];
    if (currentTrack != null) {
      await currentState.setCurrentTrack(currentTrack);
    }
    state = currentState.clone();
  }

  Future<void> setTrackQueueDisplayMode(TrackQueueDisplayMode mode) async {
    final currentState = state;
    await currentState.setTrackQueueDisplayMode(mode);
    state = currentState.clone();
  }

  Future<void> reloadPlaylist(Playlist playlist) async {
    final currentState = state;
    await currentState.reloadPlaylist(playlist);
    state = currentState.clone();
  }

  Future<void> updatePlaybackStatistics() async {
    final currentState = state;
    await currentState.updatePlaybackStatistics();
    state = currentState.clone();
  }

  Future<void> handleTrackUpdated(String oldId, String newId) async {
    final currentState = state;
    await currentState.handleTrackUpdated(oldId, newId);
    state = currentState.clone();
  }

  Future<void> setVolume(double value) async {
    final currentState = state;
    await currentState.setVolume(value);
    state = currentState.clone();
  }

  Future<void> setEqualizerGains(List<double> gains) async {
    final currentState = state;
    await currentState.setEqualizerGains(gains);
    state = currentState.clone();
  }

  Future<void> restoreDefaults() async {
    final currentState = state;
    await currentState.restoreDefaults();
    state = currentState.clone();
  }

  void setTracks(List<Track> tracks) {
    final currentState = state;
    currentState.setTracks(tracks);
    state = currentState.clone();
  }

  List<Track> getTracks() {
    return state.getTracks();
  }

  void addTracks(List<Track> tracks) {
    final currentState = state;
    currentState.addTracks(tracks);
    state = currentState.clone();
  }

  void removeTracks(List<String> trackIds) {
    final currentState = state;
    currentState.removeTracks(trackIds);
    state = currentState.clone();
  }
}
