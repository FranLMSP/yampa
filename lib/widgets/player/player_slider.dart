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

  void _initializeTimer(PlayerControllerNotifier playerControllerNotifier) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _getPlayerCurrentPosition(playerControllerNotifier);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  int _normalizeMilliseconds(int milliseconds) {
    return (milliseconds / 100).round() * 100;
  }

  Future<void> _getPlayerCurrentPosition(PlayerControllerNotifier playerControllerNotifier) async {
    if (_changeStarted) {
      return;
    }
    final playerController = playerControllerNotifier.getPlayerController();
    if (
      playerController.currentTrack == null
      || playerController.currentTrack!.duration == Duration.zero
      || playerController.state == PlayerState.stopped
    ) {
      _currentSliderValue = 0;
      return;
    }
    final totalDuration = playerController.currentTrack!.duration;
    final currentDuration = await playerController.getCurrentPosition();
    // TODO: this check here isn't very precise, so we have to find a better way to check whether the tracked has finished playing
    if (_normalizeMilliseconds(currentDuration.inMilliseconds) == _normalizeMilliseconds(totalDuration.inMilliseconds)) {
      await playerControllerNotifier.handleNextAutomatically();
      setState(() {
        _currentSliderValue = 0;
      });
      return;
    }
    final currentPosition = (currentDuration.inMilliseconds / totalDuration.inMilliseconds * 100) / 100;
    setState(() {
      _currentSliderValue = currentPosition;
    });
  }

  Future<void> _setPlayerCurrentPosition(double value) async {
    final player = ref.watch(playerControllerProvider);
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
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    _initializeTimer(playerControllerNotifier);
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
