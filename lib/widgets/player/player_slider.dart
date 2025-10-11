import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/enums.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class PlayerSlider extends ConsumerStatefulWidget {
  const PlayerSlider({
    super.key,
  });

  @override
  ConsumerState<PlayerSlider> createState() => _PlayerSliderState();
}

class _PlayerSliderState extends ConsumerState<PlayerSlider> {
  double _currentSliderValue = 0;
  bool _changeStarted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _getPlayerCurrentPosition(_currentSliderValue);
    });
  }

  Future<void> _getPlayerCurrentPosition(double value) async {
    if (_changeStarted) {
      return;
    }
    final player = ref.read(playerControllerProvider);
    if (player.currentTrack == null || player.currentTrack!.duration == Duration.zero || player.state == PlayerState.stopped) {
      _currentSliderValue = 0;
      return;
    }
    final totalDuration = player.currentTrack!.duration;
    final currentDuration = await player.getCurrentPosition();
    final currentPosition = (currentDuration.inMilliseconds / totalDuration.inMilliseconds * 100) / 100;
    setState(() {
      _currentSliderValue = currentPosition;
    });
  }

  Future<void> _setPlayerCurrentPosition(double value) async {
    final player = ref.read(playerControllerProvider);
    if (player.currentTrack == null || player.currentTrack!.duration == Duration.zero) {
      return;
    }
    final totalDuration = player.currentTrack!.duration;
    final newPosition = Duration(milliseconds: (totalDuration.inMilliseconds * value).toInt());
    await player.seek(newPosition);
    setState(() {
      _currentSliderValue = value;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      value: _currentSliderValue,
      onChanged: _setPlayerCurrentPosition,
      onChangeStart: (value) {
        setState(() {
          _changeStarted = true;
        });
      },
      onChangeEnd: (value) {
        setState(() {
          _changeStarted = false;
        });
      },
    );
  }
}
