import 'package:flutter/material.dart';
import 'package:music_player/models/track.dart';

class TrackItem extends StatelessWidget {
  const TrackItem({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Text(track.name);
  }
}
