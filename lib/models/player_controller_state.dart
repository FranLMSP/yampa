import 'package:yampa/core/player/enums.dart';

class LastPlayerControllerState {
  final String? currentTrackId;
  final String? currentPlaylistId;
  final double speed;
  final List<String> trackQueueIds;
  final List<String> shuffledTrackQueueIds;
  final PlayerState state;
  final LoopMode loopMode;
  final ShuffleMode shuffleMode;
  final TrackQueueDisplayMode trackQueueDisplayMode;
  final double volume;
  final List<double> equalizerGains;

  LastPlayerControllerState({
    required this.currentTrackId,
    required this.currentPlaylistId,
    required this.speed,
    required this.trackQueueIds,
    required this.shuffledTrackQueueIds,
    required this.state,
    required this.loopMode,
    required this.shuffleMode,
    required this.trackQueueDisplayMode,
    required this.volume,
    required this.equalizerGains,
  });
}
