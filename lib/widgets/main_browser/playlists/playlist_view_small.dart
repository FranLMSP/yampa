import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/all_tracks/main.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';


class PlaylistViewSmall extends ConsumerStatefulWidget {
  final Playlist playlist;
  final Function(Playlist editedPlaylist) onEdit;
  final Function onGoBack;
  final Function(List<String> tracks) setSelectedTrackIds;

  const PlaylistViewSmall({
    super.key,
    required this.playlist,
    required this.onEdit,
    required this.onGoBack,
    required this.setSelectedTrackIds,
  });

  @override
  ConsumerState<PlaylistViewSmall> createState() => _PlaylistViewSmallState();
}

class _PlaylistViewSmallState extends ConsumerState<PlaylistViewSmall> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final List<String> _selectedTrackIds = [];

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

  Widget _buildItemPopupMenuButton(
    Track track,
    List<Track> tracks,
    PlaylistNotifier playlistNotifier,
  ) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) {
        _handleItemOptionSelected(track, item, tracks, playlistNotifier);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelected>>[
        const PopupMenuItem<OptionSelected>(value: OptionSelected.select, child: Text('Select')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.removeFromPlaylist, child: Text('Remove from playlist')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.info, child: Text('Info')),
      ],
    );
  }

  void _handleItemOptionSelected(
    Track track,
    OptionSelected? optionSelected,
    List<Track> tracks,
    PlaylistNotifier playlistNotifier,
  ) {
    if (optionSelected == OptionSelected.removeFromPlaylist) {
      handleTrackRemovedFromPlaylist(widget.playlist, track, playlistNotifier);
    } else if (optionSelected == OptionSelected.select) {
      _toggleSelectedTrack(track.id);
    }
  }

  void _toggleSelectedTrack(String id) {
    setState(() {
      if (_selectedTrackIds.contains(id)) {
        _selectedTrackIds.remove(id);
      } else {
        _selectedTrackIds.add(id);
      }
      widget.setSelectedTrackIds(_selectedTrackIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.playlist.imagePath;
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    final playlistNotifier = ref.watch(playlistsProvider.notifier);
    final tracks = ref.watch(tracksProvider);
    final playlists = ref.watch(playlistsProvider);
    final selectedPlaylist = playlists.where((e) => e.id == widget.playlist.id).firstOrNull ?? widget.playlist;
    final isInSelectMode = _selectedTrackIds.isNotEmpty;

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
            onTapOutside: (text) {
              final editedPlaylist = Playlist(
                id: widget.playlist.id,
                name: _titleController.text,
                description: widget.playlist.description,
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
            onTapOutside: (text) {
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
                if (selectedPlaylist.tracks.isNotEmpty) {
                  await playerControllerNotifier.stop();
                  playerControllerNotifier.setTrackPlayer(JustAudioProvider());
                  playerControllerNotifier.setQueue(widget.playlist.tracks);
                  final firstTrack = playerControllerNotifier.getPlayerController().shuffledTrackQueue.first;
                  playerControllerNotifier.setCurrentTrack(firstTrack);
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
              final isSelected = _selectedTrackIds.contains(track.id);
              return TrackItem(
                key: Key(track.id),
                track: track,
                onTap: (Track track) {
                  if (isInSelectMode) {
                    _toggleSelectedTrack(track.id);
                  } else {
                    // TODO: play track
                  }
                },
                onLongPress: (Track track) {
                  _toggleSelectedTrack(track.id);
                },
                isSelected: isSelected,
                trailing: isInSelectMode ? null : _buildItemPopupMenuButton(track, tracks, playlistNotifier),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

