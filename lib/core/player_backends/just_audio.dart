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
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
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
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
  ) async {
    loadedTracksCountNotifier.reset();
    final Map<String, Track> foundTracks = HashMap();

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
    final allEffectivePaths = filePaths;

    loadedTracksCountNotifier.setTotalTracks(allEffectivePaths.length);

    for (final path in allEffectivePaths) {
      await _getTrackMetadataFromGenericPath(
        path,
        tracksNotifier,
        loadedTracksCountNotifier,
      );
    }
    loadedTracksCountNotifier.reset();
    return foundTracks.values.toList();
  }

  Future<void> _getTrackMetadataFromGenericPath(
    GenericPath path,
    TracksNotifier tracksNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
  ) async {
    try {
      final metadata = await compute(readMetadata, File(path.filename!));
      tracksNotifier.addTracks([
        Track(
          id: await generateTrackId(path.filename!),
          name: metadata.title ?? "",
          artist: metadata.artist ?? "",
          album: metadata.album ?? "",
          genre: metadata.genres.isEmpty ? metadata.genres.join(", ") : "",
          trackNumber: metadata.trackNumber ?? 0,
          path: path.filename!,
          duration: metadata.duration ?? Duration.zero,
          imageBytes: metadata.pictures.isNotEmpty
              ? metadata.pictures.first.bytes
              : null,
        ),
      ]);
    } catch (e) {
      log('Error reading metadata', error: e);
    } finally {
      loadedTracksCountNotifier.incrementLoadedTrack();
    }
  }

  @override
  Future<void> setTrack(Track track) async {
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
  }

  @override
  Duration getCurrentTrackDuration() {
    return _currentTrackDuration ?? Duration.zero;
  }

  @override
  Future<void> play() async {
    _ensurePlayerInitialized();
    if (!_player!.playing) {
      await _player!.play();
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
}
