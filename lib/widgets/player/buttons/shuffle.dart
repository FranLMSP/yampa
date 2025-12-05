import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/utils.dart';

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({super.key});

  IconData _getIcon(ShuffleMode shuffleMode) {
    final iconMap = {
      ShuffleMode.sequential: Icons.queue_music,
      ShuffleMode.random: Icons.shuffle,
      ShuffleMode.randomBasedOnHistory: Icons.history,
    };
    return iconMap[shuffleMode]!;
  }

  String _getTooltopMessage(ShuffleMode shuffleMode) {
    final shuffleModeMap = {
      ShuffleMode.sequential: "Shuffle disabled",
      ShuffleMode.random: "Randomized",
      ShuffleMode.randomBasedOnHistory: "Recommended",
    };
    return "Shuffle mode: ${shuffleModeMap[shuffleMode]!}";
  }

  Future<void> _toggleShuffleMode(PlayerControllerNotifier playerControllerNotifier) async {
    final newShuffleMode = await playerControllerNotifier.toggleShuffleMode();
    await showButtonActionMessage(_getTooltopMessage(newShuffleMode));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuffleMode = ref.watch(playerControllerProvider.select((p) => p.shuffleMode));
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    return IconButton(
      icon: Icon(_getIcon(shuffleMode)),
      tooltip: _getTooltopMessage(shuffleMode),
      onPressed: () async {
        await _toggleShuffleMode(playerControllerNotifier);
      },
    );
  }
}
