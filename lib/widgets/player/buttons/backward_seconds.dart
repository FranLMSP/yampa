import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class BackwardSecondsButton extends ConsumerWidget {
  const BackwardSecondsButton({super.key});

  Future<void> _backward(WidgetRef ref, String? currentTrackId) async {
    if (currentTrackId == null) {
      return;
    }
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final currentPosition = await playerController.getCurrentPosition();
    var newPosition = currentPosition - const Duration(seconds: 10);
    if (newPosition.isNegative) {
      newPosition = Duration.zero;
    }
    await playerControllerNotifier.seek(newPosition);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );

    return IconButton(
      icon: const Icon(Icons.replay_10),
      tooltip: ref.read(localizationProvider.notifier).translate(
        LocalizationKeys.backwardSeconds,
      ).replaceFirst('{}', '10'),
      onPressed: () async {
        _backward(ref, currentTrackId);
      },
    );
  }
}
