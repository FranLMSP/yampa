import 'dart:typed_data';

import 'package:yampa/core/utils/file_utils.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String path;
  final int trackNumber;
  final Duration duration;
  final Uint8List? imageBytes;
  final DateTime? lastModified;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.path,
    required this.trackNumber,
    required this.duration,
    this.imageBytes,
    this.lastModified,
  });

  String displayTitle() =>
      title.isNotEmpty ? title : extractFilenameFromFullPath(path);
}
