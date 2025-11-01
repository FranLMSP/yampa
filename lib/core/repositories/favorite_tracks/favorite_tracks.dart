import 'package:yampa/models/track.dart';

abstract class FavoriteTracksRepository {
  Future<List<String>> getFavoriteTrackIds();
  Future<void> addFavoriteTracks(List<Track> tracks);
  Future<void> removeTracksFromFavorites(List<Track> tracks);
  Future<void> close();
}
