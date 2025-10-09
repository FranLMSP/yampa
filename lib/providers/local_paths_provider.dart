import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/models/path.dart';

class GenericPaths {
  GenericPaths({
    this.initialLoadDone = false,
    this.paths = const [],
  });

  bool initialLoadDone = false;
  List<GenericPath> paths = [];
}


final localPathsProvider = NotifierProvider<LocalPathsNotifier, GenericPaths>(
  () => LocalPathsNotifier(),
);

class LocalPathsNotifier extends Notifier<GenericPaths> {
  @override
  GenericPaths build() => GenericPaths();

  void setPaths(List<GenericPath> paths) {
    state = GenericPaths(initialLoadDone: true, paths: paths);
  }

  bool initialLoadDone() {
    return state.initialLoadDone;
  }
}
