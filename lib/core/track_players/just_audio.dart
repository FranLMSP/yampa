import 'dart:async';
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
  List<Track> fetchTracks(List<GenericPath> paths) {
    final List<Track> result = [];
    for (final path in paths) {
      if (path.filename != null) {
        try {
          result.add(_getTrackMetadataFromGenericPath(path));
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
            result.add(_getTrackMetadataFromGenericPath(effectivePath));
          } catch (e) {
            // handle error
          }
        }
      }
    }
    return result;
  }

  Track _getTrackMetadataFromGenericPath(GenericPath path) {
    final metadata = readMetadata(File(path.filename!), getImage: true);
    return Track(
      id: path.id,
      name: metadata.title ?? "Unknown Title",
      artist: metadata.artist ?? "Unknown Artist",
      album: metadata.album ?? "Unknown Album",
      genre: metadata.genres.isEmpty ? metadata.genres.join(", ") : "Unknown Genre",
      trackNumber: metadata.trackNumber ?? 0,
      path: path.filename!,
      duration: metadata.duration ?? Duration.zero,
      imageBytes: metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
    );
  }

  @override
  Future<void> setTrack(Track track) async {
    await _player.setUrl(track.path);
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
}