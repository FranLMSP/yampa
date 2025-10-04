enum PlayerState {
  playing,
  paused,
  stopped,
}

enum LoopMode {
  singleSong,
  infinite,
  startToEnd,
  none,
}

enum NextTrackMode {
  sequential,
  random,
  randomBasedOnHistory,
}

enum SourceType {
  file,
  mpv,
  // TODO: support these in the future
  // spotify,
  // youtube,
}
