import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class PauseButton extends ConsumerWidget {
  const PauseButton({super.key});

  void _onPressed(PlayerControllerNotifier playerControllerNotifier) async {
    await playerControllerNotifier.pause();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    return ElevatedButton(
      onPressed: () => _onPressed(playerControllerNotifier),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: const Icon(Icons.pause, size: 30),
    );
  }
}
