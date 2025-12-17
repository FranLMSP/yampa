import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';

class TrackItem extends ConsumerWidget {
  const TrackItem({
    super.key,
    required this.track,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.isSelected = false,
  });

  final Track track;
  final Function(Track track)? onTap;
  final Function(Track track)? onLongPress;
  final Widget? trailing;
  final bool isSelected;

  Widget _buildTrackImage() {
    return Image.memory(
      track.imageBytes!,
      width: 45,
      height: 45,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTrackPlaceholder(bool isPlaying) {
    return Container(
      width: 45,
      height: 45,
      color: Colors.grey,
      child: isPlaying
          ? null
          : const Icon(Icons.music_note, size: 40, color: Colors.white),
    );
  }

  Widget _buildTrackIcon(bool isPlaying) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          track.imageBytes != null
              ? _buildTrackImage()
              : _buildTrackPlaceholder(isPlaying),

          if (isPlaying)
            Container(
              width: 45,
              height: 45,
              color: Colors.black.withValues(alpha: 0.4),
            ),

          if (isPlaying)
            const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildDuration(Duration duration) {
    return Text(formatDuration(duration), style: const TextStyle(fontSize: 11));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final isPlaying = isTrackCurrentlyBeingPlayed(track, currentTrackId);
    Color? color;
    if (isSelected) {
      color = Theme.of(context).colorScheme.inversePrimary;
    } else if (isPlaying) {
      color = Theme.of(context).colorScheme.surfaceDim;
    }
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(track);
        }
      },
      onLongPress: () {
        if (onLongPress != null) {
          onLongPress!(track);
        }
      },
      child: ListTile(
        mouseCursor: MouseCursor.defer,
        selected: isSelected || isPlaying,
        selectedTileColor: color,
        leading: _buildTrackIcon(isPlaying),
        title: Text(
          track.displayTitle(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(track.artist, style: const TextStyle(fontSize: 12)),
            const Spacer(),
            _buildDuration(track.duration),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
