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
}
