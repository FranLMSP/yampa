import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/path.dart';

final localPathsProvider = NotifierProvider<LocalPathsNotifier, List<GenericPath>>(
  () => LocalPathsNotifier(),
);

class LocalPathsNotifier extends Notifier<List<GenericPath>> {
  @override
  List<GenericPath> build() => [];

  void setPaths(List<GenericPath> paths) {
    state = paths;
  }

  void addPaths(List<GenericPath> paths) {
    state = [
      ...state,
      ...paths,
    ];
  }

  void removePaths(List<GenericPath> paths) {
    final pathIds = paths.map((e) => e.id).toList();
    state = state.where((e) => !pathIds.contains(e.id)).toList();
  }
}
