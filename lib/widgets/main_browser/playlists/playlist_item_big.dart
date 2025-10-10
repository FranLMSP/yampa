import 'package:flutter/material.dart';
import 'package:music_player/models/playlist.dart';

class PlaylistItemBig extends StatefulWidget {
  const PlaylistItemBig({super.key, required this.playlist, this.onSelect});

  final Playlist playlist;
  final Function? onSelect;

  @override
  State<PlaylistItemBig> createState() => _PlaylistItemBigState();
}

class _PlaylistItemBigState extends State<PlaylistItemBig> {
@override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onSelect != null) {
          widget.onSelect!();
        }
        // TODO: navigate to the actual playlist
      },
      onLongPress: () => {
        // TODO: implement functionality to select multiple tracks
      },
      child: Text("placeholder"),
    );
  }
}

