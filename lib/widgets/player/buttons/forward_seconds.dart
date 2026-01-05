import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class ForwardSecondsButton extends ConsumerWidget {
  const ForwardSecondsButton({super.key});

  Future<void> _forward(WidgetRef ref, String? currentTrackId) async {
    if (currentTrackId == null) {
      return;
    }
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final currentPosition = await playerController.getCurrentPosition();
    var newPosition = currentPosition + const Duration(seconds: 10);
    final track = playerController.tracks[currentTrackId];
    if (track == null) {
      return;
    }
    if (newPosition > track.duration) {
      newPosition = track.duration;
    }
    await playerControllerNotifier.seek(newPosition);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );

    return IconButton(
      icon: const Icon(Icons.forward_10),
      tooltip: ref
          .read(localizationProvider.notifier)
          .translate(LocalizationKeys.forwardSeconds)
          .replaceFirst('{}', '10'),
      onPressed: () async {
        _forward(ref, currentTrackId);
      },
    );
  }
}
