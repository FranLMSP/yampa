import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class TrackItem extends ConsumerWidget {
  const TrackItem({super.key, required this.track, this.onTap});

  final Track track;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerProviderNotifier = ref.read(playerControllerProvider.notifier);
    return InkWell(
      onTap: () async {
        if (onTap != null) {
          onTap!();
        }
        await playerProviderNotifier.stop();
        playerProviderNotifier.setCurrentTrack(track);
        await playerProviderNotifier.play();
      },
      // TODO: highlight the currently playing track
      child: Card(
        child: ListTile(
          title: Text(track.name),
          subtitle: Text(track.artist),
          trailing: Text('${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
        ),
      ),
    );
  }
}
