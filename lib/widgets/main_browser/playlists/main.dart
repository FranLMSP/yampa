import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';
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
              onSaved: (newPlaylist) {
                handlePlaylistCreated(newPlaylist, playlistNotifier);
                setState(() {
                  _selectedPlaylist = newPlaylist;
                });
              },
            );
          }
        );
      },
    );
  }

  Widget _buildRemoveSelectedTracksButton(PlaylistNotifier playlistNotifier) {
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
                      handleMultipleTrackRemovedFromPlaylist(_selectedPlaylist!, _selectedTrackIds, playlistNotifier);
                      _selectedTrackIds = [];
                      // TODO: show a snackbar with an "undo" button
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, PlaylistNotifier playlistNotifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_selectedTrackIds.isEmpty && _selectedPlaylist == null) _buildAddNewTrackFloatingButton(playlistNotifier),
        if (_selectedTrackIds.isNotEmpty) _buildRemoveSelectedTracksButton(playlistNotifier),
      ],
    );
  }

  void _handlePlaylistSelected(Playlist playlist) {
    setState(() {
      _selectedTrackIds = [];
      _selectedPlaylist = playlist;
    });
  }

  Future<void> _handlePlaylistOptions(BuildContext context, Playlist playlist, PlaylistNotifier playlistsNotifier, TapDownDetails details) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: const [
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
      // TODO: Don't use 'BuildContext's across async gaps. Try rewriting the code to not use the 'BuildContext', or guard the use with a 'mounted' 
      _removePlaylistModal(context, playlist, playlistsNotifier);
    } else if (selected == 'select') {
      // TODO: handle multi select
    }
  }

  void _removePlaylistModal(
    BuildContext context,
    Playlist playlist,
    PlaylistNotifier playlistsNotifier,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete this playlist?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No')
            ),
            TextButton(
              onPressed: () {
                handlePlaylistRemoved(playlist, playlistsNotifier);
                Navigator.of(context).pop();
                // TODO: show snackbar with "undo" button
              },
              child: const Text('Yes')
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlistNotifier = ref.read(playlistsProvider.notifier);
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
              _handlePlaylistOptions(context, playlist, playlistNotifier, details);
            },
          ),
      floatingActionButton: _buildFloatingActionButton(context, playlistNotifier),
    );
  }
}
