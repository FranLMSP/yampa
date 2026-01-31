import 'package:yampa/core/player/enums.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';

abstract class PlayerBackend {
  Future<List<Track>> fetchTracks(
    List<GenericPath> paths,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier, {
    List<Track>? cachedTracks,
  });
  Future<Duration> setTrack(Track track);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setVolume(double volume);
  Future<void> setEqualizerGains(List<double> gains);
  Future<void> setLoopMode(LoopMode mode);
  Stream<void> get onTrackFinished;
  Future<Duration> getCurrentPosition();
  bool hasTrackFinishedPlaying();
  Duration getCurrentTrackDuration();
  Future<void> init();
  Future<Track> updateTrackMetadata(Track track);
}
