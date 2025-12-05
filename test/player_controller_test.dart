
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/core/player/enums.dart';

void main() {
  test('PlayerControllerNotifier.next notifies select listeners', () async {
    final container = ProviderContainer();
    final notifier = container.read(playerControllerProvider.notifier);

    // Initial state
    final initialId = container.read(playerControllerProvider).currentTrackId;
    print('Initial track ID: $initialId');

    // Listen to currentTrackId using select
    String? capturedId;
    container.listen<String?>(
      playerControllerProvider.select((p) => p.currentTrackId),
      (previous, next) {
        print('Select listener fired: $previous -> $next');
        capturedId = next;
      },
      fireImmediately: true,
    );

    // Mock tracks
    final tracks = {
      'track1': Track(id: 'track1', path: '/path/1', name: 'Track 1', artist: 'Artist 1', album: 'Album 1', genre: 'Genre 1', trackNumber: 1, duration: Duration(seconds: 100)),
      'track2': Track(id: 'track2', path: '/path/2', name: 'Track 2', artist: 'Artist 2', album: 'Album 2', genre: 'Genre 2', trackNumber: 2, duration: Duration(seconds: 100)),
    };

    // Set up queue
    // Mock PlayerBackend
    final mockBackend = MockPlayerBackend();
    await notifier.setTrackPlayer(mockBackend);

    // Create and set playlist
    final playlist = Playlist(
      id: 'p1',
      name: 'Playlist 1',
      description: 'Desc',
      trackIds: ['track1', 'track2'],
    );
    await notifier.reloadPlaylist(playlist, tracks);

    // Start playing track1
    await notifier.setCurrentTrack(tracks['track1']!);
    
    // Reset capturedId
    capturedId = null;

    print('Calling next() 1...');
    await notifier.next(tracks);
    
    expect(capturedId, equals('track2'), reason: 'Listener should have fired for next() 1');

    // Reset capturedId
    capturedId = null;

    print('Calling next() 2...');
    await notifier.next(tracks);
    
    // Should loop back to track1 because loopMode is infinite by default?
    // Let's check default loopMode. It is infinite.
    expect(capturedId, equals('track1'), reason: 'Listener should have fired for next() 2');
  });
}

class MockPlayerBackend implements PlayerBackend {
  @override
  Future<List<Track>> fetchTracks(List<GenericPath> paths, TracksNotifier tracksNotifier, LoadedTracksCountProviderNotifier loadedTracksCountNotifier) async => [];

  @override
  Future<Duration> getCurrentPosition() async => Duration.zero;

  @override
  Duration getCurrentTrackDuration() => Duration.zero;

  @override
  bool hasTrackFinishedPlaying() => false;

  @override
  Future<void> init() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<Duration> setTrack(Track track) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Duration.zero;
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}
}
