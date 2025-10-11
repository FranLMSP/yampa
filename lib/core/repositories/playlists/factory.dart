import 'package:music_player/core/repositories/playlists/playlist_sqlite_repository.dart';
import 'package:music_player/core/repositories/playlists/playlists.dart';

PlaylistsRepository getPlaylistRepository() {
  return PlaylistSqliteRepository();
}
