import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class PlayerDisplayModeButton extends ConsumerWidget {
  const PlayerDisplayModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackQueueDisplayMode = ref.watch(
      playerControllerProvider.select((p) => p.trackQueueDisplayMode),
    );
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );

    return IconButton(
      icon: Icon(
        trackQueueDisplayMode == TrackQueueDisplayMode.image
            ? Icons.queue_music
            : Icons.image,
      ),
      tooltip: trackQueueDisplayMode == TrackQueueDisplayMode.image
          ? "Show upcoming tracks"
          : "Show track image",
      onPressed: () async {
        final newMode = trackQueueDisplayMode == TrackQueueDisplayMode.image
            ? TrackQueueDisplayMode.list
            : TrackQueueDisplayMode.image;
        await playerControllerNotifier.setTrackQueueDisplayMode(newMode);
      },
    );
  }
}
