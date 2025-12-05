import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/common/sort_button.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';

File getFile(String path) => File(path);

class UpcomingTracksList extends ConsumerWidget {
  const UpcomingTracksList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerControllerState = ref.watch(playerControllerProvider);
    final playerController = playerControllerState.value;
    final playlists = ref.watch(playlistsProvider);
    final tracks = ref.watch(tracksProvider);
    final playerControllerNotifier = ref.read(playerControllerProvider.notifier);

    if (playerController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentPlaylist = playlists.firstWhere(
      (p) => p.id == playerController.currentPlaylistId,
      orElse: () => playlists.first, // Fallback, though ideally shouldn't happen if playing
    );

    final shuffledTrackIds = playerController.shuffledTrackQueueIds;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              PlaylistImage(
                playlist: currentPlaylist,
                width: 40,
                height: 40,
                iconSize: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentPlaylist.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SortButton(
                currentSortMode: currentPlaylist.sortMode,
                onSortModeChanged: (mode) async {
                   final playlistsNotifier = ref.read(playlistsProvider.notifier);
                   playlistsNotifier.setSortMode(currentPlaylist, mode);
                   await playerControllerNotifier.reloadPlaylist(currentPlaylist, tracks);
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: shuffledTrackIds.length,
            itemBuilder: (context, index) {
              final trackId = shuffledTrackIds[index];
              final track = tracks[trackId];

              if (track == null) return const SizedBox.shrink();

              return TrackItem(
                key: Key(track.id),
                track: track,
                onTap: (track) async {
                  playTrack(track, tracks, playerController, playerControllerNotifier);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
