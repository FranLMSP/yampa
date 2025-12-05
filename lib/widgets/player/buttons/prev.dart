import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class PrevButton extends ConsumerWidget {
  const PrevButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final playerNotifierController = ref.watch(playerControllerProvider.notifier);
    return ElevatedButton(
      onPressed: () async {
        await playerNotifierController.prev(tracks);
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: const Icon(Icons.skip_previous, size: 20),
    );
  }
}
