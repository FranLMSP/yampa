import 'package:yampa/core/player/enums.dart';
import 'package:yampa/models/track.dart';

List<Track> sortTracks(List<Track> tracks, SortMode sortMode) {
  switch (sortMode) {
    case SortMode.titleAtoZ:
      return tracks..sort(
        (a, b) => a.displayName().toLowerCase().compareTo(
          b.displayName().toLowerCase(),
        ),
      );
    case SortMode.titleZtoA:
      return tracks..sort(
        (a, b) => b.displayName().toLowerCase().compareTo(
          a.displayName().toLowerCase(),
        ),
      );
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
