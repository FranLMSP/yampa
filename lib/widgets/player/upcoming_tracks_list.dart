import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/player_utils.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/widgets/common/constants.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_list/track_item.dart';
import 'package:yampa/widgets/main_browser/playlists/playlist_image.dart';
import 'package:yampa/widgets/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

File getFile(String path) => File(path);

class UpcomingTracksList extends ConsumerStatefulWidget {
  const UpcomingTracksList({super.key});

  @override
  ConsumerState<UpcomingTracksList> createState() => _UpcomingTracksListState();
}

class _UpcomingTracksListState extends ConsumerState<UpcomingTracksList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTrack(animated: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTrack({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final playerController = ref.read(playerControllerProvider);
    final shuffledTrackIds = playerController.shuffledTrackQueueIds;
    final currentTrackId = playerController.currentTrackId;
    if (currentTrackId == null) return;

    final index = shuffledTrackIds.indexOf(currentTrackId);
    if (index != -1) {
      final offset = index * 72.0; // itemExtent
      if (animated) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerController = ref.watch(playerControllerProvider);
    final playlists = ref.watch(playlistsProvider);
    final tracks = playerController.tracks;
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
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Padding(
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
                          currentPlaylist?.name ??
                              ref
                                  .read(localizationProvider.notifier)
                                  .translate(LocalizationKeys.playingAllTracks),
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: () => _scrollToCurrentTrack(),
                        tooltip: "Scroll to currently playing track",
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thickness: isMobile ? scrollbarThickness : null,
                  radius: isMobile ? const Radius.circular(8) : null,
                  thumbVisibility: isMobile ? true : null,
                  interactive: isMobile ? true : null,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemExtent: 72.0,
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
                          await playTrack(track, playerControllerNotifier);
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
