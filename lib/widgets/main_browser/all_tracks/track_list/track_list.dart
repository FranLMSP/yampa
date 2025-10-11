import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:music_player/widgets/misc/loader.dart';

class TrackList extends ConsumerWidget {
  const TrackList({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tracks = ref.watch(tracksProvider);
    final initialLoadDone = ref.watch(localPathsProvider).initialLoadDone;
    if (!initialLoadDone) {
      return CustomLoader();
    }
    if (initialLoadDone && tracks.isEmpty) {
      return Text("No tracks found. Go to the Added Paths tab to add some!");
    }
    return ListView(
      children: tracks .map(
        (track) => TrackItem(
          track: track,
          onTap: onTap,
        )
      ).toList()
    );
  }
}
