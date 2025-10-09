import 'package:flutter/material.dart';
import 'package:music_player/widgets/player/buttons/backward_seconds.dart';
import 'package:music_player/widgets/player/buttons/clip.dart';
import 'package:music_player/widgets/player/buttons/favorite.dart';
import 'package:music_player/widgets/player/buttons/forward_seconds.dart';
import 'package:music_player/widgets/player/buttons/loop.dart';
import 'package:music_player/widgets/player/buttons/next.dart';
import 'package:music_player/widgets/player/buttons/play_and_pause.dart';
import 'package:music_player/widgets/player/buttons/playlist.dart';
import 'package:music_player/widgets/player/buttons/prev.dart';
import 'package:music_player/widgets/player/buttons/shuffle.dart';
import 'package:music_player/widgets/player/buttons/speed.dart';

class PlayerButtons extends StatelessWidget {

  const PlayerButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            BackwardSecondsButton(),
            PrevButton(),
            PlayAndPauseButton(),
            NextButton(),
            ForwardSecondsButton(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FavoriteButton(),
            ClipButton(),
            LoopButton(),
            ShuffleButton(),
            SpeedButton(),
            PlaylistButton(),
          ],
        ),
      ],
    );
  }
}

