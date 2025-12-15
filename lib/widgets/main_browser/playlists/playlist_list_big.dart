import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_item_big.dart';

class PlaylistListBig extends ConsumerWidget {
  const PlaylistListBig({
    super.key,
    required this.selectedPlaylists,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
  });

  final List<String> selectedPlaylists;
  final Function(Playlist playlist)? onTap;
  final Function(Playlist playlist, TapDownDetails details)? onSecondaryTap;
  final Function(Playlist playlist)? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    return (playlists.isEmpty)
        ? Center(
            child: Text(
              "No playlists available. Hit the + button to create a new one!",
            ),
          )
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
                isSelected: selectedPlaylists.contains(playlist.id),
                playlist: playlist,
                onTap: (Playlist playlist) {
                  if (onTap != null) {
                    onTap!(playlist);
                  }
                },
                onSecondaryTap: (Playlist playlist, TapDownDetails details) {
                  if (onSecondaryTap != null) {
                    onSecondaryTap!(playlist, details);
                  }
                },
                onLongPress: (Playlist playlist) {
                  if (onLongPress != null) {
                    onLongPress!(playlist);
                  }
                },
              );
            },
          );
  }
}
