import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    return IconButton(
      onPressed: () async {
        await playerControllerNotifier.play();
      },
      icon: const Icon(Icons.play_arrow),
      iconSize: 48,
    );
  }
}
