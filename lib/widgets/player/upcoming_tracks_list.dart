import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';
import 'package:yampa/widgets/utils.dart';

File getFile(String path) => File(path);

class UpcomingTracksList extends ConsumerWidget {
  UpcomingTracksList({super.key});
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final playlists = ref.watch(playlistsProvider);
    final tracks = ref.watch(tracksProvider);
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );

    final currentPlaylist = playlists
        .where((p) => p.id == playerController.currentPlaylistId)
        .firstOrNull;

    final shuffledTrackIds = playerController.shuffledTrackQueueIds;
    final isMobile = isPlatformMobile();

    return DragTarget<Track>(
      onWillAcceptWithDetails: (details) {
        return playerController.currentPlaylistId != null;
      },
      onAcceptWithDetails: (details) async {
        final track = details.data;
        if (currentPlaylist != null) {
          await handleTracksAddedToPlaylist(
            [track.id],
            [currentPlaylist],
            ref.read(playlistsProvider.notifier),
            playerControllerNotifier,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isOver
                ? Theme.of(context).colorScheme.primaryContainer.withAlpha(50)
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    if (currentPlaylist != null)
                      PlaylistImage(
                        playlist: currentPlaylist,
                        width: 40,
                        height: 40,
                        iconSize: 30,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentPlaylist?.name ?? "Playing all tracks",
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  thickness: isMobile ? 20 : null,
                  radius: isMobile ? const Radius.circular(8) : null,
                  thumbVisibility: isMobile ? true : null,
                  interactive: isMobile ? true : null,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: shuffledTrackIds.length,
                    itemBuilder: (context, index) {
                      final trackId = shuffledTrackIds[index];
                      final track = tracks[trackId];

                      if (track == null) return const SizedBox.shrink();

                      return TrackItem(
                        key: Key(track.id),
                        track: track,
                        isDraggable: false,
                        onTap: (track) async {
                          await playTrack(
                            track,
                            tracks,
                            playerControllerNotifier,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
