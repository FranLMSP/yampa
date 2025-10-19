import 'package:yampa/core/repositories/playlists/playlist_sqlite_repository.dart';
import 'package:yampa/core/repositories/playlists/playlists.dart';

PlaylistsRepository getPlaylistRepository() {
  return PlaylistSqliteRepository();
}
