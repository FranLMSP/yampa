import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/common/display_track_title.dart';
import 'package:yampa/widgets/main_browser/playlists/display_track_metadata.dart';
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
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final track = tracks[currentTrackId];
    final trackQueueDisplayMode = ref.watch(
      playerControllerProvider.select((p) => p.trackQueueDisplayMode),
    );

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trackQueueDisplayMode == TrackQueueDisplayMode.image)
                PlayerImage(track: track)
              else
                const Expanded(child: UpcomingTracksList()),
              const SizedBox(height: 5),
              DisplayTrackTitle(track: track),
              DisplayTrackMetadata(track: track),
              const PlayerSlider(),
              const PlayerButtons(),
              const PlayerTotalMinutes(),
              const SizedBox(height: 70),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: NeighboringTracks(),
        ),
      ],
    );
  }
}
