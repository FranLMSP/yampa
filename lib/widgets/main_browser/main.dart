import 'package:flutter/material.dart';
import 'package:music_player/widgets/main_browser/local_path_picker/main.dart';

class MainBrowser extends StatelessWidget {

  const MainBrowser({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.music_note),
            Icon(Icons.playlist_add),
            LocalPathPicker(),
            Icon(Icons.settings),
          ],
        ),
      ),
    );
  }
}


