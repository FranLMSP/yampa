import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.watch(
      playerControllerProvider.notifier,
    );
    return IconButton(
      onPressed: () async {
        await playerControllerNotifier.play();
      },
      icon: const Icon(Icons.play_arrow),
      iconSize: 48,
      tooltip: ref
          .read(localizationProvider.notifier)
          .translate(LocalizationKeys.play),
    );
  }
}
