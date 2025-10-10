import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:ulid/ulid.dart';

// TODO: this widget is an absolute mess but I don't care (for now)

class PlaylistEditForm extends ConsumerStatefulWidget {
  final Playlist playlist;
  final bool isNew;
  final Function(Playlist newPlaylist) onSaveNew;
  final Function(Playlist editedPlaylist) onEdit;
  final Function onGoBack;

  const PlaylistEditForm({
    super.key,
    required this.playlist,
    required this.isNew,
    required this.onSaveNew,
    required this.onEdit,
    required this.onGoBack,
  });

  @override
  ConsumerState<PlaylistEditForm> createState() => _PlaylistEditFormState();
}

class _PlaylistEditFormState extends ConsumerState<PlaylistEditForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _addedTracksExpanded = true;
  bool _otherTracksExpanded = false;

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

  List<Track> _getOtherTracks(List<Track> allTracks) {
    final currentTracksIds = widget.playlist.tracks.map((e) => e.id).toList();
    return allTracks.where((e) => !currentTracksIds.contains(e.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.playlist.imagePath;
    final playlistProviderNotifier = ref.watch(playlistsProvider.notifier);
    final allTracks = ref.watch(tracksProvider);
    final otherTracks = _getOtherTracks(allTracks);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
              widget.onEdit(Playlist(
                id: widget.playlist.id,
                name: _titleController.text,
                description: widget.playlist.id,
                tracks: widget.playlist.tracks,
                imagePath: widget.playlist.imagePath,
              ));
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (text) {
              widget.onEdit(Playlist(
                id: widget.playlist.id,
                name: widget.playlist.name,
                description: _descriptionController.text,
                tracks: widget.playlist.tracks,
                imagePath: widget.playlist.imagePath,
              ));
            },
          ),
          const SizedBox(height: 24),
          ExpansionPanelList(
            expansionCallback: (_, isExpanded) {
              setState(() {
                _addedTracksExpanded = isExpanded;
                if (isExpanded) _otherTracksExpanded = false;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (_, __) => const ListTile(title: Text('Added Tracks')),
                body: widget.playlist.tracks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No tracks added'),
                      )
                    : Column(
                        children: widget.playlist.tracks.map((track) {
                          return ListTile(
                            leading: _buildTrackImage(track),
                            title: Text(track.displayName()),
                            subtitle: Text(track.artist),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() {
                                if (!widget.isNew) {
                                  playlistProviderNotifier.removeTrack(widget.playlist, track);
                                } else {
                                  widget.playlist.tracks.removeWhere((e) => e.id == track.id);
                                }
                                widget.onEdit(widget.playlist);
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                isExpanded: _addedTracksExpanded,
              ),
            ],
          ),
          ExpansionPanelList(
            expansionCallback: (_, isExpanded) {
              setState(() {
                _otherTracksExpanded = isExpanded;
                if (isExpanded) _addedTracksExpanded = false;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (_, __) => const ListTile(title: Text('Other Tracks')),
                body: otherTracks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No other tracks available'),
                      )
                    : Column(
                        children: otherTracks.map((track) {
                          return ListTile(
                            leading: _buildTrackImage(track),
                            title: Text(track.displayName()),
                            subtitle: Text(track.artist),
                            onTap: () => setState(() {
                              if (!widget.isNew) {
                                playlistProviderNotifier.addTrack(widget.playlist, track);
                              } else {
                                widget.playlist.tracks.add(track);
                              }
                              widget.onEdit(widget.playlist);
                            }),
                          );
                        }).toList(),
                      ),
                isExpanded: _otherTracksExpanded,
              ),
            ],
          ),
          if (widget.isNew)
            ElevatedButton(
              onPressed: () {
                final newPlaylist = Playlist(
                  id: Ulid().toString(),
                  name: widget.playlist.name,
                  description: widget.playlist.description,
                  tracks: widget.playlist.tracks,
                  imagePath: widget.playlist.imagePath,
                );
                playlistProviderNotifier.addPlaylist(newPlaylist);
                widget.onSaveNew(newPlaylist);
              },
              child: const Text('Save new playlist'),
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
