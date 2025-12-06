class PlayerStatistics {
  final double totalMinutesPlayed;
  final int totalTracksPlayed;
  final int totalUniqueTracksPlayed;
  final Duration uptime;
  final int timesStarted;
  final DateTime? lastPlayedAt;
  final int totalSkips;

  PlayerStatistics({
    required this.totalMinutesPlayed,
    required this.totalTracksPlayed,
    required this.totalUniqueTracksPlayed,
    required this.uptime,
    required this.timesStarted,
    this.lastPlayedAt,
    required this.totalSkips,
  });

  PlayerStatistics copyWith({
    double? totalMinutesPlayed,
    int? totalTracksPlayed,
    int? totalUniqueTracksPlayed,
    Duration? uptime,
    int? timesStarted,
    DateTime? lastPlayedAt,
    int? totalSkips,
  }) {
    return PlayerStatistics(
      totalMinutesPlayed: totalMinutesPlayed ?? this.totalMinutesPlayed,
      totalTracksPlayed: totalTracksPlayed ?? this.totalTracksPlayed,
      totalUniqueTracksPlayed: totalUniqueTracksPlayed ?? this.totalUniqueTracksPlayed,
      uptime: uptime ?? this.uptime,
      timesStarted: timesStarted ?? this.timesStarted,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalSkips: totalSkips ?? this.totalSkips,
    );
  }

  static PlayerStatistics empty() {
    return PlayerStatistics(
      totalMinutesPlayed: 0.0,
      totalTracksPlayed: 0,
      totalUniqueTracksPlayed: 0,
      uptime: Duration.zero,
      timesStarted: 0,
      lastPlayedAt: null,
      totalSkips: 0,
    );
  }
}
