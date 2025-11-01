import 'package:flutter/material.dart';
import 'package:yampa/models/playlist.dart';

class PlaylistImage extends StatelessWidget {
  const PlaylistImage({super.key, required this.playlist});

  final Playlist playlist;

@override
  Widget build(BuildContext context) {
    return playlist.imagePath != null
        ? Image.asset(
            playlist.imagePath!,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        : Container(
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(
              Icons.playlist_play,
              size: 40,
              color: Colors.black54,
            ),
          );
  }
}
