import 'package:flutter/material.dart';
import 'package:music_player/widgets/player/buttons/next.dart';
import 'package:music_player/widgets/player/buttons/play_and_pause.dart';
import 'package:music_player/widgets/player/buttons/prev.dart';

class PlayerButtons extends StatelessWidget {

  const PlayerButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        PrevButton(),
        PlayAndPauseButton(),
        NextButton(),
      ],
    );
  }
}

