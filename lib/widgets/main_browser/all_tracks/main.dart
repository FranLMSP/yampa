import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/track_list/track_list.dart';

class AllTracksPicker extends ConsumerWidget {
  const AllTracksPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackList();
  }
}
