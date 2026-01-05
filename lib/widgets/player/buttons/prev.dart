import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class PrevButton extends ConsumerWidget {
  const PrevButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final playerNotifierController = ref.watch(
          playerControllerProvider.notifier,
        );
        await playerNotifierController.prev();
      },
      icon: const Icon(Icons.skip_previous),
      iconSize: 32,
      tooltip: ref.read(localizationProvider.notifier).translate(
        LocalizationKeys.previous,
      ),
    );
  }
}
