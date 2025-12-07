import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';

class PlaylistItemList extends ConsumerWidget {
  const PlaylistItemList({super.key, required this.playlist, this.onTap});

  final Playlist playlist;
  final Function(Playlist playlist)? onTap;

  Widget _buildPlaylistPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey,
      child: Icon(Icons.playlist_add, size: 40, color: Colors.white),
    );
  }

  Widget _buildPlaylistIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: playlist.imagePath != null
          ? SizedBox(
              width: 50,
              height: 50,
              child: PlaylistImage(playlist: playlist),
            )
          : _buildPlaylistPlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlaylists = ref.watch(selectedPlaylistsProvider);
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(playlist);
        }
      },
      onLongPress: () => {
        // TODO: implement functionality to select multiple playlists
      },
      child: Card(
        color: selectedPlaylists.contains(playlist.id)
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: ListTile(
          leading: _buildPlaylistIcon(),
          title: Text(playlist.name),
          subtitle: Text(playlist.description),
        ),
      ),
    );
  }
}
