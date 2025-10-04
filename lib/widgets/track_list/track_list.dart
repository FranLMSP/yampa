import 'package:flutter/material.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/widgets/track_list/track_item.dart';

class TrackList extends StatelessWidget {
  const TrackList({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with a ListView for demonstration; customize as needed
    return Expanded(
      child: ListView(
        children: List.generate(
          100,
          (index) => TrackItem(
            track: Track(
              id: "123",
              name: "Test track name",
              artist: "Artst",
              album: "Album",
              genre: "Genre",
              path: "test",
              trackNumber: 1,
              duration: Duration(minutes: 3),
            ),
          ),
        ),
      ),
    );
  }
}
