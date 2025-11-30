import 'dart:collection';
import 'dart:developer';

import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/repositories/player_controller_state/factory.dart';
import 'package:yampa/core/repositories/playlists/factory.dart';
import 'package:yampa/core/repositories/stored_paths/factory.dart';
import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/local_paths_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

Future<void> doInitialLoad(
  bool initialLoadDone,
  InitialLoadNotifier initialLoadNotifier,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
  PlaylistNotifier playlistNotifier,
  PlayerControllerNotifier playerControllerNotifier,
  LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
) async {
  if (initialLoadDone) return;

  final storedPathsRepository = getStoredPathsRepository();
  final storedPaths = await storedPathsRepository.getStoredPaths();
  await storedPathsRepository.close();
  localPathsNotifier.setPaths(storedPaths);

  final playlistsRepo = getPlaylistRepository();
  final playlists = await playlistsRepo.getPlaylists();
  if (playlists.indexWhere((e) => e.id == favoritePlaylistId) == -1) {
    final favoritesPlaylist = Playlist(id: favoritePlaylistId, name: "Favorites", description: "", trackIds: []);
    playlists.insert(0, favoritesPlaylist);
    await playlistsRepo.addPlaylist(favoritesPlaylist);
  }
  await playlistsRepo.close();
  playlistNotifier.setPlaylists(playlists);

  // Check for images in local paths that don't currently have a playlist linked to them.
  final localImages = await listUserImages();
  final playlistImages = playlists
      .map((e) => e.imagePath)
      .where((e) => e != null)
      .map((e) => e!)
      .toSet();

  final orphanedImages = localImages.where((image) {
    return !playlistImages.contains(image);
  }).toList();

  for (final image in orphanedImages) {
    log('Deleting orphaned image: $image');
    await deleteFile(image);
  }

  initialLoadNotifier.setInitialLoadDone();

  // TODO: the player state has to be loaded before fetching the tracks to prevent a bug where the user clicks on a track before all of them have finished loading
  await loadPlayerControllerState(playerControllerNotifier);
  await _fetchAndSetTracks(storedPaths, tracksNotifier, loadedTracksCountNotifier);
}

Future<void> _fetchAndSetTracks(
  List<GenericPath> paths,
  TracksNotifier tracksNotifier,
  LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
) async {
  final tracksPlayer = await getPlayerBackend();
  await tracksPlayer.fetchTracks(paths, tracksNotifier, loadedTracksCountNotifier);
}

Future<void> handlePathsAdded(
  List<GenericPath> paths,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
  LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
) async {
  // Try to add to the provider only the tracks related to the paths
  final List<GenericPath> actuallyAddedPaths = [];
  final storedPathsRepository = getStoredPathsRepository();
  for (final path in paths) {
    final id = await storedPathsRepository.addPath(path);
    if (id.isEmpty) continue;
    final newPath = GenericPath(id: id, folder: path.folder, filename: path.filename);
    localPathsNotifier.addPaths([newPath]);
    actuallyAddedPaths.add(newPath);
  }
  await _fetchAndSetTracks(actuallyAddedPaths, tracksNotifier, loadedTracksCountNotifier);
  await storedPathsRepository.close();
}

Future<void> handlePathsRemoved(
  List<GenericPath> removedPaths,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
) async {
  // Try to remove from the provider only the tracks related to the removed paths
  final storedPathsRepository = getStoredPathsRepository();
  localPathsNotifier.removePaths(removedPaths);
  final currentTracks = tracksNotifier.getTracks();
  Map<String, String> removedFolders = HashMap();
  Map<String, String> removedFiles = HashMap();
  for (final path in removedPaths) {
    if (path.filename != null) {
      removedFiles[path.filename!] = path.filename!;
    } else if (path.folder != null) {
      removedFolders[path.folder!] = path.folder!;
    }
  }
  final filteredTracks = [...currentTracks];
  filteredTracks.removeWhere((track) {
    return (
      removedFiles[track.path] != null
      || (
        removedFiles[track.path] == null
        && removedFolders[getParentFolder(track.path)] != null
      )
    );
  });
  tracksNotifier.setTracks(filteredTracks);
  final List<Future> removePathsFutures = [];
  for (final path in removedPaths) {
    removePathsFutures.add(storedPathsRepository.removePath(path));
  }
  await Future.wait(removePathsFutures);

  await storedPathsRepository.close();
}

