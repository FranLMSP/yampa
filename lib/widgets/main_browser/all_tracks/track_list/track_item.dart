import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/common.dart';
import 'package:yampa/widgets/main_browser/playlists/add_to_playlist_modal.dart';

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

  void _handleOptionSelected(
    BuildContext context,
    OptionSelected? optionSelected,
    List<Track> tracks,
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    SelectedTracksNotifier selectedTracksNotifier,
  ) {
    if (optionSelected == OptionSelected.addToPlaylists) {
      selectedTracksNotifier.clear();
      selectedTracksNotifier.selectTrack(track);
      addToPlaylistsModal(context, tracks, playlists, playlistNotifier, selectedPlaylistsNotifier, selectedTracksNotifier);
    }
  }

  Widget _buildPopupMenuButton(
    BuildContext context,
    List<Track> tracks,
    List<Playlist> playlists,
    PlaylistNotifier playlistNotifier,
    SelectedPlaylistNotifier selectedPlaylistsNotifier,
    SelectedTracksNotifier selectedTracksNotifier,
  ) {
    return PopupMenuButton<OptionSelected>(
      initialValue: null,
      onSelected: (OptionSelected item) {
        _handleOptionSelected(context, item, tracks, playlists, playlistNotifier, selectedPlaylistsNotifier, selectedTracksNotifier);
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
    final tracks = ref.read(tracksProvider);
    final playlists = ref.read(playlistsProvider);
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    final selectedPlaylistsNotifier = ref.read(selectedPlaylistsProvider.notifier);
    final selectedTracksNotifier = ref.read(selectedTracksProvider.notifier);
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
          trailing: _buildPopupMenuButton(context, tracks, playlists, playlistNotifier, selectedPlaylistsNotifier, selectedTracksNotifier),
        ),
      ),
    );
  }
}
