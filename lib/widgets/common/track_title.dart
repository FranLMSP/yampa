import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';

class TrackTitle extends ConsumerWidget {
  const TrackTitle({super.key, this.track, this.fontSize});

  final Track? track;
  final double? fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextScroll(
      "  ${track?.displayTitle() ?? ""}  ",
      mode: TextScrollMode.bouncing,
      velocity: Velocity(pixelsPerSecond: Offset(35, 0)),
      delayBefore: Duration(seconds: 1),
      pauseBetween: Duration(seconds: 1),
      pauseOnBounce: Duration(seconds: 1),
      style: TextStyle(fontSize: fontSize ?? 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      selectable: false,
    );
  }
}