Future<void> handlePlaylistCreated(Playlist playlist, PlaylistNotifier playlistNotifier) async {
  final playlistRepository = getPlaylistRepository();
  final id = await playlistRepository.addPlaylist(playlist);
  playlistNotifier.addPlaylist(
    Playlist(
      id: id,
      name: playlist.name,
      description: playlist.description,
      imagePath: playlist.imagePath,
      trackIds: playlist.trackIds,
    )
  );
  await playlistRepository.close();
}

Future<void> handlePlaylistEdited(Playlist playlist, PlaylistNotifier playlistNotifier) async {
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.updatePlaylist(playlist);
  playlistNotifier.updatePlaylist(
    Playlist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      imagePath: playlist.imagePath,
      trackIds: playlist.trackIds,
    )
  );
  await playlistRepository.close();
}

Future<void> handlePlaylistRemoved(Playlist playlist, PlaylistNotifier playlistNotifier) async {
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.removePlaylist(playlist);
  playlistNotifier.removePlaylist(playlist);
  await playlistRepository.close();
}

Future<void> handleTracksAddedToPlaylist(
  List<String> trackIds,
  List<Playlist> playlists,
  PlaylistNotifier playlistNotifier,
) async {
  final playlistRepository = getPlaylistRepository();

  final List<Map<String, String>> mapping = [];
  for (final playlist in playlists) {
    for (final trackId in trackIds) {
      playlistNotifier.addTrack(playlist, trackId);
      mapping.add({
        "playlist_id": playlist.id,
        "track_id": trackId,
      });
    }
  }

  // TODO: if the playlist matches the current playlist being played, add it to the controller here.
  // Or maybe refactor the controller to point to the playlist ID instead of holding the list of tracks
  // indepentendly? Idk I'll figure it out later.

  await playlistRepository.linkTracksWithPlaylists(mapping);
  await playlistRepository.close();
}

Future<void> handleMultipleTrackRemovedFromPlaylist(
  Playlist playlist,
  List<String> trackIds,
  PlaylistNotifier playlistNotifier,
) async {
  playlistNotifier.removeTracks(playlist, trackIds);
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.removeMultipleTracksFromPlaylist(playlist, trackIds);
  await playlistRepository.close();
}

Future<void> handlePersistPlayerControllerState(PlayerController playerController) async {
  final playerControllerStateRepository = getPlayerControllerStateRepository();
  await playerControllerStateRepository.savePlayerControllerState(
    LastPlayerControllerState(
      currentTrackId: playerController.currentTrackId ?? "",
      currentPlaylistId: playerController.currentPlaylistId ?? "",
      currentTrackIndex: playerController.currentTrackIndex,
      speed: playerController.speed,
      trackQueueIds: playerController.trackQueueIds,
      shuffledTrackQueueIds: playerController.shuffledTrackQueueIds,
      state: playerController.state,
      loopMode: playerController.loopMode,
      shuffleMode: playerController.shuffleMode,
    )
  );
  await playerControllerStateRepository.close();
}


Future<void> loadPlayerControllerState(PlayerControllerNotifier playerControllerNotifier) async {
  final playerControllerStateRepository = getPlayerControllerStateRepository();
  final lastPlayerControllerState = await playerControllerStateRepository.getPlayerControllerState();
  // TODO: set the current track after they are all loaded
  await playerControllerNotifier.setPlayerController(await PlayerController.fromLastState(lastPlayerControllerState), {});
  await playerControllerStateRepository.close();
}
