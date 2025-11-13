import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';

Future<void> playTrack(Track track, PlayerController playerController, PlayerControllerNotifier playerControllerNotifier) async {
  if (isTrackCurrentlyBeingPlayed(track, playerController)) {
    return;
  }
  if (playerController.trackPlayer == null) {
    // TODO: here we want to set the track player type depending on the source type of the track
    await playerController.setTrackPlayer(JustAudioProvider());
  }
  await playerControllerNotifier.stop();
  await playerControllerNotifier.setCurrentTrack(track);
  await playerControllerNotifier.play();
}
  
bool isTrackCurrentlyBeingPlayed(Track track, PlayerController playerController) {
  return (
    playerController.currentTrack != null
    && track.path == playerController.currentTrack?.path
  );
}
