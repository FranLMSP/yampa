import 'package:flutter/material.dart';
import 'package:music_player/widgets/main_browser/playlists/playlist_list.dart';

class Playlists extends StatelessWidget {
  const Playlists({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaylistList();
  }
}
