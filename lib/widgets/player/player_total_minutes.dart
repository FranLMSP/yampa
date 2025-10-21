import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/providers/player_controller_provider.dart';

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
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _updateDurations();
    });
  }

  void _updateDurations() async {
    final playerController = ref.watch(playerControllerProvider);
    if (playerController.state != PlayerState.playing) {
      return;
    }
    if (playerController.currentTrack != null) {
      final totalDuration = playerController.currentTrack!.duration;
      final currentDuration = await playerController.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentDuration = currentDuration;
          _totalDuration = totalDuration;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _currentDuration = Duration.zero;
          _totalDuration = Duration.zero;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateDurations();
    return Text("${formatDuration(_currentDuration)} / ${formatDuration(_totalDuration)}");
  }
}
