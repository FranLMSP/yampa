import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/statistics_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/common/image_cropper_screen.dart';
import 'package:yampa/widgets/main_browser/all_tracks/main.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_info_dialog.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/common.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/utils/sort_utils.dart';
import 'package:yampa/widgets/common/sort_button.dart';
import 'package:yampa/widgets/utils.dart';

enum ImageTabOptions { changeImage, removeImage }

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.playlist.name);
    _descriptionController = TextEditingController(
      text: widget.playlist.description,
    );
    _scrollController = ScrollController();
  }

  Future<void> _updateImage(Playlist selectedPlaylist, String? path) async {
    String? newPath;
    if (path != null) {
      newPath = await copyImageToLocal(path);
    }
    final editedPlaylist = Playlist(
      id: selectedPlaylist.id,
      name: selectedPlaylist.name,
      description: selectedPlaylist.description,
      trackIds: selectedPlaylist.trackIds,
      imagePath: newPath,
    );
    widget.onEdit(editedPlaylist);
  }

  void _changeImage(Playlist selectedPlaylist) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    final Uint8List? croppedImage = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageCropperScreen(imageData: bytes),
      ),
    );

    if (croppedImage == null) return;

    // Save cropped image to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(croppedImage);

    await _updateImage(selectedPlaylist, tempFile.path);
  }

  void _showImageOptions(
    BuildContext context,
    Playlist selectedPlaylist,
  ) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final box = context.findRenderObject() as RenderBox?;
    if (overlay == null || box == null) return;

    final selected = await showMenu<ImageTabOptions>(
      context: context,
      position: RelativeRect.fromRect(
        box.localToGlobal(Offset.zero) & box.size,
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<ImageTabOptions>>[
        const PopupMenuItem<ImageTabOptions>(
          value: ImageTabOptions.changeImage,
          child: Row(
            children: [
              Icon(Icons.image),
              SizedBox(width: 12),
              Text('Select another image'),
            ],
          ),
        ),
        const PopupMenuItem<ImageTabOptions>(
          value: ImageTabOptions.removeImage,
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 12),
              Text('Remove image'),
            ],
          ),
        ),
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
    Map<String, Track> tracks,
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) async {
        await _handleItemOptionSelected(
          selectedPlaylist,
          track,
          item,
          tracks,
          playlistNotifier,
          playerNotifier,
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelected>>[
        const PopupMenuItem<OptionSelected>(
          value: OptionSelected.select,
          child: Row(
            children: [
              Icon(Icons.check_box),
              SizedBox(width: 12),
              Text('Select'),
            ],
          ),
        ),
        const PopupMenuItem<OptionSelected>(
          value: OptionSelected.removeFromPlaylist,
          child: Row(
            children: [
              Icon(Icons.playlist_remove),
              SizedBox(width: 12),
              Text('Remove from playlist'),
            ],
          ),
        ),
        const PopupMenuItem<OptionSelected>(
          value: OptionSelected.info,
          child: Row(
            children: [Icon(Icons.info), SizedBox(width: 12), Text('Info')],
          ),
        ),
      ],
    );
  }

  Future<void> _handleItemOptionSelected(
    Playlist selectedPlaylist,
    Track track,
    OptionSelected? optionSelected,
    Map<String, Track> tracks,
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerNotifier,
  ) async {
    if (optionSelected == OptionSelected.removeFromPlaylist) {
      await handleMultipleTrackRemovedFromPlaylist(
        selectedPlaylist,
        [track.id],
        playlistNotifier,
        playerNotifier,
      );
    } else if (optionSelected == OptionSelected.select) {
      _toggleSelectedTrack(track.id);
    } else if (optionSelected == OptionSelected.info) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) => TrackInfoDialog(track: track),
      );
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
    final playerControllerNotifier = ref.watch(
      playerControllerProvider.notifier,
    );
    final playlistNotifier = ref.watch(playlistsProvider.notifier);
    final tracks = ref.watch(tracksProvider);
    final playlists = ref.watch(playlistsProvider);
    final selectedPlaylist =
        playlists.where((e) => e.id == widget.playlist.id).firstOrNull ??
        widget.playlist;
    final isInSelectMode = _selectedTrackIds.isNotEmpty;
    final allTrackStatisticsAsync = ref.watch(allTrackStatisticsProvider);
    final isMobile = isPlatformMobile();

    return Scrollbar(
      controller: _scrollController,
      thickness: isMobile ? 20 : null,
      radius: isMobile ? const Radius.circular(8) : null,
      thumbVisibility: isMobile ? true : null,
      interactive: isMobile ? true : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        controller: _scrollController,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  SortButton(
                    currentSortMode: selectedPlaylist.sortMode,
                    onSortModeChanged: (SortMode mode) {
                      ref.invalidate(allTrackStatisticsProvider);
                      playlistNotifier.setSortMode(selectedPlaylist, mode);

                      final editedPlaylist = Playlist(
                        id: selectedPlaylist.id,
                        name: selectedPlaylist.name,
                        description: selectedPlaylist.description,
                        trackIds: selectedPlaylist.trackIds,
                        imagePath: selectedPlaylist.imagePath,
                        sortMode: mode,
                      );
                      widget.onEdit(editedPlaylist);
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      handlePlaylistsExport([selectedPlaylist]);
                    },
                    tooltip: "Export this playlist",
                    icon: const Icon(Icons.file_upload),
                  ),
                  if (selectedPlaylist.id != favoritePlaylistId)
                    IconButton(
                      onPressed: () {
                        removePlaylistsModal(
                          context,
                          [selectedPlaylist],
                          playlistNotifier,
                          () => widget.onGoBack(),
                        );
                      },
                      tooltip: "Delete this playlist",
                      icon: const Icon(Icons.delete),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (selectedPlaylist.imagePath == null ||
                    !isValidImagePath(selectedPlaylist.imagePath!)) {
                  _changeImage(selectedPlaylist);
                } else {
                  _showImageOptions(context, selectedPlaylist);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(20),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: PlaylistImage(
                    playlist: selectedPlaylist,
                  )
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              readOnly: selectedPlaylist.id == favoritePlaylistId,
              decoration: const InputDecoration(labelText: 'Title'),
              onTapOutside: (text) {
                final editedPlaylist = Playlist(
                  id: selectedPlaylist.id,
                  name: _titleController.text,
                  description: selectedPlaylist.description,
                  trackIds: selectedPlaylist.trackIds,
                  imagePath: selectedPlaylist.imagePath,
                  sortMode: selectedPlaylist.sortMode,
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
                  sortMode: selectedPlaylist.sortMode,
                );
                widget.onEdit(editedPlaylist);
              },
            ),
            const SizedBox(height: 24),
            if (selectedPlaylist.trackIds.isNotEmpty)
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedPlaylist.trackIds.isNotEmpty) {
                      await playerController.setPlaylist(
                        selectedPlaylist,
                        tracks,
                      );
                      final firstTrack =
                          tracks[selectedPlaylist.trackIds.first];
                      if (firstTrack != null) {
                        await playTrack(
                          firstTrack,
                          tracks,
                          playerControllerNotifier,
                        );
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.play_arrow),
                      Text("Play (${selectedPlaylist.trackIds.length})"),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Column(
              children:
                  sortTracks(
                    selectedPlaylist.trackIds
                        .map((e) => tracks[e])
                        .whereType<Track>()
                        .toList(),
                    selectedPlaylist.sortMode,
                    allTrackStatisticsAsync.value ?? {},
                  ).map((track) {
                    final isSelected = _selectedTrackIds.contains(track.id);
                    return TrackItem(
                      key: Key(track.id),
                      track: track,
                      onTap: (Track track) async {
                        if (isInSelectMode) {
                          _toggleSelectedTrack(track.id);
                        } else if (playerController.currentPlaylistId !=
                            selectedPlaylist.id) {
                          await playerControllerNotifier.setPlaylist(
                            selectedPlaylist,
                            tracks,
                          );
                          await playTrack(
                            track,
                            tracks,
                            playerControllerNotifier,
                          );
                        }
                      },
                      onLongPress: (Track track) {
                        _toggleSelectedTrack(track.id);
                      },
                      isSelected: isSelected,
                      trailing: isInSelectMode
                          ? null
                          : _buildItemPopupMenuButton(
                              selectedPlaylist,
                              track,
                              tracks,
                              playlistNotifier,
                              playerControllerNotifier,
                            ),
                    );
                  }).toList(),
            ),
          ],
        ),
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
