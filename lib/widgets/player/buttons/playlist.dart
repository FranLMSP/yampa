import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaylistButton extends ConsumerWidget {
  const PlaylistButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.playlist_add),
      tooltip: 'Save to playlist',
      onPressed: () async {
        print("Save to playlist");
      },
    );
  }
}


