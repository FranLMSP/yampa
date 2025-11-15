import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class BackwardSecondsButton extends ConsumerWidget {
  const BackwardSecondsButton({super.key});

  Future<void> _backward(PlayerControllerNotifier playerControllerNotifier, PlayerController playerController) async {
      if (playerController.currentTrackId == null) {
        return;
      }
      final currentPosition = await playerController.getCurrentPosition();
      var newPosition = currentPosition - const Duration(seconds: 10);
      if (newPosition.isNegative) {
        newPosition = Duration.zero;
      }
      await playerControllerNotifier.seek(newPosition);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    final playerController = ref.watch(playerControllerProvider);

    return IconButton(
      icon: const Icon(Icons.replay_10),
      tooltip: 'Back 10 seconds',
      onPressed: () async {
        _backward(playerControllerNotifier, playerController);
      },
    );
  }
}
