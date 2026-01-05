import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class SortButton extends ConsumerWidget {
  final SortMode currentSortMode;
  final Function(SortMode) onSortModeChanged;

  const SortButton({
    super.key,
    required this.currentSortMode,
    required this.onSortModeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(localizationProvider.notifier);
    return PopupMenuButton<SortMode>(
      initialValue: currentSortMode,
      icon: const Icon(Icons.sort),
      onSelected: onSortModeChanged,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
        PopupMenuItem<SortMode>(
          value: SortMode.titleAtoZ,
          child: Text(notifier.translate(LocalizationKeys.sortTitleAZ)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.titleZtoA,
          child: Text(notifier.translate(LocalizationKeys.sortTitleZA)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.mostPlayed,
          child: Text(notifier.translate(LocalizationKeys.sortMostPlayed)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.leastPlayed,
          child: Text(notifier.translate(LocalizationKeys.sortLeastPlayed)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.recentlyPlayed,
          child: Text(notifier.translate(LocalizationKeys.sortRecentlyPlayed)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.leastRecentlyPlayed,
          child: Text(notifier.translate(LocalizationKeys.sortLeastRecentlyPlayed)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.artistAtoZ,
          child: Text(notifier.translate(LocalizationKeys.sortArtistAZ)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.artistZtoA,
          child: Text(notifier.translate(LocalizationKeys.sortArtistZA)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.albumAtoZ,
          child: Text(notifier.translate(LocalizationKeys.sortAlbumAZ)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.albumZtoA,
          child: Text(notifier.translate(LocalizationKeys.sortAlbumZA)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.genreAtoZ,
          child: Text(notifier.translate(LocalizationKeys.sortGenreAZ)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.genreZtoA,
          child: Text(notifier.translate(LocalizationKeys.sortGenreZA)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.durationShortToLong,
          child: Text(notifier.translate(LocalizationKeys.sortDurationShort)),
        ),
        PopupMenuItem<SortMode>(
          value: SortMode.durationLongToShort,
          child: Text(notifier.translate(LocalizationKeys.sortDurationLong)),
        ),
      ],
    );
  }
}
