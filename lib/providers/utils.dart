import 'dart:collection';
import 'dart:developer';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';

import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/player_controller_state/factory.dart';
import 'package:yampa/core/repositories/playlists/factory.dart';
import 'package:yampa/core/repositories/statistics/factory.dart';
import 'package:yampa/core/repositories/stored_paths/factory.dart';
import 'package:yampa/core/repositories/cached_tracks/factory.dart';
import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/core/repositories/user_settings_data/factory.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:path/path.dart' as p;
import 'package:yampa/models/path.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/models/user_settings.dart';
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

  final statsRepo = getStatisticsRepository();
  await statsRepo.incrementTimesStarted();
  await statsRepo.close();

  final storedPathsRepository = getStoredPathsRepository();
  final storedPaths = await storedPathsRepository.getStoredPaths();
  await storedPathsRepository.close();
  localPathsNotifier.setPaths(storedPaths);

  final playlistsRepo = getPlaylistRepository();
  final playlists = await playlistsRepo.getPlaylists();
  if (playlists.indexWhere((e) => e.id == favoritePlaylistId) == -1) {
    final favoritesPlaylist = Playlist(
      id: favoritePlaylistId,
      name: "Favorites",
      description: "",
      trackIds: [],
    );
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

  // TODO: the player state has to be loaded before fetching the tracks to prevent a bug where the user clicks on a track before all of them have finished loading
  await loadPlayerControllerState(playerControllerNotifier);

  // Load cached tracks first for immediate UI feedback
  final cachedTracksRepository = getCachedTracksRepository();
  final cachedTracks = await cachedTracksRepository.getAll();
  tracksNotifier.setTracks(cachedTracks);
  await cachedTracksRepository.close();

  initialLoadNotifier.setInitialLoadDone();

  await _fetchAndSetTracks(
    storedPaths,
    tracksNotifier,
    loadedTracksCountNotifier,
    cachedTracks: cachedTracks,
  );
}

Future<void> _fetchAndSetTracks(
  List<GenericPath> paths,
  TracksNotifier tracksNotifier,
  LoadedTracksCountProviderNotifier loadedTracksCountNotifier, {
  List<Track>? cachedTracks,
}) async {
  final tracksPlayer = await getPlayerBackend();
  await tracksPlayer.fetchTracks(
    paths,
    tracksNotifier,
    loadedTracksCountNotifier,
    cachedTracks: cachedTracks,
  );
}

Future<void> reloadTracks(
  TracksNotifier tracksNotifier,
  LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
) async {
  final storedPathsRepository = getStoredPathsRepository();
  final paths = await storedPathsRepository.getStoredPaths();
  await storedPathsRepository.close();

  final cachedTracksRepository = getCachedTracksRepository();
  final cachedTracks = await cachedTracksRepository.getAll();
  await cachedTracksRepository.close();

  final tracksPlayer = await getPlayerBackend();
  await tracksPlayer.fetchTracks(
    paths,
    tracksNotifier,
    loadedTracksCountNotifier,
    cachedTracks: cachedTracks,
  );
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
    final newPath = GenericPath(
      id: id,
      folder: path.folder,
      filename: path.filename,
    );
    localPathsNotifier.addPaths([newPath]);
    actuallyAddedPaths.add(newPath);
  }
  await _fetchAndSetTracks(
    actuallyAddedPaths,
    tracksNotifier,
    loadedTracksCountNotifier,
  );
  await storedPathsRepository.close();
}

Future<void> handlePathsRemoved(
  List<GenericPath> removedPaths,
  LocalPathsNotifier localPathsNotifier,
  TracksNotifier tracksNotifier,
) async {
  // Try to remove from the provider only the tracks related to the removed paths
  final storedPathsRepository = getStoredPathsRepository();
  final cachedTracksRepository = getCachedTracksRepository();

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

  // Collect tracks to remove
  final List<Track> tracksToRemove = [];
  final filteredTracks = [...currentTracks];
  filteredTracks.removeWhere((track) {
    bool shouldRemove = false;

    // Check if track matches a removed file
    if (removedFiles[track.path] != null) {
      shouldRemove = true;
    } else {
      // Check if track is within any removed folder
      for (final removedFolder in removedFolders.keys) {
        if (p.isWithin(removedFolder, track.path)) {
          shouldRemove = true;
          break;
        }
      }
    }

    if (shouldRemove) {
      tracksToRemove.add(track);
    }

    return shouldRemove;
  });

  // Remove tracks from cache
  for (final track in tracksToRemove) {
    await cachedTracksRepository.remove(track.path);
  }

  tracksNotifier.setTracks(filteredTracks);
  final List<Future> removePathsFutures = [];
  for (final path in removedPaths) {
    removePathsFutures.add(storedPathsRepository.removePath(path));
  }
  await Future.wait(removePathsFutures);

  await storedPathsRepository.close();
  await cachedTracksRepository.close();
}

