import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/utils.dart';

class LoopButton extends ConsumerWidget {
  const LoopButton({super.key});

  IconData _getIcon(LoopMode loopMode) {
    final iconMap = {
      LoopMode.singleTrack: Icons.repeat_one,
      LoopMode.infinite: Icons.repeat,
      LoopMode.startToEnd: Icons.playlist_play,
      LoopMode.none: Icons.not_interested,
    };
    return iconMap[loopMode]!;
  }

  String _getTooltopMessage(LoopMode loopMode) {
    final loopModeMap = {
      LoopMode.singleTrack: "Replaying a single song",
      LoopMode.infinite: "Replaying playlist",
      LoopMode.startToEnd: "Playing playlist from start to end",
      LoopMode.none: "Not replaying",
    };
    return "Replay mode: ${loopModeMap[loopMode]!}";
  }

  Future<void> _toggleLoopMode(PlayerControllerNotifier playerControllerNotifier) async {
    final newLoopMode = await playerControllerNotifier.toggleLoopMode();
    await showButtonActionMessage(_getTooltopMessage(newLoopMode));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loopMode = ref.watch(playerControllerProvider.select((p) => p.value?.loopMode ?? LoopMode.none));
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    return IconButton(
      icon: Icon(_getIcon(loopMode)),
      tooltip: _getTooltopMessage(loopMode),
      onPressed: () async {
        await _toggleLoopMode(playerControllerNotifier);
      },
    );
  }
}
