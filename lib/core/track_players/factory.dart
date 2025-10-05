import 'package:music_player/core/track_players/interface.dart';
import 'package:music_player/core/track_players/just_audio.dart';

TrackPlayer getTrackPlayer() {
  return JustAudioProvider();
}