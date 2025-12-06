import 'package:yampa/models/track.dart';

abstract class CachedTracksRepository {
  Future<List<Track>> getAll();
  Future<void> addOrUpdate(Track track);
  Future<void> remove(String path);
  Future<void> removeAll();
  Future<void> close();
}
