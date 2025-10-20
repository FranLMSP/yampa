import 'package:yampa/core/track_players/interface.dart';
import 'package:yampa/core/track_players/just_audio.dart';

TrackPlayer getTrackPlayer() {
  return JustAudioProvider();
}