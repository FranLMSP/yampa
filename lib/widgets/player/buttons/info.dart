import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/widgets/main_browser/all_tracks/track_info_dialog.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class InfoButton extends ConsumerWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTracks = ref.watch(
      playerControllerProvider.select((p) => p.tracks),
    );
    final currentTrackId = ref.watch(
      playerControllerProvider.select((p) => p.currentTrackId),
    );
    final track = allTracks[currentTrackId];
    if (track == null) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.info),
      tooltip: ref.read(localizationProvider.notifier).translate(
        LocalizationKeys.info,
      ),
      onPressed: () async {
        showDialog(
          context: context,
          builder: (BuildContext ctx) => TrackInfoDialog(track: track),
        );
      },
    );
  }
}
