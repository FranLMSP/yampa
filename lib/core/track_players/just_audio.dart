import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
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
    final result = [];
    for (final path in paths) {
      if (path.filename != null) {
        try {
          final metadata = await MetadataRetriever.fromFile(File(path.filename!));
          final track = Track(
            id: path.id,
            name: metadata.trackName ?? "Unknown Title",
            artist: metadata.trackArtistNames?.join(", ") ?? "Unknown Artist",
            album: metadata.albumName ?? "Unknown Album",
            genre: metadata.albumName ?? "Unknown Genre",
            trackNumber: metadata.trackNumber ?? 0,
            path: path.filename!,
            duration: Duration(milliseconds: metadata.trackDuration!),
            imageBytes: metadata.albumArt,
          );
          result.add(track);
        } catch (e) {
          // handle error
        }
      } else if (path.folder != null) {
        // find all files in folder, and get valid audio files to convert them to Track
      }
    }
    return [];
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