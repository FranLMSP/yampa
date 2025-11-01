import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/widgets/main_browser/all_tracks/main.dart';
import 'package:yampa/widgets/main_browser/favorite_tracks/main.dart';
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

class _MainBrowserState extends ConsumerState<MainBrowser> with SingleTickerProviderStateMixin {
  bool _showMiniPlayer = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _getTabs().length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant MainBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLength = _getTabs().length;
    if (_tabController.length != newLength) {
      final currentIndex = _tabController.index < newLength ? _tabController.index : 0;
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this, initialIndex: currentIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _getTabs() {
    final tabs = [
      Tab(icon: Icon(Icons.music_note), text: "All tracks"),
      Tab(icon: Icon(Icons.playlist_add), text: "Playlists"),
      Tab(icon: Icon(Icons.favorite), text: "Favorites"),
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
      FavoriteTracksPicker(),
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
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
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
      body: Column(
        children: [
          Expanded(
            child: TabBarView(controller: _tabController, children: elements)
          ),
          if (_showMiniPlayer)
            MiniPlayer(
              onTap: () {
                _tabController.animateTo(0);
                if (mounted) {
                  setState(() {
                    _showMiniPlayer = false;
                  });
                }
              }
            )
        ],
      ),
    );
  }
}
