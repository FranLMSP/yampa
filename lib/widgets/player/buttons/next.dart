import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class NextButton extends ConsumerWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final playerNotifierController = ref.read(
          playerControllerProvider.notifier,
        );
        await playerNotifierController.next();
      },
      icon: const Icon(Icons.skip_next),
      iconSize: 32,
    );
  }
}
