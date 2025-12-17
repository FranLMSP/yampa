import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/widgets/common/display_track_title.dart';
import 'package:yampa/widgets/main_browser/playlists/display_track_metadata.dart';
import 'package:yampa/widgets/player/player_buttons.dart';
import 'package:yampa/widgets/player/player_image.dart';
import 'package:yampa/widgets/player/player_slider.dart';
import 'package:yampa/widgets/player/player_total_minutes.dart';
import 'package:yampa/widgets/player/neighboring_tracks.dart';
import 'package:yampa/widgets/player/upcoming_tracks_list.dart';
import 'package:yampa/core/player/enums.dart';

class BigPlayer extends ConsumerStatefulWidget {
  const BigPlayer({super.key});

  @override
  ConsumerState<BigPlayer> createState() => _BigPlayerState();
}

class _BigPlayerState extends ConsumerState<BigPlayer> {
  bool _showNeighboringTracks = true;

  void _onScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;

      if (direction == ScrollDirection.reverse && _showNeighboringTracks) {
        setState(() => _showNeighboringTracks = false);
      } else if (direction == ScrollDirection.forward &&
          !_showNeighboringTracks) {
        setState(() => _showNeighboringTracks = true);
      }
    }
  }

  Widget _buildTotalMinutes() {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 5, right: 15),
      child: PlayerTotalMinutes(),
    );
  }

  Widget _buildSmallImage(Track? track) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      child: PlayerImage(track: track, width: 50, height: 50, iconSize: 35),
    );
  }

  Widget _buildPlayerTitleAndImageBig(
    TrackQueueDisplayMode trackQueueDisplayMode,
    Track? track,
  ) {
    return Column(
      children: [
        if (trackQueueDisplayMode == TrackQueueDisplayMode.image) ...[
          const SizedBox(height: 5),
          PlayerImage(track: track),
          const SizedBox(height: 5),
          DisplayTrackTitle(track: track),
        ],
        if (trackQueueDisplayMode == TrackQueueDisplayMode.list) ...[
          Row(
            children: [
              _buildSmallImage(track),
              Expanded(
                child: Column(
                  children: [
                    DisplayTrackTitle(track: track),
                    DisplayTrackMetadata(track: track),
                  ],
                ),
              ),
              _buildTotalMinutes(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerTitleAndImageSmall(
    TrackQueueDisplayMode trackQueueDisplayMode,
    Track? track,
  ) {
    return Row(
      children: [
        const SizedBox(height: 5),
        if (trackQueueDisplayMode == TrackQueueDisplayMode.image)
          _buildSmallImage(track),
        Expanded(
          child: Column(
            children: [
              DisplayTrackTitle(track: track),
              if (trackQueueDisplayMode == TrackQueueDisplayMode.image)
                DisplayTrackMetadata(track: track),
            ],
          ),
        ),
        _buildTotalMinutes(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracks = ref.watch(tracksProvider);
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final track = tracks[currentTrackId];
    final trackQueueDisplayMode = ref.watch(
      playerControllerProvider.select((p) => p.trackQueueDisplayMode),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(notification);
        return false;
      },
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isHeightBig = constraints.maxHeight >= 460;
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trackQueueDisplayMode == TrackQueueDisplayMode.list)
                      Expanded(child: UpcomingTracksList()),
                    if (isHeightBig) ...[
                      _buildPlayerTitleAndImageBig(trackQueueDisplayMode, track),
                      SizedBox(height: 5),
                    ],
                    if (!isHeightBig)
                      _buildPlayerTitleAndImageSmall(
                        trackQueueDisplayMode,
                        track,
                      ),
                    const PlayerSlider(),
                    const PlayerButtons(),
                    if (isHeightBig &&
                        trackQueueDisplayMode == TrackQueueDisplayMode.image)
                      const PlayerTotalMinutes(),
                    if (_showNeighboringTracks)
                      const SizedBox(height: 50),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  offset: _showNeighboringTracks
                      ? Offset.zero
                      : Offset(0, 1),
                  duration: Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: _showNeighboringTracks ? 1 : 0,
                    child: NeighboringTracks(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
