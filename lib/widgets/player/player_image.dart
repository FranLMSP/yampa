import 'package:flutter/material.dart';
import 'package:yampa/models/track.dart';

const imageWidth = 200.0;
const imageHeight = 200.0;

class PlayerImage extends StatelessWidget {

  const PlayerImage({
    super.key,
    this.track,
  });

  final Track? track;

  Widget _buildImage(Track track) {
    return Image.memory(
      track.imageBytes!,
      width: imageWidth,
      height: imageHeight,
      fit: BoxFit.cover,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: imageWidth,
      height: imageHeight,
      color: Colors.grey,
      child: const Icon(Icons.music_note, size: 100, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: track?.imageBytes != null
        ? _buildImage(track!)
        : _buildImagePlaceholder(),
    );
  }
}
