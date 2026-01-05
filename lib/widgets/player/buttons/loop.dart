import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class LoopButton extends ConsumerWidget {
  const LoopButton({super.key});

  IconData _getIcon(LoopMode loopMode) {
    final iconMap = {
      LoopMode.singleTrack: Icons.repeat_one,
      LoopMode.infinite: Icons.repeat,
      LoopMode.startToEnd: Icons.playlist_play,
      LoopMode.none: Icons.not_interested,
    };
    return iconMap[loopMode]!;
  }

  String _getLoopModeLabel(LoopMode loopMode, LocalizationNotifier notifier) {
    final loopModeMap = {
      LoopMode.singleTrack: LocalizationKeys.loopModeSingle,
      LoopMode.infinite: LocalizationKeys.loopModePlaylist,
      LoopMode.startToEnd: LocalizationKeys.loopModeStartToEnd,
      LoopMode.none: LocalizationKeys.loopModeNone,
    };
    return notifier.translate(loopModeMap[loopMode]!);
  }

  String _getTooltipMessage(LoopMode loopMode, LocalizationNotifier notifier) {
    final label = _getLoopModeLabel(loopMode, notifier);
    return notifier
        .translate(LocalizationKeys.loopModeChanged)
        .replaceFirst('{}', label);
  }

  Future<void> _toggleLoopMode(
    PlayerControllerNotifier playerControllerNotifier,
    LocalizationNotifier localizationNotifier,
  ) async {
    final newLoopMode = await playerControllerNotifier.toggleLoopMode();
    await showButtonActionMessage(
      _getTooltipMessage(newLoopMode, localizationNotifier),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loopMode = ref.watch(
      playerControllerProvider.select((p) => p.loopMode),
    );
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final localizationNotifier = ref.read(localizationProvider.notifier);
    return IconButton(
      icon: Icon(_getIcon(loopMode)),
      tooltip: _getTooltipMessage(loopMode, localizationNotifier),
      onPressed: () async {
        await _toggleLoopMode(playerControllerNotifier, localizationNotifier);
      },
    );
  }
}
