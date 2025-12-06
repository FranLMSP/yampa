import 'package:yampa/models/player_statistics.dart';
import 'package:yampa/models/track_statistics.dart';

abstract class StatisticsRepository {
  // Player statistics
  Future<PlayerStatistics> getPlayerStatistics();
  Future<void> updatePlayerStatistics(PlayerStatistics stats);
  Future<void> incrementTimesStarted();
  Future<void> addPlaybackTime(Duration duration);
  Future<void> incrementTotalSkips();
  Future<void> recordTrackPlayed(String trackId);

  // Track statistics
  Future<TrackStatistics> getTrackStatistics(String trackId);
  Future<Map<String, TrackStatistics>> getAllTrackStatistics();
  Future<void> updateTrackStatistics(TrackStatistics stats);
  Future<void> incrementTrackPlayCount(String trackId);
  Future<void> incrementTrackSkipCount(String trackId);
  Future<void> incrementTrackCompletionCount(String trackId);
  Future<void> addTrackPlaybackTime(String trackId, Duration duration);

  Future<void> close();
}
