import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class MiniPlayerSlider extends ConsumerStatefulWidget {
  const MiniPlayerSlider({super.key});

  @override
  ConsumerState<MiniPlayerSlider> createState() => _MiniPlayerSliderState();
}

class _MiniPlayerSliderState extends ConsumerState<MiniPlayerSlider> {
  double _currentSliderValue = 0;
  Timer? _timer;

  void _initializeTimer(
    Map<String, Track> tracks,
    PlayerController playerController,
    PlayerControllerNotifier playerControllerNotifier,
  ) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _getPlayerCurrentPosition(
        tracks,
        playerController,
        playerControllerNotifier,
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getPlayerCurrentPosition(
    Map<String, Track> tracks,
    PlayerController playerController,
    PlayerControllerNotifier playerControllerNotifier,
  ) async {
    if (!mounted) return;
    Track? currentTrack;
    if (playerController.currentTrackId != null) {
      currentTrack = tracks[playerController.currentTrackId];
    }
    if (currentTrack == null ||
        currentTrack.duration == Duration.zero ||
        playerController.state == PlayerState.stopped) {
      setState(() {
        _currentSliderValue = 0;
      });
      return;
    }
    final totalDuration = playerController.getCurrentTrackDuration();
    final currentDuration = await playerController.getCurrentPosition();
    final currentPosition =
        ((currentDuration.inMilliseconds / totalDuration.inMilliseconds * 100) /
                100)
            .clamp(0.0, 1.0);
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
    final tracks = ref.watch(tracksProvider);
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.watch(
      playerControllerProvider.notifier,
    );
    _initializeTimer(tracks, playerController, playerControllerNotifier);
    return LinearProgressIndicator(value: _currentSliderValue);
  }
}
