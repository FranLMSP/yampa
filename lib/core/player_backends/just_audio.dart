import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/core/utils/id_utils.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/repositories/cached_tracks/cached_tracks.dart';
import 'package:yampa/core/repositories/cached_tracks/factory.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:path/path.dart' as p;
import 'interface.dart';

AudioPlayer? _player;

class JustAudioBackend implements PlayerBackend {
  Duration? _currentTrackDuration;

  @override
  Future<void> init() async {
    _player ??= AudioPlayer();
    if (!Platform.isAndroid && !Platform.isIOS) {
      JustAudioMediaKit.ensureInitialized(
        linux: Platform.isLinux,
        windows: Platform.isWindows,
        macOS: Platform.isMacOS,
      );
    }
  }

  void _ensurePlayerInitialized() {
    _player ??= AudioPlayer();
  }

  @override
  Future<List<Track>> fetchTracks(
    List<GenericPath> paths,
    TracksNotifier tracksNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier, {
    List<Track>? cachedTracks,
  }) async {
    loadedTracksCountNotifier.reset();
    final Map<String, Track> foundTracks = HashMap();

    final Map<String, Track> cachedTracksMap = {
      if (cachedTracks != null)
        for (final track in cachedTracks) track.path: track,
    };
    final cachedTracksRepository = getCachedTracksRepository();

    final allEffectivePaths = await _gatherEffectivePaths(paths);

    loadedTracksCountNotifier.setTotalTracks(allEffectivePaths.length);

    for (final path in allEffectivePaths) {
      final cachedTrack = cachedTracksMap[path.filename];
      bool useCache = false;

      if (cachedTrack != null) {
        final file = File(path.filename!);
        if (await file.exists()) {
          final lastModified = await file.lastModified();
          if (cachedTrack.lastModified != null &&
              cachedTrack.lastModified!.isAtSameMomentAs(lastModified)) {
            useCache = true;
          }
        }
      }

      if (useCache) {
        foundTracks[cachedTrack!.id] = cachedTrack;
        loadedTracksCountNotifier.incrementLoadedTrack();
      } else {
        final track = await _getTrackMetadataFromGenericPath(path.filename!);
        if (track != null) {
          tracksNotifier.addTracks([track]);
          await cachedTracksRepository.addOrUpdate(track);
        }
        loadedTracksCountNotifier.incrementLoadedTrack();
      }
    }

    await _removeStaleCachedTracks(
      cachedTracks,
      foundTracks,
      paths,
      cachedTracksRepository,
      tracksNotifier,
    );

    await cachedTracksRepository.close();
    loadedTracksCountNotifier.reset();
    return foundTracks.values.toList();
  }

