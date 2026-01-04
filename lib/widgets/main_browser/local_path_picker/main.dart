import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/local_paths_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/widgets/main_browser/local_path_picker/path_item.dart';
import 'package:yampa/widgets/misc/loader.dart';

class LocalPathPicker extends ConsumerStatefulWidget {
  const LocalPathPicker({super.key});

  @override
  ConsumerState<LocalPathPicker> createState() => _LocalPathPickerState();
}

class _LocalPathPickerState extends ConsumerState<LocalPathPicker> {
  bool _isActive = true;
  bool _showActions = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    super.dispose();
    _isActive = false;
  }

  void _showActionsToggle() {
    if (!_isActive) return;
    if (_selectedIds.isNotEmpty) return;
    setState(() {
      _showActions = !_showActions;
    });
  }

  Widget _buildActionWidgets(IconData icon, VoidCallback onPressed) {
    return Container(
      height: 35,
      width: 35,
      alignment: Alignment.topCenter,
      child: FloatingActionButton(onPressed: onPressed, child: Icon(icon)),
    );
  }

  void _pickDirectory(
    LocalPathsNotifier localPathsNotifier,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
  ) async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final genericPath = GenericPath(
        id: "temp-id",
        folder: result,
        filename: null,
      );
      await handlePathsAdded(
        [genericPath],
        localPathsNotifier,
        playerControllerNotifier,
        loadedTracksCountNotifier,
      );
    }
  }

  void _pickIndividualFiles(
    LocalPathsNotifier localPathsNotifier,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      final genericPaths = result.files.map((file) {
        return GenericPath(
          id: "temp-id-${file.name}",
          folder: null,
          filename: file.path,
        );
      }).toList();
      genericPaths.removeWhere((e) => !isValidMusicPath(e.filename!));
      handlePathsAdded(
        genericPaths,
        localPathsNotifier,
        playerControllerNotifier,
        loadedTracksCountNotifier,
      );
    }
  }

  void _toggleSelection(String id) {
    if (!_isActive) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isNotEmpty) _showActions = false;
    });
  }

  void _clearSelection() {
    if (!_isActive) return;
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _confirmDeleteSelected(
    LocalPathsNotifier localPathsNotifier,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
    List<GenericPath> currentPaths,
    BuildContext context,
  ) async {
    if (_selectedIds.isEmpty) return;
    final selectedPaths = currentPaths
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    final count = selectedPaths.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete $count path${count > 1 ? 's' : ''}?"),
        content: Text(
          "This will stop tracking the selected path${count > 1 ? 's' : ''}. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await handlePathsRemoved(
        selectedPaths,
        localPathsNotifier,
        playerControllerNotifier,
      );
      _clearSelection();
    }
  }

  List<Widget> _buildShowActionsWidgets(
    LocalPathsNotifier localPathsNotifier,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
    List<GenericPath> currentPaths,
  ) {
    if (_selectedIds.isNotEmpty) {
      return [
        FloatingActionButton(
          onPressed: () => _confirmDeleteSelected(
            localPathsNotifier,
            playerControllerNotifier,
            loadedTracksCountNotifier,
            currentPaths,
            context,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          child: Icon(Icons.delete),
        ),
      ];
    }

    return [
      if (_showActions) ...[
        _buildActionWidgets(
          Icons.file_present,
          () => _pickIndividualFiles(
            localPathsNotifier,
            playerControllerNotifier,
            loadedTracksCountNotifier,
          ),
        ),
        SizedBox(height: 10),
        _buildActionWidgets(
          Icons.folder,
          () => _pickDirectory(
            localPathsNotifier,
            playerControllerNotifier,
            loadedTracksCountNotifier,
          ),
        ),
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
      return Center(
        child: Text("No paths being tracked. Hit the + button to add some!"),
      );
    }
    return ListView(
      children: [
        ...paths.map(
          (path) => PathItem(
            path: path,
            isSelected: _selectedIds.contains(path.id),
            onLongPress: () => _toggleSelection(path.id),
            onTap: () {
              if (_selectedIds.isNotEmpty) {
                _toggleSelection(path.id);
              } else {}
            },
          ),
        ),
        SizedBox(height: 75),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    final localPaths = ref.watch(localPathsProvider);
    final localPathsNotifier = ref.watch(localPathsProvider.notifier);
    final playerControllerNotifier = ref.watch(
      playerControllerProvider.notifier,
    );
    final loadedTracksCountNotifier = ref.watch(
      loadedTracksCountProvider.notifier,
    );

    if (!initialLoadDone) {
      return CustomLoader();
    }
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildShowActionsWidgets(
          localPathsNotifier,
          playerControllerNotifier,
          loadedTracksCountNotifier,
          localPaths,
        ),
      ),
      body: _buildPathsList(localPaths),
    );
  }
}
