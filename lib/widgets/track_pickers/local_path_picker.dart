
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/repositories/stored_paths/factory.dart';
import 'package:music_player/core/track_players/factory.dart';
import 'package:music_player/core/track_players/just_audio.dart';
import 'package:music_player/models/path.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/player_controller_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
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
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final genericPath = GenericPath(
        id: "temp-id",
        folder: result,
        filename: null,
      );
      final storedPathsRepository = getStoredPathsRepository();
      setState(() {
        _isLoading = true;
      });
      await storedPathsRepository.addPath(genericPath);
      final storedPaths = await storedPathsRepository.getStoredPaths();

      // TODO: write a function with these three lines of code to reuse it
      ref.read(localPathsProvider.notifier).setPaths(storedPaths);
      final tracksPlayer = getTrackPlayer();
      ref.read(tracksProvider.notifier).setTracks(tracksPlayer.fetchTracks(storedPaths));
      setState(() {
        _isLoading = false;
      });
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
      setState(() {
        _isLoading = true;
      });
      // TODO: implement a batch insert in the repository
      for (final path in genericPaths) {
        await storedPathsRepository.addPath(path);
      }
      final storedPaths = await storedPathsRepository.getStoredPaths();
      // TODO: write a function with these three lines of code to reuse it
      ref.read(localPathsProvider.notifier).setPaths(storedPaths);
      final tracksPlayer = getTrackPlayer();
      ref.read(tracksProvider.notifier).setTracks(tracksPlayer.fetchTracks(storedPaths));
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _loadInitialPaths() async {
    final initialLoadDone = ref.read(localPathsProvider.notifier).initialLoadDone();
    if (initialLoadDone) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final storedPathsRepository = getStoredPathsRepository();
    final storedPaths = await storedPathsRepository.getStoredPaths();
    ref.read(localPathsProvider.notifier).setPaths(storedPaths);
    final tracksPlayer = getTrackPlayer();
    ref.read(tracksProvider.notifier).setTracks(tracksPlayer.fetchTracks(storedPaths));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadInitialPaths();
    final playerController = ref.watch(playerControllerProvider);
    final playerControllerNotifier = ref.watch(playerControllerProvider.notifier);
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildShowActionsWidgets(),
      ),
      body: Column(
        children: [
          // TODO: maybe add a loader or spinner here?
          _isLoading ? Text("Loading...") : TrackList(onTap: () {
            final isInstance = playerController.trackPlayer is JustAudioProvider;
            if (!isInstance) {
              playerControllerNotifier.setTrackPlayer(JustAudioProvider());
            }
          }),
        ],
      ),
    );
  }
}