  Future<List<GenericPath>> _gatherEffectivePaths(
    List<GenericPath> paths,
  ) async {
    final List<GenericPath> filePaths = [];
    filePaths.addAll(paths.where((e) => e.filename != null));

    for (final path in paths.where(
      (e) => e.filename == null && e.folder != null,
    )) {
      final dir = Directory(path.folder!);
      try {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File && isValidMusicPath(entity.path)) {
            filePaths.add(
              GenericPath(
                id: path.id,
                folder: path.folder,
                filename: entity.path,
              ),
            );
          }
        }
      } catch (e) {
        log("Couldn't read directory", error: e);
      }
    }

    return filePaths;
  }

  Future<void> _removeStaleCachedTracks(
    List<Track>? cachedTracks,
    Map<String, Track> foundTracks,
    List<GenericPath> rootPaths,
    CachedTracksRepository cachedTracksRepository,
    TracksNotifier tracksNotifier,
  ) async {
    if (cachedTracks == null) return;

    final List<String> tracksToRemove = [];

    for (final cachedTrack in cachedTracks) {
      if (!foundTracks.containsKey(cachedTrack.id)) {
        bool belongsToScannedPaths = false;
        for (final rootPath in rootPaths) {
          if (rootPath.folder != null) {
            if (p.isWithin(rootPath.folder!, cachedTrack.path)) {
              belongsToScannedPaths = true;
              break;
            }
          } else if (rootPath.filename != null) {
            if (cachedTrack.path == rootPath.filename) {
              belongsToScannedPaths = true;
              break;
            }
          }
        }

        if (belongsToScannedPaths) {
          tracksToRemove.add(cachedTrack.id);
          await cachedTracksRepository.remove(cachedTrack.path);
        }
      }
    }

    if (tracksToRemove.isNotEmpty) {
      tracksNotifier.removeTracks(tracksToRemove);
    }
  }

  Future<Track?> _getTrackMetadataFromGenericPath(String path) async {
    try {
      final metadata = await compute(readMetadata, File(path));
      final file = File(path);
      final lastModified = await file.lastModified();
      return Track(
        id: await generateTrackId(path),
        name: metadata.title ?? "",
        artist: metadata.artist ?? "",
        album: metadata.album ?? "",
        genre: metadata.genres.isEmpty ? metadata.genres.join(", ") : "",
        trackNumber: metadata.trackNumber ?? 0,
        path: path,
        duration: metadata.duration ?? Duration.zero,
        imageBytes: metadata.pictures.isNotEmpty
            ? metadata.pictures.first.bytes
            : null,
        lastModified: lastModified,
      );
    } catch (e) {
      log('Error reading metadata', error: e);
    }
    return null;
  }

  @override
  Future<Duration> setTrack(Track track) async {
    _ensurePlayerInitialized();
    // TODO: maybe detect here if the path is an URL or not, and call setUrl if that's the case
    final duration = await _player!.setAudioSource(
      AudioSource.uri(
        Uri.file(track.path),
        tag: MediaItem(
          id: track.id,
          title: track.name,
          artist: track.artist,
          artUri: track.imageBytes != null
              ? bytesToDataUri(track.imageBytes!)
              : null,
        ),
      ),
    );
    _currentTrackDuration = duration;
    return duration ?? Duration.zero;
  }

  @override
  Duration getCurrentTrackDuration() {
    return _currentTrackDuration ?? Duration.zero;
  }

  @override
  Future<void> play() async {
    _ensurePlayerInitialized();
    if (!_player!.playing) {
      // Do not await play() because just_audio's play() future completes when playback completes (song ends).
      // We want to return immediately to update the UI.
      _player!.play();
    }
  }

  @override
  Future<void> pause() async {
    _ensurePlayerInitialized();
    if (_player!.playing) {
      await _player!.pause();
    }
  }

  @override
  Future<void> stop() async {
    _ensurePlayerInitialized();
    if (_player!.playing) {
      await _player!.stop();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    _ensurePlayerInitialized();
    await _player!.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    _ensurePlayerInitialized();
    await _player!.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    _ensurePlayerInitialized();
    await _player!.setVolume(volume);
  }

  @override
  Future<Duration> getCurrentPosition() async {
    _ensurePlayerInitialized();
    return _player!.position;
  }

  @override
  bool hasTrackFinishedPlaying() {
    _ensurePlayerInitialized();
    return _player!.processingState == ProcessingState.completed;
  }

  @override
  Future<Track> updateTrackMetadata(Track track) async {
    final file = File(track.path);
    updateMetadata(
      file,
      (metadata) {
        metadata.setTitle(track.name);
        metadata.setArtist(track.artist);
        metadata.setAlbum(track.album);
        metadata.setTrackNumber(track.trackNumber);
        metadata.setGenres(track.genre.split(", "));
        metadata.setPictures([
          Picture(Uint8List.fromList(track.imageBytes ?? []), "image/png", PictureType.coverFront)
        ]);
      },
    );
    final updatedTrack = await _getTrackMetadataFromGenericPath(track.path);
    return updatedTrack!;
  }
}
