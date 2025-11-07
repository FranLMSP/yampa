import 'package:flutter/material.dart';
import 'package:yampa/core/utils/filename_utils.dart';
import 'package:yampa/models/playlist.dart';

class PlaylistImage extends StatelessWidget {
  const PlaylistImage({super.key, required this.playlist});

  final Playlist playlist;

  bool _isImagePathValid() {
    return playlist.imagePath != null && isValidImagePath(playlist.imagePath!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isImagePathValid()) {
      return Image.asset(
        playlist.imagePath!,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: double.infinity,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(
        Icons.playlist_play,
        size: 40,
        color: Colors.black54,
      ),
    );
  }
}
