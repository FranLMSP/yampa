import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final playlists = ref.watch(playlistsProvider);
    final playlistsNotifier = ref.read(playlistsProvider.notifier);
    final playerControllerNotifier = ref.read(
      playerControllerProvider.notifier,
    );
    final localizationNotifier = ref.read(localizationProvider.notifier);
    final favoritesPlaylist = playlists.firstWhere(
      (e) => e.id == favoritePlaylistId,
    );
    final isFavorite = favoritesPlaylist.trackIds.contains(currentTrackId);
    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      tooltip: isFavorite
          ? localizationNotifier.translate(LocalizationKeys.removeFromFavorites)
          : localizationNotifier.translate(LocalizationKeys.addToFavorites),
      onPressed: () async {
        if (currentTrackId == null) {
          return;
        }
        if (isFavorite) {
          await Future.wait([
            showButtonActionMessage(
              localizationNotifier.translate(
                LocalizationKeys.trackRemovedFromFavorites,
              ),
            ),
            handleMultipleTrackRemovedFromPlaylist(
              favoritesPlaylist,
              [currentTrackId],
              playlistsNotifier,
              playerControllerNotifier,
            ),
          ]);
        } else {
          await Future.wait([
            showButtonActionMessage(
              localizationNotifier.translate(
                LocalizationKeys.trackAddedFromFavorites,
              ),
            ),
            handleTracksAddedToPlaylist(
              [currentTrackId],
              [favoritesPlaylist],
              playlistsNotifier,
              playerControllerNotifier,
            ),
          ]);
        }
      },
    );
  }
}
