import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class MiniPlayerSlider extends ConsumerStatefulWidget {
  const MiniPlayerSlider({
    super.key,
  });

  @override
  ConsumerState<MiniPlayerSlider> createState() => _MiniPlayerSliderState();
}

class _MiniPlayerSliderState extends ConsumerState<MiniPlayerSlider> {
  double _currentSliderValue = 0;
  Timer? _timer;

  void _initializeTimer(PlayerControllerNotifier playerControllerNotifier) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _getPlayerCurrentPosition(playerControllerNotifier);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getPlayerCurrentPosition(PlayerControllerNotifier playerControllerNotifier) async {
    if (!mounted) return;
    final playerController = playerControllerNotifier.getPlayerController();
    if (
      playerController.currentTrack == null
      || playerController.currentTrack!.duration == Duration.zero
      || playerController.state == PlayerState.stopped
    ) {
      setState(() {
        _currentSliderValue = 0;
      });
      return;
    }
    final totalDuration = playerController.currentTrack!.duration;
    final currentDuration = await playerController.getCurrentPosition();
    final currentPosition = (currentDuration.inMilliseconds / totalDuration.inMilliseconds * 100) / 100;
    if (!mounted) return;
    setState(() {
      _currentSliderValue = currentPosition;
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
    return LinearProgressIndicator(
      value: _currentSliderValue,
    );
  }
}
