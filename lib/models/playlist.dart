import 'package:yampa/core/player/enums.dart';

const favoritePlaylistId = "favorites";

class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final SortMode sortMode;
  final String? imagePath;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.trackIds,
    this.sortMode = SortMode.titleAtoZ,
    this.imagePath,
  });

  Playlist clone() {
    return Playlist(
      id: id,
      name: name,
      description: description,
      trackIds: trackIds,
      imagePath: imagePath,
      sortMode: sortMode,
    );
  }

  Map<String, dynamic> toJson({String? imageB64}) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'trackIds': trackIds,
      'sortMode': sortMode.index,
      'imageB64': imageB64,
    };
  }

  static Playlist fromJson(Map<String, dynamic> json, {String? imagePath}) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      trackIds: List<String>.from(json['trackIds']),
      sortMode: SortMode.values[json['sortMode'] ?? 0],
      imagePath: imagePath,
    );
  }
}
