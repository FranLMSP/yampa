import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/models/playlist.dart';

class PlaylistImage extends StatelessWidget {
  const PlaylistImage({
    super.key,
    required this.playlist,
    this.width,
    this.height,
    this.iconSize = 40,
  });

  final Playlist playlist;
  final double? width;
  final double? height;
  final double iconSize;

  bool _isImagePathValid() {
    return playlist.imagePath != null && isValidImagePath(playlist.imagePath!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isImagePathValid()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image.file(
          File(playlist.imagePath!),
          width: width ?? double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 100,
      color: Colors.grey[300],
      child: Icon(
        playlist.id == favoritePlaylistId
            ? Icons.favorite
            : Icons.playlist_play,
        size: iconSize,
        color: Colors.black54,
      ),
    );
  }
}
