import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/core/player_backends/just_audio.dart';

PlayerBackend getPlayerBackend() {
  return JustAudioBackend();
}