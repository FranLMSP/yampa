import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/repositories/stored_paths/factory.dart';
import 'package:music_player/core/track_players/factory.dart';
import 'package:music_player/models/path.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
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

  void _pickDirectory() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final genericPath = GenericPath(
        id: "temp-id",
        folder: result,
        filename: null,
      );
      final storedPathsRepository = getStoredPathsRepository();
      await storedPathsRepository.addPath(genericPath);
      final storedPaths = await storedPathsRepository.getStoredPaths();

      // TODO: write a function with these three lines of code to reuse it
      ref.read(localPathsProvider.notifier).setPaths(storedPaths);
      final tracksPlayer = getTrackPlayer();
      ref.read(tracksProvider.notifier).setTracks(await tracksPlayer.fetchTracks(storedPaths));
    }
  }

  void _pickIndividualFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      final genericPaths = result.files.map((file) {
        return GenericPath(
          id: "temp-id-${file.name}",
          folder: null,
          filename: file.path,
        );
      }).toList();
      final storedPathsRepository = getStoredPathsRepository();
      // TODO: implement a batch insert in the repository
      for (final path in genericPaths) {
        await storedPathsRepository.addPath(path);
      }
      final storedPaths = await storedPathsRepository.getStoredPaths();
      // TODO: write a function with these three lines of code to reuse it
      ref.read(localPathsProvider.notifier).setPaths(storedPaths);
      final tracksPlayer = getTrackPlayer();
      ref.read(tracksProvider.notifier).setTracks(await tracksPlayer.fetchTracks(storedPaths));
    }
  }

  List<Widget> _buildShowActionsWidgets() {
    return [
      if (_showActions) ...[
        _buildActionWidgets(Icons.file_present, _pickIndividualFiles),
        SizedBox(height: 10),
        _buildActionWidgets(Icons.folder, _pickDirectory),
        SizedBox(height: 10),
      ],
      FloatingActionButton(
        onPressed: _showActionsToggle,
        child: Icon(_showActions ? Icons.close : Icons.add),
      ),
    ];
  }

  Future<void> _loadInitialPaths() async {
    final initialLoadDone = ref.read(localPathsProvider).initialLoadDone;
    if (initialLoadDone) {
      return;
    }
    final storedPathsRepository = getStoredPathsRepository();
    final storedPaths = await storedPathsRepository.getStoredPaths();
    await Future.delayed(const Duration(seconds: 5));
    ref.read(localPathsProvider.notifier).setPaths(storedPaths);
    final tracksPlayer = getTrackPlayer();
    ref.read(tracksProvider.notifier).setTracks(await tracksPlayer.fetchTracks(storedPaths));
  }

  Widget _buildPathsList(List<GenericPath> paths) {
    if (paths.isEmpty) {
      return Text("No paths being tracked. Hit the + button to add some!");
    }
    return Expanded(
      child: ListView(
        children: paths.map((path) => PathItem(path: path)).toList()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadInitialPaths();
    final localPaths = ref.watch(localPathsProvider);
    if (!localPaths.initialLoadDone) {
      return CustomLoader();
    }
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildShowActionsWidgets(),
      ),
      body: _buildPathsList(localPaths.paths),
    );
  }
}
