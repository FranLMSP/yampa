import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/models/track.dart';

bool isTrackCurrentlyPlaying(Track track, PlayerController playerController) {
  return (
    playerController.currentTrack != null
    && track.path == playerController.currentTrack?.path
  );
}
