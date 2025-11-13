import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class SpeedButton extends ConsumerWidget {
  const SpeedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    final speed = playerController.speed;
    final formattedSpeed = speed.toStringAsFixed(2).replaceAll(RegExp(r'([.]*0+)$'), '');

    final List<double> speedValues = [0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00];

    return PopupMenuButton<double>(
      tooltip: "Playback speed",
      icon: Chip(
        label: Text('x$formattedSpeed'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      onSelected: (double selectedSpeed) async {
        await playerControllerNotifier.setSpeed(selectedSpeed);
      },
      itemBuilder: (BuildContext context) {
        return speedValues.map((double speedOption) {
          return PopupMenuItem<double>(
            value: speedOption,
            child: Text("x${speedOption.toStringAsFixed(2)}"),
          );
        }).toList();
      },
    );
  }
}
