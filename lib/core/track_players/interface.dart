import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';

abstract class TrackPlayer {
  Future<List<Track>> fetchTracks(List<GenericPath> paths);
  Future<void> setTrack(Track track);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setVolume(double volume);
  Future<Duration> getCurrentPosition();
} 
