import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';

import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/selected_playlists_provider.dart';
import 'package:yampa/providers/selected_tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_item_list.dart';

class AddToPlaylistDialog extends ConsumerStatefulWidget {
  const AddToPlaylistDialog({super.key});

  @override
  ConsumerState<AddToPlaylistDialog> createState() =>
      _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends ConsumerState<AddToPlaylistDialog> {
  String? _editingPlaylistId;

  Future<void> _createNewPlaylist(WidgetRef ref) async {
    final newPlaylist = Playlist(
      id: "temp",
      name: 'New Playlist',
      description: '',
      trackIds: [],
      sortMode: SortMode.titleAtoZ,
    );

    final createdPlaylist = await handlePlaylistCreated(
      newPlaylist,
      ref.read(playlistsProvider.notifier),
    );
    ref
        .read(selectedPlaylistsProvider.notifier)
        .selectPlaylist(createdPlaylist);

    setState(() {
      _editingPlaylistId = createdPlaylist.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    final selectedPlaylistsNotifier = ref.read(
      selectedPlaylistsProvider.notifier,
    );
    final selectedTracksNotifier = ref.read(selectedTracksProvider.notifier);
    final playlistNotifier = ref.read(playlistsProvider.notifier);
    final playerNotifier = ref.read(playerControllerProvider.notifier);

    return AlertDialog(
      scrollable: true,
      title: const Text('Playlists'),
      content: Column(
        children: [
          ...playlists.map(
            (playlist) => PlaylistItemList(
              playlist: playlist,
              isEditable: playlist.id == _editingPlaylistId,
              onRenameSubmit: (newName) async {
                final updatedPlaylist = Playlist(
                  id: playlist.id,
                  name: newName,
                  description: playlist.description,
                  trackIds: playlist.trackIds,
                  imagePath: playlist.imagePath,
                  sortMode: playlist.sortMode,
                );
                await handlePlaylistEdited(updatedPlaylist, playlistNotifier);
                setState(() {
                  _editingPlaylistId = null;
                });
              },
              onTap: (playlist) {
                if (selectedPlaylistsNotifier.getPlaylistIds().contains(
                  playlist.id,
                )) {
                  selectedPlaylistsNotifier.unselectPlaylist(playlist);
                } else {
                  selectedPlaylistsNotifier.selectPlaylist(playlist);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _createNewPlaylist(ref),
            child: const Text('New playlist'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            selectedPlaylistsNotifier.clear();
            if (selectedTracksNotifier.getTrackIds().length == 1) {
              selectedTracksNotifier.clear();
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await handleTracksAddedToPlaylist(
              selectedTracksNotifier.getTrackIds(),
              playlists
                  .where(
                    (e) => selectedPlaylistsNotifier.getPlaylistIds().contains(
                      e.id,
                    ),
                  )
                  .toList(),
              playlistNotifier,
              playerNotifier,
            );
            selectedTracksNotifier.clear();
            selectedPlaylistsNotifier.clear();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

void addToPlaylistsModal(
  BuildContext context,
  List<String> selectedTrackIds,
  PlaylistNotifier playlistNotifier,
  SelectedPlaylistNotifier selectedPlaylistsNotifier,
  SelectedTracksNotifier selectedTracksNotifier,
  PlayerControllerNotifier playerNotifier,
) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return const AddToPlaylistDialog();
    },
  );
}
