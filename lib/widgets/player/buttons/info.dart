import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_info_dialog.dart';

class InfoButton extends ConsumerWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTracks = ref.watch(tracksProvider);
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.value?.currentTrackId),
    );
    final track = allTracks[currentTrackId];
    if (track == null) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.info),
      tooltip: 'Info',
      onPressed: () async {
        showDialog(
          context: context,
          builder: (BuildContext ctx) => TrackInfoDialog(track: track),
        );
      },
    );
  }
}
