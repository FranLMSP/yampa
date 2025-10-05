import 'package:music_player/core/repositories/stored_paths/stored_paths.dart';
import 'package:music_player/core/repositories/stored_paths/stored_paths_sqlite.dart';

StoredPaths getStoredPathsRepository() {
  return StoredPathsSqlite();
}
