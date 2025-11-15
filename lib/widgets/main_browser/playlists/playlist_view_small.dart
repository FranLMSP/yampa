import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/track_players/just_audio.dart';
import 'package:yampa/core/utils/filename_utils.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/all_tracks/main.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';

enum ImageTabOptions {
  changeImage,
  removeImage,
}

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

  void _updateImage(Playlist selectedPlaylist, String? path) {
    // TODO: here we want to copy the image to a local path in case the user deletes or moves the image in the original location
    final editedPlaylist = Playlist(
      id: selectedPlaylist.id,
      name: selectedPlaylist.name,
      description: selectedPlaylist.description,
      trackIds: selectedPlaylist.trackIds,
      imagePath: path,
    );
    widget.onEdit(editedPlaylist);
  }

  void _changeImage(Playlist selectedPlaylist) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      return;
    }
    final path = result.paths.first;
    if (path == null || !isValidImagePath(path)) {
      return;
    }

    _updateImage(selectedPlaylist, path);
  }

  void _showImageOptions(BuildContext context, Playlist selectedPlaylist) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final box = context.findRenderObject() as RenderBox?;
    if (overlay == null || box == null) return;

    final selected = await showMenu<ImageTabOptions>(
      context: context,
      position: RelativeRect.fromRect(
        box.localToGlobal(Offset.zero) & box.size,
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<ImageTabOptions>>[
        const PopupMenuItem<ImageTabOptions>(value: ImageTabOptions.changeImage, child: Text('Select another image')),
        const PopupMenuItem<ImageTabOptions>(value: ImageTabOptions.removeImage, child: Text('Remove image')),
      ],
    );

    if (selected == ImageTabOptions.changeImage) {
      _changeImage(selectedPlaylist);
    } else if (selected == ImageTabOptions.removeImage) {
      _updateImage(selectedPlaylist, null);
    }
  }

  Widget _buildItemPopupMenuButton(
    Playlist selectedPlaylist,
    Track track,
    List<Track> tracks,
    PlaylistNotifier playlistNotifier,
  ) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) {
        _handleItemOptionSelected(selectedPlaylist, track, item, tracks, playlistNotifier);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelected>>[
        const PopupMenuItem<OptionSelected>(value: OptionSelected.select, child: Text('Select')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.removeFromPlaylist, child: Text('Remove from playlist')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.info, child: Text('Info')),
      ],
    );
  }

  void _handleItemOptionSelected(
    Playlist selectedPlaylist,
    Track track,
    OptionSelected? optionSelected,
    List<Track> tracks,
    PlaylistNotifier playlistNotifier,
  ) {
    if (optionSelected == OptionSelected.removeFromPlaylist) {
      handleMultipleTrackRemovedFromPlaylist(selectedPlaylist, [track.id], playlistNotifier);
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
    final playerController = ref.watch(playerControllerProvider);
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
          InkWell(
            onTap: () {
              if (selectedPlaylist.imagePath == null || !isValidImagePath(selectedPlaylist.imagePath!)) {
                _changeImage(selectedPlaylist);
              } else {
                _showImageOptions(context, selectedPlaylist);
              }
            },
            child: PlaylistImage(playlist: selectedPlaylist),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            onTapOutside: (text) {
              final editedPlaylist = Playlist(
                id: selectedPlaylist.id,
                name: _titleController.text,
                description: selectedPlaylist.description,
                trackIds: selectedPlaylist.trackIds,
                imagePath: selectedPlaylist.imagePath,
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
                id: selectedPlaylist.id,
                name: selectedPlaylist.name,
                description: _descriptionController.text,
                trackIds: selectedPlaylist.trackIds,
                imagePath: selectedPlaylist.imagePath,
              );
              widget.onEdit(editedPlaylist);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () async {
                if (selectedPlaylist.trackIds.isNotEmpty) {
                  await playerControllerNotifier.stop();
                  playerControllerNotifier.setTrackPlayer(JustAudioProvider());
                  await playerControllerNotifier.setPlaylist(selectedPlaylist);
                  final firstTrackId = playerControllerNotifier.getPlayerController().shuffledTrackQueueIds.first;
                  final firstTrack = tracks.firstWhere((e) => e.id == firstTrackId);
                  await playerControllerNotifier.setCurrentTrack(firstTrack);
                  await playerControllerNotifier.play(tracks);
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
            children: selectedPlaylist.trackIds.map((trackId) {
              final isSelected = _selectedTrackIds.contains(trackId);
              final track = tracks.firstWhere((e) => e.id == trackId);
              return TrackItem(
                key: Key(trackId),
                track: track,
                onTap: (Track track) {
                  if (isInSelectMode) {
                    _toggleSelectedTrack(track.id);
                  } else {
                    playTrack(track, tracks, playerController, playerControllerNotifier);
                  }
                },
                onLongPress: (Track track) {
                  _toggleSelectedTrack(track.id);
                },
                isSelected: isSelected,
                trailing: isInSelectMode ? null : _buildItemPopupMenuButton(selectedPlaylist, track, tracks, playlistNotifier),
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

