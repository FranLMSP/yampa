import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class PrevButton extends ConsumerWidget {
  const PrevButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final playerNotifierController = ref.watch(
      playerControllerProvider.notifier,
    );
    return IconButton(
      onPressed: () async {
        await playerNotifierController.prev(tracks);
      },
      icon: const Icon(Icons.skip_previous),
      iconSize: 32,
    );
  }
}
