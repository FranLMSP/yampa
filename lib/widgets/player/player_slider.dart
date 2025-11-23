import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

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

  void _initializeTimer(Map<String, Track> tracks, PlayerController player) {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _getPlayerCurrentPosition(tracks, player);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getPlayerCurrentPosition(Map<String, Track> tracks, PlayerController player) async {
    if (_changeStarted) {
      return;
    }
    Track? currentTrack = tracks[player.currentTrackId];
    if (
      currentTrack == null
      || currentTrack.duration == Duration.zero
      || player.state == PlayerState.stopped
    ) {
      _currentSliderValue = 0;
      return;
    }
    final totalDuration = currentTrack.duration;
    final currentDuration = await player.getCurrentPosition();
    final currentPosition = (currentDuration.inMilliseconds / totalDuration.inMilliseconds * 100) / 100;
    if (!mounted) return;
    setState(() {
      _currentSliderValue = currentPosition;
    });
  }

  Future<void> _setPlayerCurrentPosition(Map<String, Track> tracks, PlayerController player, double value) async {
    Track? currentTrack = tracks[player.currentTrackId];

    if (currentTrack == null || currentTrack.duration == Duration.zero) {
      return;
    }
    final totalDuration = currentTrack.duration;
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
    final tracks = ref.watch(tracksProvider);
    final player = ref.watch(playerControllerProvider);
    _initializeTimer(tracks, player);
    return Slider(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      value: _currentSliderValue,
      onChanged: (value) => _setPlayerCurrentPosition(tracks, player, value),
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
