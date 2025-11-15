import 'package:yampa/core/player/enums.dart';

class LastPlayerControllerState {
  final String? currentTrackId;
  final String? currentPlaylistId;
  final int currentTrackIndex;
  final double speed;
  final List<String> trackQueueIds;
  final List<String> shuffledTrackQueueIds;
  final PlayerState state;
  final LoopMode loopMode;
  final ShuffleMode shuffleMode;

  LastPlayerControllerState({
    required this.currentTrackId,
    required this.currentPlaylistId,
    required this.currentTrackIndex,
    required this.speed,
    required this.trackQueueIds,
    required this.shuffledTrackQueueIds,
    required this.state,
    required this.loopMode,
    required this.shuffleMode,
  });
}
