import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';

class PlayerTotalMinutes extends ConsumerStatefulWidget {
  const PlayerTotalMinutes({super.key});

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
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      await _updateDurations();
    });
  }

  Future<void> _updateDurations() async {
    final tracks = ref.watch(tracksProvider);
    final player = ref.watch(playerControllerProvider);
    final track = tracks[player.currentTrackId];
    if (track != null) {
      final totalDuration = player.getCurrentTrackDuration();
      final currentDuration = await player.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentDuration = currentDuration;
          _totalDuration = totalDuration;
        });
      }
    } else if (mounted) {
      setState(() {
        _currentDuration = Duration.zero;
        _totalDuration = Duration.zero;
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
    return Text(
      "${formatDuration(_currentDuration)} / ${formatDuration(_totalDuration)}",
    );
  }
}
