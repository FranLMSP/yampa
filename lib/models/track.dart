import 'dart:typed_data';

import 'package:yampa/core/utils/filename_utils.dart';

class Track {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String genre;
  final String path;
  final int trackNumber;
  final Duration duration;
  final Uint8List? imageBytes;

  Track({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.genre,
    required this.path,
    required this.trackNumber,
    required this.duration,
    this.imageBytes,
  });

  String displayName() => name.isNotEmpty ? name : extractFilenameFromFullPath(path);
}
