import 'package:flutter/material.dart';
import 'package:yampa/models/playlist.dart';

class PlaylistItemBig extends StatelessWidget {
  const PlaylistItemBig({super.key, required this.playlist, this.onTap});

  final Playlist playlist;
  final Function(Playlist playlist)? onTap;

@override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: InkWell(
        onTap: () => onTap != null ? onTap!(playlist) : () {},
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: playlist.imagePath != null
                  ? Image.asset(
                      playlist.imagePath!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.playlist_play,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Colors.white,
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

