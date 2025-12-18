import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';

class PlaylistItemList extends ConsumerStatefulWidget {
  const PlaylistItemList({
    super.key,
    required this.playlist,
    this.onTap,
    this.isEditable = false,
    this.onRenameSubmit,
  });

  final Playlist playlist;
  final Function(Playlist playlist)? onTap;
  final bool isEditable;
  final Function(String)? onRenameSubmit;

  @override
  ConsumerState<PlaylistItemList> createState() => _PlaylistItemListState();
}

class _PlaylistItemListState extends ConsumerState<PlaylistItemList> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.playlist.name);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.isEditable) {
      if (widget.onRenameSubmit != null) {
        widget.onRenameSubmit!(_controller.text);
      }
    }
  }

  Widget _buildPlaylistPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Theme.of(context).colorScheme.outline,
      child: Icon(
        widget.playlist.id == favoritePlaylistId
            ? Icons.favorite
            : Icons.playlist_add,
        size: 40,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPlaylistIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: widget.playlist.imagePath != null
          ? SizedBox(
              width: 50,
              height: 50,
              child: PlaylistImage(playlist: widget.playlist),
            )
          : _buildPlaylistPlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlaylists = ref.watch(selectedPlaylistsProvider);
    return InkWell(
      onTap: () {
        if (widget.onTap != null && !widget.isEditable) {
          widget.onTap!(widget.playlist);
        }
      },
      child: Card(
        color: selectedPlaylists.contains(widget.playlist.id)
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: ListTile(
          leading: _buildPlaylistIcon(),
          title: widget.isEditable
              ? TextField(
                  focusNode: _focusNode,
                  autofocus: true,
                  controller: _controller,
                  onSubmitted: (value) {
                    if (widget.onRenameSubmit != null) {
                      widget.onRenameSubmit!(value);
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                )
              : Text(widget.playlist.name),
          subtitle: Text(widget.playlist.description),
        ),
      ),
    );
  }
}
