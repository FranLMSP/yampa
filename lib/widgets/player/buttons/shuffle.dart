import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({super.key});

  IconData _getIcon(ShuffleMode shuffleMode) {
    final iconMap = {
      ShuffleMode.sequential: Icons.queue_music,
      ShuffleMode.random: Icons.shuffle,
      ShuffleMode.randomBasedOnHistory: Icons.history,
    };
    return iconMap[shuffleMode]!;
  }

  String _getShuffleModeLabel(
    ShuffleMode shuffleMode,
    LocalizationNotifier notifier,
  ) {
    final shuffleModeMap = {
      ShuffleMode.sequential: LocalizationKeys.shuffleModeDisabled,
      ShuffleMode.random: LocalizationKeys.shuffleModeRandomized,
      ShuffleMode.randomBasedOnHistory: LocalizationKeys.shuffleModeRecommended,
    };
    return notifier.translate(shuffleModeMap[shuffleMode]!);
  }

  String _getTooltipMessage(
    ShuffleMode shuffleMode,
    LocalizationNotifier notifier,
  ) {
    final label = _getShuffleModeLabel(shuffleMode, notifier);
    return notifier
        .translate(LocalizationKeys.shuffleModeChanged)
        .replaceFirst('{}', label);
  }

  Future<void> _toggleShuffleMode(
    PlayerControllerNotifier playerControllerNotifier,
    LocalizationNotifier localizationNotifier,
  ) async {
    final newShuffleMode = await playerControllerNotifier.toggleShuffleMode();
    await showButtonActionMessage(
      _getTooltipMessage(newShuffleMode, localizationNotifier),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuffleMode = ref.watch(
      playerControllerProvider.select((p) => p.shuffleMode),
    );
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final localizationNotifier = ref.read(localizationProvider.notifier);
    return IconButton(
      icon: Icon(_getIcon(shuffleMode)),
      tooltip: _getTooltipMessage(shuffleMode, localizationNotifier),
      onPressed: () async {
        await _toggleShuffleMode(
          playerControllerNotifier,
          localizationNotifier,
        );
      },
    );
  }
}
