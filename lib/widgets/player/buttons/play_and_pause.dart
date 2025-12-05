import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/widgets/player/buttons/play.dart';
import 'package:yampa/widgets/player/buttons/pause.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class PlayAndPauseButton extends ConsumerWidget {

  const PlayAndPauseButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider.select((p) => p.value?.state));

    return playerState == PlayerState.playing
      ? PauseButton()
      : PlayButton();
  }
}
