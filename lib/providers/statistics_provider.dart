import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/repositories/statistics/factory.dart';
import 'package:yampa/core/repositories/statistics/statistics.dart';
import 'package:yampa/models/player_statistics.dart';
import 'package:yampa/models/track_statistics.dart';

final statisticsRepositoryProvider = FutureProvider<StatisticsRepository>((ref) async {
  return await getStatisticsRepository();
});

final playerStatisticsProvider = FutureProvider<PlayerStatistics>((ref) async {
  final repo = await ref.watch(statisticsRepositoryProvider.future);
  return await repo.getPlayerStatistics();
});

final trackStatisticsProvider = FutureProvider.family<TrackStatistics, String>((ref, trackId) async {
  final repo = await ref.watch(statisticsRepositoryProvider.future);
  return await repo.getTrackStatistics(trackId);
});

final allTrackStatisticsProvider = FutureProvider<Map<String, TrackStatistics>>((ref) async {
  final repo = await ref.watch(statisticsRepositoryProvider.future);
  return await repo.getAllTrackStatistics();
});
