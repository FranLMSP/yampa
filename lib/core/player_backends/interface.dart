import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

abstract class PlayerBackend {
  Future<List<Track>> fetchTracks(
    List<GenericPath> paths,
    TracksNotifier tracksNotifier,
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
  Future<Duration> getCurrentPosition();
  bool hasTrackFinishedPlaying();
  Duration getCurrentTrackDuration();
  Future<void> init();
}
