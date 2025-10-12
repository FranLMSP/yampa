import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/models/track.dart';

bool isTrackCurrentlyPlaying(Track track, PlayerController playerController) {
  return (
    playerController.currentTrack != null
    && track.path == playerController.currentTrack?.path
  );
}
