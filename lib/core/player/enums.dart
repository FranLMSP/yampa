enum PlayerState { playing, paused, stopped }

enum LoopMode { singleTrack, infinite, startToEnd, none }

enum ShuffleMode { sequential, random, randomBasedOnHistory }

enum SourceType {
  file,
  mpv,
  // TODO: support these in the future
  // spotify,
  // youtube,
}

enum SortMode {
  // Title
  titleAtoZ,
  titleZtoA,

  // Artist
  artistAtoZ,
  artistZtoA,

  // Album
  albumAtoZ,
  albumZtoA,

  // Genre
  genreAtoZ,
  genreZtoA,

  // Play count
  // mostPlayed, // TODO: implement after track statistics
  // leastPlayed, // TODO: implement after track statistics

  // Recently played
  // recentlyPlayed, // TODO: implement after track statistics

  // Duration
  durationShortToLong,
  durationLongToShort,

  // Release year
  newestRelease,
  oldestRelease,
}

enum TrackQueueDisplayMode { image, list }
