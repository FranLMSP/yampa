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
  Playlist? _openedPlaylist;
  List<String> _selectedTrackIds = [];
  List<String> _selectedPlaylistIds = [];

  void _toggleSelectedPlaylist(String playlistId) {
    if (playlistId == favoritePlaylistId) {
      return;
    }
    setState(() {
      if (_selectedPlaylistIds.contains(playlistId)) {
        _selectedPlaylistIds.removeWhere((e) => e == playlistId);
      } else {
        _selectedPlaylistIds.add(playlistId);
      }
    });
  }

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
                  _openedPlaylist = createdPlaylist;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRemoveSelectedPlaylistsButton(
    List<Playlist> allPlaylists,
    PlaylistNotifier playlistsNotifier,
  ) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
      child: Icon(Icons.delete),
      onPressed: () {
        final selectedPlaylists = allPlaylists.where((e) => _selectedPlaylistIds.contains(e.id)).toList();
        removePlaylistsModal(context, selectedPlaylists, playlistsNotifier, () => setState(() {
          _selectedPlaylistIds = [];
        }));
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
                        _openedPlaylist!,
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
    List<Playlist> allPlaylists,
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_selectedPlaylistIds.isNotEmpty)
          _buildRemoveSelectedPlaylistsButton(allPlaylists, playlistNotifier),
        if (_selectedPlaylistIds.isEmpty && _selectedTrackIds.isEmpty && _openedPlaylist == null)
          _buildAddNewTrackFloatingButton(playlistNotifier),
        if (_selectedPlaylistIds.isEmpty && _selectedTrackIds.isNotEmpty && _openedPlaylist != null)
          _buildRemoveSelectedTracksButton(playlistNotifier, playerNotifier),
      ],
    );
  }

  void _handlePlaylistOpened(Playlist playlist) {
    setState(() {
      _selectedTrackIds = [];
      _openedPlaylist = playlist;
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
        removePlaylistsModal(context, [playlist], playlistsNotifier, null);
      }
    } else if (selected == 'select') {
      _toggleSelectedPlaylist(playlist.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlaylists = ref.watch(playlistsProvider);
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    final playerNotifier = ref.read(playerControllerProvider.notifier);
    final isMultiSelecting = _selectedPlaylistIds.isNotEmpty;
    return Scaffold(
      body: _openedPlaylist != null && !isMultiSelecting
          ? PlaylistViewSmall(
              playlist: _openedPlaylist!,
              onEdit: (Playlist editedPlaylist) {
                handlePlaylistEdited(editedPlaylist, playlistNotifier);
              },
              onGoBack: () {
                setState(() {
                  _openedPlaylist = null;
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
              selectedPlaylists: _selectedPlaylistIds,
              onTap: (Playlist playlist) {
                if (isMultiSelecting) {
                  _toggleSelectedPlaylist(playlist.id);
                } else {
                  _handlePlaylistOpened(playlist);
                }
              },
              onLongPress: (Playlist playlist) {
                if (!isMultiSelecting) {
                  _toggleSelectedPlaylist(playlist.id);
                }
              },
              onSecondaryTap: (Playlist playlist, TapDownDetails details) {
                if (!isMultiSelecting) {
                  _handlePlaylistOptions(
                    context,
                    playlist,
                    playlistNotifier,
                    details,
                  );
                }
              },
            ),
      floatingActionButton: _buildFloatingActionButton(
        context,
        allPlaylists,
        playlistNotifier,
        playerNotifier,
      ),
    );
  }
}
