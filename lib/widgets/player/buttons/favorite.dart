import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/favorite_tracks_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/utils.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackId = ref.watch(playerControllerProvider).currentTrackId;
    final favorites = ref.watch(favoriteTracksProvider);
    final favoritesNotifier = ref.watch(favoriteTracksProvider.notifier);
    // TODO: check against the favorite playlist here
    final isFavorite = favorites.contains(currentTrack?.id);
    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
      onPressed: () async {
        if (currentTrack == null) {
          return;
        }
        if (isFavorite) {
          handleTracksRemovedFromFavorites([currentTrack], favoritesNotifier);
        } else {
          handleTracksAddedToFavorites([currentTrack], favoritesNotifier);
        }
      },
    );
  }
}
