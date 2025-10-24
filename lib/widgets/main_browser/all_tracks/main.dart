import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/common.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';

class AllTracksPicker extends ConsumerStatefulWidget {
  const AllTracksPicker({super.key});

  @override
  ConsumerState<AllTracksPicker> createState() => _AllTracksPickerState();
}

class _AllTracksPickerState extends ConsumerState<AllTracksPicker> {

  List<String> _selectedTrackIds = [];

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

  Future<void> _toggleSelectedTrack(Track track) async {
    setState(() {
      if (_selectedTrackIds.contains(track.id)) {
        _selectedTrackIds.remove(track.id);
      } else {
        _selectedTrackIds.add(track.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    final tracks = ref.watch(tracksProvider);
    final playerController = ref.read(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    final isInSelectMode = _selectedTrackIds.isNotEmpty;

    if (initialLoadDone && tracks.isEmpty) {
      return Center(child:Text("No tracks found. Go to the Added Paths tab to add some!"));
    }
    return Scaffold(
      appBar: null,
      body: ListView(
        children: tracks.map(
          (track) {
            Function(Track track)? onTap;
            Function(Track track)? onLongPress;
            void _onSelect(Track track) {
              _toggleSelectedTrack(track);
            }
            if (isInSelectMode) {
              onTap = _onSelect;
            } else {
              onTap = (Track track) {
                _playSelectedTrack(track, playerController, playerControllerNotifier);
              };
              onLongPress = _onSelect;
            }
            final isSelected = _selectedTrackIds.contains(track.id);
            return TrackItem(
              key: Key(track.id),
              track: track,
              onTap: onTap,
              onLongPress: onLongPress,
              isSelected: isSelected,
              onSelect: _onSelect,
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
