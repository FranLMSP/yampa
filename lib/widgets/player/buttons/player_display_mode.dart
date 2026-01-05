import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

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
    final localizationNotifier = ref.read(localizationProvider.notifier);

    return IconButton(
      icon: Icon(
        trackQueueDisplayMode == TrackQueueDisplayMode.image
            ? Icons.queue_music
            : Icons.image,
      ),
      tooltip: trackQueueDisplayMode == TrackQueueDisplayMode.image
          ? localizationNotifier.translate(LocalizationKeys.showUpcomingTracks)
          : localizationNotifier.translate(LocalizationKeys.showTrackImage),
      onPressed: () async {
        final newMode = trackQueueDisplayMode == TrackQueueDisplayMode.image
            ? TrackQueueDisplayMode.list
            : TrackQueueDisplayMode.image;
        await playerControllerNotifier.setTrackQueueDisplayMode(newMode);
      },
    );
  }
}
