import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/providers/local_paths_provider.dart';
import 'package:yampa/providers/tracks_provider.dart';
import 'package:yampa/providers/utils.dart';

class PathItem extends ConsumerStatefulWidget {
  const PathItem({
    super.key,
    required this.path,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
  });

  final GenericPath path;

  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  @override
  ConsumerState<PathItem> createState() => _PathItemState();
}

class _PathItemState extends ConsumerState<PathItem> {

  Widget _buildDeleteButton(BuildContext context, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
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
                  handlePathsRemoved([widget.path], localPathsNotifier, tracksNotifier);
                  Navigator.of(context).pop();
                },
                child: const Text('Yes')
              ),
            ],
          );
        });
      },
      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String name, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    final theme = Theme.of(context);
    final int selectionAlpha = (0.12 * 255).round();
    final bg = widget.isSelected ? theme.colorScheme.primary.withAlpha(selectionAlpha) : null;
    final leading = widget.isSelected
        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
        : Icon(icon);

    return ListTile(
      key: Key(widget.path.id),
      tileColor: bg,
      leading: leading,
      title: Text(extractFilenameFromFullPath(name)),
      subtitle: Text(getParentFolder(name)),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      trailing: _buildDeleteButton(context, localPathsNotifier, tracksNotifier),
    );
  }

  Widget _buildFolderCard(BuildContext context, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return _buildCard(context, Icons.folder, widget.path.folder!, localPathsNotifier, tracksNotifier);
  }

  Widget _buildFileCard(BuildContext context, LocalPathsNotifier localPathsNotifier, TracksNotifier tracksNotifier) {
    return _buildCard(context, Icons.file_present, widget.path.filename!, localPathsNotifier, tracksNotifier);
  }
@override
  Widget build(BuildContext context) {
    final localPathsNotifier = ref.read(localPathsProvider.notifier);
    final tracksNotifier = ref.read(tracksProvider.notifier);
    return widget.path.filename != null 
      ? _buildFileCard(context, localPathsNotifier, tracksNotifier)
      : _buildFolderCard(context, localPathsNotifier, tracksNotifier);
  }
}
