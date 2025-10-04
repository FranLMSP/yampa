import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class NextButton extends ConsumerWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerNotifierController = ref.read(playerControllerProvider.notifier);
    return ElevatedButton(
      onPressed: () {
        ref.invalidate(playerControllerProvider);
        playerNotifierController.next();
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: const Icon(Icons.skip_next, size: 30),
    );
  }
}
