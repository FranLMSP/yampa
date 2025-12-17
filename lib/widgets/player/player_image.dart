import 'package:flutter/material.dart';
import 'package:yampa/models/track.dart';

class PlayerImage extends StatelessWidget {
  const PlayerImage({
    super.key,
    this.track,
    this.width = 175.0,
    this.height = 175.0,
    this.iconSize = 100.0,
  });

  final Track? track;
  final double width;
  final double height;
  final double iconSize;

  Widget _buildImage(Track track) {
    return Image.memory(
      track.imageBytes!,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey,
      child: Icon(Icons.music_note, size: iconSize, color: Colors.white),
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
