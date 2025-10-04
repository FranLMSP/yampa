import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
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
  Future<List<Track>> fetchTracks() async {
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