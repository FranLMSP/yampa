import 'package:music_player/core/repositories/playlists/factory.dart';
import 'package:music_player/core/repositories/stored_paths/factory.dart';
import 'package:music_player/core/track_players/factory.dart';
import 'package:music_player/models/path.dart';
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

Future<void> _fetchAndSetTracks(
  List<GenericPath> paths,
  TracksNotifier tracksNotifier,
) async {
  final tracksPlayer = getTrackPlayer();
  final newTracks = await tracksPlayer.fetchTracks(paths);
  tracksNotifier.addTracks(newTracks);
}

Future<void> handlePathsAdded(
  List<GenericPath> paths,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
) async {
  final storedPathsRepository = getStoredPathsRepository();
  localPathsNotifier.addPaths(paths);
  final List<Future> futures = [];
  futures.add(_fetchAndSetTracks(paths, tracksNotifier));
  for (final path in paths) {
    futures.add(storedPathsRepository.addPath(path));
  }
  await Future.wait(futures);
}

Future<void> handlePathsRemoved(
  List<GenericPath> paths,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
) async {
  final storedPathsRepository = getStoredPathsRepository();
  localPathsNotifier.removePaths(paths);
  final List<Future> removePathsFutures = [];
  for (final path in paths) {
    removePathsFutures.add(storedPathsRepository.removePath(path));
  }
  await Future.wait(removePathsFutures);

  final newPaths = await storedPathsRepository.getStoredPaths();
  final tracksPlayer = getTrackPlayer();
  final newTracks = await tracksPlayer.fetchTracks(newPaths);
  tracksNotifier.setTracks(newTracks);
}
