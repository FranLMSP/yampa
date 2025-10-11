import 'package:music_player/models/track.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final List<Track> tracks;
  final String? imagePath;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.tracks,
    this.imagePath,
  });

  Playlist clone() {
    return Playlist(
      id: id,
      name: name,
      description: description,
      tracks: tracks,
      imagePath: imagePath
    );
  }
}
