import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart';
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
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTrackPlaceholder(String? currentTrackId) {
    final icon = track.id == currentTrackId
        ? Icons.play_arrow
        : Icons.music_note;
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey,
      child: Icon(icon, size: 40, color: Colors.white),
    );
  }

  Widget _buildTrackIcon(String? currentTrackId) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: track.imageBytes != null
          ? _buildTrackImage()
          : _buildTrackPlaceholder(currentTrackId),
    );
  }

  Widget _buildDuration(Duration duration) {
    return Text(formatDuration(duration));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.value?.currentTrackId),
    );
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
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: ListTile(
          leading: _buildTrackIcon(currentTrackId),
          title: Text(track.displayName()),
          subtitle: Row(
            children: [
              Text(track.artist),
              Spacer(),
              _buildDuration(track.duration),
            ],
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}
