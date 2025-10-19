enum PlayerState {
  playing,
  paused,
  stopped,
}

enum LoopMode {
  singleTrack,
  infinite,
  startToEnd,
  none,
}

enum ShuffleMode {
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
