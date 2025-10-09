import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class ForwardSecondsButton extends ConsumerWidget {
  const ForwardSecondsButton({super.key});

  Future<void> _forward(PlayerControllerNotifier playerControllerNotifier, PlayerController playerController) async {
      if (playerController.currentTrack == null) {
        return;
      }
      final currentPosition = await playerController.getCurrentPosition();
      var newPosition = currentPosition + const Duration(seconds: 10);
      if (newPosition > playerController.currentTrack!.duration) {
        newPosition = playerController.currentTrack!.duration;
      }
      await playerControllerNotifier.seek(newPosition);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    final playerController = ref.watch(playerControllerProvider);

    return IconButton(
      icon: const Icon(Icons.forward_10),
      tooltip: 'Forward 10 seconds',
      onPressed: () async {
        _forward(playerControllerNotifier, playerController);
      },
    );
  }
}
