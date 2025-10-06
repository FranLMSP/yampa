import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/widgets/track_list/track_item.dart';

class TrackList extends ConsumerWidget {
  const TrackList({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    return Expanded(
      child: ListView(
        children: tracks .map(
          (track) => TrackItem(
            track: track,
            onTap: onTap,
          )).toList()
      ),
    );
  }
}
