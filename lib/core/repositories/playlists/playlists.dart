import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';

abstract class PlaylistsRepository {
  Future<List<Playlist>> getPlaylists(List<Track> tracks);
  Future<String> addPlaylist(Playlist playlist);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> addTrackToPlaylist(Playlist playlist, Track track);
  Future<void> linkTracksWithPlaylists(List<Map<String, String>> playlistAndTrackMapping);
  Future<void> removeTrackFromPlaylist(Playlist playlist, Track track);
  Future<void> removeMultipleTracksFromPlaylist(Playlist playlist, List<Track> tracks);
  Future<void> removePlaylist(Playlist playlist);
  Future<void> close();
}
