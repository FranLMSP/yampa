import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/player/player_buttons.dart';
import 'package:yampa/widgets/player/player_image.dart';
import 'package:yampa/widgets/player/player_slider.dart';
import 'package:yampa/widgets/player/player_total_minutes.dart';
import 'package:yampa/widgets/player/neighboring_tracks.dart';
import 'package:yampa/widgets/player/upcoming_tracks_list.dart';
import 'package:yampa/core/player/enums.dart';

class BigPlayer extends ConsumerWidget {
  const BigPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.value?.currentTrackId),
    );
    final track = tracks[currentTrackId];
    final trackQueueDisplayMode = ref.watch(
      playerControllerProvider.select((p) => p.value?.trackQueueDisplayMode),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (trackQueueDisplayMode == TrackQueueDisplayMode.image)
          PlayerImage(track: track)
        else
          const Expanded(child: UpcomingTracksList()),
        const SizedBox(height: 20),
        Text(
          track != null ? track.displayName() : "",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          track?.album ?? "",
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const PlayerSlider(),
        const PlayerButtons(),
        const SizedBox(height: 10),
        const PlayerTotalMinutes(),
        const SizedBox(height: 20),
        const NeighboringTracks(),
      ],
    );
  }
}
