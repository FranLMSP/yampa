import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:yampa/models/track.dart';

class DisplayTrackTitle extends StatelessWidget {
  const DisplayTrackTitle({
    super.key,
    this.track,
    this.fontSize,
    this.textAlign,
  });

  final Track? track;
  final double? fontSize;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TextScroll(
      "  ${track?.displayTitle() ?? ""}  ",
      mode: TextScrollMode.bouncing,
      velocity: Velocity(pixelsPerSecond: Offset(35, 0)),
      delayBefore: Duration(seconds: 1),
      pauseBetween: Duration(seconds: 1),
      pauseOnBounce: Duration(seconds: 1),
      style: TextStyle(fontSize: fontSize ?? 20, fontWeight: FontWeight.bold),
      textAlign: textAlign ?? TextAlign.center,
      selectable: false,
    );
  }
}
