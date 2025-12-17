import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/common/track_title.dart';
import 'package:yampa/widgets/player/buttons/play_and_pause.dart';
import 'package:yampa/widgets/player/mini_slider.dart';
import 'package:yampa/widgets/player/player_image.dart';
import 'package:yampa/widgets/player/player_total_minutes.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, this.onTap});

  final Function? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final tracks = ref.watch(tracksProvider);
    final track = tracks[currentTrackId];
    if (track == null) {
      return Row();
    }
    return InkWell(
      onTap: () => onTap != null ? onTap!() : null,
      child: SizedBox(
        height: 75,
        child: Column(
          children: [
            MiniPlayerSlider(),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: PlayerImage(
                    track: track,
                    width: 50.0,
                    height: 50.0,
                    iconSize: 40.0,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TrackTitle(track: track, fontSize: 16),
                      Text(track.album),
                    ],
                  ),
                ),
                Row(children: [PlayerTotalMinutes(), PlayAndPauseButton()]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
