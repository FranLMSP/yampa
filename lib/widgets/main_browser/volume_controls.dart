import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class VolumeControls extends ConsumerStatefulWidget {
  const VolumeControls({super.key});

  @override
  ConsumerState<VolumeControls> createState() => _VolumeControlsState();
}

class _VolumeControlsState extends ConsumerState<VolumeControls> {
  double _volume = 1.0;
  List<double> _equalizerGains = [];

  @override
  void initState() {
    super.initState();
    final playerController = ref.read(playerControllerProvider);
    _volume = playerController.volume;
    _equalizerGains = playerController.equalizerGains;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.masterVolume),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              const Icon(Icons.volume_mute),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                    });
                    ref
                        .read(playerControllerProvider.notifier)
                        .setVolume(value);
                  },
                ),
              ),
              const Icon(Icons.volume_up),
              Text("${(_volume * 100).toInt()}%"),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.equalizer),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_equalizerGains.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  ref
                      .read(localizationProvider.notifier)
                      .translate(LocalizationKeys.equalizerNotAvailable),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _equalizerGains.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: _equalizerGains[index],
                              min: -10.0,
                              max: 10.0,
                              onChanged: (value) {
                                final newGains = List<double>.from(
                                  _equalizerGains,
                                );
                                setState(() {
                                  _equalizerGains = newGains;
                                });
                                newGains[index] = value;
                                ref
                                    .read(playerControllerProvider.notifier)
                                    .setEqualizerGains(newGains);
                              },
                            ),
                          ),
                        ),
                        Text("${_equalizerGains[index].toStringAsFixed(1)} dB"),
                        Text(
                          "${ref.read(localizationProvider.notifier).translate(LocalizationKeys.band)} ${index + 1}",
                        ),
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
                setState(() {
                  _volume = 1.0;
                });
                ref.read(playerControllerProvider.notifier).restoreDefaults();
              },
              icon: const Icon(Icons.restore),
              label: Text(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.restoreDefaults),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
