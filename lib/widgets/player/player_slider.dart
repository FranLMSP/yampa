import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class PlayerSlider extends ConsumerStatefulWidget {
  const PlayerSlider({super.key});

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
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      await _getPlayerCurrentPosition();
    });
  }

  Future<void> _getPlayerCurrentPosition() async {
    if (_changeStarted) {
      return;
    }
    final tracks = ref.watch(tracksProvider);
    final playerState = ref.watch(playerControllerProvider);
    final player = playerState.value;
    if (player == null) return;
    final track = tracks[player.currentTrackId];
    final totalDuration = player.getCurrentTrackDuration();
    if (track == null || totalDuration == Duration.zero || player.state == PlayerState.stopped) {
      if (!mounted) return;
      setState(() {
        _currentSliderValue = 0;
      });
      return;
    }
    final currentDuration = await player.getCurrentPosition();
    final currentPosition = ((currentDuration.inMilliseconds / totalDuration.inMilliseconds * 100) / 100).clamp(0.0, 1.0);
    if (!mounted) return;
    setState(() {
      _currentSliderValue = currentPosition;
    });
  }

  Future<void> _setPlayerCurrentPosition(
    Map<String, Track> tracks,
    String? currentTrackId,
    double value,
  ) async {
    Track? currentTrack = tracks[currentTrackId];

    if (currentTrack == null || currentTrack.duration == Duration.zero) {
      return;
    }
    final playerControllerState = ref.read(playerControllerProvider);
    final playerController = playerControllerState.value;
    if (playerController == null) return;
    final totalDuration = playerController.getCurrentTrackDuration();
    final newPosition = Duration(
      milliseconds: (totalDuration.inMilliseconds * value).toInt(),
    );
    await playerController.seek(newPosition);
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
    final currentTrackId = ref.watch(playerControllerProvider.select((p) => p.value?.currentTrackId));
    return Slider(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      value: _currentSliderValue,
      onChanged: (value) => _setPlayerCurrentPosition(tracks, currentTrackId, value),
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
