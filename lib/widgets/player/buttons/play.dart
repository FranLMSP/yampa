import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  void _onPressed(BuildContext context, PlayerControllerNotifier playerControllerNotifier) async {
    await playerControllerNotifier.play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    return ElevatedButton(
      onPressed: () => _onPressed(context, playerControllerNotifier),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: const Icon(Icons.play_arrow, size: 30),
    );
  }
}
