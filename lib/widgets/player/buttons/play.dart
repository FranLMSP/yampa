import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/track_players/just_audio.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  void _onPressed(BuildContext context, PlayerControllerNotifier playerControllerNotifier) async {
    await playerControllerNotifier.stop();
    playerControllerNotifier.setTrackPlayer(JustAudioProvider());
    playerControllerNotifier.setCurrentTrack(Track(
      id: '1',
      name: 'Sample Track',
      artist: 'Unknown Artist',
      album: 'Unknown Album',
      genre: 'Unknown Genre',
      trackNumber: 0,
      duration: Duration(minutes: 3, seconds: 30),
      path: 'file:///home/fran/Music/sample.mp3',
    ));
    // TODO: show snackbar if error occurs
    await playerControllerNotifier.play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    return ElevatedButton(
      onPressed: () => _onPressed(context, playerControllerNotifier),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: const Icon(Icons.play_arrow, size: 30),
    );
  }
}
