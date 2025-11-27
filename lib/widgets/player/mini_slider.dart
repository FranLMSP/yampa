import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      await _getPlayerCurrentPosition();
    });
  }

  Future<void> _getPlayerCurrentPosition() async {
    final tracks = ref.watch(tracksProvider);
    final player = ref.watch(playerControllerProvider);
    final track = tracks[player.currentTrackId];
    if (track != null) {
      final totalDuration = player.getCurrentTrackDuration();
      final currentPosition = await player.getCurrentPosition();
      final position = ((currentPosition.inMilliseconds / totalDuration.inMilliseconds * 100) / 100) .clamp(0.0, 1.0);
      if (mounted) {
        setState(() {
          _currentSliderValue = position;
        });
      }
    } else if (mounted) {
      setState(() {
        _currentSliderValue = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: _currentSliderValue);
  }
}
