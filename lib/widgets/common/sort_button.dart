import 'package:flutter/material.dart';
import 'package:yampa/core/player/enums.dart';

class SortButton extends StatelessWidget {
  final SortMode currentSortMode;
  final Function(SortMode) onSortModeChanged;

  const SortButton({
    super.key,
    required this.currentSortMode,
    required this.onSortModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortMode>(
      initialValue: currentSortMode,
      icon: const Icon(Icons.sort),
      onSelected: onSortModeChanged,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
        const PopupMenuItem<SortMode>(
          value: SortMode.titleAtoZ,
          child: Text('Title (A-Z)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.titleZtoA,
          child: Text('Title (Z-A)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.artistAtoZ,
          child: Text('Artist (A-Z)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.artistZtoA,
          child: Text('Artist (Z-A)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.albumAtoZ,
          child: Text('Album (A-Z)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.albumZtoA,
          child: Text('Album (Z-A)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.genreAtoZ,
          child: Text('Genre (A-Z)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.genreZtoA,
          child: Text('Genre (Z-A)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.durationShortToLong,
          child: Text('Duration (Shortest first)'),
        ),
        const PopupMenuItem<SortMode>(
          value: SortMode.durationLongToShort,
          child: Text('Duration (Longest first)'),
        ),
      ],
    );
  }
}
