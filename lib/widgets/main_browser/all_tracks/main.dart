import 'package:flutter/material.dart';
import 'package:music_player/widgets/main_browser/all_tracks/track_list/track_list.dart';

class AllTracksPicker extends StatelessWidget {
  const AllTracksPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return TrackList();
  }
}
