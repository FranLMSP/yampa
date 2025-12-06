import 'package:yampa/core/repositories/cached_tracks/cached_tracks.dart';
import 'package:yampa/core/repositories/cached_tracks/cached_tracks_sqlite.dart';

CachedTracksRepository getCachedTracksRepository() {
  return CachedTracksSqlite();
}
