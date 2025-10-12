import 'package:music_player/models/path.dart';

abstract class StoredPaths {
  Future<List<GenericPath>> getStoredPaths();
  Future<String> addPath(GenericPath path);
  Future<void> removePath(GenericPath path);
  Future<void> close();
}
