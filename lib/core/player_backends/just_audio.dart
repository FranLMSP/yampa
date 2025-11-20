import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:yampa/core/utils/filename_utils.dart';
import 'package:yampa/core/utils/id_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'interface.dart';

class JustAudioBackend implements PlayerBackend {
  final AudioPlayer _player = AudioPlayer();

  JustAudioBackend() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      JustAudioMediaKit.ensureInitialized(
        linux: true,
        windows: true,
        macOS: true,
      );
    }
  }

  @override
  Future<List<Track>> fetchTracks(List<GenericPath> paths, TracksNotifier tracksNotifier, LoadedTracksCountProviderNotifier loadedTracksCountNotifier) async {
    loadedTracksCountNotifier.reset();
    final Map<String, Track> foundTracks = HashMap();

    final List<GenericPath> filePaths = [];
    filePaths.addAll(paths.where((e) => e.filename != null));
    for (final path in paths.where((e) => e.filename == null && e.folder != null)) {
      final dir = Directory(path.folder!);
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File && isValidMusicPath(entity.path)) {
            filePaths.add(GenericPath(id: path.id, folder: path.folder, filename: entity.path));
          }
        }
      } catch (e) {
        // ignore directories we cannot read
      }
    }
    final allEffectivePaths = filePaths;

    loadedTracksCountNotifier.setTotalTracks(allEffectivePaths.length);
    for (final path in allEffectivePaths) {
      final track = await _getTrackMetadataFromGenericPath(path);
      if (track != null && foundTracks[track.id] == null) {
        foundTracks[track.id] = track;
        tracksNotifier.addTracks([track]);
      }
      loadedTracksCountNotifier.incrementLoadedTrack();
    }
    loadedTracksCountNotifier.reset();
    return foundTracks.values.toList();
  }

  Future<Track?> _getTrackMetadataFromGenericPath(GenericPath path) async {
    try {
      final metadata = await compute(readMetadata, File(path.filename!));
      final tempPlayer = AudioPlayer();
      final duration = await tempPlayer.setFilePath(path.filename!);
      return Track(
        id: await generateTrackId(path.filename!),
        name: metadata.title ?? "",
        artist: metadata.artist ?? "",
        album: metadata.album ?? "",
        genre: metadata.genres.isEmpty ? metadata.genres.join(", ") : "",
        trackNumber: metadata.trackNumber ?? 0,
        path: path.filename!,
        duration: duration ?? Duration.zero,
        imageBytes: metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
      );
    } catch(e) {
      print(e);
    }
    return null;
  }

  @override
  Future<void> setTrack(Track track) async {
    // TODO: maybe detect here if the path is an URL or not, and call setUrl if that's the case
    await _player.setFilePath(track.path);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  @override
  Future<Duration> getCurrentPosition() async {
    return _player.position;
  }

  @override
  bool hasTrackFinishedPlaying() {
    return _player.processingState == ProcessingState.completed;
  }
}
