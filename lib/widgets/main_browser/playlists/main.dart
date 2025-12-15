import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/playlists/common.dart';
import 'package:yampa/widgets/main_browser/playlists/new_playlist_dialog.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_list_big.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_view_small.dart';

class Playlists extends ConsumerStatefulWidget {
  const Playlists({super.key});

  @override
  ConsumerState<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends ConsumerState<Playlists> {
  Playlist? _selectedPlaylist;
  List<String> _selectedTrackIds = [];

  Widget _buildAddNewTrackFloatingButton(PlaylistNotifier playlistNotifier) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewPlaylistDialog(
              onSaved: (newPlaylist) async {
                final createdPlaylist = await handlePlaylistCreated(
                  newPlaylist,
                  playlistNotifier,
                );
                setState(() {
                  _selectedPlaylist = createdPlaylist;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRemoveSelectedTracksButton(
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
      child: Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Remove from playlist?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    setState(() {
                      handleMultipleTrackRemovedFromPlaylist(
                        _selectedPlaylist!,
                        _selectedTrackIds,
                        playlistNotifier,
                        playerNotifier,
                      );
                      _selectedTrackIds = [];
                      // TODO: show a snackbar with an "undo" button
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_selectedTrackIds.isEmpty && _selectedPlaylist == null)
          _buildAddNewTrackFloatingButton(playlistNotifier),
        if (_selectedTrackIds.isNotEmpty)
          _buildRemoveSelectedTracksButton(playlistNotifier, playerNotifier),
      ],
    );
  }

  void _handlePlaylistSelected(Playlist playlist) {
    setState(() {
      _selectedTrackIds = [];
      _selectedPlaylist = playlist;
    });
  }

  Future<void> _handlePlaylistOptions(
    BuildContext context,
    Playlist playlist,
    PlaylistNotifier playlistsNotifier,
    TapDownDetails details,
  ) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: [
        if (playlist.id != favoritePlaylistId)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete),
                SizedBox(width: 12),
                Text('Delete'),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'select',
          child: Row(
            children: [
              Icon(Icons.check_box),
              SizedBox(width: 12),
              Text('Select'),
            ],
          ),
        ),
      ],
    );

    if (selected == 'delete') {
      if (context.mounted) {
        removePlaylistModal(context, playlist, playlistsNotifier, null);
      }
    } else if (selected == 'select') {
      // TODO: handle multi select
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    final playerNotifier = ref.read(playerControllerProvider.notifier);
    return Scaffold(
      body: _selectedPlaylist != null
          ? PlaylistViewSmall(
              playlist: _selectedPlaylist!,
              onEdit: (Playlist editedPlaylist) {
                handlePlaylistEdited(editedPlaylist, playlistNotifier);
              },
              onGoBack: () {
                setState(() {
                  _selectedPlaylist = null;
                  _selectedTrackIds = [];
                });
              },
              setSelectedTrackIds: (List<String> selectedTrackIds) {
                setState(() {
                  _selectedTrackIds = selectedTrackIds;
                });
              },
            )
          : PlaylistListBig(
              onTap: (Playlist playlist) {
                _handlePlaylistSelected(playlist);
              },
              onLongPress: (Playlist playlist) {
                // TODO: handle multi select
              },
              onSecondaryTap: (Playlist playlist, TapDownDetails details) {
                _handlePlaylistOptions(
                  context,
                  playlist,
                  playlistNotifier,
                  details,
                );
              },
            ),
      floatingActionButton: _buildFloatingActionButton(
        context,
        playlistNotifier,
        playerNotifier,
      ),
    );
  }
}
