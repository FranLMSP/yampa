import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player_backends/just_audio.dart';

final playerControllerProvider =
    NotifierProvider<PlayerControllerNotifier, PlayerController>(
      PlayerControllerNotifier.new,
    );

class PlayerControllerNotifier extends Notifier<PlayerController> {
  @override
  PlayerController build() {
    final pc = PlayerController.instance;
    final subscription = pc.onUpdate.listen((_) {
      state = pc.clone();
    });
    ref.onDispose(() {
      subscription.cancel();
    });
    return pc.clone();
  }

  Future<void> play() async {
    await state.play();
  }

  Future<void> pause() async {
    await state.pause();
  }

  Future<void> next() async {
    await state.next(true);
  }

  Future<void> prev() async {
    await state.prev();
  }

  Future<void> stop() async {
    await state.stop();
  }

  Future<void> seek(Duration duration) async {
    await state.seek(duration);
  }

  Future<void> setPlayerBackend(PlayerBackend playerBackend) async {
    await state.setPlayerBackend(playerBackend);
  }

  Future<void> setCurrentTrack(Track track) async {
    await state.setCurrentTrack(track);
  }

  Future<void> setPlaylist(Playlist playlist) async {
    await state.setPlaylist(playlist);
  }

  Future<void> handleTracksAddedToPlaylist(
    List<Map<String, String>> playlistTrackMapping,
  ) async {
    await state.handleTracksAddedToPlaylist(playlistTrackMapping);
  }

  Future<void> handleTracksRemovedFromPlaylist(
    Playlist playlist,
    List<String> trackIds,
  ) async {
    await state.handleTracksRemovedFromPlaylist(playlist, trackIds);
  }

  Future<LoopMode> toggleLoopMode() async {
    return await state.toggleLoopMode();
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    return await state.toggleShuffleMode();
  }

  Future<void> handleNextAutomatically() async {
    await state.handleNextAutomatically();
  }

  PlayerController getPlayerController() {
    return state.clone();
  }

  Future<void> setSpeed(double value) async {
    await state.setSpeed(value);
  }

  Future<void> playTrack(Track track) async {
    final player = state;
    if (player.playerBackend == null) {
      await player.setPlayerBackend(await getPlayerBackend());
    }
    await player.stop();
    await player.setCurrentTrack(track);
    await player.play();
  }

  Future<void> setPlayerController(PlayerController playerController) async {
    // This is essentially initializing the singleton state
    final pc = PlayerController.instance;
    pc.currentTrackId = playerController.currentTrackId;
    pc.currentPlaylistId = playerController.currentPlaylistId;
    pc.speed = playerController.speed;
    pc.trackQueueIds = List.from(playerController.trackQueueIds);
    pc.shuffledTrackQueueIds = List.from(playerController.shuffledTrackQueueIds);
    pc.state = playerController.state;
    pc.loopMode = playerController.loopMode;
    pc.shuffleMode = playerController.shuffleMode;
    pc.trackQueueDisplayMode = playerController.trackQueueDisplayMode;
    pc.playerBackend = playerController.playerBackend;
    pc.lastTrackDuration = playerController.lastTrackDuration;
    pc.volume = playerController.volume;
    pc.equalizerGains = List.from(playerController.equalizerGains);
    pc.tracks = Map.from(playerController.tracks);
    pc.notifyListeners();
  }

  Future<void> setTrackQueueDisplayMode(TrackQueueDisplayMode mode) async {
    await state.setTrackQueueDisplayMode(mode);
  }

  Future<void> reloadPlaylist(Playlist playlist) async {
    await state.reloadPlaylist(playlist);
  }

  Future<void> updatePlaybackStatistics() async {
    await state.updatePlaybackStatistics();
  }

  Future<void> handleTrackUpdated(String oldId, String newId) async {
    await state.handleTrackUpdated(oldId, newId);
  }

  Future<void> setVolume(double value) async {
    await state.setVolume(value);
  }

  Future<void> setEqualizerGains(List<double> gains) async {
    await state.setEqualizerGains(gains);
  }

  Future<void> restoreDefaults() async {
    await state.restoreDefaults();
  }

  void setTracks(List<Track> tracks) {
    state.setTracks(tracks);
  }

  List<Track> getTracks() {
    return state.getTracks();
  }

  void addTracks(List<Track> tracks) {
    state.addTracks(tracks);
  }

  void removeTracks(List<String> trackIds) {
    state.removeTracks(trackIds);
  }

  void initAudioHandler() {
    // No longer needed as handler uses singleton directly
  }
}
