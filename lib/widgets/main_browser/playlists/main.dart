import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';
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
    setState(() {
      if (_selectedPlaylistIds.contains(playlistId)) {
        _selectedPlaylistIds.removeWhere((e) => e == playlistId);
      } else {
        _selectedPlaylistIds.add(playlistId);
      }
    });
  }

  PreferredSizeWidget _buildAppBar(
    List<Playlist> allPlaylists,
    PlaylistNotifier playlistNotifier,
  ) {
    final isMultiSelecting = _selectedPlaylistIds.isNotEmpty;

    if (isMultiSelecting) {
      return AppBar(
        title: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.selectedCount).replaceFirst('{}', _selectedPlaylistIds.length.toString())),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => setState(() => _selectedPlaylistIds = []),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              final selectedPlaylists = allPlaylists
                  .where((e) => _selectedPlaylistIds.contains(e.id))
                  .toList();
              handlePlaylistsExport(selectedPlaylists);
            },
            tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.exportSelected),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              final selectedPlaylists = allPlaylists
                  .where((e) => _selectedPlaylistIds.contains(e.id))
                  .toList();
              removePlaylistsModal(
                context,
                selectedPlaylists,
                playlistNotifier,
                () => setState(() => _selectedPlaylistIds = []),
              );
            },
            tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.deleteSelected),
          ),
        ],
      );
    }

    if (_openedPlaylist != null) {
      return AppBar(
        title: Text(_openedPlaylist!.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _openedPlaylist = null;
            _selectedTrackIds = [];
          }),
        ),
      );
    }

    return AppBar(
      title: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.playlistsTab)),
      actions: [
        IconButton(
          icon: Icon(Icons.add_circle_outline),
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
          tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.newPlaylistTooltip),
        ),
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () async {
            await handlePlaylistsImport(playlistNotifier, allPlaylists);
          },
          tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.importPlaylistsTooltip),
        ),
        IconButton(
          icon: Icon(Icons.file_upload),
          onPressed: () {
            handlePlaylistsExport(allPlaylists);
          },
          tooltip: ref.read(localizationProvider.notifier).translate(LocalizationKeys.exportAllTooltip),
        ),
      ],
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
              title: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.removeFromPlaylistQuestion)),
              actions: <Widget>[
                TextButton(
                  child: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.no)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.yes)),
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
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerNotifier,
  ) {
    if (_openedPlaylist != null && _selectedTrackIds.isNotEmpty) {
      return _buildRemoveSelectedTracksButton(playlistNotifier, playerNotifier);
    }
    return null;
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
                Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.delete)),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'select',
          child: Row(
            children: [
              Icon(Icons.check_box),
              SizedBox(width: 12),
              Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.select)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_upload),
              SizedBox(width: 12),
              Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.export)),
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
    } else if (selected == 'export') {
      handlePlaylistsExport([playlist]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlaylists = ref.watch(playlistsProvider);
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    final playerNotifier = ref.read(playerControllerProvider.notifier);
    final isMultiSelecting = _selectedPlaylistIds.isNotEmpty;
    return Scaffold(
      appBar: _buildAppBar(allPlaylists, playlistNotifier),
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
        playlistNotifier,
        playerNotifier,
      ),
    );
  }
}