Future<Playlist> handlePlaylistCreated(
  Playlist playlist,
  PlaylistNotifier playlistNotifier, {
  String? forceWithId,
}) async {
  final playlistRepository = getPlaylistRepository();
  final id = await playlistRepository.addPlaylist(
    playlist,
    forceWithId: forceWithId,
  );
  final newPlaylist = Playlist(
    id: id,
    name: playlist.name,
    description: playlist.description,
    imagePath: playlist.imagePath,
    trackIds: playlist.trackIds,
  );
  playlistNotifier.addPlaylist(newPlaylist);
  await playlistRepository.close();
  return newPlaylist;
}

Future<void> handlePlaylistEdited(
  Playlist playlist,
  PlaylistNotifier playlistNotifier,
) async {
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.updatePlaylist(playlist);
  playlistNotifier.updatePlaylist(
    Playlist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      imagePath: playlist.imagePath,
      trackIds: playlist.trackIds,
    ),
  );
  await playlistRepository.close();
}

Future<void> handlePlaylistRemoved(
  Playlist playlist,
  PlaylistNotifier playlistNotifier,
) async {
  if (playlist.id == favoritePlaylistId) {
    await handlePlaylistEdited(
      Playlist(
        id: favoritePlaylistId,
        name: "Favorites",
        description: "",
        trackIds: [],
      ),
      playlistNotifier,
    );
    return;
  }
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.removePlaylist(playlist);
  playlistNotifier.removePlaylist(playlist);
  await playlistRepository.close();
}

Future<void> handleTracksAddedToPlaylist(
  List<String> trackIds,
  List<Playlist> playlists,
  PlaylistNotifier playlistNotifier,
  PlayerControllerNotifier playerNotifier,
) async {
  final playlistRepository = getPlaylistRepository();

  final List<Map<String, String>> mapping = [];
  for (final playlist in playlists) {
    for (final trackId in trackIds) {
      playlistNotifier.addTrack(playlist, trackId);
      mapping.add({"playlist_id": playlist.id, "track_id": trackId});
    }
  }

  playerNotifier.handleTracksAddedToPlaylist(mapping);

  await playlistRepository.linkTracksWithPlaylists(mapping);
  await playlistRepository.close();
}

Future<void> handleMultipleTrackRemovedFromPlaylist(
  Playlist playlist,
  List<String> trackIds,
  PlaylistNotifier playlistNotifier,
  PlayerControllerNotifier playerNotifier,
) async {
  playlistNotifier.removeTracks(playlist, trackIds);
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.removeMultipleTracksFromPlaylist(playlist, trackIds);
  await playlistRepository.close();
  await playerNotifier.handleTracksRemovedFromPlaylist(playlist, trackIds);
}

Future<void> handlePersistPlayerControllerState(
  PlayerController playerController,
) async {
  final playerControllerStateRepository = getPlayerControllerStateRepository();
  await playerControllerStateRepository.savePlayerControllerState(
    LastPlayerControllerState(
      currentTrackId: playerController.currentTrackId ?? "",
      currentPlaylistId: playerController.currentPlaylistId ?? "",
      speed: playerController.speed,
      trackQueueIds: playerController.trackQueueIds,
      shuffledTrackQueueIds: playerController.shuffledTrackQueueIds,
      state: playerController.state,
      loopMode: playerController.loopMode,
      shuffleMode: playerController.shuffleMode,
      trackQueueDisplayMode: playerController.trackQueueDisplayMode,
    ),
  );
  await playerControllerStateRepository.close();
}

