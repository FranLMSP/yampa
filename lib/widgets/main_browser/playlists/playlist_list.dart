import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_item_big.dart';

class PlaylistList extends ConsumerWidget {
  const PlaylistList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    return (playlists.isEmpty)
      ? Center(child: Text("No playlists available. Hit the + button to create a new one!"))
      : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return PlaylistItemBig(
            key: Key(playlist.id),
            playlist: playlist,
          );
        },
      );
  }
}
