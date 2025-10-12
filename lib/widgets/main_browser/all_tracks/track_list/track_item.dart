import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/core/track_players/just_audio.dart';
import 'package:music_player/core/utils/format_utils.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/player_controller_provider.dart';

class TrackItem extends ConsumerWidget {
  const TrackItem({super.key, required this.track, this.onTap});

  final Track track;
  final VoidCallback? onTap;

  Widget _buildTrackImage() {
    return Image.memory(
      track.imageBytes!,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTrackPlaceholder(PlayerController playerController) {
    final icon = _isTrackCurrentlyPlaying(playerController)
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

  bool _isTrackCurrentlyPlaying(PlayerController playerController) {
    return (
      playerController.currentTrack != null
      && track.path == playerController.currentTrack?.path
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerProviderNotifier = ref.read(playerControllerProvider.notifier);
    final playerController = ref.watch(playerControllerProvider);
    return InkWell(
      onTap: () async {
        if (onTap != null) {
          onTap!();
        }
        if (_isTrackCurrentlyPlaying(playerController)) {
          return;
        }
        if (playerController.trackPlayer == null) {
          // TODO: here we want to set the track player type depending on the
          // source type of the track
          playerController.setTrackPlayer(JustAudioProvider());
        }
        await playerProviderNotifier.stop();
        playerProviderNotifier.setCurrentTrack(track);
        await playerProviderNotifier.play();
      },
      onLongPress: () => {
        // TODO: implement functionality to select multiple tracks
      },
      child: Card(
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
          trailing: IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              // TODO: popup menu button
            },
          ),
        ),
      ),
    );
  }
}
