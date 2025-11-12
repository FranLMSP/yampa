import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/core/utils/search_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/favorite_tracks_provider.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/add_to_playlist_modal.dart';


enum OptionSelected {
  select,
  addToPlaylists,
  addToFavorites,
  removeFromPlaylist,
  info,
}

class AllTracksPicker extends ConsumerStatefulWidget {
  const AllTracksPicker({super.key});

  @override
  ConsumerState<AllTracksPicker> createState() => _AllTracksPickerState();
}

class _AllTracksPickerState extends ConsumerState<AllTracksPicker> {
  late TextEditingController _searchTextController;
  bool _isSearchingEnabled = false;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
    _isSearchingEnabled = false;
  }

  Widget _buildItemPopupMenuButton(
    BuildContext context,
    Track track,
    List<Track> tracks,
    List<Playlist> playlists,
    List<String> selectedTrackIds,
    PlaylistNotifier playlistNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    SelectedTracksNotifier selectedTracksNotifier,
    FavoriteTracksNotifier favoriteTracksNotifier,
  ) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) {
        _handleItemOptionSelected(context, track, item, tracks, playlists, playlistNotifier, selectedPlaylistsNotifier, selectedTracksNotifier, favoriteTracksNotifier);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelected>>[
        const PopupMenuItem<OptionSelected>(value: OptionSelected.select, child: Text('Select')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.addToPlaylists, child: Text('Add to playlists')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.addToFavorites, child: Text('Add to favorites')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.info, child: Text('Info')),
      ],
    );
  }

  void _addToFavoritesModal(
    BuildContext context,
    List<Track> tracks,
    List<String> selectedTrackIds,
    SelectedTracksNotifier selectedTracksNotifier,
    FavoriteTracksNotifier favoriteTracksNotifier,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Add to favorites?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No')
            ),
            TextButton(
              onPressed: () {
                handleTracksAddedToFavorites(
                  tracks.where((e) => selectedTrackIds.contains(e.id)).toList(),
                  favoriteTracksNotifier,
                );
                selectedTracksNotifier.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Yes')
            ),
          ],
        );
      }
    );
  }
 
  void _handleItemOptionSelected(
    BuildContext context,
    Track track,
    OptionSelected? optionSelected,
    List<Track> tracks,
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    SelectedTracksNotifier selectedTracksNotifier,
    FavoriteTracksNotifier favoriteTracksNotifier,
  ) {
    if (optionSelected == OptionSelected.addToPlaylists) {
      selectedTracksNotifier.clear();
      selectedTracksNotifier.selectTrack(track);
      addToPlaylistsModal(context, tracks, playlists, playlistNotifier, selectedPlaylistsNotifier, selectedTracksNotifier);
    } else if (optionSelected == OptionSelected.select) {
      selectedTracksNotifier.selectTrack(track);
    } else if (optionSelected == OptionSelected.addToFavorites) {
      selectedTracksNotifier.clear();
      selectedTracksNotifier.selectTrack(track);
      _addToFavoritesModal(context, tracks, [track.id], selectedTracksNotifier, favoriteTracksNotifier);
    }
  }

  Future<void> _playSelectedTrack(Track track, PlayerController playerController, PlayerControllerNotifier playerControllerNotifier) async {
    playTrack(track, playerController, playerControllerNotifier);
  }

  void _toggleSelectedTrack(Track track, List<String> selectedTracks, SelectedTracksNotifier selectedTracksNotifier) {
    if (selectedTracks.contains(track.id)) {
      selectedTracksNotifier.unselectTrack(track);
    } else {
      selectedTracksNotifier.selectTrack(track);
    }
  }

  PreferredSizeWidget? _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isSearchingEnabled = false;
            _searchTextController.text = "";
          });
        },
      ),
      title: TextField(
        controller: _searchTextController,
        decoration: const InputDecoration(labelText: 'Search'),
        onChanged: (_) => setState(() => {}),
      ),
    );
  }

  PreferredSizeWidget? _buildMultiSelectAppBar(
    BuildContext context,
    List<Track> tracks,
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    List<String> selectedTracks,
    SelectedTracksNotifier selectedTracksNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    FavoriteTracksNotifier favoriteTracksNotifier,
  ) {
    if (selectedTracks.isEmpty) {
      return null;
    }
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          selectedTracksNotifier.clear();
        },
      ),
      title: Text('${selectedTracks.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite),
          tooltip: 'Add to favorites',
          onPressed: () {
            _addToFavoritesModal(
              context,
              tracks,
              selectedTracks,
              selectedTracksNotifier,
              favoriteTracksNotifier,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          tooltip: 'Add to playlist',
          onPressed: () {
            addToPlaylistsModal(
              context,
              tracks,
              playlists,
              playlistNotifier,
              selectedPlaylistsNotifier,
              selectedTracksNotifier,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    final tracks = ref.watch(tracksProvider);
    final playlists = ref.watch(playlistsProvider);
    final playlistsNotifier = ref.watch(playlistsProvider.notifier);
    final selectedTracks = ref.watch(selectedTracksProvider);
    final selectedTracksNotifier = ref.watch(selectedTracksProvider.notifier);
    final selectedPlaylistsNotifier = ref.watch(selectedPlaylistsProvider.notifier);
    final playerController = ref.read(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    final favoriteTracksNotifier = ref.read(favoriteTracksProvider.notifier);
    final isInSelectMode = selectedTracks.isNotEmpty;
    final filteredTracks = _isSearchingEnabled
      ? tracks.where((e) => checkSearchMatch(_searchTextController.text, stringifyTrackProperties(e)))
      : tracks;

    if (initialLoadDone && tracks.isEmpty) {
      return Center(child:Text("No tracks found. Go to the Added Paths tab to add some!"));
    }
    return Scaffold(
      appBar: _isSearchingEnabled ? _buildSearchAppBar() : _buildMultiSelectAppBar(
        context,
        tracks,
        playlists,
        playlistsNotifier,
        selectedTracks,
        selectedTracksNotifier,
        selectedPlaylistsNotifier,
        favoriteTracksNotifier,
      ),
      body: ListView(
        children: filteredTracks.map(
          (track) {
            Function(Track track)? onTap;
            Function(Track track)? onLongPress;
            void onSelect(Track track) {
              _toggleSelectedTrack(track, selectedTracks, selectedTracksNotifier);
            }
            if (isInSelectMode) {
              onTap = onSelect;
            } else {
              onTap = (Track track) {
                _playSelectedTrack(track, playerController, playerControllerNotifier);
              };
              onLongPress = onSelect;
            }
            final isSelected = selectedTracks.contains(track.id);
            return TrackItem(
              key: Key(track.id),
              track: track,
              onTap: onTap,
              onLongPress: onLongPress,
              isSelected: isSelected,
              trailing: isInSelectMode ? null : _buildItemPopupMenuButton(context, track, tracks, playlists, selectedTracks, playlistsNotifier, selectedPlaylistsNotifier, selectedTracksNotifier, favoriteTracksNotifier),
            );
        }).toList()
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isSearchingEnabled = true;
                _searchTextController.text = "";
              });
            },
            child: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
