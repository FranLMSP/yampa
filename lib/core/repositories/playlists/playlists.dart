import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';

abstract class PlaylistsRepository {
  Future<List<Playlist>> getPlaylists();
  Future<String> addPlaylist(Playlist playlist);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> addTrackToPlaylist(Playlist playlist, Track track);
  Future<void> removeTrackFromPlaylist(Playlist playlist, Track track);
  Future<void> removePlaylist(Playlist playlist);
}
