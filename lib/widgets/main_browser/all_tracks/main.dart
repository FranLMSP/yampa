import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/core/track_players/just_audio.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/initial_load_provider.dart';
import 'package:music_player/providers/player_controller_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/widgets/main_browser/all_tracks/track_list/common.dart';
import 'package:music_player/widgets/main_browser/all_tracks/track_list/track_list.dart';

class AllTracksPicker extends ConsumerWidget {
  const AllTracksPicker({super.key});

  Future<void> _playSelectedTrack(Track track, PlayerController playerController, PlayerControllerNotifier playerControllerNotifier) async {
    if (isTrackCurrentlyPlaying(track, playerController)) {
      return;
    }
    if (playerController.trackPlayer == null) {
      // TODO: here we want to set the track player type depending on the
      // source type of the track
      playerController.setTrackPlayer(JustAudioProvider());
    }
    await playerControllerNotifier.stop();
    playerControllerNotifier.setCurrentTrack(track);
    await playerControllerNotifier.play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    final tracks = ref.watch(tracksProvider);
    final playerController = ref.read(playerControllerProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);
    if (initialLoadDone && tracks.isEmpty) {
      return Center(child:Text("No tracks found. Go to the Added Paths tab to add some!"));
    }
    return TrackList(
      tracks: tracks,
      onTap: (Track track) {
        _playSelectedTrack(track, playerController, playerControllerNotifier);
      },
    );
  }
}
