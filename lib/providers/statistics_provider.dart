import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/repositories/statistics/factory.dart';
import 'package:yampa/core/repositories/statistics/statistics.dart';
import 'package:yampa/models/player_statistics.dart';
import 'package:yampa/models/track_statistics.dart';

final statisticsRepositoryProvider = FutureProvider<StatisticsRepository>((
  ref,
) async {
  return getStatisticsRepository();
});

final playerStatisticsProvider = FutureProvider<PlayerStatistics>((ref) async {
  final repo = await ref.watch(statisticsRepositoryProvider.future);
  return await repo.getPlayerStatistics();
});

// Stream provider for track statistics that auto-updates
final trackStatisticsStreamProvider = StreamProvider.autoDispose
    .family<TrackStatistics, String>((ref, trackId) async* {
      // Emit initial value
      final repo = getStatisticsRepository();
      final stats = await repo.getTrackStatistics(trackId);
      await repo.close();
      yield stats;

      // Refresh every 5 seconds
      await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
        final repo = getStatisticsRepository();
        final stats = await repo.getTrackStatistics(trackId);
        await repo.close();
        yield stats;
      }
    });

final trackStatisticsProvider = FutureProvider.family<TrackStatistics, String>((
  ref,
  trackId,
) async {
  final repo = await ref.watch(statisticsRepositoryProvider.future);
  return await repo.getTrackStatistics(trackId);
});

final allTrackStatisticsProvider = FutureProvider<Map<String, TrackStatistics>>(
  (ref) async {
    final repo = await ref.watch(statisticsRepositoryProvider.future);
    return await repo.getAllTrackStatistics();
  },
);
