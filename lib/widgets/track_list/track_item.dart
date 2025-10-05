import 'package:flutter/material.dart';
import 'package:music_player/models/track.dart';

class TrackItem extends StatelessWidget {
  const TrackItem({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(track.name),
        subtitle: Text(track.artist),
        trailing: Text('${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
      ),
    );
  }
}
