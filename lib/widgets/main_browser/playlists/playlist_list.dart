import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_item_big.dart';

class PlaylistList extends ConsumerWidget {
  const PlaylistList({super.key});

  Widget _buildList(List<Playlist> playlists) {
    return ListView(
      children: playlists.map((playlist) => PlaylistItemBig(
        playlist: playlist,
      )).toList()
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Text("temp"))
              );
            },
          ),
        ]
      ),
      body: _buildList(playlists),
    );
  }
}