Future<void> loadPlayerControllerState(
  PlayerControllerNotifier playerControllerNotifier,
) async {
  final playerControllerStateRepository = getPlayerControllerStateRepository();
  final lastPlayerControllerState = await playerControllerStateRepository
      .getPlayerControllerState();
  // TODO: set the current track after they are all loaded
  await playerControllerNotifier.setPlayerController(
    await PlayerController.fromLastState(lastPlayerControllerState),
    {},
  );
  await playerControllerStateRepository.close();
}

Future<void> handleTrackMetadataEdited(
  Track newTrackInfo,
  Map<String, Track> allTracks,
  List<Playlist> allPlaylists,
  TracksNotifier tracksNotifier,
  PlaylistNotifier playlistNotifier,
  PlayerControllerNotifier playerControllerNotifier,
) async {
  final existingId = newTrackInfo.id;

  // TODO: get the audio backend depending on the source type of the track
  final playerBackend = await getPlayerBackend();
  final updatedTrack = await playerBackend.updateTrackMetadata(newTrackInfo);

  for (final playlist in allPlaylists) {
    bool didPlaylistChange = false;
    for (final (index, trackId) in playlist.trackIds.indexed) {
      if (trackId == existingId) {
        didPlaylistChange = true;
        playlist.trackIds[index] = updatedTrack.id;
        break;
      }
    }
    if (didPlaylistChange) {
      await handlePlaylistEdited(playlist, playlistNotifier);
    }
  }
  tracksNotifier.removeTracks([existingId]);
  tracksNotifier.addTracks([updatedTrack]);

  playerControllerNotifier.handleTrackUpdated(existingId, updatedTrack.id);
}

Future<void> handleAppWindowSizeChanged(WindowSize windowSize) async {
  final repo = getUserSettingsDataRepository();
  await repo.saveLastWindowSize(windowSize);
  await repo.close();
}

Future<void> handlePlaylistsExport(List<Playlist> playlists) async {
  try {
    final List<Map<String, dynamic>> exportData = [];
    for (final playlist in playlists) {
      String? imageB64;
      if (playlist.imagePath != null) {
        imageB64 = await fileToBase64(playlist.imagePath!);
      }
      exportData.add(playlist.toJson(imageB64: imageB64));
    }

    final jsonString = jsonEncode(exportData);
    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Playlists',
      fileName: 'playlists.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (outputFile != null) {
      final file = io.File(outputFile);
      await file.writeAsString(jsonString);
    }
  } catch (e) {
    log("Error exporting playlists", error: e);
  }
}

Future<void> handlePlaylistsImport(
  PlaylistNotifier playlistNotifier,
  List<Playlist> currentPlaylists,
) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final file = io.File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final List<dynamic> importData = jsonDecode(jsonString);

    final playlistRepository = getPlaylistRepository();
    final existingPlaylists = await playlistRepository.getPlaylists();

    for (final item in importData) {
      final Map<String, dynamic> json = item as Map<String, dynamic>;
      final String? imageB64 = json['imageB64'];
      String? newImagePath;
      if (imageB64 != null) {
        newImagePath = await saveBase64Image(imageB64);
      }

      final existingPlaylist = existingPlaylists
          .where((e) => e.id == json['id'])
          .firstOrNull;

      if (existingPlaylist != null) {
        // Merge track IDs
        final List<String> importedTrackIds = List<String>.from(
          json['trackIds'],
        );
        final Set<String> mergedTrackIds = {
          ...existingPlaylist.trackIds,
          ...importedTrackIds,
        };

        final updatedPlaylist = Playlist(
          id: existingPlaylist.id,
          name: json['name'] ?? existingPlaylist.name,
          description: json['description'] ?? existingPlaylist.description,
          trackIds: mergedTrackIds.toList(),
          imagePath: newImagePath ?? existingPlaylist.imagePath,
          sortMode: SortMode
              .values[json['sortMode'] ?? existingPlaylist.sortMode.index],
        );

        await handlePlaylistEdited(updatedPlaylist, playlistNotifier);
      } else {
        final newPlaylistData = Playlist.fromJson(
          json,
          imagePath: newImagePath,
        );
        await handlePlaylistCreated(
          newPlaylistData,
          playlistNotifier,
          forceWithId: newPlaylistData.id,
        );
      }
    }
    await playlistRepository.close();
  } catch (e) {
    log("Error importing playlists", error: e);
  }
}
