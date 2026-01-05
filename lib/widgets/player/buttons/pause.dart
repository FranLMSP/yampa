import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class PauseButton extends ConsumerWidget {
  const PauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    return IconButton(
      onPressed: () async {
        await playerControllerNotifier.pause();
      },
      icon: const Icon(Icons.pause),
      iconSize: 48,
      tooltip: ref.read(localizationProvider.notifier).translate(
        LocalizationKeys.pause,
      ),
    );
  }
}
