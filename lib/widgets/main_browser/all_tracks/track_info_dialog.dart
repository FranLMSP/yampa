import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/statistics_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/common/track_title.dart';

class TrackInfoDialog extends ConsumerStatefulWidget {
  const TrackInfoDialog({super.key, required this.track});

  final Track track;

  @override
  ConsumerState<TrackInfoDialog> createState() => _TrackInfoDialogState();
}

class _TrackInfoDialogState extends ConsumerState<TrackInfoDialog> {
  bool _isEditing = false;

  late TextEditingController _titleCtrl;
  late TextEditingController _artistCtrl;
  late TextEditingController _albumCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _trackNumCtrl;

  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.track.title);
    _artistCtrl = TextEditingController(text: widget.track.artist);
    _albumCtrl = TextEditingController(text: widget.track.album);
    _genreCtrl = TextEditingController(text: widget.track.genre);
    _trackNumCtrl = TextEditingController(
      text: widget.track.trackNumber.toString(),
    );
    _imageBytes = widget.track.imageBytes;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    _genreCtrl.dispose();
    _trackNumCtrl.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value, bool isResponsive) {
    // TODO: make this responsive
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Unknown" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    // TODO: make this responsive
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(isDense: true),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _handleSave() async {
    final updatedTrack = Track(
      id: widget.track.id,
      title: _titleCtrl.text.trim(),
      artist: _artistCtrl.text.trim(),
      album: _albumCtrl.text.trim(),
      genre: _genreCtrl.text.trim(),
      path: widget.track.path,
      trackNumber:
          int.tryParse(_trackNumCtrl.text.trim()) ?? widget.track.trackNumber,
      duration: widget.track.duration,
      imageBytes: _imageBytes,
      lastModified: DateTime.now(),
    );

    final allTracks = ref.read(tracksProvider);
    final allPlaylists = ref.read(playlistsProvider);
    final tracksNotifier = ref.read(tracksProvider.notifier);
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );

    await handleTrackMetadataEdited(
      updatedTrack,
      allTracks,
      allPlaylists,
      tracksNotifier,
      playlistNotifier,
      playerControllerNotifier,
    );

    if (mounted) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => TrackInfoDialog(track: updatedTrack),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackStatsAsync = ref.watch(
      trackStatisticsStreamProvider(widget.track.id),
    );

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: TrackTitle(track: widget.track)),
          // TODO: metadata editing doesn't currently work on Android (permission issue)
          if (!Platform.isAndroid && !Platform.isIOS)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() => _isEditing = !_isEditing);
              },
            ),
        ],
      ),
      scrollable: true,
      content: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track image
            Center(
              child: InkWell(
                onTap: _isEditing ? _pickNewImage : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.music_note, size: 64),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isEditing && _imageBytes != null)
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _imageBytes = null),
                  child: const Text(
                    "Remove Image",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              "Metadata",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_isEditing) ...[
              _buildEditableRow('Title', _titleCtrl),
              _buildEditableRow('Artist', _artistCtrl),
              _buildEditableRow('Album', _albumCtrl),
              _buildEditableRow('Genre', _genreCtrl),
              _buildEditableRow(
                'Track #',
                _trackNumCtrl,
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              _buildInfoRow('Title', widget.track.title, true),
              _buildInfoRow('Artist', widget.track.artist, true),
              _buildInfoRow('Album', widget.track.album, true),
              _buildInfoRow('Genre', widget.track.genre, true),
              _buildInfoRow('Duration', formatDuration(widget.track.duration), false),
              _buildInfoRow(
                'Track Number',
                widget.track.trackNumber.toString(),
                false,
              ),
              _buildInfoRow('Path', widget.track.path, true),
            ],
            const SizedBox(height: 24),
            Text(
              "Statistics",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            trackStatsAsync.when(
              data: (stats) {
                if (stats.timesPlayed == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No statistics yet - play this track to start tracking!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    _buildInfoRow(
                      'Times Played',
                      formatCount(stats.timesPlayed),
                      false,
                    ),
                    _buildInfoRow(
                      'Times Skipped',
                      formatCount(stats.timesSkipped),
                      false,
                    ),
                    _buildInfoRow(
                      'Times Completed',
                      formatCount(stats.completionCount),
                      false,
                    ),
                    _buildInfoRow(
                      'Total Playback Time',
                      formatDurationLong(
                        Duration(seconds: (stats.minutesPlayed * 60).round()),
                      ),
                      false,
                    ),
                    _buildInfoRow(
                      'Last Played',
                      formatTimestamp(stats.lastPlayedAt),
                      false,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text("Error loading stats: $e"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (_isEditing)
          ElevatedButton(onPressed: _handleSave, child: const Text("Save")),
      ],
    );
  }
}
