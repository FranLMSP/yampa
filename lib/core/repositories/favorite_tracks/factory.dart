import 'package:yampa/core/repositories/favorite_tracks/favorite_tracks.dart';
import 'package:yampa/core/repositories/favorite_tracks/favorite_tracks_sqlite_repository.dart';

FavoriteTracksRepository getFavoriteTracksRepository() {
  return FavoriteTracksSqliteRepository();
}
