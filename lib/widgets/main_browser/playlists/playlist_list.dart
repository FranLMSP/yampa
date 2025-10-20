import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_item_list.dart';

class PlaylistList extends ConsumerWidget {
  const PlaylistList({super.key, this.onTap, required this.playlists});

  final Function(Playlist track)? onTap;
  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: playlists.map(
        (playlist) => PlaylistItemList(
          key: Key(playlist.id),
          playlist: playlist,
          onTap: onTap,
        )
      ).toList()
    );
  }
}
