import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class VolumeControls extends ConsumerWidget {
  const VolumeControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final volume = playerController.volume;
    final equalizerGains = playerController.equalizerGains;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Master Volume",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              const Icon(Icons.volume_mute),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    ref.read(playerControllerProvider.notifier).setVolume(value);
                  },
                ),
              ),
              const Icon(Icons.volume_up),
              Text("${(volume * 100).toInt()}%"),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Equalizer",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (equalizerGains.isEmpty)
            const Expanded(
              child: Center(
                child: Text("Equalizer not available for the current backend or platform."),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: equalizerGains.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: equalizerGains[index],
                              min: -10.0,
                              max: 10.0,
                              onChanged: (value) {
                                final newGains = List<double>.from(equalizerGains);
                                newGains[index] = value;
                                ref
                                    .read(playerControllerProvider.notifier)
                                    .setEqualizerGains(newGains);
                              },
                            ),
                          ),
                        ),
                        Text("${equalizerGains[index].toStringAsFixed(1)} dB"),
                        Text("Band ${index + 1}"),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(playerControllerProvider.notifier).restoreDefaults();
              },
              icon: const Icon(Icons.restore),
              label: const Text("Restore defaults"),
            ),
          ),
        ],
      ),
    );
  }
}
