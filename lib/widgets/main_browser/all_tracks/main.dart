import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/common.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/add_to_playlist_modal.dart';

class AllTracksPicker extends ConsumerStatefulWidget {
  const AllTracksPicker({super.key});

  @override
  ConsumerState<AllTracksPicker> createState() => _AllTracksPickerState();
}

class _AllTracksPickerState extends ConsumerState<AllTracksPicker> {

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
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    List<String> selectedTracks,
    SelectedTracksNotifier selectedTracksNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
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
    final isInSelectMode = selectedTracks.isNotEmpty;

    if (initialLoadDone && tracks.isEmpty) {
      return Center(child:Text("No tracks found. Go to the Added Paths tab to add some!"));
    }
    return Scaffold(
      appBar: _buildAppBar(
        context,
        tracks,
        playlists,
        playlistsNotifier,
        selectedTracks,
        selectedTracksNotifier,
        selectedPlaylistsNotifier,
      ),
      body: ListView(
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
              onSelect: onSelect,
            );
        }).toList()
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
