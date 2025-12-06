class TrackStatistics {
  final String trackId;
  final int timesPlayed;
  final int timesSkipped;
  final double minutesPlayed;
  final DateTime? lastPlayedAt;
  final int completionCount;

  TrackStatistics({
    required this.trackId,
    required this.timesPlayed,
    required this.timesSkipped,
    required this.minutesPlayed,
    this.lastPlayedAt,
    required this.completionCount,
  });

  TrackStatistics copyWith({
    String? trackId,
    int? timesPlayed,
    int? timesSkipped,
    double? minutesPlayed,
    DateTime? lastPlayedAt,
    int? completionCount,
  }) {
    return TrackStatistics(
      trackId: trackId ?? this.trackId,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      timesSkipped: timesSkipped ?? this.timesSkipped,
      minutesPlayed: minutesPlayed ?? this.minutesPlayed,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      completionCount: completionCount ?? this.completionCount,
    );
  }

  static TrackStatistics empty(String trackId) {
    return TrackStatistics(
      trackId: trackId,
      timesPlayed: 0,
      timesSkipped: 0,
      minutesPlayed: 0.0,
      lastPlayedAt: null,
      completionCount: 0,
    );
  }
}
