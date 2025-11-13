import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({super.key});

  IconData _getIcon(PlayerController playerController) {
    final iconMap = {
      ShuffleMode.sequential: Icons.queue_music,
      ShuffleMode.random: Icons.shuffle,
      ShuffleMode.randomBasedOnHistory: Icons.history,
    };
    return iconMap[playerController.shuffleMode]!;
  }

  String _getTooltop(PlayerController playerController) {
    final shuffleModeMap = {
      ShuffleMode.sequential: "Shuffle disabled",
      ShuffleMode.random: "Randomized",
      ShuffleMode.randomBasedOnHistory: "Randomized special",
    };
    return shuffleModeMap[playerController.shuffleMode]!;
  }

  Future<void> _toggleShuffleMode(PlayerControllerNotifier playerControllerNotifier) async {
    await playerControllerNotifier.toggleShuffleMode();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    return IconButton(
      icon: Icon(_getIcon(playerController)),
      tooltip: _getTooltop(playerController),
      onPressed: () async {
        await _toggleShuffleMode(playerControllerNotifier);
      },
    );
  }
}
