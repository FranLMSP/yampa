import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
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
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTrackPlaceholder(PlayerController playerController) {
    final icon = isTrackCurrentlyBeingPlayed(track, playerController)
      ? Icons.play_arrow
      : Icons.music_note;
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey,
      child: Icon(icon, size: 40, color: Colors.white),
    );
  }

  Widget _buildTrackIcon(PlayerController playerController) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: track.imageBytes != null
        ? _buildTrackImage()
        : _buildTrackPlaceholder(playerController),
    );
  }

  Widget _buildDuration(Duration duration) {
    return Text(formatDuration(duration));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
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
        color: isSelected ? Colors.indigo : null, // TODO: grab this from the main theme of the app
        child: ListTile(
          leading: _buildTrackIcon(playerController),
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
