import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';

class TrackList extends ConsumerWidget {
  const TrackList({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.tracks
  });

  final List<Track> tracks;
  final Function(Track track)? onTap;
  final Function(Track track)? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row();
  }
}
