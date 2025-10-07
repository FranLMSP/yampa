import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/player_controller_provider.dart';
import 'package:music_player/widgets/player/player_buttons.dart';
import 'package:music_player/widgets/player/player_image.dart';
import 'package:music_player/widgets/player/player_slider.dart';
import 'package:music_player/widgets/player/player_total_minutes.dart';

class BigPlayer extends ConsumerWidget {

  const BigPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playerControllerProvider).currentTrack;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlayerImage(track: track),
        const SizedBox(height: 20),
        Text(
          track?.name ?? "",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          track?.artist ?? "",
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const PlayerButtons(),
        const PlayerSlider(),
        const PlayerTotalMinutes(),
      ],
    );
  }
}



