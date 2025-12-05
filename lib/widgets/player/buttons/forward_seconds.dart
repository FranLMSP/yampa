import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class ForwardSecondsButton extends ConsumerWidget {
  const ForwardSecondsButton({super.key});

  Future<void> _forward(WidgetRef ref, Map<String, Track> tracks, String? currentTrackId) async {
      if (currentTrackId == null) {
        return;
      }
      final playerControllerState = ref.read(playerControllerProvider);
      final playerController = playerControllerState.value;
      if (playerController == null) return;
      final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
      final currentPosition = await playerController.getCurrentPosition();
      var newPosition = currentPosition + const Duration(seconds: 10);
      final track = tracks[currentTrackId];
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
    final tracks = ref.watch(tracksProvider);
    final currentTrackId = ref.watch(playerControllerProvider.select((p) => p.value?.currentTrackId));

    return IconButton(
      icon: const Icon(Icons.forward_10),
      tooltip: 'Forward 10 seconds',
      onPressed: () async {
        _forward(ref, tracks, currentTrackId);
      },
    );
  }
}
