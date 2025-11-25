import 'package:yampa/core/player_backends/interface.dart';
import 'package:yampa/core/player_backends/just_audio.dart';

Future<PlayerBackend> getPlayerBackend() async {
  final backend = JustAudioBackend();
  await backend.init();
  return backend;
}
