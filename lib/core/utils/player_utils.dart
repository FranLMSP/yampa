import 'dart:convert';
import 'dart:typed_data';

import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player_backends/factory.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';

Future<void> playTrack(
  Track track,
  Map<String, Track> tracks,
  PlayerController playerController,
  PlayerControllerNotifier playerControllerNotifier,
) async {
  if (playerController.playerBackend == null) {
    // TODO: here we want to set the track player type depending on the source type of the track
    await playerControllerNotifier.setPlayerBackend(await getPlayerBackend());
  }
  await playerControllerNotifier.stop();
  await playerControllerNotifier.setCurrentTrack(track, tracks);
  await playerControllerNotifier.play();
}

bool isTrackCurrentlyBeingPlayed(Track track, String? currentTrackId) {
  return (currentTrackId != null && track.id == currentTrackId);
}

Uri bytesToDataUri(Uint8List bytes) {
  final base64Data = base64Encode(bytes);
  return Uri.parse('data:image/png;base64,$base64Data');
}
