import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';

class TrackList extends ConsumerWidget {
  const TrackList({super.key, this.onTap, required this.tracks});

  final Function(Track track)? onTap;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: tracks.map(
        (track) => TrackItem(
          key: Key(track.id),
          track: track,
          onTap: onTap,
        )
      ).toList()
    );
  }
}
