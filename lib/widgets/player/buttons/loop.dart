import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class LoopButton extends ConsumerWidget {
  const LoopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    final playerController = ref.read(playerControllerProvider);

    return IconButton(
      icon: const Icon(Icons.loop),
      tooltip: 'Loop mode',
      onPressed: () async {
        print("clicked on loop mode");
      },
    );
  }
}

