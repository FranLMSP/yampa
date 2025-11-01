import 'dart:collection';

import 'package:yampa/core/repositories/playlists/factory.dart';
import 'package:yampa/core/repositories/stored_paths/factory.dart';
import 'package:yampa/core/track_players/factory.dart';
import 'package:yampa/core/utils/filename_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/local_paths_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

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
  await storedPathsRepository.close();
  localPathsNotifier.setPaths(storedPaths);
  final tracksPlayer = getTrackPlayer();
  final tracks = await tracksPlayer.fetchTracks(storedPaths);
  tracksNotifier.setTracks(tracks);
  final playlistsRepo = getPlaylistRepository();
  final playlists = await playlistsRepo.getPlaylists(tracks);
  await playlistsRepo.close();
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
  await _fetchAndSetTracks(actuallyAddedPaths, tracksNotifier);
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

  final newPaths = await storedPathsRepository.getStoredPaths();
  final tracksPlayer = getTrackPlayer();
  final newTracks = await tracksPlayer.fetchTracks(newPaths);
  tracksNotifier.setTracks(newTracks);
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
      tracks: playlist.tracks,
    )
  );
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
      tracks: playlist.tracks,
    )
  );
}

Future<void> handleTracksAddedToPlaylist(
  List<Track> tracks,
  List<Playlist> playlists,
  PlaylistNotifier playlistNotifier,
  SelectedPlaylistNotifier selectedPlaylistsNotifier,
  SelectedTracksNotifier selectedTracksNotifier,
) async {
  final selectedPlaylistIds = selectedPlaylistsNotifier.getPlaylistIds();
  final selectedTrackIds = selectedTracksNotifier.getTrackIds();
  final playlistRepository = getPlaylistRepository();

  final Map<String, Track> trackMap = HashMap();
  final Map<String, Playlist> playlistMap = HashMap();

  for (final track in tracks) {
    trackMap[track.id] = track;
  }
  for (final playlist in playlists) {
    playlistMap[playlist.id] = playlist;
  }

  final List<Map<String, String>> mapping = [];
  for (final playlistId in selectedPlaylistIds) {
    for (final trackId in selectedTrackIds) {
      final track = trackMap[trackId];
      final playlist = playlistMap[playlistId];
      if (track != null && playlist != null) {
        playlistNotifier.addTrack(playlist, track);
      }
      mapping.add({
        "playlist_id": playlistId,
        "track_id": trackId,
      });
    }
  }

  // TODO: if the playlist matches the current playlist being played, add it to the controller here.
  // Or maybe refactor the controller to point to the playlist ID instead of holding the list of tracks
  // indepentendly? Idk I'll figure it out later.

  selectedTracksNotifier.clear();
  selectedPlaylistsNotifier.clear();

  await playlistRepository.linkTracksWithPlaylists(mapping);
  await playlistRepository.close();
}

Future<void> handleTrackRemovedFromPlaylist(
  Playlist playlist,
  Track track,
  PlaylistNotifier playlistNotifier,
) async {
  playlistNotifier.removeTrack(playlist, track);
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.removeTrackFromPlaylist(playlist, track);
  await playlistRepository.close();
}

Future<void> handleMultipleTrackRemovedFromPlaylist(
  Playlist playlist,
  List<Track> tracks,
  PlaylistNotifier playlistNotifier,
) async {
  for (final track in tracks) {
    playlistNotifier.removeTrack(playlist, track);
  }
  final playlistRepository = getPlaylistRepository();
  await playlistRepository.removeMultipleTracksFromPlaylist(playlist, tracks);
  await playlistRepository.close();
}
