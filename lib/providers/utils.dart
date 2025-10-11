import 'package:music_player/core/repositories/playlists/factory.dart';
import 'package:music_player/core/repositories/stored_paths/factory.dart';
import 'package:music_player/core/track_players/factory.dart';
import 'package:music_player/providers/initial_load_provider.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';

Future<void> doInitialLoad(
  bool initialLoadDone,
  InitialLoadNotifier initialLoadNotifier,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
  PlaylistNotifier playlistNotifier,
) async {
  if (initialLoadDone) return;

  final storedPathsRepository = getStoredPathsRepository();
  final storedPaths = await storedPathsRepository.getStoredPaths();
  localPathsNotifier.setPaths(storedPaths);
  final tracksPlayer = getTrackPlayer();
  final tracks = await tracksPlayer.fetchTracks(storedPaths);
  tracksNotifier.setTracks(tracks);
  final playlistsRepo = getPlaylistRepository();
  final playlists = await playlistsRepo.getPlaylists(tracks);
  playlistNotifier.setPlaylists(playlists);

  initialLoadNotifier.setInitialLoadDone();
}
