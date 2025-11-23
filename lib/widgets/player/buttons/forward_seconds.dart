import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class ForwardSecondsButton extends ConsumerWidget {
  const ForwardSecondsButton({super.key});

  Future<void> _forward(Map<String, Track> tracks, PlayerControllerNotifier playerControllerNotifier, PlayerController playerController) async {
      if (playerController.currentTrackId == null) {
        return;
      }
      final currentPosition = await playerController.getCurrentPosition();
      var newPosition = currentPosition + const Duration(seconds: 10);
      final track = tracks[playerController.currentTrackId];
      if (track == null) {
        return;
      }
      if (newPosition > track.duration) {
        newPosition = track.duration;
      }
      await playerControllerNotifier.seek(newPosition);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    final playerController = ref.watch(playerControllerProvider);

    return IconButton(
      icon: const Icon(Icons.forward_10),
      tooltip: 'Forward 10 seconds',
      onPressed: () async {
        _forward(tracks, playerControllerNotifier, playerController);
      },
    );
  }
}
