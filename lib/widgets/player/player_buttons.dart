import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/player/buttons/next.dart';
import 'package:music_player/widgets/player/buttons/play_and_pause.dart';
import 'package:music_player/widgets/player/buttons/prev.dart';

class PlayerButtons extends ConsumerWidget {

  const PlayerButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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

