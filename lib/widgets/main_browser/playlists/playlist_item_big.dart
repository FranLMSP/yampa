import 'package:flutter/material.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';

class PlaylistItemBig extends StatelessWidget {
  const PlaylistItemBig({
    super.key,
    required this.playlist,
    this.isSelected = false,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
  });

  final Playlist playlist;
  final bool isSelected;
  final Function(Playlist playlist)? onTap;
  final Function(Playlist playlist, TapDownDetails details)? onSecondaryTap;
  final Function(Playlist playlist)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: InkWell(
        onTap: () => onTap != null ? onTap!(playlist) : () {},
        onSecondaryTapDown: (TapDownDetails details) =>
            onSecondaryTap != null ? onSecondaryTap!(playlist, details) : () {},
        onLongPress: () => onLongPress != null ? onLongPress!(playlist) : () {},
        child: Card(
          color: isSelected
              ? Theme.of(context).colorScheme.inversePrimary
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: PlaylistImage(playlist: playlist)),
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: isSelected
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Colors.white,
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
