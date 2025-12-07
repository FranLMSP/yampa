import 'package:flutter/material.dart';
import 'package:yampa/widgets/player/buttons/backward_seconds.dart';
import 'package:yampa/widgets/player/buttons/clip.dart';
import 'package:yampa/widgets/player/buttons/favorite.dart';
import 'package:yampa/widgets/player/buttons/forward_seconds.dart';
import 'package:yampa/widgets/player/buttons/info.dart';
import 'package:yampa/widgets/player/buttons/loop.dart';
import 'package:yampa/widgets/player/buttons/next.dart';
import 'package:yampa/widgets/player/buttons/play_and_pause.dart';
import 'package:yampa/widgets/player/buttons/playlist.dart';
import 'package:yampa/widgets/player/buttons/player_display_mode.dart';
import 'package:yampa/widgets/player/buttons/prev.dart';
import 'package:yampa/widgets/player/buttons/shuffle.dart';
import 'package:yampa/widgets/player/buttons/speed.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12.5,
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
            PlayerDisplayModeButton(),
            FavoriteButton(),
            ClipButton(),
            LoopButton(),
            ShuffleButton(),
            SpeedButton(),
            PlaylistButton(),
            InfoButton(),
          ],
        ),
      ],
    );
  }
}
