import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/models/playlist.dart';


class NewPlaylistDialog extends ConsumerStatefulWidget {

  const NewPlaylistDialog({
    super.key,
    required this.onSaved,
  });

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
    _titleController = TextEditingController(text: "New playlist");
    _descriptionController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New playlist'),
      scrollable: true,
      content: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: _isValid ? null : "Title can't be empty",
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
          child: const Text('Create'),
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
                  )
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

