import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/utils/filename_utils.dart';
import 'package:music_player/models/path.dart';
import 'package:music_player/providers/local_paths_provider.dart';
import 'package:music_player/providers/tracks_provider.dart';
import 'package:music_player/providers/utils.dart';

class PathItem extends ConsumerStatefulWidget {
  const PathItem({super.key, required this.path});

  final GenericPath path;

  @override
  ConsumerState<PathItem> createState() => _PathItemState();
}

class _PathItemState extends ConsumerState<PathItem> {

  Widget _buildDeleteButton(BuildContext context, List<GenericPath> paths, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return IconButton(
      onPressed: () async {
        showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Remove this path?'),
            content: Text(widget.path.filename != null ? widget.path.filename! : widget.path.folder!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No')
              ),
              TextButton(
                onPressed: () {
                  handlePathsRemoved(paths, localPathsNotifier, tracksNotifier);
                  Navigator.of(context).pop();
                },
                child: const Text('Yes')
              ),
            ],
          );
        });
      },
      icon: Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String name, List<GenericPath> paths, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return ListTile(
      key: Key(widget.path.id),
      leading: Icon(icon),
      title: Text(extractFilenameFromFullPath(name)),
      subtitle: Text(getParentFolder(name)),
      trailing: _buildDeleteButton(context, paths, localPathsNotifier, tracksNotifier),
    );
  }

  Widget _buildFolderCard(BuildContext context, List<GenericPath> paths, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return _buildCard(context, Icons.folder, widget.path.folder!, paths, localPathsNotifier, tracksNotifier);
  }

  Widget _buildFileCard(BuildContext context, List<GenericPath> paths,  LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return _buildCard(context, Icons.file_present, widget.path.filename!, paths, localPathsNotifier, tracksNotifier);
  }
@override
  Widget build(BuildContext context) {
    final paths = ref.read(localPathsProvider);
    final localPathsNotifier = ref.read(localPathsProvider.notifier);
    final tracksNotifier = ref.read(tracksProvider.notifier);
    return widget.path.filename != null 
      ? _buildFileCard(context, paths, localPathsNotifier, tracksNotifier)
      : _buildFolderCard(context, paths, localPathsNotifier, tracksNotifier);
  }
}
