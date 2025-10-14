import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/player/player_controller.dart';
import 'package:music_player/core/utils/format_utils.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/providers/player_controller_provider.dart';
import 'package:music_player/providers/playlists_provider.dart';
import 'package:music_player/widgets/main_browser/all_tracks/track_list/common.dart';
import 'package:music_player/widgets/main_browser/playlists/add_to_playlist_modal.dart';

enum OptionSelected {
  select,
  addToPlaylists,
  info,
}

class TrackItem extends ConsumerWidget {
  const TrackItem({super.key, required this.track, this.onTap});

  final Track track;
  final Function(Track track)? onTap;

  Widget _buildTrackImage() {
    return Image.memory(
      track.imageBytes!,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTrackPlaceholder(PlayerController playerController) {
    final icon = isTrackCurrentlyPlaying(track, playerController)
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

  void _handleOptionSelected(BuildContext context, OptionSelected? optionSelected, List<Playlist> playlists) {
    if (optionSelected == OptionSelected.addToPlaylists) {
      addToPlaylistsModal(context, playlists);
    }
  }

  Widget _buildPopupMenuButton(BuildContext context, List<Playlist> playlists) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) {
        _handleOptionSelected(context, item, playlists);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OptionSelected>>[
        const PopupMenuItem<OptionSelected>(value: OptionSelected.select, child: Text('Select')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.addToPlaylists, child: Text('Add to playlists')),
        const PopupMenuItem<OptionSelected>(value: OptionSelected.info, child: Text('Info')),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final playlists = ref.read(playlistsProvider);
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(track);
        }
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
          trailing: _buildPopupMenuButton(context, playlists),
        ),
      ),
    );
  }
}
