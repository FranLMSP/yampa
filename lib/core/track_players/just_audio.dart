import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:music_player/models/path.dart';
import 'package:music_player/models/track.dart';
import 'interface.dart';

class JustAudioProvider implements TrackPlayer {
  final AudioPlayer _player = AudioPlayer();

  JustAudioProvider() {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
      android: true,
      iOS: true,
      macOS: true,
    );
  }

  @override
  Future<List<Track>> fetchTracks(List<GenericPath> paths) async {
    final Map<String, Track> result = HashMap();
    for (final path in paths) {
      if (path.filename != null) {
        try {
          final track = await _getTrackMetadataFromGenericPath(path);
          result[track.path] = track;
        } catch (e) {
          // handle error
        }
      } else if (path.folder != null) {
        final files = Directory(path.folder!)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) =>
              file.path.endsWith(".mp4") ||
              file.path.endsWith(".m4a") ||
              file.path.endsWith(".mp3") ||
              file.path.endsWith(".ogg") ||
              file.path.endsWith(".ogg") ||
              file.path.endsWith(".opus") ||
              file.path.endsWith(".wav") ||
              file.path.endsWith(".flac"))
          .toList();
        for (final file in files) {
          try {
            final effectivePath = GenericPath(
              id: path.id,
              folder: path.folder,
              filename: file.path,
            );
            final track = await _getTrackMetadataFromGenericPath(effectivePath);
            result[track.path] = track;
          } catch (e) {
            // handle error
          }
        }
      }
    }
    return result.values.toList();
  }

  Future<Track> _getTrackMetadataFromGenericPath(GenericPath path) async {
    final metadata = readMetadata(File(path.filename!), getImage: true);
    final tempPlayer = AudioPlayer();
    final duration = await tempPlayer.setFilePath(path.filename!);
    return Track(
      id: path.id,
      name: metadata.title ?? "",
      artist: metadata.artist ?? "",
      album: metadata.album ?? "",
      genre: metadata.genres.isEmpty ? metadata.genres.join(", ") : "",
      trackNumber: metadata.trackNumber ?? 0,
      path: path.filename!,
      duration: duration ?? Duration.zero,
      imageBytes: metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
    );
  }

  @override
  Future<void> setTrack(Track track) async {
    // TODO: maybe detect here if the path is an URL or not
    // and call setUrl if that's the case
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
