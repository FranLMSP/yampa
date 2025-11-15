const favoritePlaylistId = "favorites";

class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final String? imagePath;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.trackIds,
    this.imagePath,
  });

  Playlist clone() {
    return Playlist(
      id: id,
      name: name,
      description: description,
      trackIds: trackIds,
      imagePath: imagePath
    );
  }
}
