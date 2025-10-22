import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/widgets/main_browser/all_tracks/main.dart';
import 'package:yampa/widgets/main_browser/local_path_picker/main.dart';
import 'package:yampa/widgets/main_browser/playlists/main.dart';
import 'package:yampa/widgets/player/big_player.dart';
import 'package:yampa/widgets/player/mini_player.dart';
import 'package:yampa/widgets/utils.dart';

class MainBrowser extends ConsumerStatefulWidget {

  const MainBrowser({
    super.key,
    required this.viewMode,
  });

  final ViewMode viewMode;

  @override
  ConsumerState<MainBrowser> createState() => _MainBrowserState();
}

class _MainBrowserState extends ConsumerState<MainBrowser> {
  bool _showMiniPlayer = false;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _getTabs() {
    final tabs = [
      Tab(icon: Icon(Icons.music_note), text: "All tracks"),
      Tab(icon: Icon(Icons.playlist_add), text: "Playlists"),
      Tab(icon: Icon(Icons.folder), text: "Added paths"),
      Tab(icon: Icon(Icons.settings), text: "Settings"),
    ];

    if (widget.viewMode == ViewMode.portrait) {
      tabs.insert(0, Tab(icon: Icon(Icons.play_arrow), text: "Player"));
    }

    return tabs;
  }

  List<Widget> _getTabsContent() {
    final elements = [
      AllTracksPicker(),
      Playlists(),
      LocalPathPicker(),
      Icon(Icons.settings),
    ];

    if (widget.viewMode == ViewMode.portrait) {
      elements.insert(0, BigPlayer());
    }

    return elements;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs();
    final elements = _getTabsContent();
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: TabBar(
          tabs: tabs,
          onTap: (index) {
            if (index != 0 && widget.viewMode == ViewMode.portrait && _showMiniPlayer == false) {
              setState(() {
                _showMiniPlayer = true;
              });
            }
            if ((index == 0 || widget.viewMode != ViewMode.portrait) && _showMiniPlayer == true) {
              setState(() {
                _showMiniPlayer = false;
              });
            }
          },
        ),
        body: TabBarView(children: elements),
        bottomSheet: _showMiniPlayer ? MiniPlayer() : null,
      ),
    );
  }
}
