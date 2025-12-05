import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class NextButton extends ConsumerWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);

    final playerNotifierController = ref.read(playerControllerProvider.notifier);
    return IconButton(
      onPressed: () async {
        await playerNotifierController.next(tracks);
      },
      icon: const Icon(Icons.skip_next),
      iconSize: 32,
    );
  }
}
