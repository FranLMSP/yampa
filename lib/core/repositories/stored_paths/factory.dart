import 'package:yampa/core/repositories/stored_paths/stored_paths.dart';
import 'package:yampa/core/repositories/stored_paths/stored_paths_sqlite.dart';

StoredPaths getStoredPathsRepository() {
  return StoredPathsSqlite();
}
