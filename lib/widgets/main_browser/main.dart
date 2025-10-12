import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/main_browser/all_tracks/main.dart';
import 'package:music_player/widgets/main_browser/local_path_picker/main.dart';
import 'package:music_player/widgets/main_browser/playlists/main.dart';

class MainBrowser extends ConsumerWidget {

  const MainBrowser({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.music_note), text: "All tracks"),
            Tab(icon: Icon(Icons.playlist_add), text: "Playlists"),
            Tab(icon: Icon(Icons.folder), text: "Added paths"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ]
        ),
        body: TabBarView(
          children: [
            AllTracksPicker(),
            Playlists(),
            LocalPathPicker(),
            Icon(Icons.settings),
          ],
        ),
      ),
    );
  }
}


