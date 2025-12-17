import 'dart:convert';
import 'dart:typed_data';

import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';

Future<void> playTrack(
  Track track,
  Map<String, Track> tracks,
  PlayerControllerNotifier playerControllerNotifier,
) async {
  await playerControllerNotifier.playTrack(track, tracks);
}

bool isTrackCurrentlyBeingPlayed(Track track, String? currentTrackId) {
  return (currentTrackId != null && track.id == currentTrackId);
}

Uri bytesToDataUri(Uint8List bytes) {
  final base64Data = base64Encode(bytes);
  return Uri.parse('data:image/png;base64,$base64Data');
}
