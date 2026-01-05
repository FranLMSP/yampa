import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class NewPlaylistDialog extends ConsumerStatefulWidget {
  const NewPlaylistDialog({super.key, required this.onSaved});

  final Function onSaved;

  @override
  ConsumerState<NewPlaylistDialog> createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends ConsumerState<NewPlaylistDialog> {
  bool _isValid = true;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: ref
          .read(localizationProvider.notifier)
          .translate(LocalizationKeys.newPlaylist),
    );
    _descriptionController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        ref
            .read(localizationProvider.notifier)
            .translate(LocalizationKeys.newPlaylist),
      ),
      scrollable: true,
      content: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _titleController,
            decoration: InputDecoration(
              labelText: ref
                  .read(localizationProvider.notifier)
                  .translate(LocalizationKeys.titleLabel),
              errorText: _isValid
                  ? null
                  : ref
                        .read(localizationProvider.notifier)
                        .translate(LocalizationKeys.titleEmptyError),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: ref
                  .read(localizationProvider.notifier)
                  .translate(LocalizationKeys.descriptionLabel),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: Text(
            ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.cancel),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: Text(
            ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.create),
          ),
          onPressed: () {
            setState(() {
              _isValid = _titleController.text.isNotEmpty;
              if (_isValid) {
                widget.onSaved(
                  Playlist(
                    id: "temp-id",
                    name: _titleController.text,
                    description: _descriptionController.text,
                    trackIds: [],
                  ),
                );
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
