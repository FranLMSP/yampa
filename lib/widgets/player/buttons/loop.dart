import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class LoopButton extends ConsumerWidget {
  const LoopButton({super.key});

  IconData _getIcon(PlayerController playerController) {
    final iconMap = {
      LoopMode.singleTrack: Icons.repeat_one,
      LoopMode.infinite: Icons.repeat,
      LoopMode.startToEnd: Icons.playlist_play,
      LoopMode.none: Icons.not_interested,
    };
    return iconMap[playerController.loopMode]!;
  }

  String _getTooltop(PlayerController playerController) {
    final loopModeMap = {
      LoopMode.singleTrack: "Replaying a single song",
      LoopMode.infinite: "Replaying playlist",
      LoopMode.startToEnd: "Playing playlist from start to end",
      LoopMode.none: "Not replaying",
    };
    return loopModeMap[playerController.loopMode]!;
  }

  void _toggleLoopMode(PlayerControllerNotifier playerControllerNotifier) {
    playerControllerNotifier.toggleLoopMode();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    return IconButton(
      icon: Icon(_getIcon(playerController)),
      tooltip: _getTooltop(playerController),
      onPressed: () {
        _toggleLoopMode(playerControllerNotifier);
      },
    );
  }
}
