import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

void removePlaylistsModal(
  BuildContext context,
  List<Playlist> playlists,
  PlaylistNotifier playlistsNotifier,
  Function? onDeleteCallback,
) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return Consumer(
        builder: (context, ref, child) {
          final localizationNotifier = ref.read(localizationProvider.notifier);
          return AlertDialog(
            title: playlists.length == 1
                ? Text(
                    localizationNotifier.translate(
                      LocalizationKeys.deletePlaylistQuestion,
                    ),
                  )
                : Text(
                    localizationNotifier.translate(
                      LocalizationKeys.deletePlaylistsQuestion,
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localizationNotifier.translate(LocalizationKeys.no)),
              ),
              TextButton(
                onPressed: () async {
                  for (final playlist in playlists) {
                    await handlePlaylistRemoved(playlist, playlistsNotifier);
                  }
                  Navigator.of(context).pop();
                  if (onDeleteCallback != null) {
                    onDeleteCallback();
                  }
                  // TODO: show snackbar with "undo" button
                },
                child: Text(localizationNotifier.translate(LocalizationKeys.yes)),
              ),
            ],
          );
        },
      );
    },
  );
}
