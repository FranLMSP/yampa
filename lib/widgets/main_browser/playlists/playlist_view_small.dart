import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/track_players/just_audio.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/player_controller_provider.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/utils.dart';


class PlaylistViewSmall extends ConsumerStatefulWidget {
  final Playlist playlist;
  final Function(Playlist editedPlaylist) onEdit;
  final Function onGoBack;

  const PlaylistViewSmall({
    super.key,
    required this.playlist,
    required this.onEdit,
    required this.onGoBack,
  });

  @override
  ConsumerState<PlaylistViewSmall> createState() => _PlaylistViewSmallState();
}

class _PlaylistViewSmallState extends ConsumerState<PlaylistViewSmall> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.playlist.name);
    _descriptionController = TextEditingController(text: widget.playlist.description);
  }

  void _changeImage() async {
    // Replace this with your image picking logic
    final newImagePath = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Image'),
        content: const Text('Simulate picking image here...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'path/to/new/image.png'),
            child: const Text('Pick'),
          ),
        ],
      ),
    );

    if (newImagePath != null) {
      setState(() {
        // You might want to save this to the backend or update state elsewhere
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.playlist.imagePath;
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    final playlistNotifier = ref.watch(playlistsProvider.notifier);
    final playlists = ref.watch(playlistsProvider);
    final selectedPlaylist = playlists.where((e) => e.id == widget.playlist.id).firstOrNull ?? widget.playlist;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => widget.onGoBack(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ),
          GestureDetector(
            onTap: _changeImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  imagePath != null ? AssetImage(imagePath) : null,
              child: imagePath == null
                  ? const Icon(Icons.playlist_play, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            onEditingComplete: () {
              final editedPlaylist = Playlist(
                id: widget.playlist.id,
                name: _titleController.text,
                description: widget.playlist.id,
                tracks: widget.playlist.tracks,
                imagePath: widget.playlist.imagePath,
              );
              widget.onEdit(editedPlaylist);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (text) {
              final editedPlaylist = Playlist(
                id: widget.playlist.id,
                name: widget.playlist.name,
                description: _descriptionController.text,
                tracks: widget.playlist.tracks,
                imagePath: widget.playlist.imagePath,
              );
              widget.onEdit(editedPlaylist);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () async {
                if (widget.playlist.tracks.isNotEmpty) {
                  await playerControllerNotifier.stop();
                  playerControllerNotifier.setTrackPlayer(JustAudioProvider());
                  playerControllerNotifier.setQueue(widget.playlist.tracks);
                  playerControllerNotifier.setCurrentTrack(widget.playlist.tracks.first);
                  await playerControllerNotifier.play();
                }
              },
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  Text("Play"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: selectedPlaylist.tracks.map((track) {
              return ListTile(
                leading: _buildTrackImage(track),
                title: Text(track.displayName()),
                subtitle: Text(track.artist),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // TODO: scaffold with an "undo" button
                    setState(() {
                      widget.playlist.tracks.removeWhere((e) => e.id == track.id);
                      widget.onEdit(widget.playlist);
                    });
                    await handleTrackRemovedFromPlaylist(widget.playlist, track, playlistNotifier);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackImage(Track track) {
    if (track.imageBytes != null) {
      return CircleAvatar(
        backgroundImage: MemoryImage(track.imageBytes!),
      );
    } else {
      return const CircleAvatar(child: Icon(Icons.music_note));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

