import 'package:yampa/core/player/enums.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/models/track_statistics.dart';

List<Track> sortTracks(
  List<Track> tracks,
  SortMode sortMode,
  Map<String, TrackStatistics> allTrackStatistics,
) {
  switch (sortMode) {
    case SortMode.titleAtoZ:
      return tracks..sort(
        (a, b) => a.displayTitle().toLowerCase().compareTo(
          b.displayTitle().toLowerCase(),
        ),
      );
    case SortMode.titleZtoA:
      return tracks..sort(
        (a, b) => b.displayTitle().toLowerCase().compareTo(
          a.displayTitle().toLowerCase(),
        ),
      );
    case SortMode.mostPlayed:
      return tracks..sort((a, b) {
        final statsA = allTrackStatistics[a.id];
        final statsB = allTrackStatistics[b.id];
        final timesPlayedA = statsA != null ? statsA.timesPlayed : 0;
        final timesPlayedB = statsB != null ? statsB.timesPlayed : 0;
        return timesPlayedB.compareTo(timesPlayedA);
      });
    case SortMode.leastPlayed:
      return tracks..sort((a, b) {
        final statsA = allTrackStatistics[a.id];
        final statsB = allTrackStatistics[b.id];
        final timesPlayedA = statsA?.timesPlayed ?? 0;
        final timesPlayedB = statsB?.timesPlayed ?? 0;
        return timesPlayedA.compareTo(timesPlayedB);
      });
    case SortMode.recentlyPlayed:
      return tracks..sort((a, b) {
        final statsA = allTrackStatistics[a.id];
        final statsB = allTrackStatistics[b.id];
        final lastPlayedAtA = statsA?.lastPlayedAt ?? DateTime.utc(0);
        final lastPlayedAtB = statsB?.lastPlayedAt ?? DateTime.utc(0);
        return lastPlayedAtB.compareTo(lastPlayedAtA);
      });
    case SortMode.leastRecentlyPlayed:
      return tracks..sort((a, b) {
        final statsA = allTrackStatistics[a.id];
        final statsB = allTrackStatistics[b.id];
        final lastPlayedAtA = statsA?.lastPlayedAt ?? DateTime.utc(0);
        final lastPlayedAtB = statsB?.lastPlayedAt ?? DateTime.utc(0);
        return lastPlayedAtA.compareTo(lastPlayedAtB);
      });
    case SortMode.artistAtoZ:
      return tracks..sort(
        (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
      );
    case SortMode.artistZtoA:
      return tracks..sort(
        (a, b) => b.artist.toLowerCase().compareTo(a.artist.toLowerCase()),
      );
    case SortMode.albumAtoZ:
      return tracks..sort(
        (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
      );
    case SortMode.albumZtoA:
      return tracks..sort(
        (a, b) => b.album.toLowerCase().compareTo(a.album.toLowerCase()),
      );
    case SortMode.genreAtoZ:
      return tracks..sort(
        (a, b) => a.genre.toLowerCase().compareTo(b.genre.toLowerCase()),
      );
    case SortMode.genreZtoA:
      return tracks..sort(
        (a, b) => b.genre.toLowerCase().compareTo(a.genre.toLowerCase()),
      );
    case SortMode.durationShortToLong:
      return tracks..sort((a, b) => a.duration.compareTo(b.duration));
    case SortMode.durationLongToShort:
      return tracks..sort((a, b) => b.duration.compareTo(a.duration));
    default:
      return tracks;
  }
}
