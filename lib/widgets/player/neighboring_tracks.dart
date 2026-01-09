import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/player/player_image.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class NeighboringTracks extends ConsumerWidget {
  const NeighboringTracks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final prevTrack = playerController.getPreviousTrack();
    final nextTrack = playerController.getNextTrack();

    if (prevTrack == null && nextTrack == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final playerNotifierController = ref.read(
                  playerControllerProvider.notifier,
                );
                await playerNotifierController.prev();
              },
              child: prevTrack != null
                  ? _buildTrackInfo(
                      context,
                      prevTrack,
                      ref
                          .read(localizationProvider.notifier)
                          .translate(LocalizationKeys.previous),
                      CrossAxisAlignment.start,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: InkWell(
              onTap: () async {
                final playerNotifierController = ref.read(
                  playerControllerProvider.notifier,
                );
                await playerNotifierController.next();
              },
              child: nextTrack != null
                  ? _buildTrackInfo(
                      context,
                      nextTrack,
                      ref
                          .read(localizationProvider.notifier)
                          .translate(LocalizationKeys.next),
                      CrossAxisAlignment.end,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    Track track,
    String label,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignment == CrossAxisAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (alignment == CrossAxisAlignment.end) ...[
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      track.displayTitle(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      track.artist.isNotEmpty ? track.artist : "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PlayerImage(track: track, width: 40, height: 40, iconSize: 20),
            ] else ...[
              PlayerImage(track: track, width: 40, height: 40, iconSize: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.displayTitle(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track.artist.isNotEmpty ? track.artist : "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
