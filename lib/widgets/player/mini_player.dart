import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/player/buttons/play_and_pause.dart';
import 'package:yampa/widgets/player/player_image.dart';
import 'package:yampa/widgets/player/player_total_minutes.dart';

class MiniPlayer extends ConsumerWidget {

  const MiniPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playerControllerProvider).currentTrack;
    if (track == null) {
      return Row();
    }
    return SizedBox(
      height: 75,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: .2,
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                // TODO: use PlayerImage here
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
                    Text(
                      track.displayName(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(track.album),
                  ],
                ),
              ),
              Row(
                children: [
                  PlayerTotalMinutes(),
                  PlayAndPauseButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
