import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/path.dart';
import 'package:music_player/providers/initial_load_provider.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/providers/utils.dart';
import 'package:music_player/widgets/main_browser/local_path_picker/path_item.dart';
import 'package:music_player/widgets/misc/loader.dart';

class LocalPathPicker extends ConsumerStatefulWidget {
  const LocalPathPicker({super.key});

  @override
  ConsumerState<LocalPathPicker> createState() => _LocalPathPickerState();
}

class _LocalPathPickerState extends ConsumerState<LocalPathPicker> {
  bool _isActive = true;
  bool _showActions = false;

  @override
  void dispose() {
    super.dispose();
    _isActive = false;
  }

  void _showActionsToggle() {
    if (!_isActive) return;
    setState(() {
      _showActions = !_showActions;
    });
  }

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

  void _pickDirectory(LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final genericPath = GenericPath(
        id: "temp-id",
        folder: result,
        filename: null,
      );
      await handlePathsAdded([genericPath], localPathsNotifier, tracksNotifier);
    }
  }

  void _pickIndividualFiles(LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      final genericPaths = result.files.map((file) {
        return GenericPath(
          id: "temp-id-${file.name}",
          folder: null,
          filename: file.path,
        );
      }).toList();
      handlePathsAdded(genericPaths, localPathsNotifier, tracksNotifier);
    }
  }

  List<Widget> _buildShowActionsWidgets(LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return [
      if (_showActions) ...[
        _buildActionWidgets(Icons.file_present, () => _pickIndividualFiles(localPathsNotifier, tracksNotifier)),
        SizedBox(height: 10),
        _buildActionWidgets(Icons.folder, () => _pickDirectory(localPathsNotifier, tracksNotifier)),
        SizedBox(height: 10),
      ],
      FloatingActionButton(
        onPressed: _showActionsToggle,
        child: Icon(_showActions ? Icons.close : Icons.add),
      ),
    ];
  }

  Widget _buildPathsList(List<GenericPath> paths) {
    if (paths.isEmpty) {
      return Center(child:Text("No paths being tracked. Hit the + button to add some!"));
    }
    return ListView(
      children: paths.map((path) => PathItem(path: path)).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    final localPaths = ref.watch(localPathsProvider);
    final localPathsNotifier = ref.read(localPathsProvider.notifier);
    final tracksNotifier = ref.read(tracksProvider.notifier);

    if (!initialLoadDone) {
      return CustomLoader();
    }
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildShowActionsWidgets(localPathsNotifier, tracksNotifier),
      ),
      body: _buildPathsList(localPaths),
    );
  }
}
