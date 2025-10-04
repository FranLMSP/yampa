
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/track_list/track_list.dart';

class LocalPathPicker extends ConsumerStatefulWidget {
  const LocalPathPicker({super.key});

  @override
  ConsumerState<LocalPathPicker> createState() => _LocalPathPickerState();
}

class _LocalPathPickerState extends ConsumerState<LocalPathPicker> {
  bool _isLoading = false;
  bool _showActions = false;

  Widget _buildActionWidgets(IconData icon, VoidCallback onPressed) {
    return Container(
      height: 35,
      width: 35,
      alignment: Alignment.topCenter,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }

  void _showActionsToggle() {
    setState(() {
      _showActions = !_showActions;
    });
  }

  void _pickDirectory() async {

    // Simulate a delay for picking directory
    // FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      print(result);
    }

    // setState(() {
    //   _isLoading = false;
    // });
  }

  void _pickIndividualFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      print(result);
    }
  }

  List<Widget> _buildShowActionsWidgets() {
    return [
      if (_showActions) ...[
        _buildActionWidgets(Icons.file_present, _pickIndividualFiles),
        SizedBox(height: 10),
        _buildActionWidgets(Icons.folder, _pickDirectory),
        SizedBox(height: 10),
        _buildActionWidgets(Icons.edit, () {}),
        SizedBox(height: 10),
      ],
      FloatingActionButton(
        onPressed: _showActionsToggle,
        child: Icon(_showActions ? Icons.close : Icons.add),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildShowActionsWidgets(),
      ),
      body: Column(
        children: [
          TrackList(),
        ],
      ),
    );
  }
}