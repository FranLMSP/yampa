import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/player/buttons/play_and_pause.dart';
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
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Icon(Icons.music_note, size: 40, color: Colors.white),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Sample title",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Sample artist and album"),
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
