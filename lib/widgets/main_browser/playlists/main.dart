import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
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
    final selectedTracks = ref.watch(tracksProvider).where((e) => _selectedTrackIds.contains(e.id)).toList();
    return FloatingActionButton(
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
                      _selectedTrackIds = [];
                      handleMultipleTrackRemovedFromPlaylist(_selectedPlaylist!, selectedTracks, playlistNotifier);
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

  @override
  Widget build(BuildContext context) {
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    return Scaffold(
      body: _selectedPlaylist != null
        ? PlaylistViewSmall(
            playlist: _selectedPlaylist!,
            onEdit: (Playlist editedPlaylist) {
              // TODO
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
          ),
      floatingActionButton: _buildFloatingActionButton(context, playlistNotifier),
    );
  }
}
