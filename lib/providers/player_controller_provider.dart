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
    await PlayerController.instance.play();
  }

  Future<void> pause() async {
    await PlayerController.instance.pause();
  }

  Future<void> next() async {
    await PlayerController.instance.next(true);
  }

  Future<void> prev() async {
    await PlayerController.instance.prev();
  }

  Future<void> stop() async {
    await PlayerController.instance.stop();
  }

  Future<void> seek(Duration duration) async {
    await PlayerController.instance.seek(duration);
  }

  Future<void> setPlayerBackend(PlayerBackend playerBackend) async {
    await PlayerController.instance.setPlayerBackend(playerBackend);
  }

  Future<void> setCurrentTrack(Track track) async {
    await PlayerController.instance.setCurrentTrack(track);
  }

  Future<void> setPlaylist(Playlist playlist) async {
    await PlayerController.instance.setPlaylist(playlist);
  }

  Future<void> handleTracksAddedToPlaylist(
    List<Map<String, String>> playlistTrackMapping,
  ) async {
    await PlayerController.instance.handleTracksAddedToPlaylist(playlistTrackMapping);
  }

  Future<void> handleTracksRemovedFromPlaylist(
    Playlist playlist,
    List<String> trackIds,
  ) async {
    await PlayerController.instance.handleTracksRemovedFromPlaylist(playlist, trackIds);
  }

  Future<LoopMode> toggleLoopMode() async {
    return await PlayerController.instance.toggleLoopMode();
  }

  Future<ShuffleMode> toggleShuffleMode() async {
    return await PlayerController.instance.toggleShuffleMode();
  }

  Future<void> handleNextAutomatically() async {
    await PlayerController.instance.handleNextAutomatically();
  }

  PlayerController getPlayerController() {
    return PlayerController.instance.clone();
  }

  Future<void> setSpeed(double value) async {
    await PlayerController.instance.setSpeed(value);
  }

  Future<void> playTrack(Track track) async {
    final pc = PlayerController.instance;
    if (pc.playerBackend == null) {
      await pc.setPlayerBackend(await getPlayerBackend());
    }
    await pc.stop();
    await pc.setCurrentTrack(track);
    await pc.play();
  }

  Future<void> setPlayerController(PlayerController playerController) async {
    // This is essentially initializing the singleton state
    final pc = PlayerController.instance;
    pc.currentTrackId = playerController.currentTrackId;
    pc.currentPlaylistId = playerController.currentPlaylistId;
    pc.speed = playerController.speed;
    pc.trackQueueIds = List.from(playerController.trackQueueIds);
    pc.shuffledTrackQueueIds = List.from(
      playerController.shuffledTrackQueueIds,
    );
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
    await PlayerController.instance.setTrackQueueDisplayMode(mode);
  }

  Future<void> reloadPlaylist(Playlist playlist) async {
    await PlayerController.instance.reloadPlaylist(playlist);
  }

  Future<void> updatePlaybackStatistics() async {
    await PlayerController.instance.updatePlaybackStatistics();
  }

  Future<void> handleTrackUpdated(String oldId, String newId) async {
    await PlayerController.instance.handleTrackUpdated(oldId, newId);
  }

  Future<void> setVolume(double value) async {
    await PlayerController.instance.setVolume(value);
  }

  Future<void> setEqualizerGains(List<double> gains) async {
    await PlayerController.instance.setEqualizerGains(gains);
  }

  Future<void> restoreDefaults() async {
    await PlayerController.instance.restoreDefaults();
  }

  void setTracks(List<Track> tracks) {
    PlayerController.instance.setTracks(tracks);
  }

  List<Track> getTracks() {
    return PlayerController.instance.getTracks();
  }

  void addTracks(List<Track> tracks) {
    PlayerController.instance.addTracks(tracks);
  }

  void removeTracks(List<String> trackIds) {
    PlayerController.instance.removeTracks(trackIds);
  }

  void initAudioHandler() {
    // No longer needed as handler uses singleton directly
  }
}
