import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yampa/core/utils/filename_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';
import 'interface.dart';

class JustAudioProvider implements TrackPlayer {
  final AudioPlayer _player = AudioPlayer();

  JustAudioProvider() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      JustAudioMediaKit.ensureInitialized(
        linux: true,
        windows: true,
        macOS: true,
      );
    }
  }

  @override
  Future<List<Track>> fetchTracks(List<GenericPath> paths) async {
    if (!await Permission.storage.request().isGranted) {
      // return [];
    }
    final Map<String, Track> result = HashMap();
    final List<Future<Track?>> futures = [];
    for (final path in paths) {
      if (path.filename != null && isValidMusicPath(path.filename!)) {
        futures.add(_getTrackMetadataFromGenericPath(path));
      } else if (path.folder != null) {
        final files = Directory(path.folder!)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => isValidMusicPath(file.path))
          .toList();
        for (final file in files) {
          final effectivePath = GenericPath(
            id: path.id,
            folder: path.folder,
            filename: file.path,
          );
          futures.add(_getTrackMetadataFromGenericPath(effectivePath));
        }
      }
    }
    final tracks = await Future.wait(futures);
    for (final track in tracks) {
      if (track == null) {
        continue;
      }
      result[track.path] = track;
    }
    return result.values.toList();
  }

  Future<Track?> _getTrackMetadataFromGenericPath(GenericPath path) async {
    try {
      final metadata = readMetadata(File(path.filename!), getImage: true);
      final tempPlayer = AudioPlayer();
      final duration = await tempPlayer.setFilePath(path.filename!);
      return Track(
        // id: path.id,
        id: path.filename!, // TODO: find a better way to give these an actual ID
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
}
