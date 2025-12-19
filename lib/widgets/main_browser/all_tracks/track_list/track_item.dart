import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/utils.dart';

class TrackItem extends ConsumerWidget {
  const TrackItem({
    super.key,
    required this.track,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.isSelected = false,
    this.isDraggable = true,
  });

  final Track track;
  final Function(Track track)? onTap;
  final Function(Track track)? onLongPress;
  final Widget? trailing;
  final bool isSelected;
  final bool isDraggable;

  Widget _buildTrackImage() {
    return Image.memory(
      track.imageBytes!,
      width: 45,
      height: 45,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTrackPlaceholder(BuildContext context, bool isPlaying) {
    return Container(
      width: 45,
      height: 45,
      color: Theme.of(context).hintColor,
      child: isPlaying
          ? null
          : Icon(
              Icons.music_note,
              size: 40,
              color: Theme.of(context).canvasColor,
            ),
    );
  }

  Widget _buildTrackIcon(BuildContext context, bool isPlaying) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          track.imageBytes != null
              ? _buildTrackImage()
              : _buildTrackPlaceholder(context, isPlaying),

          if (isPlaying)
            Container(
              width: 45,
              height: 45,
              color: Theme.of(context).hintColor.withAlpha(70),
            ),

          if (isPlaying)
            Icon(
              Icons.play_arrow,
              color: Theme.of(context).canvasColor,
              size: 32,
            ),
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
    final item = InkWell(
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
        leading: _buildTrackIcon(context, isPlaying),
        title: Text(
          track.displayTitle(),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
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

    if (!isDraggable) {
      return item;
    }

    final isMobile = isPlatformMobile();

    Widget feedback = Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          leading: _buildTrackIcon(context, isPlaying),
          title: Text(
            track.displayTitle(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artist,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (isMobile) {
      return LongPressDraggable<Track>(
        data: track,
        feedback: feedback,
        childWhenDragging: Opacity(opacity: 0.5, child: item),
        child: item,
      );
    }

    return Draggable<Track>(
      data: track,
      feedback: feedback,
      childWhenDragging: Opacity(opacity: 0.5, child: item),
      child: item,
    );
  }
}
