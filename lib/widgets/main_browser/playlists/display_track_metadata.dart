import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:yampa/models/track.dart';

class DisplayTrackMetadata extends StatelessWidget {
  const DisplayTrackMetadata({super.key, this.track});

  final Track? track;

  @override
  Widget build(BuildContext context) {
    final finalText = [];
    final artist = track?.artist ?? "";
    if (artist.trim().isNotEmpty) {
      finalText.add(artist.trim());
    }
    final album = track?.album ?? "";
    if (album.trim().isNotEmpty) {
      finalText.add(album.trim());
    }
    if (finalText.isEmpty) {
      return SizedBox.shrink();
    }
    return TextScroll(
      finalText.join(" | "),
      mode: TextScrollMode.bouncing,
      velocity: Velocity(pixelsPerSecond: Offset(35, 0)),
      delayBefore: Duration(seconds: 1),
      pauseBetween: Duration(seconds: 1),
      pauseOnBounce: Duration(seconds: 1),
      textAlign: TextAlign.center,
      selectable: false,
    );
  }
}
