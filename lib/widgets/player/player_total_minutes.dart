import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/enums.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class PlayerTotalMinutes extends ConsumerStatefulWidget {
  const PlayerTotalMinutes({
    super.key,
  });
 
  @override
  ConsumerState<PlayerTotalMinutes> createState() => _PlayerTotalMinutesState();
}

class _PlayerTotalMinutesState extends ConsumerState<PlayerTotalMinutes> {
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _updateDurations();
    });
  }

  void _updateDurations() async {
    final playerController = ref.read(playerControllerProvider);
    if (playerController.state != PlayerState.playing) {
      return;
    }
    if (playerController.currentTrack != null) {
      final totalDuration = playerController.currentTrack!.duration;
      final currentDuration = await playerController.getCurrentPosition();
      setState(() {
        _currentDuration = currentDuration;
        _totalDuration = totalDuration;
      });
    } else {
      setState(() {
        _currentDuration = Duration.zero;
        _totalDuration = Duration.zero;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateDurations();
    return Text("${_formatDuration(_currentDuration)} / ${_formatDuration(_totalDuration)}");
  }
}
