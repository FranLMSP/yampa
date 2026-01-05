import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/core/utils/search_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/statistics_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_info_dialog.dart';
import 'package:yampa/widgets/main_browser/playlists/add_to_playlist_modal.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/sort_mode_provider.dart';
import 'package:yampa/core/utils/sort_utils.dart';
import 'package:yampa/widgets/common/sort_button.dart';
import 'package:yampa/widgets/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
    _isSearchingEnabled = false;
    _scrollController = ScrollController();
  }

  Widget _buildItemPopupMenuButton(
    BuildContext context,
    Track track,
    Map<String, Track> tracks,
    List<Playlist> playlists,
    List<String> selectedTrackIds,
    PlaylistNotifier playlistNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    SelectedTracksNotifier selectedTracksNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) {
        _handleItemOptionSelected(
          context,
          track,
          item,
          tracks,
          playlists,
          playlistNotifier,
          selectedPlaylistsNotifier,
          selectedTracksNotifier,
          playerNotifier,
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelected>>[
        PopupMenuItem<OptionSelected>(
          value: OptionSelected.select,
          child: Row(
            children: [
              Icon(Icons.check_box),
              SizedBox(width: 12),
              Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.select)),
            ],
          ),
        ),
        PopupMenuItem<OptionSelected>(
          value: OptionSelected.addToPlaylists,
          child: Row(
            children: [
              Icon(Icons.playlist_add),
              SizedBox(width: 12),
              Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.addToPlaylists)),
            ],
          ),
        ),
        PopupMenuItem<OptionSelected>(
          value: OptionSelected.addToFavorites,
          child: Row(
            children: [
              Icon(Icons.favorite),
              SizedBox(width: 12),
              Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.addToFavorites)),
            ],
          ),
        ),
        PopupMenuItem<OptionSelected>(
          value: OptionSelected.info,
          child: Row(
            children: [Icon(Icons.info), SizedBox(width: 12), Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.info))],
          ),
        ),
      ],
    );
  }

  void _addToFavoritesModal(
    BuildContext context,
    List<String> selectedTrackIds,
    SelectedTracksNotifier selectedTracksNotifier,
    PlaylistNotifier playlistsNotifier,
    List<Playlist> playlists,
    PlayerControllerNotifier playerNotifier,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.addToFavoritesQuestion)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.no)),
            ),
            TextButton(
              onPressed: () {
                final favoritesPlaylist = playlists.firstWhere(
                  (e) => e.id == favoritePlaylistId,
                );
                handleTracksAddedToPlaylist(
                  selectedTrackIds,
                  [favoritesPlaylist],
                  playlistsNotifier,
                  playerNotifier,
                );
                selectedTracksNotifier.clear();
                Navigator.of(context).pop();
              },
              child: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.yes)),
            ),
          ],
        );
      },
    );
  }

  void _handleItemOptionSelected(
    BuildContext context,
    Track track,
    OptionSelected? optionSelected,
    Map<String, Track> tracks,
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    SelectedTracksNotifier selectedTracksNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    if (optionSelected == OptionSelected.addToPlaylists) {
      selectedTracksNotifier.clear();
      selectedTracksNotifier.selectTrack(track);
      addToPlaylistsModal(
        context,
        selectedTracksNotifier.getTrackIds(),
        playlistNotifier,
        selectedPlaylistsNotifier,
        selectedTracksNotifier,
        playerNotifier,
      );
    } else if (optionSelected == OptionSelected.select) {
      selectedTracksNotifier.selectTrack(track);
    } else if (optionSelected == OptionSelected.addToFavorites) {
      selectedTracksNotifier.clear();
      selectedTracksNotifier.selectTrack(track);
      _addToFavoritesModal(
        context,
        selectedTracksNotifier.getTrackIds(),
        selectedTracksNotifier,
        playlistNotifier,
        playlists,
        playerNotifier,
      );
    } else if (optionSelected == OptionSelected.info) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) => TrackInfoDialog(track: track),
      );
    }
  }

  Future<void> _playSelectedTrack(
    Track track,
    PlayerControllerNotifier playerControllerNotifier,
  ) async {
    await playTrack(track, playerControllerNotifier);
  }

  void _toggleSelectedTrack(
    Track track,
    List<String> selectedTracks,
    SelectedTracksNotifier selectedTracksNotifier,
  ) {
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
        autofocus: true,
        controller: _searchTextController,
        decoration: InputDecoration(labelText: ref.read(localizationProvider.notifier).translate(LocalizationKeys.search)),
        onChanged: (_) => setState(() => {}),
      ),
    );
  }

  PreferredSizeWidget? _buildMultiSelectAppBar(
    BuildContext context,
    Map<String, Track> tracks,
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    List<String> selectedTracks,
    SelectedTracksNotifier selectedTracksNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    PlayerControllerNotifier playerNotifier,
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
      title: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.selectedCount).replaceFirst('{}', selectedTracks.length.toString())),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite),
          tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.addToFavorites),
          onPressed: () {
            _addToFavoritesModal(
              context,
              selectedTracks,
              selectedTracksNotifier,
              playlistNotifier,
              playlists,
              playerNotifier,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.addToPlaylist),
          onPressed: () {
            addToPlaylistsModal(
              context,
              selectedTracks,
              playlistNotifier,
              selectedPlaylistsNotifier,
              selectedTracksNotifier,
              playerNotifier,
            );
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildDefaultAppBar(int tracksCount) {
    final sortMode = ref.watch(allTracksSortModeProvider);
    return AppBar(
      title: Text('${ref.read(localizationProvider.notifier).translate(LocalizationKeys.allTracksTitle)} ${tracksCount > 0 ? "($tracksCount)" : ""}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.reloadTracksTooltip),
          onPressed: () {
            reloadTracks(
              ref.read(playerControllerProvider.notifier),
              ref.read(loadedTracksCountProvider.notifier),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearchingEnabled = true;
              _searchTextController.text = "";
            });
          },
        ),
        SortButton(
          currentSortMode: sortMode,
          onSortModeChanged: (SortMode item) {
            ref.invalidate(allTrackStatisticsProvider);
            ref.read(allTracksSortModeProvider.notifier).setSortMode(item);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final tracks = playerControllerNotifier.getPlayerController().tracks;
    final loadedTracksCount = ref.watch(loadedTracksCountProvider);
    debugPrint(loadedTracksCount.toString());
    final playlists = ref.watch(playlistsProvider);
    final playlistsNotifier = ref.watch(playlistsProvider.notifier);
    final selectedTracks = ref.watch(selectedTracksProvider);
    final selectedTracksNotifier = ref.watch(selectedTracksProvider.notifier);
    final selectedPlaylistsNotifier = ref.watch(
      selectedPlaylistsProvider.notifier,
    );
    final loadedTracksCountNotifier = ref.watch(
      loadedTracksCountProvider.notifier,
    );
    final isInSelectMode = selectedTracks.isNotEmpty;
    final sortMode = ref.watch(allTracksSortModeProvider);
    final filteredTracks = _isSearchingEnabled
        ? tracks.values
              .toList()
              .where(
                (e) => checkSearchMatch(
                  _searchTextController.text,
                  stringifyTrackProperties(e),
                ),
              )
              .toList()
        : tracks.values.toList();

    final allTrackStatisticsAsync = ref.watch(allTrackStatisticsProvider);
    final sortedTracks = sortTracks(
      filteredTracks,
      sortMode,
      allTrackStatisticsAsync.value ?? {},
    );
    final isMobile = isPlatformMobile();

    if (tracks.isEmpty) {
      return Center(
        child: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.noTracksFound)),
      );
    }
    return Scaffold(
      appBar: _isSearchingEnabled
          ? _buildSearchAppBar()
          : (isInSelectMode
                ? _buildMultiSelectAppBar(
                    context,
                    tracks,
                    playlists,
                    playlistsNotifier,
                    selectedTracks,
                    selectedTracksNotifier,
                    selectedPlaylistsNotifier,
                    playerControllerNotifier,
                  )
                : _buildDefaultAppBar(tracks.values.length)),
      body: Column(
        children: [
          if (loadedTracksCountNotifier.isLoading())
            SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: loadedTracksCountNotifier.getPercentage(),
              ),
            ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thickness: isMobile ? 20 : null,
              radius: isMobile ? const Radius.circular(8) : null,
              thumbVisibility: isMobile ? true : null,
              interactive: isMobile ? true : null,
              child: ListView(
                controller: _scrollController,
                children: sortedTracks.map((track) {
                  Function(Track track)? onTap;
                  Function(Track track)? onLongPress;
                  void onSelect(Track track) {
                    _toggleSelectedTrack(
                      track,
                      selectedTracks,
                      selectedTracksNotifier,
                    );
                  }

                  if (isInSelectMode) {
                    onTap = onSelect;
                  } else {
                    onTap = (Track track) async {
                      await _playSelectedTrack(track, playerControllerNotifier);
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
                    trailing: isInSelectMode
                        ? null
                        : _buildItemPopupMenuButton(
                            context,
                            track,
                            tracks,
                            playlists,
                            selectedTracks,
                            playlistsNotifier,
                            selectedPlaylistsNotifier,
                            selectedTracksNotifier,
                            playerControllerNotifier,
                          ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
