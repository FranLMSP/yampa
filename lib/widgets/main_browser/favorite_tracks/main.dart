import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/favorite_tracks_provider.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/common.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';


enum OptionSelectedFavorites {
  select,
  removeFromFavorites,
}

class FavoriteTracksPicker extends ConsumerWidget {
  const FavoriteTracksPicker({super.key});

  Widget _buildItemPopupMenuButton(
    BuildContext context,
    Track track,
    List<Track> tracks,
    List<String> selectedTrackIds,
    SelectedTracksNotifier selectedTracksNotifier,
    FavoriteTracksNotifier favoriteTracksNotifier,
  ) {
    return PopupMenuButton<OptionSelectedFavorites>(
      initialValue: null,
      onSelected: (OptionSelectedFavorites item) {
        _handleItemOptionSelected(context, track, item, tracks, selectedTrackIds, selectedTracksNotifier, favoriteTracksNotifier);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelectedFavorites>>[
        const PopupMenuItem<OptionSelectedFavorites>(value: OptionSelectedFavorites.select, child: Text('Select')),
        const PopupMenuItem<OptionSelectedFavorites>(value: OptionSelectedFavorites.removeFromFavorites, child: Text('Remove from favorites')),
      ],
    );
  }

  void _removeFromFavoritesModal(
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
          title: const Text('Remove from favorites?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No')
            ),
            TextButton(
              onPressed: () {
                handleTracksRemovedFromFavorites(
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
    OptionSelectedFavorites? optionSelected,
    List<Track> tracks,
    List<String> selectedTrackIds,
    SelectedTracksNotifier selectedTracksNotifier,
    FavoriteTracksNotifier favoriteTracksNotifier,
  ) {
    if (optionSelected == OptionSelectedFavorites.removeFromFavorites) {
      selectedTracksNotifier.clear();
      selectedTracksNotifier.selectTrack(track);
      _removeFromFavoritesModal(context, tracks, selectedTrackIds, selectedTracksNotifier, favoriteTracksNotifier);
    } else if (optionSelected == OptionSelectedFavorites.select) {
      selectedTracksNotifier.selectTrack(track);
    }
  }

  Future<void> _playSelectedTrack(Track track, PlayerController playerController, PlayerControllerNotifier playerControllerNotifier) async {
    if (isTrackCurrentlyPlaying(track, playerController)) {
      return;
    }
    if (playerController.trackPlayer == null) {
      // TODO: here we want to set the track player type depending on the source type of the track
      playerController.setTrackPlayer(JustAudioProvider());
    }
    await playerControllerNotifier.stop();
    playerControllerNotifier.setCurrentTrack(track);
    await playerControllerNotifier.play();
  }

  void _toggleSelectedTrack(Track track, List<String> selectedTracks, SelectedTracksNotifier selectedTracksNotifier) {
    if (selectedTracks.contains(track.id)) {
      selectedTracksNotifier.unselectTrack(track);
    } else {
      selectedTracksNotifier.selectTrack(track);
    }
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    List<Track> tracks,
    List<String> selectedTracks,
    SelectedTracksNotifier selectedTracksNotifier,
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
          icon: const Icon(Icons.favorite_border),
          tooltip: 'Remove from favorites',
          onPressed: () {
            _removeFromFavoritesModal(context, tracks, selectedTracks, selectedTracksNotifier, favoriteTracksNotifier);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    final tracks = ref.watch(tracksProvider);
    final selectedTracks = ref.watch(selectedTracksProvider);
    final selectedTracksNotifier = ref.watch(selectedTracksProvider.notifier);
    final playerController = ref.read(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    final isInSelectMode = selectedTracks.isNotEmpty;
    final favoriteTrackIds = ref.watch(favoriteTracksProvider);
    final favoriteTracksNotifier = ref.watch(favoriteTracksProvider.notifier);
    final favoriteTracks = tracks.where((e) => favoriteTrackIds.contains(e.id)).toList();

    if (initialLoadDone && favoriteTracks.isEmpty) {
      return Center(child:Text("No favorite tracks found. Go to the \"All Tracks\" tab to add some!"));
    }
    return Scaffold(
      appBar: _buildAppBar(
        context,
        tracks,
        selectedTracks,
        selectedTracksNotifier,
        favoriteTracksNotifier,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 5, bottom: 5)),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () async {
                await playerControllerNotifier.stop();
                playerControllerNotifier.setTrackPlayer(JustAudioProvider());
                playerControllerNotifier.setQueue(favoriteTracks);
                final firstTrack = playerControllerNotifier.getPlayerController().shuffledTrackQueue.first;
                playerControllerNotifier.setCurrentTrack(firstTrack);
                await playerControllerNotifier.play();
              },
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  Text("Play"),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
          Expanded(
            child: ListView(
              children: tracks.map(
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
                    trailing: isInSelectMode ? null : _buildItemPopupMenuButton(context, track, tracks, selectedTracks, selectedTracksNotifier, favoriteTracksNotifier),
                  );
              }).toList()
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // TODO: implement searching
            },
            child: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
